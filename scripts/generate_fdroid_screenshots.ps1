# Generate F-Droid store screenshots (1080x1920) via golden files on Windows.
#
# Usage (from repo root):
#   powershell -ExecutionPolicy Bypass -File scripts/generate_fdroid_screenshots.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

$Flutter = if (Test-Path ".flutter\bin\flutter.bat") { ".\.flutter\bin\flutter.bat" } else { "flutter" }

function Update-GoldenShots {
  param([string]$locale)
  & $Flutter test integration_test/fdroid_screenshots_test.dart -d windows `
    --dart-define=SEED_DEMO=true `
    --dart-define=SCREENSHOT_LOCALE=$locale `
    --update-goldens
}

Update-GoldenShots 'en'
Update-GoldenShots 'ar'

# 512px icon
$iconSrc = Join-Path $Root "assets\icon\app_icon.png"
$iconEn = Join-Path $Root "metadata\en-US\images\icon.png"
$iconAr = Join-Path $Root "metadata\ar\images\icon.png"
New-Item -ItemType Directory -Force -Path (Split-Path $iconEn), (Split-Path $iconAr) | Out-Null
Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile($iconSrc)
$bmp = New-Object System.Drawing.Bitmap 512, 512
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($img, 0, 0, 512, 512)
$bmp.Save($iconEn, [System.Drawing.Imaging.ImageFormat]::Png)
Copy-Item $iconEn $iconAr -Force
$g.Dispose(); $bmp.Dispose(); $img.Dispose()

Write-Host "Done. Review metadata/en-US and metadata/ar images."
