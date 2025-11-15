# Nether-Grasp Installer Launcher
# This script prompts for a target directory and runs the installer

param(
    [switch]$Help
)

# Force console output to be visible
$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"

# Test if we can write to console
try {
    Write-Output "Starting Nether-Grasp Installer..."
    [Console]::WriteLine("Initializing...")
}
catch {
    # Fallback if console methods fail
}

if ($Help) {
    Write-Host @"
=============================================================
         NETHER-GRASP INSTALLER LAUNCHER
=============================================================

This launcher will:
  1. Prompt you for where to create your new project
  2. Run the Nether-Grasp installer automatically

Usage: .\NetherGraspInstaller.ps1
   Or: Double-click NetherGraspInstaller.exe

"@
    Read-Host "Press Enter to exit"
    exit 0
}

# Set console title
try {
    $host.UI.RawUI.WindowTitle = "Nether-Grasp Installer"
}
catch {
    # Ignore if we can't set title
}

# Clear screen for better visibility
Clear-Host

Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "         NETHER-GRASP INSTALLER LAUNCHER" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will help you install Nether-Grasp into a new project." -ForegroundColor White
Write-Host ""

# Get the directory where this launcher script is located (source directory)
$SourcePath = if ($PSScriptRoot) { 
    $PSScriptRoot 
} elseif ($MyInvocation.MyCommand.Path) { 
    Split-Path -Parent $MyInvocation.MyCommand.Path 
} else { 
    Get-Location 
}

Write-Host "[DEBUG] Script location: $SourcePath" -ForegroundColor Gray
Write-Host ""

# Prompt for target directory
Write-Host "Where would you like to create your new project?" -ForegroundColor Yellow
Write-Host "Please provide the FULL PATH where the project should be created." -ForegroundColor White
Write-Host ""
Write-Host "Example: C:\Users\YourName\Projects" -ForegroundColor Gray
Write-Host "         (The T3 App will be created inside this directory)" -ForegroundColor Gray
Write-Host ""

$targetDirectory = Read-Host "Target Directory"
Write-Host ""

# Validate input
if ([string]::IsNullOrWhiteSpace($targetDirectory)) {
    Write-Host "[ERROR] Target directory is required!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Expand environment variables if present (e.g., %USERPROFILE%)
$targetDirectory = [System.Environment]::ExpandEnvironmentVariables($targetDirectory)

# Check if target directory exists
if (-not (Test-Path $targetDirectory)) {
    Write-Host "[ERROR] Target directory does not exist: $targetDirectory" -ForegroundColor Red
    Write-Host "[NOTE] Please create the directory first or use an existing one." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Confirm with user
Write-Host "[INFO] Configuration:" -ForegroundColor Cyan
Write-Host "   Source: $SourcePath" -ForegroundColor White
Write-Host "   Target: $targetDirectory" -ForegroundColor White
Write-Host ""
Write-Host "The installer will now:" -ForegroundColor Yellow
Write-Host "   1. Create a new T3 App in the target directory" -ForegroundColor White
Write-Host "   2. Install Nether-Grasp components" -ForegroundColor White
Write-Host "   3. Configure your project" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Continue? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host ""
    Write-Host "[CANCELLED] Installation cancelled by user." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

Write-Host ""
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""

# Change to target directory
try {
    Set-Location $targetDirectory
    Write-Host "[OK] Changed to target directory: $targetDirectory" -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host "[ERROR] Could not change to target directory: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Run the installer script
$installerScript = Join-Path $SourcePath "install-nether-grasp.ps1"

if (-not (Test-Path $installerScript)) {
    Write-Host "[ERROR] Installer script not found: $installerScript" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "[INFO] Running installer script..." -ForegroundColor Cyan
Write-Host ""

try {
    # Run the installer script
    & $installerScript
    
    $exitCode = $LASTEXITCODE
    
    Write-Host ""
    Write-Host "=============================================================" -ForegroundColor Cyan
    
    if ($exitCode -eq 0) {
        Write-Host "[SUCCESS] Installation completed!" -ForegroundColor Green
    }
    else {
        Write-Host "[WARNING] Installation completed with warnings (exit code: $exitCode)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit $exitCode
}
catch {
    Write-Host ""
    Write-Host "=============================================================" -ForegroundColor Cyan
    Write-Host "[ERROR] Installation failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

