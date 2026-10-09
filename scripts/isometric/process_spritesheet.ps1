Add-Type -AssemblyName System.Drawing

$srcPath = "d:\GoDotProjects\life-simulator-isometric\assets\isometric\characters\Pixel-Art Isometric Walking Sprite Sheet.png"
if (-not (Test-Path $srcPath)) {
    Write-Error "Source file not found: $srcPath"
    exit 1
}

$bmp = [System.Drawing.Bitmap]::FromFile($srcPath)
$outDir = "d:\GoDotProjects\life-simulator-isometric\assets\isometric\characters\processed"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$rows = @(
    @{ymin=25; ymax=330},
    @{ymin=335; ymax=632},
    @{ymin=635; ymax=925},
    @{ymin=930; ymax=1235}
)
$cols = @(
    @{xmin=90; xmax=260},
    @{xmin=390; xmax=550},
    @{xmin=705; xmax=870},
    @{xmin=1005; xmax=1175}
)

$targetW = 160
$targetH = 320
$baselineY = 308 # Ground baseline for character feet

function Process-Frame($r, $c) {
    $minX = 9999; $maxX = -1; $minY = 9999; $maxY = -1
    for ($y = $rows[$r].ymin; $y -lt $rows[$r].ymax; $y++) {
        for ($x = $cols[$c].xmin; $x -lt $cols[$c].xmax; $x++) {
            $p = $bmp.GetPixel($x, $y)
            if ($p.A -gt 15) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    
    $charW = $maxX - $minX + 1
    $charH = $maxY - $minY + 1
    
    $destBmp = New-Object System.Drawing.Bitmap($targetW, $targetH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($destBmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    
    $destX = [int][math]::Round(($targetW - $charW) / 2.0)
    $destY = $baselineY - $charH
    
    $srcRect = [System.Drawing.Rectangle]::FromLTRB($minX, $minY, $maxX + 1, $maxY + 1)
    $destRect = New-Object System.Drawing.Rectangle($destX, $destY, $charW, $charH)
    
    $g.DrawImage($bmp, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    
    return $destBmp
}

# 1. Row 0: walk_se
for ($c = 0; $c -lt 4; $c++) {
    $frame = Process-Frame 0 $c
    $frame.Save("$outDir\walk_se_$c.png", [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Horizontally flipped for walk_sw
    $flipped = [System.Drawing.Bitmap]$frame.Clone()
    $flipped.RotateFlip([System.Drawing.RotateFlipType]::RotateNoneFlipX)
    $flipped.Save("$outDir\walk_sw_$c.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $flipped.Dispose()
    $frame.Dispose()
}

# 2. Row 2: walk_ne
for ($c = 0; $c -lt 4; $c++) {
    $frame = Process-Frame 2 $c
    $frame.Save("$outDir\walk_ne_$c.png", [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Horizontally flipped for walk_nw
    $flipped = [System.Drawing.Bitmap]$frame.Clone()
    $flipped.RotateFlip([System.Drawing.RotateFlipType]::RotateNoneFlipX)
    $flipped.Save("$outDir\walk_nw_$c.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $flipped.Dispose()
    $frame.Dispose()
}

# 3. Idle poses:
# idle_se uses frame [0, 3] (standing upright with feet together)
$idleSe = Process-Frame 0 3
$idleSe.Save("$outDir\idle_se.png", [System.Drawing.Imaging.ImageFormat]::Png)
$idleSw = [System.Drawing.Bitmap]$idleSe.Clone()
$idleSw.RotateFlip([System.Drawing.RotateFlipType]::RotateNoneFlipX)
$idleSw.Save("$outDir\idle_sw.png", [System.Drawing.Imaging.ImageFormat]::Png)
$idleSe.Dispose()
$idleSw.Dispose()

# idle_ne uses frame [2, 3] (standing upright facing away)
$idleNe = Process-Frame 2 3
$idleNe.Save("$outDir\idle_ne.png", [System.Drawing.Imaging.ImageFormat]::Png)
$idleNw = [System.Drawing.Bitmap]$idleNe.Clone()
$idleNw.RotateFlip([System.Drawing.RotateFlipType]::RotateNoneFlipX)
$idleNw.Save("$outDir\idle_nw.png", [System.Drawing.Imaging.ImageFormat]::Png)
$idleNe.Dispose()
$idleNw.Dispose()

$bmp.Dispose()
Write-Host "All animation frames processed and saved to $outDir successfully."
