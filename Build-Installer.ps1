# Build script to convert PowerShell script to EXE
# This uses ps2exe module to create the executable

Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host "         NETHER-GRASP INSTALLER BUILD SCRIPT" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""

# Check if ps2exe is installed
$ps2exeModule = Get-Module -ListAvailable -Name ps2exe

if (-not $ps2exeModule) {
    Write-Host "[INFO] ps2exe module not found. Installing..." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber
        Write-Host "[OK] ps2exe module installed successfully" -ForegroundColor Green
        Write-Host ""
    }
    catch {
        Write-Host "[ERROR] Failed to install ps2exe module: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please install manually:" -ForegroundColor Yellow
        Write-Host "   Install-Module -Name ps2exe -Scope CurrentUser" -ForegroundColor White
        Write-Host ""
        exit 1
    }
}
else {
    Write-Host "[OK] ps2exe module is already installed" -ForegroundColor Green
    Write-Host ""
}

# Import the module
try {
    Import-Module ps2exe
    Write-Host "[OK] ps2exe module imported" -ForegroundColor Green
    Write-Host ""
}
catch {
    Write-Host "[ERROR] Failed to import ps2exe module: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Build the executable
$scriptPath = Join-Path $PSScriptRoot "NetherGraspInstaller.ps1"
$exePath = Join-Path $PSScriptRoot "NetherGraspInstaller.exe"

if (-not (Test-Path $scriptPath)) {
    Write-Host "[ERROR] Source script not found: $scriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Building executable..." -ForegroundColor Yellow
Write-Host "   Source: $scriptPath" -ForegroundColor White
Write-Host "   Output: $exePath" -ForegroundColor White
Write-Host ""

try {
    ps2exe `
        -inputFile $scriptPath `
        -outputFile $exePath `
        -title "Nether-Grasp Installer" `
        -description "Nether-Grasp Automated Installer" `
        -company "Nether-Grasp" `
        -product "Nether-Grasp Installer" `
        -version "1.0.0.0" `
        -requireAdmin:$false `
        -verbose
    
    if (Test-Path $exePath) {
        Write-Host ""
        Write-Host "=============================================================" -ForegroundColor Cyan
        Write-Host "[SUCCESS] Executable created successfully!" -ForegroundColor Green
        Write-Host "=============================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Output file: $exePath" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "You can now:" -ForegroundColor Yellow
        Write-Host "   1. Double-click NetherGraspInstaller.exe to run" -ForegroundColor White
        Write-Host "   2. Share this directory with others" -ForegroundColor White
        Write-Host ""
    }
    else {
        Write-Host ""
        Write-Host "[ERROR] Executable was not created" -ForegroundColor Red
        Write-Host ""
        exit 1
    }
}
catch {
    Write-Host ""
    Write-Host "[ERROR] Failed to build executable: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try running manually:" -ForegroundColor Yellow
    Write-Host "   ps2exe -inputFile NetherGraspInstaller.ps1 -outputFile NetherGraspInstaller.exe" -ForegroundColor White
    Write-Host ""
    exit 1
}

