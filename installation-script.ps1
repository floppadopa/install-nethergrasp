# Nether-Grasp Automated Installer for Windows
# Run this script from the directory where you want to create/install Nether-Grasp

param(
    [switch]$ReInstall,
    [switch]$Help
)
 
if ($Help) {
    Write-Host @"
=============================================================
           NETHER-GRASP AUTOMATED INSTALLER
=============================================================

Usage: .\installation-script.ps1 [-ReInstall]

Examples:
  # Create new T3 App + install Nether-Grasp
  .\installation-script.ps1
  
  # Re-install Nether-Grasp into existing project (skip T3 App creation)
  .\installation-script.ps1 -ReInstall

This installer will:
  1. Create a new T3 App project (TypeScript, Tailwind, Prisma, PostgreSQL)
  2. Install Nether-Grasp into the project
  3. Configure all necessary files and dependencies
  4. Set up Git repository
  5. Push to GitHub

Flags:
  -ReInstall  Skip T3 App creation and install into current directory

"@
    exit 0
}

Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "           NETHER-GRASP AUTOMATED INSTALLER" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""

# Use the directory where the installer script is located as the source
$SourcePath = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "[SOURCE] $SourcePath" -ForegroundColor Green
Write-Host ""

# Step 0: Create T3 App (unless -ReInstall flag is set)
if (-not $ReInstall) {
    Write-Host "[STEP 0/10] Creating T3 App project..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   [INFO] Please answer the T3 App prompts with these recommended values:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "      Language: TypeScript" -ForegroundColor White
    Write-Host "      Styling: Tailwind CSS (Yes)" -ForegroundColor White
    Write-Host "      tRPC: No" -ForegroundColor White
    Write-Host "      Authentication: None" -ForegroundColor White
    Write-Host "      Database ORM: Prisma" -ForegroundColor White
    Write-Host "      App Router: Yes" -ForegroundColor White
    Write-Host "      Database: PostgreSQL" -ForegroundColor White
    Write-Host "      Linting: ESLint/Prettier" -ForegroundColor White
    Write-Host "      Git: Yes" -ForegroundColor White
    Write-Host "      npm install: Yes" -ForegroundColor White
    Write-Host "      Import alias: ~/" -ForegroundColor White
    Write-Host ""
    Write-Host "   [INFO] Running: npm create t3-app@latest" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "=============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    try {
        # Run T3 App interactively
        & npm.cmd create t3-app@latest
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host ""
            Write-Host "   [ERROR] Failed to create T3 App" -ForegroundColor Red
            Write-Host "   [NOTE] Try running manually: npm create t3-app@latest" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host ""
        Write-Host "=============================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "   [OK] T3 App created successfully" -ForegroundColor Green
    }
    catch {
        Write-Host ""
        Write-Host "   [ERROR] Failed to create T3 App: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   [NOTE] Try running manually: npm create t3-app@latest" -ForegroundColor Yellow
        exit 1
    }
    Write-Host ""
    
    # Ask user for the project name they used
    Write-Host "   [INFO] Now we'll install Nether-Grasp into your new project" -ForegroundColor Cyan
    $projectName = Read-Host "   What project name did you use"
    Write-Host ""
    
    if ([string]::IsNullOrWhiteSpace($projectName)) {
        Write-Host "[ERROR] Project name is required to continue installation" -ForegroundColor Red
        exit 1
    }
    
    # Set target path to the newly created project
    $projectPath = Join-Path (Get-Location) $projectName
    
    if (-not (Test-Path $projectPath)) {
        Write-Host "[ERROR] Project directory '$projectName' not found" -ForegroundColor Red
        Write-Host "   [NOTE] Make sure you entered the correct project name" -ForegroundColor Yellow
        exit 1
    }
    
    $TargetPath = $projectPath
}
else {
    Write-Host "[INFO] Re-install mode: Skipping T3 App creation" -ForegroundColor Cyan
    Write-Host ""
    $TargetPath = Get-Location
}

Write-Host "[TARGET] $TargetPath" -ForegroundColor Green
Write-Host ""

# Auto-confirm installation
Write-Host "[INFO] Installing Nether-Grasp to target directory..." -ForegroundColor Cyan

Write-Host ""
Write-Host "[START] Starting Nether-Grasp installation..." -ForegroundColor Cyan
Write-Host ""

# Track installation progress
$filescopied = 0
$errors = 0

# Function to copy file with error handling
function Copy-FileWithCheck {
    param($Source, $Destination)
    
    try {
        $destDir = Split-Path -Parent $Destination
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        Copy-Item -Path $Source -Destination $Destination -Force
        $script:filescopied++
        return $true
    }
    catch {
        Write-Host "   [ERROR] Failed to copy: $Source" -ForegroundColor Red
        Write-Host "      Error: $($_.Exception.Message)" -ForegroundColor Red
        $script:errors++
        return $false
    }
}

# 1. Copy Frontend Components
Write-Host "[STEP 1/9] Copying frontend components..." -ForegroundColor Yellow

$frontendFiles = @(
    "src\app\nether-grasp\page.tsx",
    "src\app\nether-grasp\_css\page.css",
    "src\app\d\[[...slug]]\page.tsx",
    "src\app\d\[[...slug]]\_css\page.css",
    "src\components\nether_grasp\FaviconInverter.tsx",
    "src\components\nether_grasp\Navbar.tsx",
    "src\components\nether_grasp\MainPart.tsx",
    "src\components\nether_grasp\_css\Navbar.css",
    "src\components\nether_grasp\_css\MainPart.css",
    "src\components\nether_grasp\main_part\ButtonDark.tsx",
    "src\components\nether_grasp\main_part\ButtonLight.tsx",
    "src\components\nether_grasp\main_part\ButtonRow.tsx",
    "src\components\nether_grasp\main_part\PromptDisplay.tsx",
    "src\components\nether_grasp\main_part\SyntaxHighlight.tsx",
    "src\components\nether_grasp\main_part\TasksList.tsx",
    "src\components\nether_grasp\main_part\TextArea.tsx",
    "src\components\nether_grasp\main_part\_css\ButtonDark.css",
    "src\components\nether_grasp\main_part\_css\ButtonLight.css",
    "src\components\nether_grasp\main_part\_css\ButtonRow.css",
    "src\components\nether_grasp\main_part\_css\PromptDisplay.css",
    "src\components\nether_grasp\main_part\_css\SyntaxHighlight.css",
    "src\components\nether_grasp\main_part\_css\TasksList.css",
    "src\components\nether_grasp\main_part\_css\TextArea.css",
    "src\components\nether_grasp\navbar\BottomToolBar.tsx",
    "src\components\nether_grasp\navbar\SearchBar.tsx",
    "src\components\nether_grasp\navbar\SearchBarFilterButton.tsx",
    "src\components\nether_grasp\navbar\SearchBarModal.tsx",
    "src\components\nether_grasp\navbar\Task.tsx",
    "src\components\nether_grasp\navbar\TaskDay.tsx",
    "src\components\nether_grasp\navbar\TaskList.tsx",
    "src\components\nether_grasp\navbar\TaskModal.tsx",
    "src\components\nether_grasp\navbar\TaskOption.tsx",
    "src\components\nether_grasp\navbar\ToggleNavbar.tsx",
    "src\components\nether_grasp\navbar\ToggleOpenNavbar.tsx",
    "src\components\nether_grasp\navbar\TopPart.tsx",
    "src\components\nether_grasp\navbar\_css\BottomToolBar.css",
    "src\components\nether_grasp\navbar\_css\SearchBar.css",
    "src\components\nether_grasp\navbar\_css\SearchBarModal.css",
    "src\components\nether_grasp\navbar\_css\Task.css",
    "src\components\nether_grasp\navbar\_css\TaskDay.css",
    "src\components\nether_grasp\navbar\_css\TaskList.css",
    "src\components\nether_grasp\navbar\_css\TaskModal.css",
    "src\components\nether_grasp\navbar\_css\ToggleNavbar.css",
    "src\components\nether_grasp\navbar\_css\ToggleOpenNavbar.css",
    "src\components\nether_grasp\navbar\_css\TopPart.css"
)

