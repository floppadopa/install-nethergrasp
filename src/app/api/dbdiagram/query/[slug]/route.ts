import { type NextRequest, NextResponse } from "next/server";
import { readFileSync, writeFileSync } from "fs";
import { join } from "path";
import { pool as dbPool } from "~/server/db-pool";

// Force Node.js runtime for raw SQL queries
export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const DB_FILE_PATH = join(process.cwd(), "public", "query", "database.json");

interface TableInfo {
  table_name: string;
  column_name: string;
  data_type: string;
  is_nullable: string;
  column_default: string | null;
  constraint_type: string | null;
  constraint_name: string | null;
}

interface ForeignKeyInfo {
  table_name: string;
  column_name: string;
  foreign_table_name: string;
  foreign_column_name: string;
  constraint_name: string;
  delete_rule: string;
}

interface IndexInfo {
  table_name: string;
  index_name: string;
  column_name: string;
  is_unique: boolean;
}

function getDatabaseJson() {
  try {
    const data = readFileSync(DB_FILE_PATH, "utf-8");
    return JSON.parse(data);
  } catch {
    return null;
  }
}

function saveDatabaseJson(data: unknown) {
  try {
    writeFileSync(DB_FILE_PATH, JSON.stringify(data, null, 2), "utf-8");
    return true;
  } catch (error) {
    console.error("[API] Error saving database.json:", error);
    return false;
  }
}

function mapPostgresTypeToDbml(pgType: string): string {
  const typeMap: Record<string, string> = {
    integer: "Int",
    bigint: "BigInt",
    smallint: "Int",
    serial: "Int",
    bigserial: "BigInt",
    "character varying": "String",
    varchar: "String",
    text: "String",
    boolean: "Boolean",
    "timestamp without time zone": "DateTime",
    "timestamp with time zone": "DateTime",
    timestamp: "DateTime",
    date: "DateTime",
    "double precision": "Float",
    real: "Float",
    numeric: "Float",
    json: "Json",
    jsonb: "Json",
    uuid: "String",
    bytea: "Bytes",
    ARRAY: "String[]",
  };

  if (pgType.endsWith("[]") || pgType.startsWith("_")) {
    return "String[]";
  }

  return typeMap[pgType.toLowerCase()] || "String";
}

