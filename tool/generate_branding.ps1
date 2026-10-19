# Rebuild native branding without changing the approved source PNG.
# Run from the repository root: pwsh -File tool/generate_branding.ps1
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing.Common,System.Drawing.Primitives,System.Private.Windows.GdiPlus,System.Private.Windows.Core,System.Collections -TypeDefinition @"
using System;
using System.IO;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

public static class OynikaBranding {
    // Render the extracted tile through a clean rounded boundary so no matte
    // fragments from background extraction reach the app or native icon assets.
    public static void BorderlessTile(string input, string output) {
        using (var image = new Bitmap(input)) {
            int inset = (int)Math.Round(image.Width * .0303);
            int size = image.Width - inset * 2;
            int radius = (int)Math.Round(size * .213);
            using (var tile = new Bitmap(size, size, PixelFormat.Format32bppArgb))
            using (var g = Graphics.FromImage(tile))
            using (var path = new GraphicsPath()) {
                g.Clear(Color.Transparent);
                g.SmoothingMode = SmoothingMode.AntiAlias;
                int d = radius * 2;
                path.AddArc(0, 0, d, d, 180, 90);
                path.AddArc(size-d, 0, d, d, 270, 90);
                path.AddArc(size-d, size-d, d, d, 0, 90);
                path.AddArc(0, size-d, d, d, 90, 90);
                path.CloseFigure();
                g.SetClip(path);
                g.DrawImage(image, new Rectangle(0, 0, size, size),
                    new Rectangle(inset, inset, size, size), GraphicsUnit.Pixel);
                tile.Save(output, ImageFormat.Png);
            }
        }
    }
    public static Bitmap Compose(Image source, int size, int content, bool opaque, bool creamBackground = false) {
        var output = new Bitmap(size, size, PixelFormat.Format32bppArgb);
        using (var g = Graphics.FromImage(output)) {
            g.Clear(opaque ? (creamBackground ? Color.FromArgb(255, 249, 241) : Color.White) : Color.Transparent);
            g.CompositingQuality = CompositingQuality.HighQuality;
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;
            g.SmoothingMode = SmoothingMode.HighQuality;
            g.PixelOffsetMode = PixelOffsetMode.HighQuality;
            int inset = (size - content) / 2;
            using (var attributes = new ImageAttributes()) {
                attributes.SetWrapMode(WrapMode.TileFlipXY);
                g.DrawImage(source, new Rectangle(inset, inset, content, content),
                    0, 0, source.Width, source.Height, GraphicsUnit.Pixel, attributes);
            }
        }
        return output;
    }

    public static void Save(Image source, string path, int size, int content, bool opaque, bool creamBackground = false) {
        Directory.CreateDirectory(Path.GetDirectoryName(path));
        using (var image = Compose(source, size, content, opaque, creamBackground)) {
            if (opaque) {
                using (var rgb = new Bitmap(size, size, PixelFormat.Format24bppRgb)) {
                    using (var g = Graphics.FromImage(rgb)) { g.Clear(creamBackground ? Color.FromArgb(255, 249, 241) : Color.White); g.DrawImage(image, 0, 0); }
                    rgb.Save(path, ImageFormat.Png);
                }
            } else { image.Save(path, ImageFormat.Png); }
        }
    }