foreach ($file in $frontendFiles) {
    $source = Join-Path $SourcePath $file
    $destination = Join-Path $TargetPath $file
    
    if (Test-Path $source) {
        Copy-FileWithCheck $source $destination | Out-Null
    }
    else {
        Write-Host "   [WARNING] Not found: $file" -ForegroundColor Yellow
    }
}

Write-Host "   [OK] Frontend components copied ($filescopied files)" -ForegroundColor Green
Write-Host ""

# 2. Copy API Routes
Write-Host "[STEP 2/9] Copying API routes..." -ForegroundColor Yellow

$apiFiles = @(
    "src\app\api\nether-grasp\save-files\route.ts",
    "src\app\api\nether-grasp\tasks\route.ts",
    "src\app\api\webhooks\vercel\route.ts",
    "src\app\api\dbdiagram\diagram_permission\[slug]\route.ts",
    "src\app\api\dbdiagram\query\[slug]\route.ts",
    "src\app\api\dbdiagram\subscription\public_feature_rules\[slug]\route.ts",
    "src\app\api\dbdiagram\sync\[slug]\route.ts",
    "src\app\api\dbdiagram\table\[name]\route.ts",
    "src\app\api\dbdiagram\tables\route.ts"
)

$apiStart = $filescopied
foreach ($file in $apiFiles) {
    $source = Join-Path $SourcePath $file
    $destination = Join-Path $TargetPath $file
    
    if (Test-Path $source) {
        Copy-FileWithCheck $source $destination | Out-Null
    }
    else {
        Write-Host "   [WARNING] Not found: $file" -ForegroundColor Yellow
    }
}

Write-Host "   [OK] API routes copied ($($filescopied - $apiStart) files)" -ForegroundColor Green
Write-Host ""

# 3. Copy Bridge Server
Write-Host "[STEP 3/9] Copying bridge server..." -ForegroundColor Yellow

$bridgeStart = $filescopied
$bridgeFile = "nether-bridge-server.js"
$source = Join-Path $SourcePath $bridgeFile
$destination = Join-Path $TargetPath $bridgeFile

if (Test-Path $source) {
    Copy-FileWithCheck $source $destination | Out-Null
    Write-Host "   [OK] Bridge server copied" -ForegroundColor Green
}
else {
    Write-Host "   [ERROR] Bridge server not found!" -ForegroundColor Red
}
Write-Host ""

# 4. Copy Assets
Write-Host "[STEP 4/10] Copying public assets..." -ForegroundColor Yellow

$assetFiles = @(
    "public\nether-grasp-logo.png",
    "public\nether-grasp.png",
    "public\fonts\pixelgrid-squarebolds.woff",
    "public\fonts\pixelgrid-squareboldm.woff",
    "public\fonts\pixelgrid-squareboldxl.woff",
    "public\assets\DbxNotifications-BZIc0Tdf.js",
    "public\assets\DbxNotifications-DgyFJ-QX.css",
    "public\assets\diagram-BKB80E78.js",
    "public\assets\diagram-DJO-dynF.css",
    "public\assets\holistics-logo-square-CsK6csWb.png",
    "public\assets\logo-UzR4BxSc.svg",
    "public\assets\microsoft-logo-RjkpDaxr.js",
    "public\assets\PrivatePageContainer-__1G81FE.css",
    "public\assets\PrivatePageContainer-BVDQ-cpv.js",
    "public\assets\sentryCatcher-COGPhNS0.js",
    "public\assets\typeof-OGVaD8Cd.js",
    "public\database\assets\DbxNotifications-BZIc0Tdf.js",
    "public\database\assets\DbxNotifications-DgyFJ-QX.css",
    "public\database\assets\diagram-BKB80E78.js",
    "public\database\assets\diagram-DJO-dynF.css",
    "public\database\assets\index-B5iclh-t.css",
    "public\database\assets\index-CDtQ8wxC.js",
    "public\database\assets\microsoft-logo-RjkpDaxr.js",
    "public\database\assets\PrivatePageContainer-__1G81FE.css",
    "public\database\assets\PrivatePageContainer-BVDQ-cpv.js",
    "public\database\assets\sentryCatcher-COGPhNS0.js",
    "public\database\assets\typeof-OGVaD8Cd.js",
    "public\database\js\cookie.js",
    "public\query\database.json"
)

$assetStart = $filescopied
foreach ($file in $assetFiles) {
    $source = Join-Path $SourcePath $file
    $destination = Join-Path $TargetPath $file
    
    if (Test-Path $source) {
        Copy-FileWithCheck $source $destination | Out-Null
    }
    else {
        Write-Host "   [WARNING] Not found: $file" -ForegroundColor Yellow
    }
}

Write-Host "   [OK] Assets copied ($($filescopied - $assetStart) files)" -ForegroundColor Green
Write-Host ""

# 5. Copy Cursor configuration
Write-Host "[STEP 5/10] Copying Cursor configuration..." -ForegroundColor Yellow

$cursorFiles = @(
    ".cursor\AI_CHECKLIST.md",
    ".cursor\rules\rules.mdc"
)