function generateDbmlFromSchema(
  tables: Map<string, TableInfo[]>,
  foreignKeys: ForeignKeyInfo[],
  indexes: Map<string, IndexInfo[]>
): string {
  const lines: string[] = [];
  lines.push("// Database Schema - Auto-synced from Supabase");
  lines.push(`// Last synced: ${new Date().toISOString()}`);
  lines.push("");

  for (const [tableName, columns] of tables) {
    lines.push(`Table ${tableName} {`);

    for (const col of columns) {
      const dbmlType = mapPostgresTypeToDbml(col.data_type);
      const attrs: string[] = [];

      if (col.constraint_type === "PRIMARY KEY") {
        attrs.push("pk");
        if (col.column_default?.includes("nextval")) {
          attrs.push("increment");
        }
      }

      if (col.constraint_type === "UNIQUE") {
        attrs.push("unique");
      }

      if (col.is_nullable === "NO" && col.constraint_type !== "PRIMARY KEY") {
        attrs.push("not null");
      }

      if (col.column_default && !col.column_default.includes("nextval")) {
        let defaultVal = col.column_default
          .replace(/::[\w\s[\]"]+$/g, "") // Remove type cast like ::text[]
          .trim();

        // Handle common default values
        if (
          defaultVal === "now()" ||
          defaultVal === "CURRENT_TIMESTAMP" ||
          defaultVal.includes("now()")
        ) {
          attrs.push("default: `now()`");
        } else if (defaultVal === "gen_random_uuid()") {
          attrs.push("default: `gen_random_uuid()`");
        } else if (
          defaultVal === "ARRAY[]" ||
          defaultVal === "'{}'" ||
          defaultVal === "{}"
        ) {
          // Skip empty array defaults - not supported in DBML
        } else if (defaultVal === "true" || defaultVal === "false") {
          attrs.push(`default: ${defaultVal}`);
        } else if (/^-?\d+(\.\d+)?$/.test(defaultVal)) {
          // Numeric default
          attrs.push(`default: ${defaultVal}`);
        } else if (defaultVal.startsWith("'") && defaultVal.endsWith("'")) {
          // String default - convert to double quotes
          const strVal = defaultVal.slice(1, -1);
          attrs.push(`default: "${strVal}"`);
        } else if (defaultVal !== "" && !defaultVal.includes("(")) {
          // Other non-function defaults - wrap in quotes if not already
          attrs.push(`default: "${defaultVal}"`);
        }
      }

      const attrStr = attrs.length > 0 ? ` [${attrs.join(", ")}]` : "";
      lines.push(`  ${col.column_name} ${dbmlType}${attrStr}`);
    }

    const tableIndexes = indexes.get(tableName);
    if (tableIndexes && tableIndexes.length > 0) {
      const indexGroups = new Map<string, IndexInfo[]>();
      for (const idx of tableIndexes) {
        const existing = indexGroups.get(idx.index_name) || [];
        existing.push(idx);
        indexGroups.set(idx.index_name, existing);
      }

      const validIndexes = Array.from(indexGroups.entries()).filter(
        ([name]) => !name.endsWith("_pkey")
      );

      if (validIndexes.length > 0) {
        lines.push("");
        lines.push("  indexes {");
        for (const [, idxCols] of validIndexes) {
          const colNames = idxCols.map((i) => i.column_name);
          const isUnique = idxCols[0]?.is_unique;

          if (colNames.length === 1) {
            lines.push(`    ${colNames[0]}${isUnique ? " [unique]" : ""}`);
          } else {
            lines.push(
              `    (${colNames.join(", ")})${isUnique ? " [unique]" : ""}`
            );
          }
        }
        lines.push("  }");
      }
    }

    lines.push("}");
    lines.push("");
  }

  if (foreignKeys.length > 0) {
    lines.push("// Relationships");
    for (const fk of foreignKeys) {
      const deleteRule =
        fk.delete_rule === "CASCADE" ? " [delete: cascade]" : "";
      lines.push(
        `Ref: ${fk.table_name}.${fk.column_name} > ${fk.foreign_table_name}.${fk.foreign_column_name}${deleteRule}`
      );
    }
  }

  return lines.join("\n");
}

async function syncDatabaseSchema(): Promise<{
  success: boolean;
  data?: unknown;
  error?: string;
}> {
  try {
    console.log("[Sync] Syncing schema from Supabase...");

    const columnsQuery = await dbPool.query<TableInfo>(`
      SELECT 
        c.table_name,
        c.column_name,
        c.data_type,
        c.is_nullable,
        c.column_default,
        tc.constraint_type,
        tc.constraint_name
      FROM information_schema.columns c
      LEFT JOIN information_schema.constraint_column_usage ccu 
        ON c.table_name = ccu.table_name 
        AND c.column_name = ccu.column_name
        AND c.table_schema = ccu.table_schema
      LEFT JOIN information_schema.table_constraints tc 
        ON ccu.constraint_name = tc.constraint_name
        AND tc.table_schema = c.table_schema
        AND (tc.constraint_type = 'PRIMARY KEY' OR tc.constraint_type = 'UNIQUE')
      WHERE c.table_schema = 'public'
        AND c.table_name NOT LIKE '_prisma%'
        AND c.table_name NOT LIKE 'pg_%'
      ORDER BY c.table_name, c.ordinal_position
    `);
    const columnsResult = columnsQuery.rows;

    const foreignKeysQuery = await dbPool.query<ForeignKeyInfo>(`
      SELECT
        tc.table_name,
        kcu.column_name,
        ccu.table_name AS foreign_table_name,
        ccu.column_name AS foreign_column_name,
        tc.constraint_name,
        rc.delete_rule
      FROM information_schema.table_constraints AS tc
      JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      JOIN information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
      JOIN information_schema.referential_constraints AS rc
        ON tc.constraint_name = rc.constraint_name
        AND tc.table_schema = rc.constraint_schema
      WHERE tc.constraint_type = 'FOREIGN KEY'
        AND tc.table_schema = 'public'
    `);
    const foreignKeysResult = foreignKeysQuery.rows;

    const indexesQuery = await dbPool.query<IndexInfo>(`
      SELECT
        t.relname AS table_name,
        i.relname AS index_name,
        a.attname AS column_name,
        ix.indisunique AS is_unique
      FROM pg_class t
      JOIN pg_index ix ON t.oid = ix.indrelid
      JOIN pg_class i ON i.oid = ix.indexrelid
      JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = ANY(ix.indkey)
      JOIN pg_namespace n ON n.oid = t.relnamespace
      WHERE n.nspname = 'public'
        AND t.relkind = 'r'
        AND NOT ix.indisprimary
      ORDER BY t.relname, i.relname
    `);
    const indexesResult = indexesQuery.rows;

    const tables = new Map<string, TableInfo[]>();
    for (const row of columnsResult) {
      const existing = tables.get(row.table_name) || [];
      if (!existing.find((c) => c.column_name === row.column_name)) {
        existing.push(row);
      } else if (row.constraint_type === "PRIMARY KEY") {
        const idx = existing.findIndex(
          (c) => c.column_name === row.column_name
        );
        if (idx >= 0) {
          existing[idx] = row;
        }
      }
      tables.set(row.table_name, existing);
    }

    const indexes = new Map<string, IndexInfo[]>();
    for (const row of indexesResult) {
      const existing = indexes.get(row.table_name) || [];
      existing.push(row);
      indexes.set(row.table_name, existing);
    }

    const dbmlContent = generateDbmlFromSchema(
      tables,
      foreignKeysResult,
      indexes
    );

    console.log(
      `[Sync] Generated DBML: ${tables.size} tables, ${foreignKeysResult.length} relationships`
    );

    const existingData = getDatabaseJson();

    const existingPositions = new Map<string, { x: number; y: number }>();
    if (existingData?.diagram?.tables) {
      for (const t of existingData.diagram.tables) {
        existingPositions.set(t.name, { x: t.x, y: t.y });
      }
    }

    const newTables: Array<{
      name: string;
      schemaName: string;
      x: number;
      y: number;
    }> = [];
    let xOffset = 50;
    let yOffset = 50;
    const COL_WIDTH = 300;
    const ROW_HEIGHT = 250;
    let colCount = 0;

    for (const tableName of tables.keys()) {
      const existingPos = existingPositions.get(tableName);
      if (existingPos) {
        newTables.push({
          name: tableName,
          schemaName: "public",
          x: existingPos.x,
          y: existingPos.y,
        });
      } else {
        newTables.push({
          name: tableName,
          schemaName: "public",
          x: xOffset,
          y: yOffset,
        });
        xOffset += COL_WIDTH;
        colCount++;
        if (colCount >= 5) {
          colCount = 0;
          xOffset = 50;
          yOffset += ROW_HEIGHT;
        }
      }
    }

    const updatedData = {
      _id: existingData?._id || "openleviator_dashboard",
      content: dbmlContent,
      userid: existingData?.userid || "openleviator",
      name: existingData?.name || "OpenLeviator Dashboard",
      diagram: {
        tables: newTables,
      },
      tableGroups: existingData?.tableGroups || [],
      referencePaths: existingData?.referencePaths || [],
      detailLevel: existingData?.detailLevel || "All",
      createdAt: existingData?.createdAt || new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    saveDatabaseJson(updatedData);
    console.log("[Sync] Schema synced successfully");

    return { success: true, data: updatedData };
  } catch (error) {
    console.error("[Sync] Error syncing schema:", error);
    // Return existing data if sync fails
    const existingData = getDatabaseJson();
    if (existingData) {
      return { success: false, data: existingData, error: String(error) };
    }
    return { success: false, error: String(error) };
  }
}

export async function GET() {
  // Always sync from database before returning
  const result = await syncDatabaseSchema();

  if (result.data) {
    return NextResponse.json(result.data);
  }

  return NextResponse.json({ error: "Database not found" }, { status: 404 });
}

export async function POST() {
  // Also sync from database on POST (dbdiagram.io uses POST to fetch data)
  const result = await syncDatabaseSchema();

  if (result.data) {
    return NextResponse.json(result.data);
  }

  return NextResponse.json({ error: "Database not found" }, { status: 404 });
}

export async function PUT(request: NextRequest) {
  try {
    const body = await request.json();

    // Get existing data
    const existingData = getDatabaseJson();
    if (!existingData) {
      return NextResponse.json(
        { error: "Database not found" },
        { status: 404 },
      );
    }

    // Deep merge the update with existing data
    const updatedData = { ...existingData };

    // Update diagram (contains table positions)
    if (body.diagram) {
      if (body.diagram.tables && Array.isArray(body.diagram.tables)) {
        // Simply replace the tables array with the new one
        // The client sends the complete, correctly-named tables list
        console.log("[API] Received", body.diagram.tables.length, "tables");
        console.log("[API] First table:", body.diagram.tables[0]);

        updatedData.diagram = {
          ...existingData.diagram,
          ...body.diagram,
          tables: body.diagram.tables,
        };
      } else {
        updatedData.diagram = {
          ...existingData.diagram,
          ...body.diagram,
        };
      }
    }

    // Update content if provided
    if (body.content !== undefined) {
      updatedData.content = body.content;
    }

    // Update referencePaths if provided
    if (body.referencePaths !== undefined) {
      updatedData.referencePaths = body.referencePaths;
    }

    // Update tableGroups if provided
    if (body.tableGroups !== undefined) {
      updatedData.tableGroups = body.tableGroups;
    }

    // Update detailLevel if provided
    if (body.detailLevel !== undefined) {
      updatedData.detailLevel = body.detailLevel;
    }

    // Update timestamp
    updatedData.updatedAt = new Date().toISOString();

    // Save to file
    if (saveDatabaseJson(updatedData)) {
      console.log("[API] ✓ Diagram saved to database.json");
      return NextResponse.json(updatedData);
    } else {
      return NextResponse.json({ error: "Failed to save" }, { status: 500 });
    }
  } catch (error) {
    console.error("[API] Error updating database:", error);
    return NextResponse.json(
      { error: "Invalid request body" },
      { status: 400 },
    );
  }
}

export async function PATCH(request: NextRequest) {
  return PUT(request);
}