    // A separate alpha silhouette of the central word, smile and confetti.
    // Colored corner/background fields are intentionally excluded from themed icons.
    public static Bitmap Monochrome(Bitmap source) {
        var mask = new Bitmap(source.Width, source.Height, PixelFormat.Format32bppArgb);
        int left = (int)(source.Width * .10), right = (int)(source.Width * .90);
        int top = (int)(source.Height * .23), bottom = (int)(source.Height * .76);
        var active = new bool[source.Width * source.Height];
        for (int y = top; y <= bottom; y++)
            for (int x = left; x <= right; x++) {
                var c = source.GetPixel(x, y);
                int max = Math.Max(c.R, Math.Max(c.G, c.B));
                int min = Math.Min(c.R, Math.Min(c.G, c.B));
                active[y * source.Width + x] = c.A > 0 && (max - min > 65 || max < 150);
            }
        // Discard corner/background components intersecting the crop boundary.
        // Retain the complete, enclosed logo glyphs and decorative strokes.
        for (int y = top; y <= bottom; y++)
            for (int x = left; x <= right; x++) {
                int start = y * source.Width + x;
                if (!active[start]) continue;
                var queue = new Queue<int>();
                var component = new List<int>();
                bool boundary = false;
                queue.Enqueue(start); active[start] = false;
                while (queue.Count > 0) {
                    int index = queue.Dequeue(), cx = index % source.Width, cy = index / source.Width;
                    component.Add(index);
                    if (cx == left || cx == right || cy == top || cy == bottom) boundary = true;
                    foreach (int next in new int[] { index - 1, index + 1, index - source.Width, index + source.Width }) {
                        int nx = next % source.Width, ny = next / source.Width;
                        if (nx < left || nx > right || ny < top || ny > bottom || !active[next]) continue;
                        active[next] = false; queue.Enqueue(next);
                    }
                }
                if (!boundary && component.Count > 8)
                    foreach (int index in component) {
                        int cx = index % source.Width, cy = index / source.Width;
                        mask.SetPixel(cx, cy, Color.FromArgb(source.GetPixel(cx, cy).A, 255, 255, 255));
                    }
            }
        return mask;
    }

    public static void Preview(Bitmap foreground, string path, string shape, bool themed) {
        int size = 360;
        using (var output = new Bitmap(size, size, PixelFormat.Format32bppArgb)) {
            // An adaptive layer's visible viewport is the central 72 / 108.
            for (int y = 0; y < size; y++)
                for (int x = 0; x < size; x++) {
                    double dx = (x + .5 - size / 2.0) / (size / 2.0);
                    double dy = (y + .5 - size / 2.0) / (size / 2.0);
                    bool inside = shape == "circle" ? dx * dx + dy * dy <= 1
                        : shape == "squircle" ? Math.Pow(Math.Abs(dx), 4) + Math.Pow(Math.Abs(dy), 4) <= 1
                        : Math.Pow(Math.Max(Math.Abs(dx) - .65, 0), 2) +
                          Math.Pow(Math.Max(Math.Abs(dy) - .65, 0), 2) <= .35 * .35;
                    if (!inside) continue;
                    int sx = (int)(foreground.Width / 6.0 + x * (foreground.Width * 2.0 / 3.0) / size);
                    int sy = (int)(foreground.Height / 6.0 + y * (foreground.Height * 2.0 / 3.0) / size);
                    var c = foreground.GetPixel(Math.Min(sx, foreground.Width - 1), Math.Min(sy, foreground.Height - 1));
                    var bg = themed ? Color.FromArgb(232, 221, 251) : Color.FromArgb(255, 249, 241);
                    var fg = themed ? Color.FromArgb(70, 48, 155) : Color.FromArgb(c.R, c.G, c.B);
                    double alpha = c.A / 255.0;
                    output.SetPixel(x, y, Color.FromArgb(255,
                        (int)(fg.R * alpha + bg.R * (1-alpha)),
                        (int)(fg.G * alpha + bg.G * (1-alpha)),
                        (int)(fg.B * alpha + bg.B * (1-alpha))));
                }
            output.Save(path, ImageFormat.Png);
        }
    }
}
"@

