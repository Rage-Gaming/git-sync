# Renders assets/gitwolf-icon.svg to the Windows app icon, cropped to the tile so it fills the
# taskbar like other apps, and to the installer's pictures. Run again after the artwork changes:
#   powershell -ExecutionPolicy Bypass -File windows/tools/make-icon.ps1
# Reads only what that file uses: one rounded rect, then paths and circles in one translate/scale group.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName PresentationCore, WindowsBase

$root = Split-Path (Split-Path $PSScriptRoot)
[xml]$svg = Get-Content -Raw -LiteralPath "$root\assets\gitwolf-icon.svg"
$out = "$root\windows\src\GitWolf.App\Assets\app.ico"
$culture = [Globalization.CultureInfo]::InvariantCulture

function Read-Number($text) { [double]::Parse($text, $culture) }
function Get-Brush($colour) {
    New-Object Windows.Media.SolidColorBrush ([Windows.Media.ColorConverter]::ConvertFromString($colour))
}

$rect = $svg.svg.rect
$group = $svg.svg.g
if ($group.transform -notmatch '^translate\(([\d.]+) ([\d.]+)\) scale\(([\d.]+)\)$') { throw 'Unexpected transform' }
$move = New-Object Windows.Media.TranslateTransform (Read-Number $Matches[1]), (Read-Number $Matches[2])
$grow = New-Object Windows.Media.ScaleTransform (Read-Number $Matches[3]), (Read-Number $Matches[3])
$left = Read-Number $rect.x
$width = Read-Number $rect.width

# The tile and its mark, $size across, drawn at the context's origin.
function Add-Tile($dc, [double]$size) {
    $dc.PushTransform((New-Object Windows.Media.ScaleTransform ($size / $width), ($size / $width)))
    $dc.PushTransform((New-Object Windows.Media.TranslateTransform (-$left), (-$left)))
    $radius = Read-Number $rect.rx
    $tile = New-Object Windows.Rect $left, $left, $width, $width
    $dc.DrawRoundedRectangle((Get-Brush $rect.fill), $null, $tile, $radius, $radius)
    $dc.PushTransform($move)
    $dc.PushTransform($grow)
    foreach ($node in $group.ChildNodes) {
        if ($node.LocalName -eq 'path') {
            # F0 is even-odd and F1 non-zero, which is the SVG default.
            $rule = if ($node.GetAttribute('fill-rule') -eq 'evenodd') { 'F0 ' } else { 'F1 ' }
            $geometry = [Windows.Media.Geometry]::Parse($rule + $node.d)
            $fill = if ($node.fill) { Get-Brush $node.fill }
            $pen = if ($node.stroke) { New-Object Windows.Media.Pen (Get-Brush $node.stroke), 1 }
            $dc.DrawGeometry($fill, $pen, $geometry)
        }
        elseif ($node.LocalName -eq 'circle') {
            $centre = New-Object Windows.Point (Read-Number $node.cx), (Read-Number $node.cy)
            $r = Read-Number $node.r
            $dc.DrawEllipse((Get-Brush $node.fill), $null, $centre, $r, $r)
        }
        else { throw "Unexpected element: $($node.LocalName)" }
    }
    # The tile's two transforms and the mark's two.
    foreach ($i in 1..4) { $dc.Pop() }
}

# A square picture of the tile, on a flat background if given.
function Get-Picture([int]$size, $background, $encoder) {
    $visual = New-Object Windows.Media.DrawingVisual
    $dc = $visual.RenderOpen()
    if ($background) {
        $dc.DrawRectangle((Get-Brush $background), $null, (New-Object Windows.Rect 0, 0, $size, $size))
    }
    Add-Tile $dc $size
    $dc.Close()
    $bitmap = New-Object Windows.Media.Imaging.RenderTargetBitmap $size, $size, 96, 96, ([Windows.Media.PixelFormats]::Pbgra32)
    $bitmap.Render($visual)
    # Inno Setup reads .bmp files without transparency.
    if ($encoder -is [Windows.Media.Imaging.BmpBitmapEncoder]) {
        $bitmap = New-Object Windows.Media.Imaging.FormatConvertedBitmap $bitmap, ([Windows.Media.PixelFormats]::Bgr24), $null, 0
    }
    $encoder.Frames.Add([Windows.Media.Imaging.BitmapFrame]::Create($bitmap))
    $stream = New-Object IO.MemoryStream
    $encoder.Save($stream)
    , $stream.ToArray()
}

# An .ico is a directory of images; each entry here is a PNG.
$sizes = 16, 20, 24, 32, 40, 48, 64, 128, 256
$images = foreach ($size in $sizes) {
    , (Get-Picture $size $null (New-Object Windows.Media.Imaging.PngBitmapEncoder))
}
$file = New-Object IO.MemoryStream
$writer = New-Object IO.BinaryWriter $file
$writer.Write([uint16]0); $writer.Write([uint16]1); $writer.Write([uint16]$sizes.Count)
$offset = 6 + 16 * $sizes.Count
for ($i = 0; $i -lt $sizes.Count; $i++) {
    $side = [byte]($sizes[$i] % 256) # 0 stands for 256
    $writer.Write($side); $writer.Write($side); $writer.Write([byte]0); $writer.Write([byte]0)
    $writer.Write([uint16]1); $writer.Write([uint16]32)
    $writer.Write([uint32]$images[$i].Length); $writer.Write([uint32]$offset)
    $offset += $images[$i].Length
}
foreach ($image in $images) { $writer.Write([byte[]]$image) }
$writer.Flush()
[IO.File]::WriteAllBytes($out, $file.ToArray())
"Wrote $out ($($file.Length) bytes)"

# The installer's logo, at the common display scalings, on its window colour (WizardBackColor).
foreach ($scale in 1, 1.5, 2) {
    $path = "$root\windows\installer\logo-$($scale * 100).bmp"
    $bytes = Get-Picture (96 * $scale) '#1E1F25' (New-Object Windows.Media.Imaging.BmpBitmapEncoder)
    [IO.File]::WriteAllBytes($path, $bytes)
    "Wrote $path ($($bytes.Length) bytes)"
}