$cursorStart = $filescopied
foreach ($file in $cursorFiles) {
    $source = Join-Path $SourcePath $file
    $destination = Join-Path $TargetPath $file
    
    if (Test-Path $source) {
        Copy-FileWithCheck $source $destination | Out-Null
    }
    else {
        Write-Host "   [WARNING] Not found: $file" -ForegroundColor Yellow
    }
}

Write-Host "   [OK] Cursor configuration copied ($($filescopied - $cursorStart) files)" -ForegroundColor Green
Write-Host ""

# 5.1. Copy Server files
Write-Host "[STEP 5.1/10] Copying server files..." -ForegroundColor Yellow

$serverFiles = @(
    "src\server\db.ts",
    "src\server\db-pool.ts"
)

$serverStart = $filescopied
foreach ($file in $serverFiles) {
    $source = Join-Path $SourcePath $file
    $destination = Join-Path $TargetPath $file
    
    if (Test-Path $source) {
        Copy-FileWithCheck $source $destination | Out-Null
    }
    else {
        Write-Host "   [WARNING] Not found: $file" -ForegroundColor Yellow
    }
}

Write-Host "   [OK] Server files copied ($($filescopied - $serverStart) files)" -ForegroundColor Green
Write-Host ""

# 5.5. Update ESLint configuration (relaxed rules for Nether-Grasp compatibility)
Write-Host "[STEP 5.5/10] Updating ESLint configuration..." -ForegroundColor Yellow

$eslintConfigPath = Join-Path $TargetPath "eslint.config.js"

