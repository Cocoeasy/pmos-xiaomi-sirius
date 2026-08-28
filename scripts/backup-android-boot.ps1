# Copy this phone's current Android boot (and recovery/dtbo if present)
# to hardware/dump/ (gitignored). Run before flashing a Linux boot.
#
# Root on this phone cannot write /data/local/tmp or /sdcard (SELinux),
# so images are streamed with adb exec-out.
param(
    [string]$Adb = "D:\Android\platform-tools\adb.exe"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
if (-not (Test-Path $Adb)) {
    $found = Get-Command adb -ErrorAction SilentlyContinue
    if (-not $found) { throw "adb not found. Pass -Adb" }
    $Adb = $found.Source
}

$serials = & $Adb devices | Select-String "\tdevice$"
if (-not $serials) {
    Write-Host "No authorized device."
    exit 2
}

$id = & $Adb shell "su -c id"
if ($id -notmatch "uid=0") {
    Write-Host "Need root. Grant Shell in SukiSU."
    exit 3
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$out = Join-Path $Root "hardware\dump\$stamp-android-boot-backup"
New-Item -ItemType Directory -Force -Path $out | Out-Null
$map = Join-Path $out "map.txt"

function Pull-Partition([string]$Name) {
    $src = (& $Adb shell su -c "readlink -f /dev/block/by-name/$Name").Trim()
    if (-not $src -or $src -match "No such file") {
        Write-Host "skip $Name (no by-name node)"
        return
    }
    $expect = [int64]((& $Adb shell su -c "blockdev --getsize64 $src").Trim())
    $dest = Join-Path $out "$Name.img"
    Write-Host "copying $Name $src ($expect bytes)"

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $Adb
    $psi.Arguments = "exec-out su -c `"dd if=$src bs=4096 2>/dev/null`""
    $psi.RedirectStandardOutput = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $p = [Diagnostics.Process]::Start($psi)
    $fs = [IO.File]::Create($dest)
    $p.StandardOutput.BaseStream.CopyTo($fs)
    $fs.Close()
    $p.WaitForExit()
    if ($p.ExitCode -ne 0) { throw "exec-out dd failed for $Name" }

    $got = (Get-Item $dest).Length
    if ($got -ne $expect) {
        throw "$Name size mismatch: got $got expected $expect"
    }
    $hash = (Get-FileHash $dest -Algorithm SHA256).Hash
    $line = "$Name $src $got $hash"
    Add-Content -Path $map -Value $line
    Add-Content -Path (Join-Path $out "SHA256.txt") -Value ("{0}  {1}  {2}" -f $got, $hash, "$Name.img")
    Write-Host $line
}

foreach ($n in @("boot", "recovery", "dtbo")) {
    Pull-Partition $n
}

$boot = Join-Path $out "boot.img"
if (-not (Test-Path $boot)) { throw "boot.img was not copied" }
$hdr = [IO.File]::ReadAllBytes($boot)[0..7]
$magic = [Text.Encoding]::ASCII.GetString($hdr)
if ($magic -ne "ANDROID!") { throw "boot.img magic is '$magic', expected ANDROID!" }

Write-Host "Saved (gitignored) at $out"
Write-Host "To restore later: fastboot flash boot boot.img"
