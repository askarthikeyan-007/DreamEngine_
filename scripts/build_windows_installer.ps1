# Build script to generate DreamEngine AI Windows Setup Installer

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Building DreamEngine AI Windows Setup   " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Set-Location $ProjectRoot

Write-Host "`n[1/3] Building Flutter Windows Release..." -ForegroundColor Green
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter release build failed."
    exit $LASTEXITCODE
}

Write-Host "`n[2/3] Locating Inno Setup Compiler (ISCC)..." -ForegroundColor Green
$ISCC_PATHS = @(
    "iscc.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 6\ISCC.exe",
    "${env:LocalAppData}\Programs\Inno Setup 6\ISCC.exe"
)

$IsccExe = $null
foreach ($path in $ISCC_PATHS) {
    if (Get-Command $path -ErrorAction SilentlyContinue) {
        $IsccExe = $path
        break
    }
    if (Test-Path $path) {
        $IsccExe = $path
        break
    }
}

if (-not $IsccExe) {
    Write-Error "Inno Setup Compiler (ISCC.exe) not found. Please install Inno Setup 6 (e.g. winget install JRSoftware.InnoSetup)."
    exit 1
}

Write-Host "Found Inno Setup at: $IsccExe" -ForegroundColor Gray

Write-Host "`n[3/3] Compiling Windows Setup Installer..." -ForegroundColor Green
$IssPath = Join-Path $ProjectRoot "windows\installer\dream_engine_ai_setup.iss"
& $IsccExe "$IssPath"

if ($LASTEXITCODE -eq 0) {
    $OutputDir = Join-Path $ProjectRoot "build\installer"
    Write-Host "`n=========================================" -ForegroundColor Cyan
    Write-Host " SUCCESS! Installer generated in:" -ForegroundColor Green
    Write-Host " $OutputDir" -ForegroundColor Yellow
    Write-Host "=========================================" -ForegroundColor Cyan
    Get-ChildItem -Path $OutputDir -Filter "*.exe" | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize
} else {
    Write-Error "Failed to compile Inno Setup script."
    exit $LASTEXITCODE
}