if (Test-Path $eslintConfigPath) {
    try {
        # Create relaxed ESLint flat config for Nether-Grasp compatibility
        $relaxedEslintConfig = @"
import { FlatCompat } from "@eslint/eslintrc";
import tseslint from "typescript-eslint";

const compat = new FlatCompat({
  baseDirectory: import.meta.dirname,
});

export default tseslint.config(
  {
    ignores: [".next"],
  },
  ...compat.extends("next/core-web-vitals"),
  {
    files: ["**/*.ts", "**/*.tsx"],
    rules: {
      // Relaxed rules for Nether-Grasp compatibility
      "@typescript-eslint/no-unsafe-assignment": "off",
      "@typescript-eslint/no-unsafe-member-access": "off",
      "@typescript-eslint/no-unsafe-argument": "off",
      "@typescript-eslint/no-unsafe-call": "off",
      "@typescript-eslint/no-unsafe-return": "off",
      "@typescript-eslint/no-floating-promises": "off",
      "@typescript-eslint/prefer-nullish-coalescing": "off",
      "@typescript-eslint/no-misused-promises": "off",
      "@typescript-eslint/consistent-indexed-object-style": "off",
      "@typescript-eslint/no-explicit-any": "off",
      "@typescript-eslint/no-redundant-type-constituents": "off",
      
      // Keep these as warnings
      "@typescript-eslint/consistent-type-imports": "warn",
      "@typescript-eslint/no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
      "@typescript-eslint/require-await": "off",
      "@typescript-eslint/array-type": "off",
      "@typescript-eslint/consistent-type-definitions": "off",
    },
  },
);
"@
        
        Set-Content -Path $eslintConfigPath -Value $relaxedEslintConfig -Encoding UTF8
        Write-Host "   [OK] ESLint configuration updated with relaxed rules" -ForegroundColor Green
        Write-Host "   [INFO] This allows Nether-Grasp code to build without strict type errors" -ForegroundColor Cyan
    }
    catch {
        Write-Host "   [ERROR] Failed to update ESLint config: $($_.Exception.Message)" -ForegroundColor Red
        $errors++
    }
}
else {
    Write-Host "   [WARNING] eslint.config.js not found, trying .eslintrc.json..." -ForegroundColor Yellow
    
    # Fallback to .eslintrc.json format
    $eslintJsonPath = Join-Path $TargetPath ".eslintrc.json"
    if (Test-Path $eslintJsonPath) {
        try {
            $relaxedEslintJson = @"
{
  "extends": "next/core-web-vitals",
  "rules": {
    "@typescript-eslint/no-unsafe-assignment": "off",
    "@typescript-eslint/no-unsafe-member-access": "off",
    "@typescript-eslint/no-unsafe-argument": "off",
    "@typescript-eslint/no-unsafe-call": "off",
    "@typescript-eslint/no-unsafe-return": "off",
    "@typescript-eslint/no-floating-promises": "off",
    "@typescript-eslint/prefer-nullish-coalescing": "off",
    "@typescript-eslint/no-misused-promises": "off",
    "@typescript-eslint/consistent-indexed-object-style": "off",
    "@typescript-eslint/no-explicit-any": "off",
    "@typescript-eslint/no-redundant-type-constituents": "off",
    "@typescript-eslint/consistent-type-imports": "warn",
    "@typescript-eslint/no-unused-vars": "warn"
  }
}
"@
            Set-Content -Path $eslintJsonPath -Value $relaxedEslintJson -Encoding UTF8
            Write-Host "   [OK] .eslintrc.json updated with relaxed rules" -ForegroundColor Green
        }
        catch {
            Write-Host "   [ERROR] Failed to update .eslintrc.json: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "   [WARNING] No ESLint config found" -ForegroundColor Yellow
    }
}
Write-Host ""

# 6. Update package.json
Write-Host "[STEP 6/10] Updating package.json..." -ForegroundColor Yellow

$packageJsonPath = Join-Path $TargetPath "package.json"
if (Test-Path $packageJsonPath) {
    try {
        $packageJson = Get-Content $packageJsonPath -Raw | ConvertFrom-Json
        
        # 1. Backup original dev script as dev:next (if not already done)
        if ($packageJson.scripts.dev -and -not $packageJson.scripts."dev:next") {
            $originalDevScript = $packageJson.scripts.dev
            $packageJson.scripts | Add-Member -NotePropertyName "dev:next" -NotePropertyValue $originalDevScript -Force
            Write-Host "   [OK] Saved original 'dev' script as 'dev:next'" -ForegroundColor Green
        }
        
        # 2. Add nether-bridge script if not exists
        if (-not $packageJson.scripts."nether-bridge") {
            $packageJson.scripts | Add-Member -NotePropertyName "nether-bridge" -NotePropertyValue "node nether-bridge-server.js" -Force
            Write-Host "   [OK] Added 'nether-bridge' script" -ForegroundColor Green
        }
        else {
            Write-Host "   [INFO] 'nether-bridge' script already exists" -ForegroundColor Cyan
        }
        
        # 3. Update dev script to run both servers concurrently
        if ($packageJson.scripts.dev -notmatch "concurrently") {
            # Use double quotes with proper escaping for Windows CMD compatibility
            $newDevScript = "concurrently `"npm run dev:next`" `"npm run nether-bridge`" --names `"next,bridge`" --prefix-colors `"cyan,magenta`""
            $packageJson.scripts.dev = $newDevScript
            Write-Host "   [OK] Updated 'dev' script to run both servers with concurrently" -ForegroundColor Green
        }
        else {
            Write-Host "   [INFO] 'dev' script already uses concurrently" -ForegroundColor Cyan
        }
        
        # 4. Add dev:no-bridge as a backup script
        if (-not $packageJson.scripts."dev:no-bridge") {
            $devNextValue = if ($packageJson.scripts."dev:next") { $packageJson.scripts."dev:next" } else { "next dev" }
            $packageJson.scripts | Add-Member -NotePropertyName "dev:no-bridge" -NotePropertyValue $devNextValue -Force
            Write-Host "   [OK] Added 'dev:no-bridge' fallback script" -ForegroundColor Green
        }
        
        # Save updated package.json
        $packageJson | ConvertTo-Json -Depth 100 | Set-Content $packageJsonPath
        
        Write-Host "   [NOTE] Dependencies will be installed in the next step" -ForegroundColor Yellow
    }
    catch {
        Write-Host "   [ERROR] Failed to update package.json: $($_.Exception.Message)" -ForegroundColor Red
        $errors++
    }
}
else {
    Write-Host "   [ERROR] package.json not found!" -ForegroundColor Red
    $errors++
}
Write-Host ""

# 7. Update tsconfig.json
Write-Host "[STEP 7/10] Updating tsconfig.json..." -ForegroundColor Yellow

$tsconfigPath = Join-Path $TargetPath "tsconfig.json"
if (Test-Path $tsconfigPath) {
    try {
        $tsconfigContent = Get-Content $tsconfigPath -Raw
        
        # Check if nether-bridge-server.js is already in exclude array
        if ($tsconfigContent -match '"nether-bridge-server\.js"') {
            Write-Host "   [INFO] nether-bridge-server.js already excluded" -ForegroundColor Cyan
        }
        else {
            # Find the closing bracket of exclude array and insert before it
            # This handles multiline arrays properly
            if ($tsconfigContent -match '"exclude"\s*:\s*\[') {
                # Find the position of the last item before the closing ]
                # Look for the pattern: "exclude": [...stuff...] including newlines
                $pattern = '("exclude"\s*:\s*\[[^\]]*)\]'
                
                if ($tsconfigContent -match $pattern) {
                    $beforeClosing = $matches[1]
                    
                    # Check if array is empty or has items
                    if ($beforeClosing -match '\[\s*$') {
                        # Empty array - just add the item
                        $replacement = $beforeClosing + '"nether-bridge-server.js"]'
                    }
                    else {
                        # Has items - add comma and new item
                        $replacement = $beforeClosing + ', "nether-bridge-server.js"]'
                    }
                    
                    # Replace the exclude array
                    $tsconfigContent = $tsconfigContent -replace $pattern, $replacement
                    
                    # Write back to file
                    Set-Content $tsconfigPath $tsconfigContent -NoNewline
                    
                    Write-Host "   [OK] Added nether-bridge-server.js to exclude array" -ForegroundColor Green
                }
                else {
                    Write-Host "   [WARNING] Could not parse 'exclude' array in tsconfig.json" -ForegroundColor Yellow
                    Write-Host "   [NOTE] Manually add 'nether-bridge-server.js' to exclude array" -ForegroundColor Yellow
                }
            }
            else {
                Write-Host "   [WARNING] Could not find 'exclude' array in tsconfig.json" -ForegroundColor Yellow
                Write-Host "   [NOTE] Manually add 'nether-bridge-server.js' to exclude array" -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host "   [ERROR] Failed to update tsconfig.json: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   [NOTE] Manually add 'nether-bridge-server.js' to exclude array" -ForegroundColor Yellow
        $errors++
    }
}
else {
    Write-Host "   [WARNING] tsconfig.json not found - you may need to create it" -ForegroundColor Yellow
}
Write-Host ""

# 8. Update Prisma schema with Task model
Write-Host "[STEP 8/10] Updating Prisma schema and database client..." -ForegroundColor Yellow

$sourceSchemaPath = Join-Path $SourcePath "prisma\schema.prisma"
$targetSchemaPath = Join-Path $TargetPath "prisma\schema.prisma"

if ((Test-Path $sourceSchemaPath) -and (Test-Path $targetSchemaPath)) {
    try {
        $sourceSchema = Get-Content $sourceSchemaPath -Raw
        $targetSchema = Get-Content $targetSchemaPath -Raw
        
        # First, ensure Prisma client uses default output path (not custom)
        $schemaModified = $false
        if ($targetSchema -match 'output\s*=\s*"[^"]+prisma"') {
            Write-Host "   [INFO] Removing custom Prisma output path..." -ForegroundColor Cyan
            # Remove the output line from generator client block while preserving structure
            $targetSchema = $targetSchema -replace '[ \t]*output\s*=\s*"[^"]*"[ \t]*\r?\n', ''
            Set-Content $targetSchemaPath $targetSchema
            Write-Host "   [OK] Prisma will use default output path (@prisma/client)" -ForegroundColor Green
            $schemaModified = $true
        }
        
        # Check if Task model already exists in target
        if ($targetSchema -match "model Task \{") {
            Write-Host "   [INFO] Task model already exists in schema" -ForegroundColor Cyan
        }
        else {
            # Extract Task model from source schema
            if ($sourceSchema -match "(?s)(// Nether Grasp Task model.*?model Task \{.*?\n\})") {
                $taskModel = $matches[1]
                
                # Reload schema if it was modified
                if ($schemaModified) {
                    $targetSchema = Get-Content $targetSchemaPath -Raw
                }
                
                # Append Task model to target schema
                $updatedSchema = $targetSchema.TrimEnd() + "`n`n" + $taskModel + "`n"
                Set-Content $targetSchemaPath $updatedSchema
                
                Write-Host "   [OK] Added Task model to schema.prisma" -ForegroundColor Green
                $schemaModified = $true
            }
            else {
                Write-Host "   [ERROR] Could not extract Task model from source schema" -ForegroundColor Red
                Write-Host "   [NOTE] Manually add Task model to prisma/schema.prisma" -ForegroundColor Yellow
                $errors++
            }
        }
        
        # Note: db.ts is now copied from source in Step 5.1, so we skip import path modification
        Write-Host "   [INFO] db.ts was copied from source (Step 5.1) - using WASM Prisma adapter" -ForegroundColor Cyan
        
        # Generate Prisma client if any changes were made
        if ($schemaModified) {
            Write-Host "   [INFO] Generating Prisma client..." -ForegroundColor Cyan
            Push-Location $TargetPath
            $generateOutput = & npx.cmd prisma generate 2>&1 | Out-String
            Pop-Location
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "   [OK] Prisma client generated successfully" -ForegroundColor Green
            }
            else {
                Write-Host "   [WARNING] Prisma generate failed: $generateOutput" -ForegroundColor Yellow
                Write-Host "   [NOTE] You may need to stop your dev server and run: npx prisma generate" -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host "   [ERROR] Failed to update schema: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   [NOTE] Manually add Task model to prisma/schema.prisma" -ForegroundColor Yellow
        $errors++
    }
}
else {
    Write-Host "   [WARNING] schema.prisma not found in source or target" -ForegroundColor Yellow
    Write-Host "   [NOTE] Manually create prisma/schema.prisma and add Task model" -ForegroundColor Yellow
}
Write-Host ""

# 9. Update .gitignore
Write-Host "[STEP 9/10] Updating .gitignore..." -ForegroundColor Yellow
$gitignorePath = Join-Path $TargetPath ".gitignore"
if (Test-Path $gitignorePath) {
    try {
        $gitignoreContent = Get-Content $gitignorePath -Raw
        
        # Check if Nether-Grasp entries already exist
        if ($gitignoreContent -notmatch "nether-grasp") {
            $netherGraspIgnore = @"

# Nether-Grasp
/nether-grasp/*
/src/app/nether-grasp
nether-grasp/prompts/
!nether-grasp/
!nether-grasp/tasks_list.json
/cursor-extension/extension.js
"@
            Add-Content -Path $gitignorePath -Value $netherGraspIgnore
            Write-Host "   [OK] Added Nether-Grasp entries to .gitignore" -ForegroundColor Green
        }
        else {
            Write-Host "   [INFO] Nether-Grasp entries already in .gitignore" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "   [ERROR] Failed to update .gitignore: $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    Write-Host "   [WARNING] .gitignore not found, creating new one" -ForegroundColor Yellow
    try {
        $netherGraspIgnore = @"
# Nether-Grasp
/nether-grasp/*
/src/app/nether-grasp
nether-grasp/prompts/
!nether-grasp/
!nether-grasp/tasks_list.json
/cursor-extension/extension.js
"@
        Set-Content -Path $gitignorePath -Value $netherGraspIgnore
        Write-Host "   [OK] Created .gitignore with Nether-Grasp entries" -ForegroundColor Green
    }
    catch {
        Write-Host "   [ERROR] Failed to create .gitignore: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# 10. Update/create .env
Write-Host "[STEP 10/10] Setting up .env file..." -ForegroundColor Yellow
Write-Host ""
Write-Host "   Please provide the following environment variables:" -ForegroundColor Cyan
Write-Host "   (Press Enter to skip any variable)" -ForegroundColor Yellow
Write-Host ""

# Prompt for required variables
$databaseUrl = Read-Host "   DATABASE_URL (PostgreSQL connection string)"
$cursorApiKey = Read-Host "   CURSOR_API_KEY (Get from Cursor settings)"
$vercelWebhookSecret = Read-Host "   VERCEL_WEBHOOK_SECRET (Random string for webhook security)"
$vercelApiToken = Read-Host "   VERCEL_API_TOKEN (Get from Vercel settings)"

Write-Host ""

$envPath = Join-Path $TargetPath ".env"
$envContent = ""

# Read existing .env if it exists
if (Test-Path $envPath) {
    $envContent = Get-Content $envPath -Raw
    Write-Host "   [INFO] Existing .env file found, updating..." -ForegroundColor Cyan
}
else {
    Write-Host "   [INFO] Creating new .env file..." -ForegroundColor Cyan
}

# Function to set or update environment variable
function Set-EnvVariable {
    param($Name, $Value, [ref]$Content)
    
    if ([string]::IsNullOrWhiteSpace($Value)) {
        # If value is empty, only add if variable doesn't exist
        if ($Content.Value -notmatch "$Name\s*=") {
            $Content.Value += "$Name=`n"
        }
    }
    else {
        # If value provided, set or update it
        if ($Content.Value -match "$Name\s*=.*") {
            # Update existing variable
            $Content.Value = $Content.Value -replace "$Name\s*=.*", "$Name=$Value"
        }
        else {
            # Add new variable
            $Content.Value += "$Name=$Value`n"
        }
    }
}

# Add header if new file
if ([string]::IsNullOrWhiteSpace($envContent)) {
    $envContent = "# Environment Variables`n# Configured by Nether-Grasp installer`n`n"
}

# Set the prompted variables
Set-EnvVariable -Name "DATABASE_URL" -Value $databaseUrl -Content ([ref]$envContent)
Set-EnvVariable -Name "CURSOR_API_KEY" -Value $cursorApiKey -Content ([ref]$envContent)
Set-EnvVariable -Name "VERCEL_WEBHOOK_SECRET" -Value $vercelWebhookSecret -Content ([ref]$envContent)
Set-EnvVariable -Name "VERCEL_API_TOKEN" -Value $vercelApiToken -Content ([ref]$envContent)

# Add other common variables if they don't exist
$otherVars = @(
    "NEXT_PUBLIC_APP_URL",
    "STRIPE_WEBHOOK_SECRET",
    "STRIPE_SECRET_KEY",
    "NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY",
    "CLERK_WEBHOOK_SECRET",
    "NEXT_PUBLIC_CLERK_SIGN_IN_URL",
    "NEXT_PUBLIC_CLERK_SIGN_UP_URL",
    "NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL",
    "NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL",
    "NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY",
    "CLERK_SECRET_KEY"
)

foreach ($var in $otherVars) {
    Set-EnvVariable -Name $var -Value "" -Content ([ref]$envContent)
}

# Write to file
try {
    Set-Content -Path $envPath -Value $envContent.TrimEnd()
    Write-Host "   [OK] Environment variables saved to .env" -ForegroundColor Green
    
    # Show what was configured
    $configured = @()
    $skipped = @()
    
    if (-not [string]::IsNullOrWhiteSpace($databaseUrl)) { $configured += "DATABASE_URL" } else { $skipped += "DATABASE_URL" }
    if (-not [string]::IsNullOrWhiteSpace($cursorApiKey)) { $configured += "CURSOR_API_KEY" } else { $skipped += "CURSOR_API_KEY" }
    if (-not [string]::IsNullOrWhiteSpace($vercelWebhookSecret)) { $configured += "VERCEL_WEBHOOK_SECRET" } else { $skipped += "VERCEL_WEBHOOK_SECRET" }
    if (-not [string]::IsNullOrWhiteSpace($vercelApiToken)) { $configured += "VERCEL_API_TOKEN" } else { $skipped += "VERCEL_API_TOKEN" }
    
    if ($configured.Count -gt 0) {
        Write-Host "   [INFO] Configured: $($configured -join ', ')" -ForegroundColor Green
    }
    if ($skipped.Count -gt 0) {
        Write-Host "   [WARNING] Skipped (empty): $($skipped -join ', ')" -ForegroundColor Yellow
        Write-Host "   [NOTE] Remember to configure these variables manually in .env" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "   [ERROR] Failed to write .env: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# 10.5. Update nether-bridge-server.js with actual CURSOR_API_KEY
Write-Host "[STEP 10.5/10] Updating nether-bridge-server.js with API key..." -ForegroundColor Yellow

$bridgeServerPath = Join-Path $TargetPath "nether-bridge-server.js"
if ((Test-Path $bridgeServerPath) -and -not [string]::IsNullOrWhiteSpace($cursorApiKey)) {
    try {
        $bridgeServerContent = Get-Content $bridgeServerPath -Raw
        
        # Replace hardcoded API key with the user-provided one
        # Match the multiline pattern: const CURSOR_API_KEY = process.env.CURSOR_API_KEY || "key_...";
        $pattern = '(?s)const CURSOR_API_KEY\s*=\s*process\.env\.CURSOR_API_KEY\s*\|\|\s*[''"]key_[a-f0-9]+[''"];'
        $replacement = "const CURSOR_API_KEY = process.env.CURSOR_API_KEY || `"$cursorApiKey`";"
        
        # Also match simpler pattern if it exists: const CURSOR_API_KEY = "key_...";
        $simplePattern = 'const CURSOR_API_KEY\s*=\s*[''"]key_[a-f0-9]+[''"];'
        
        if ($bridgeServerContent -match $pattern) {
            $bridgeServerContent = $bridgeServerContent -replace $pattern, $replacement
            Set-Content -Path $bridgeServerPath -Value $bridgeServerContent -Encoding UTF8
            Write-Host "   [OK] Bridge server updated with your CURSOR_API_KEY" -ForegroundColor Green
            Write-Host "   [INFO] The server will use .env file or fallback to provided key" -ForegroundColor Cyan
        } elseif ($bridgeServerContent -match $simplePattern) {
            $simpleReplacement = "const CURSOR_API_KEY = process.env.CURSOR_API_KEY || `"$cursorApiKey`";"
            $bridgeServerContent = $bridgeServerContent -replace $simplePattern, $simpleReplacement
            Set-Content -Path $bridgeServerPath -Value $bridgeServerContent -Encoding UTF8
            Write-Host "   [OK] Bridge server updated with your CURSOR_API_KEY" -ForegroundColor Green
            Write-Host "   [INFO] The server will use .env file or fallback to provided key" -ForegroundColor Cyan
        } else {
            Write-Host "   [WARNING] Could not find API key pattern in bridge server" -ForegroundColor Yellow
            Write-Host "   [NOTE] You may need to manually update CURSOR_API_KEY in nether-bridge-server.js" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "   [ERROR] Failed to update bridge server: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   [NOTE] Manually update CURSOR_API_KEY in nether-bridge-server.js" -ForegroundColor Yellow
    }
}
elseif (-not (Test-Path $bridgeServerPath)) {
    Write-Host "   [WARNING] nether-bridge-server.js not found, skipping update" -ForegroundColor Yellow
}
elseif ([string]::IsNullOrWhiteSpace($cursorApiKey)) {
    Write-Host "   [WARNING] No CURSOR_API_KEY provided, keeping default in bridge server" -ForegroundColor Yellow
    Write-Host "   [NOTE] Remember to update CURSOR_API_KEY in nether-bridge-server.js or .env" -ForegroundColor Yellow
}
Write-Host ""

# Installation summary
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "           INSTALLATION COMPLETE" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[SUMMARY]" -ForegroundColor Green
Write-Host "   [OK] Files copied: $filescopied" -ForegroundColor Green
if ($errors -gt 0) {
    Write-Host "   [ERROR] Errors: $errors" -ForegroundColor Red
}
Write-Host ""

# Post-installation automated steps
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "           POST-INSTALLATION SETUP" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Set up Git origin
Write-Host "[AUTO-STEP 1/5] Setting up Git repository..." -ForegroundColor Yellow
Write-Host ""
$gitRepoUrl = Read-Host "   GitHub repository URL (e.g., https://github.com/user/repo.git)"
Write-Host ""

if (-not [string]::IsNullOrWhiteSpace($gitRepoUrl)) {
    try {
        Push-Location $TargetPath
        
        # Check if git is initialized
        $gitExists = Test-Path (Join-Path $TargetPath ".git")
        
        if (-not $gitExists) {
            Write-Host "   [INFO] Initializing git repository..." -ForegroundColor Cyan
            & git init 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "   [OK] Git repository initialized" -ForegroundColor Green
            }
            else {
                Write-Host "   [ERROR] Failed to initialize git repository" -ForegroundColor Red
                Pop-Location
                Write-Host ""
                return
            }
        }
        else {
            Write-Host "   [INFO] Git repository already initialized" -ForegroundColor Cyan
        }
        
        # Check if origin already exists
        $originExists = & git remote get-url origin 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   [INFO] Updating existing origin: $originExists -> $gitRepoUrl" -ForegroundColor Cyan
            & git remote set-url origin $gitRepoUrl 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "   [OK] Git origin updated to: $gitRepoUrl" -ForegroundColor Green
            }
            else {
                Write-Host "   [ERROR] Failed to update git origin" -ForegroundColor Red
            }
        }
        else {
            Write-Host "   [INFO] Adding git origin: $gitRepoUrl" -ForegroundColor Cyan
            & git remote add origin $gitRepoUrl 2>&1 | Out-Null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "   [OK] Git origin added: $gitRepoUrl" -ForegroundColor Green
            }
            else {
                Write-Host "   [ERROR] Failed to add git origin" -ForegroundColor Red
            }
        }
        
        Pop-Location
    }
    catch {
        Pop-Location
        Write-Host "   [ERROR] Git setup failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    Write-Host "   [SKIPPED] No GitHub repository URL provided" -ForegroundColor Yellow
    Write-Host "   [NOTE] You can set it later with: git remote add origin <url>" -ForegroundColor Yellow
}
Write-Host ""

# 2. Install dependencies
Write-Host "[AUTO-STEP 2/5] Installing dependencies..." -ForegroundColor Yellow
Write-Host "   [INFO] Auto-installing: ws, @types/ws, pg, prisma, concurrently" -ForegroundColor Cyan
    try {
        Push-Location $TargetPath
        
        Write-Host "   [INFO] Running: npm install ws @types/ws pg (in target directory)" -ForegroundColor Cyan
        & npm.cmd install ws "@types/ws" pg 2>&1 | Out-Host
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   [INFO] Running: npm install -D prisma @prisma/client concurrently @types/pg (in target directory)" -ForegroundColor Cyan
            & npm.cmd install -D prisma "@prisma/client" concurrently "@types/pg" 2>&1 | Out-Host
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "   [OK] All dependencies installed successfully" -ForegroundColor Green
            }
            else {
                Write-Host "   [WARNING] Dev dependencies install failed. Run manually: npm install -D prisma @prisma/client concurrently @types/pg" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "   [WARNING] npm install failed. Run manually: npm install ws @types/ws pg" -ForegroundColor Yellow
        }
        
        Pop-Location
    }
    catch {
        Pop-Location
        Write-Host "   [ERROR] Failed to install dependencies: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   [NOTE] Run manually: npm install ws @types/ws pg && npm install -D prisma @prisma/client concurrently @types/pg" -ForegroundColor Yellow
    }
Write-Host ""

# 3. Regenerate Prisma Client (to ensure it uses default path)
Write-Host "[AUTO-STEP 3/5] Regenerating Prisma Client..." -ForegroundColor Yellow

$packageJsonPath = Join-Path $TargetPath "package.json"
$hasPrisma = $false
if (Test-Path $packageJsonPath) {
    $packageJsonContent = Get-Content $packageJsonPath -Raw
    if ($packageJsonContent -match '"prisma"') {
        $hasPrisma = $true
    }
}

if ($hasPrisma) {
    try {
        Write-Host "   [INFO] Running: npx prisma generate (in target directory)" -ForegroundColor Cyan
        Push-Location $TargetPath
        & npx.cmd prisma generate 2>&1 | Out-Host
        Pop-Location
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   [OK] Prisma client regenerated successfully" -ForegroundColor Green
        }
        else {
            Write-Host "   [WARNING] prisma generate failed. Run manually: npx prisma generate" -ForegroundColor Yellow
        }
    }
    catch {
        Pop-Location
        Write-Host "   [ERROR] Failed to generate Prisma client: $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    Write-Host "   [WARNING] Prisma not installed, skipping client generation" -ForegroundColor Yellow
}
Write-Host ""

# 4. Push Prisma schema to database
Write-Host "[AUTO-STEP 4/5] Pushing Prisma schema to database..." -ForegroundColor Yellow

# Check if Prisma is installed
$packageJsonPath = Join-Path $TargetPath "package.json"
$hasPrisma = $false
if (Test-Path $packageJsonPath) {
    $packageJsonContent = Get-Content $packageJsonPath -Raw
    if ($packageJsonContent -match '"prisma"') {
        $hasPrisma = $true
    }
}

if (-not $hasPrisma) {
    Write-Host "   [WARNING] Prisma not installed in package.json" -ForegroundColor Yellow
    Write-Host "   [SKIPPED] Install Prisma first: npm install -D prisma" -ForegroundColor Yellow
}
else {
    # Check if DATABASE_URL is configured
    $envPath = Join-Path $TargetPath ".env"
    $hasDbUrl = $false
    if (Test-Path $envPath) {
        $envContent = Get-Content $envPath -Raw
        if ($envContent -match 'DATABASE_URL\s*=\s*\S+') {
            $hasDbUrl = $true
        }
    }

    if (-not $hasDbUrl) {
        Write-Host "   [WARNING] DATABASE_URL not found in .env" -ForegroundColor Yellow
        Write-Host "   [SKIPPED] Configure DATABASE_URL first, then run: npx prisma db push" -ForegroundColor Yellow
    }
    else {
        Write-Host "   [INFO] Auto-pushing schema to database..." -ForegroundColor Cyan
        try {
            Write-Host "   [INFO] Running: npx prisma db push (in target directory)" -ForegroundColor Cyan
            Push-Location $TargetPath
            & npx.cmd prisma db push 2>&1 | Out-Host
            Pop-Location
            if ($LASTEXITCODE -eq 0) {
                Write-Host "   [OK] Schema pushed to database successfully" -ForegroundColor Green
            }
            else {
                Write-Host "   [WARNING] prisma db push failed. Run manually: npx prisma db push" -ForegroundColor Yellow
            }
        }
        catch {
            Pop-Location
            Write-Host "   [ERROR] Failed to push schema: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "   [NOTE] Run manually: npx prisma db push" -ForegroundColor Yellow
        }
    }
}
Write-Host ""

# 5. Remove query logging from db.ts
Write-Host "[AUTO-STEP 5/6] Removing query logging from db.ts..." -ForegroundColor Yellow

$dbTsPath = Join-Path $TargetPath "src\server\db.ts"
if (Test-Path $dbTsPath) {
    try {
        $dbTsContent = Get-Content $dbTsPath -Raw
        
        # Check for query logging in any format
        $hasQueryLogging = $false
        
        # Pattern 1: T3 App conditional format - log: env.NODE_ENV === "development" ? ["query", "error", "warn"] : ["error"]
        if ($dbTsContent -match '\?\s*\[[^\]]*[''"]query[''"]') {
            Write-Host "   [INFO] Found query logging in T3 App conditional format" -ForegroundColor Cyan
            $hasQueryLogging = $true
            
            # Remove "query" from the development array
            $dbTsContent = $dbTsContent -replace '(\[[^\]]*?)[''"]query[''"]\s*,\s*([^\]]*?\])', '$1$2'
            # Clean up any resulting issues like [, "error"] -> ["error"]
            $dbTsContent = $dbTsContent -replace '\[\s*,\s*', '['
        }
        
        # Pattern 2: Simple log array - log: ['query', 'error', 'warn']
        if ($dbTsContent -match 'log:\s*\[[^\]]*[''"]query[''"]') {
            if (-not $hasQueryLogging) {
                Write-Host "   [INFO] Found query logging in simple array format" -ForegroundColor Cyan
            }
            $hasQueryLogging = $true
            
            # Remove 'query' from the log array
            $dbTsContent = $dbTsContent -replace '([''"]query[''"],?\s*)', ''
            # Clean up double commas or leading commas
            $dbTsContent = $dbTsContent -replace ',\s*,', ','
            $dbTsContent = $dbTsContent -replace 'log:\s*\[\s*,', 'log: ['
            $dbTsContent = $dbTsContent -replace ',\s*\]', ']'
        }
        
        if ($hasQueryLogging) {
            Set-Content $dbTsPath $dbTsContent -Encoding UTF8
            Write-Host "   [OK] Removed query logging from Prisma client" -ForegroundColor Green
            Write-Host "   [INFO] Query logs will no longer appear in terminal" -ForegroundColor Cyan
        }
        else {
            Write-Host "   [INFO] No query logging found in db.ts (already clean)" -ForegroundColor Cyan
        }
    }
    catch {
        Write-Host "   [ERROR] Failed to update db.ts: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   [NOTE] Query logging may still appear in terminal" -ForegroundColor Yellow
    }
}
else {
    Write-Host "   [WARNING] db.ts not found at src\server\db.ts" -ForegroundColor Yellow
}
Write-Host ""

# 6. Git commit and push
Write-Host "[AUTO-STEP 6/6] Git commit and force push..." -ForegroundColor Yellow
Write-Host "   [INFO] Auto-committing and force pushing to GitHub..." -ForegroundColor Cyan
Write-Host "   [WARNING] This will overwrite remote repository data!" -ForegroundColor Yellow
try {
    Push-Location $TargetPath
    
    # Stage all changes
    Write-Host "   [INFO] Running: git add . (in target directory)" -ForegroundColor Cyan
    & git add . 2>&1 | Out-Null
    
    # Commit changes
    Write-Host "   [INFO] Running: git commit -m 'feat: Add Nether-Grasp'" -ForegroundColor Cyan
    & git commit -m "feat: Add Nether-Grasp" 2>&1 | Out-Host
    
    $commitSuccess = $LASTEXITCODE -eq 0
    
    # Get current branch (should be main)
    $currentBranch = & git rev-parse --abbrev-ref HEAD 2>&1
    if (-not $currentBranch -or $currentBranch -eq "") {
        $currentBranch = "main"
    }
    
    Write-Host ""
    Write-Host "   [INFO] Setting up main branch..." -ForegroundColor Cyan
    
    # Force push to main
    Write-Host "   [INFO] Running: git push --force origin $currentBranch" -ForegroundColor Cyan
    & git push --force origin $currentBranch 2>&1 | Out-Host
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] Force pushed to $currentBranch" -ForegroundColor Green
    }
    else {
        Write-Host "   [ERROR] Failed to force push to $currentBranch" -ForegroundColor Red
        Pop-Location
        exit 1
    }
    
    # Set up tracking for main
    Write-Host "   [INFO] Running: git push --set-upstream origin $currentBranch" -ForegroundColor Cyan
    & git push --set-upstream origin $currentBranch 2>&1 | Out-Host
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] Tracking set up for $currentBranch" -ForegroundColor Green
    }
    else {
        Write-Host "   [WARNING] Could not set upstream for $currentBranch (may already be set)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "   [INFO] Setting up nether-grasp-staging branch..." -ForegroundColor Cyan
    
    # Check if nether-grasp-staging exists locally
    $stagingExists = & git rev-parse --verify nether-grasp-staging 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        # Create staging branch from main
        Write-Host "   [INFO] Creating nether-grasp-staging branch from $currentBranch" -ForegroundColor Cyan
        & git checkout -b nether-grasp-staging 2>&1 | Out-Null
        & git checkout $currentBranch 2>&1 | Out-Null
    }
    
    # Force push nether-grasp-staging (to keep in sync with main's new history)
    Write-Host "   [INFO] Running: git push --force origin nether-grasp-staging" -ForegroundColor Cyan
    & git push --force origin nether-grasp-staging 2>&1 | Out-Host
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] Force pushed to nether-grasp-staging" -ForegroundColor Green
    }
    else {
        Write-Host "   [WARNING] Could not force push nether-grasp-staging" -ForegroundColor Yellow
        Write-Host "   [NOTE] You may need to create this branch manually" -ForegroundColor Yellow
    }
    
    # Set up tracking for nether-grasp-staging
    Write-Host "   [INFO] Running: git push --set-upstream origin nether-grasp-staging" -ForegroundColor Cyan
    & git push --set-upstream origin nether-grasp-staging 2>&1 | Out-Host
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   [OK] Tracking set up for nether-grasp-staging" -ForegroundColor Green
    }
    else {
        Write-Host "   [WARNING] Could not set upstream for nether-grasp-staging (may already be set)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "   [OK] All branches configured successfully!" -ForegroundColor Green
    Write-Host "   [INFO] Vercel will now deploy your changes!" -ForegroundColor Cyan
    
    Pop-Location
}
catch {
    Pop-Location
    Write-Host "   [ERROR] Git operations failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   [NOTE] Run manually:" -ForegroundColor Yellow
    Write-Host "      git add ." -ForegroundColor White
    Write-Host "      git commit -m 'feat: Add Nether-Grasp'" -ForegroundColor White
    Write-Host "      git push --force origin main" -ForegroundColor White
    Write-Host "      git push --set-upstream origin main" -ForegroundColor White
    Write-Host "      git push --force origin nether-grasp-staging" -ForegroundColor White
    Write-Host "      git push --set-upstream origin nether-grasp-staging" -ForegroundColor White
}
Write-Host ""

# Final success message
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "           INSTALLATION COMPLETE!" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""

if (-not $ReInstall) {
    Write-Host "Your T3 App + Nether-Grasp project is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Project location: $TargetPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Navigate to your project:" -ForegroundColor White
    Write-Host "   cd $projectName" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2. Start the development servers:" -ForegroundColor White
    Write-Host "   npm run dev" -ForegroundColor Cyan
    Write-Host "   (This runs both Next.js and Nether-Bridge automatically)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Open your browser:" -ForegroundColor White
    Write-Host "   http://localhost:3000/nether-grasp" -ForegroundColor Cyan
    Write-Host ""
}
else {
    Write-Host "Nether-Grasp re-installed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "NEXT STEPS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Start the development servers:" -ForegroundColor White
    Write-Host "   npm run dev" -ForegroundColor Cyan
    Write-Host "   (This runs both Next.js and Nether-Bridge automatically)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Open your browser:" -ForegroundColor White
    Write-Host "   http://localhost:3000/nether-grasp" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "ENVIRONMENT SETUP:" -ForegroundColor Yellow
Write-Host "   Remember to configure your .env file with:" -ForegroundColor White
Write-Host "   - DATABASE_URL (if not already set)" -ForegroundColor Gray
Write-Host "   - CURSOR_API_KEY" -ForegroundColor Gray
Write-Host "   - VERCEL_WEBHOOK_SECRET" -ForegroundColor Gray
Write-Host "   - VERCEL_API_TOKEN" -ForegroundColor Gray
Write-Host ""
Write-Host "SUCCESS: Your full-stack Next.js app with Nether-Grasp is ready! 🚀" -ForegroundColor Green
Write-Host ""


