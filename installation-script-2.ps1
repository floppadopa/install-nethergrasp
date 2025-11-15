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

# Ask if this is an upgrade or new installation
Write-Host "Is this for an upgrade/re-install or a new installation?" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [1] New Installation - Create a new T3 App + install Nether-Grasp" -ForegroundColor White
Write-Host "  [2] Upgrade/Re-install - Update Nether-Grasp in an existing project" -ForegroundColor White
Write-Host ""
$installType = Read-Host "Enter your choice (1 or 2)"
Write-Host ""

if ($installType -eq "2") {
    # UPGRADE MODE
    Write-Host "=============================================================" -ForegroundColor Cyan
    Write-Host "         UPGRADE MODE - RE-INSTALL NETHER-GRASP" -ForegroundColor Cyan
    Write-Host "=============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This will re-install/update Nether-Grasp files in your existing project." -ForegroundColor White
    Write-Host "Existing Nether-Grasp files will be OVERWRITTEN." -ForegroundColor Yellow
    Write-Host ""
    
    # Ask for existing project directory
    Write-Host "Enter the FULL PATH to your existing project:" -ForegroundColor Yellow
    Write-Host "Example: C:\Users\YourName\Projects\my-existing-project" -ForegroundColor Gray
    Write-Host ""
    $existingProjectPath = Read-Host "Existing Project Directory"
    Write-Host ""
    
    # Validate path
    if ([string]::IsNullOrWhiteSpace($existingProjectPath)) {
        Write-Host "[ERROR] Project path is required!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    
    # Expand environment variables
    $existingProjectPath = [System.Environment]::ExpandEnvironmentVariables($existingProjectPath)
    
    # Check if directory exists
    if (-not (Test-Path $existingProjectPath)) {
        Write-Host "[ERROR] Directory does not exist: $existingProjectPath" -ForegroundColor Red
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    
    # Confirm
    Write-Host "[INFO] Target project: $existingProjectPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[WARNING] This will overwrite existing Nether-Grasp files!" -ForegroundColor Yellow
    $confirm = Read-Host "Continue with upgrade? (Y/N)"
    
    if ($confirm -ne "Y" -and $confirm -ne "y") {
        Write-Host ""
        Write-Host "[CANCELLED] Upgrade cancelled by user." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 0
    }
    
    Write-Host ""
    Write-Host "=============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Change to existing project directory
    try {
        Set-Location $existingProjectPath
        Write-Host "[OK] Changed to project directory: $existingProjectPath" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host "[ERROR] Could not change to project directory: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    
    # Run installer in ReInstall mode
    $installerScript = Join-Path $SourcePath "installation-script.ps1"
    
    if (-not (Test-Path $installerScript)) {
        Write-Host "[ERROR] Installer script not found: $installerScript" -ForegroundColor Red
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
    
    Write-Host "[INFO] Running installer in upgrade mode..." -ForegroundColor Cyan
    Write-Host ""
    
    try {
        # Run with -ReInstall flag
        & $installerScript -ReInstall
        
        $exitCode = $LASTEXITCODE
        
        Write-Host ""
        Write-Host "=============================================================" -ForegroundColor Cyan
        
        if ($exitCode -eq 0) {
            Write-Host "[SUCCESS] Upgrade completed!" -ForegroundColor Green
        }
        else {
            Write-Host "[WARNING] Upgrade completed with warnings (exit code: $exitCode)" -ForegroundColor Yellow
        }
        
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit $exitCode
    }
    catch {
        Write-Host ""
        Write-Host "=============================================================" -ForegroundColor Cyan
        Write-Host "[ERROR] Upgrade failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Press any key to exit..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 1
    }
}
elseif ($installType -ne "1") {
    Write-Host "[ERROR] Invalid choice. Please enter 1 or 2." -ForegroundColor Red
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Continue with NEW INSTALLATION mode
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "         NEW INSTALLATION MODE" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will create a new T3 App and install Nether-Grasp." -ForegroundColor White
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
$installerScript = Join-Path $SourcePath "installation-script.ps1"

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