$logoPath = Join-Path $projectRoot 'assets/branding/oynika_logo.png'
if (-not (Test-Path -LiteralPath $logoPath)) { throw "Approved logo missing: $logoPath" }
$sourceHash = (Get-FileHash -LiteralPath $logoPath -Algorithm SHA256).Hash
$sourceImage = [System.Drawing.Bitmap]::FromFile($logoPath)
$borderlessPath = Join-Path $projectRoot 'assets/branding/oynika_logo_borderless.png'
[OynikaBranding]::BorderlessTile((Join-Path $projectRoot 'design_reference/oynika_logo_cutout.png'), $borderlessPath)
if (-not (Test-Path -LiteralPath $borderlessPath)) { $sourceImage.Dispose(); throw "Borderless logo missing: $borderlessPath" }
$borderlessImage = [System.Drawing.Bitmap]::FromFile($borderlessPath)
try {
    if ($sourceImage.Width -ne $sourceImage.Height) { throw 'The approved icon source must be square.' }
    $androidRoot = Join-Path $projectRoot 'android/app/src/main/res'
    $densities = @(@('mdpi',1.0), @('hdpi',1.5), @('xhdpi',2.0), @('xxhdpi',3.0), @('xxxhdpi',4.0))
    $monoSource = [OynikaBranding]::Monochrome($sourceImage)
    try {
        foreach ($density in $densities) {
            $name = $density[0]
            $scale = [double]$density[1]
            [OynikaBranding]::Save($borderlessImage, "$androidRoot/mipmap-$name/ic_launcher.png", [int](48*$scale), [int](48*$scale), $true, $true)
            # Fill the 72 dp masked viewport; central word/confetti remain within its safe region.
            [OynikaBranding]::Save($borderlessImage, "$androidRoot/drawable-$name/ic_launcher_foreground.png", [int](108*$scale), [int](72*$scale), $false)
            [OynikaBranding]::Save($monoSource, "$androidRoot/drawable-$name/ic_launcher_monochrome.png", [int](108*$scale), [int](60*$scale), $false)
            [OynikaBranding]::Save($sourceImage, "$androidRoot/drawable-$name/splash_logo.png", [int](144*$scale), [int](144*$scale), $true)
            # Android 12+: full square inside the system's 192 dp diameter circle.
            [OynikaBranding]::Save($sourceImage, "$androidRoot/drawable-$name/splash_icon.png", [int](288*$scale), [int](128*$scale), $false)
        }

        $iosIcons = Join-Path $projectRoot 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
        $catalog = Get-Content -Raw "$iosIcons/Contents.json" | ConvertFrom-Json
        foreach ($entry in $catalog.images) {
            $pointSize = [double]($entry.size.Split('x')[0])
            $scale = [double]$entry.scale.TrimEnd('x')
            $size = [int]($pointSize * $scale)
            [OynikaBranding]::Save($borderlessImage, "$iosIcons/$($entry.filename)", $size, $size, $true, $true)
        }
        $iosLaunch = Join-Path $projectRoot 'ios/Runner/Assets.xcassets/LaunchImage.imageset'
        foreach ($scale in 1..3) {
            $name = if ($scale -eq 1) { 'LaunchImage.png' } else { "LaunchImage@${scale}x.png" }
            [OynikaBranding]::Save($sourceImage, "$iosLaunch/$name", 168*$scale, 168*$scale, $true)
        }

        $previewDir = Join-Path $projectRoot 'build/branding-verification'
        New-Item -ItemType Directory -Force $previewDir | Out-Null
        $foreground = [System.Drawing.Bitmap]::FromFile("$androidRoot/drawable-xxxhdpi/ic_launcher_foreground.png")
        $monochrome = [System.Drawing.Bitmap]::FromFile("$androidRoot/drawable-xxxhdpi/ic_launcher_monochrome.png")
        try {
            foreach ($shape in @('circle','squircle','rounded-square')) {
                [OynikaBranding]::Preview($foreground, "$previewDir/adaptive-$shape.png", $shape, $false)
            }
            [OynikaBranding]::Preview($monochrome, "$previewDir/themed-circle.png", 'circle', $true)
        } finally { $foreground.Dispose(); $monochrome.Dispose() }
    } finally { $monoSource.Dispose() }
} finally { $borderlessImage.Dispose(); $sourceImage.Dispose() }
if ((Get-FileHash -LiteralPath $logoPath -Algorithm SHA256).Hash -ne $sourceHash) { throw 'Source logo changed.' }
Write-Output "Generated Android/iOS icons and splash assets. Source SHA256: $sourceHash"
