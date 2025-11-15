# Copy Nether-Grasp Files Script
# Copies all Nether-Grasp related files to the installation folder

$SourcePath = "C:\Users\louis\Desktop\edu_luden_fr"
$TargetPath = "C:\Users\louis\Desktop\install-nether-grasp"

Write-Host "Copying Nether-Grasp files..." -ForegroundColor Cyan
Write-Host ""

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
        
        if (Test-Path $Source) {
            Copy-Item -Path $Source -Destination $Destination -Force
            $script:filescopied++
            Write-Host "  [OK] $Source" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "  [SKIP] Not found: $Source" -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "  [ERROR] Failed to copy: $Source" -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
        $script:errors++
        return $false
    }
}

# All files to copy
$allFiles = @(
    # Frontend Components
    "src\app\nether-grasp\page.tsx",
    "src\app\nether-grasp\_css\page.css",
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
    "src\components\nether_grasp\navbar\_css\TopPart.css",
    
    # API Routes
    "src\app\api\nether-grasp\save-files\route.ts",
    "src\app\api\nether-grasp\tasks\route.ts",
    "src\app\api\webhooks\vercel\route.ts",
    
    # Bridge Server
    "nether-bridge-server.js",
    
    # Assets
    "public\nether-grasp-logo.png",
    "public\nether-grasp.png",
    "public\fonts\pixelgrid-squarebolds.woff",
    "public\fonts\pixelgrid-squareboldm.woff",
    "public\fonts\pixelgrid-squareboldxl.woff",
    
    # Cursor Configuration
    ".cursor\AI_CHECKLIST.md",
    ".cursor\rules\rules.mdc",
    
    # Prisma Schema
    "prisma\schema.prisma"
)

Write-Host "Copying files from source to installation folder..." -ForegroundColor Yellow
Write-Host ""

foreach ($file in $allFiles) {
    $source = Join-Path $SourcePath $file
    $destination = Join-Path $TargetPath $file
    Copy-FileWithCheck $source $destination | Out-Null
}

Write-Host ""
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "   COPY COMPLETE" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files copied: $filescopied" -ForegroundColor Green
if ($errors -gt 0) {
    Write-Host "Errors: $errors" -ForegroundColor Red
}
Write-Host ""

