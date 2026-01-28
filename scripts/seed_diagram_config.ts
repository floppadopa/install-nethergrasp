/**
 * Seed script to import diagram coordinates from database.json into the diagram_config table
 * Run with: npx tsx scripts/seed_diagram_config.ts
 */

import { PrismaClient } from "@prisma/client";
import { readFileSync } from "fs";
import { join } from "path";

const prisma = new PrismaClient();

async function main() {
  console.log("Reading database.json...");
  
  const jsonPath = join(process.cwd(), "public", "query", "database.json");
  const jsonData = JSON.parse(readFileSync(jsonPath, "utf-8"));
  
  console.log("Found diagram with", jsonData.diagram?.tables?.length || 0, "tables");
  
  // Seed for the "zebi" slug (and also "default" as fallback)
  const slugsToSeed = ["zebi", "default"];
  
  for (const slug of slugsToSeed) {
    console.log(`\nSeeding diagram_config for slug: ${slug}`);
    
    const result = await prisma.diagramConfig.upsert({
      where: { slug },
      create: {
        slug,
        content: jsonData.content || "",
        userid: jsonData.userid || "openleviator",
        name: jsonData.name || "OpenLeviator Dashboard",
        diagram: jsonData.diagram || { tables: [] },
        tableGroups: jsonData.tableGroups || [],
        referencePaths: jsonData.referencePaths || [],
        detailLevel: jsonData.detailLevel || "All",
      },
      update: {
        content: jsonData.content || "",
        userid: jsonData.userid || "openleviator",
        name: jsonData.name || "OpenLeviator Dashboard",
        diagram: jsonData.diagram || { tables: [] },
        tableGroups: jsonData.tableGroups || [],
        referencePaths: jsonData.referencePaths || [],
        detailLevel: jsonData.detailLevel || "All",
      },
    });
    
    console.log(`✓ Seeded diagram_config (id: ${result.id}) for slug: ${slug}`);
  }
  
  console.log("\n✓ Seeding complete!");
}

main()
  .catch((e) => {
    console.error("Error seeding:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
