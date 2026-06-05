#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"

$FuzzyPackage = "@fuzzyos/fuzzy-code"
$FuzzyCmd = "fuzzy"
# Fuzzy publishes npm-shrinkwrap.json, so the explicit installer/reinstaller can
# bypass npm's release-age gate without reopening transitive dependency ranges.
$NpmMinReleaseAgeArg = "--min-release-age=0"
$NodeMinimum = [version]"22.19.0"
$FuzzyEsc = [char]27
$FuzzyCr = [char]13

function Write-InstallerTitle {
  if (Test-InstallerAnsiOutput) {
    [Console]::Write("${FuzzyEsc}[1m  Fuzzy Installer${FuzzyEsc}[0m`n${FuzzyEsc}[2m  There are many code harnesses, but this one is mine.${FuzzyEsc}[0m`n`n")
  } else {
    Write-Host ""
    Write-Host "  Fuzzy Installer"
    Write-Host "  There are many code harnesses, but this one is mine."
    Write-Host ""
  }
}

function Test-InstallerInteractiveOutput {
  return (-not [Console]::IsOutputRedirected) -and ($env:TERM -ne "dumb")
}

function Enable-VirtualTerminalOutput {
  if (-not (Test-InstallerInteractiveOutput)) {
    return $false
  }

  if ($null -ne $script:FuzzyVirtualTerminalEnabled) {
    return $script:FuzzyVirtualTerminalEnabled
  }

  if (-not ("ConsoleMode.NativeMethods" -as [Type])) {
    Add-Type -Namespace ConsoleMode -Name NativeMethods -MemberDefinition @"
[DllImport("kernel32.dll", SetLastError = true)]
public static extern System.IntPtr GetStdHandle(int nStdHandle);

[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool GetConsoleMode(System.IntPtr hConsoleHandle, out uint lpMode);

[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool SetConsoleMode(System.IntPtr hConsoleHandle, uint dwMode);
"@
  }

  $stdOutputHandle = -11
  $enableVirtualTerminalProcessing = 0x0004
  $handle = [ConsoleMode.NativeMethods]::GetStdHandle($stdOutputHandle)
  $mode = [uint32]0
  $script:FuzzyVirtualTerminalEnabled = [ConsoleMode.NativeMethods]::GetConsoleMode($handle, [ref]$mode) -and [ConsoleMode.NativeMethods]::SetConsoleMode($handle, ($mode -bor $enableVirtualTerminalProcessing))
  return $script:FuzzyVirtualTerminalEnabled
}

function Test-InstallerAnsiOutput {
  return Enable-VirtualTerminalOutput
}

function Test-InstallerInteractiveInput {
  return -not [Console]::IsInputRedirected
}

function Test-TerminalSupportsUnicode {
  $locale = "$env:LC_ALL$env:LC_CTYPE$env:LANG"
  if ($locale -match "(?i)utf-?8") {
    return $true
  }

  if ($env:TERM_PROGRAM -in @("Apple_Terminal", "iTerm.app", "vscode", "WezTerm")) {
    return $true
  }

  if ($env:WT_SESSION -or $env:TERMINAL_EMULATOR) {
    return $true
  }

  return $false
}

function Get-SpinnerFrame {
  param([int]$Step)

  switch ($Step % 4) {
    0 { return "-" }
    1 { return "\" }
    2 { return "|" }
    default { return "/" }
  }
}

function Get-InstallLogLines {
  param([string]$LogFile)

  if (Test-Path $LogFile) {
    return Get-Content $LogFile
  }
  return @()
}

function Get-NpmInstallProgressLabel {
  param([string]$LogFile, [string]$CurrentLabel)

  $label = $CurrentLabel
  $metadataCacheCount = 0
  $metadataFetchCount = 0
  $tarballCacheCount = 0
  $tarballFetchCount = 0

  foreach ($line in (Get-InstallLogLines $LogFile)) {
    $line = ($line -split $FuzzyCr)[-1]
    if ($line -like "npm verbose title npm install*") {
      $label = "resolving packages"
    } elseif ($line -match "npm http fetch GET .*https://registry\.npmjs\.org/.*\.tgz") {
      $tarballFetchCount += 1
      $label = "fetching tarballs ($tarballFetchCount)"
    } elseif ($line -match "npm http cache .*@https://registry\.npmjs\.org/.*\.tgz") {
      $tarballCacheCount += 1
      if ($tarballFetchCount -gt 0) {
        $label = "fetching tarballs ($tarballFetchCount)"
      } else {
        $label = "checking tarballs ($tarballCacheCount)"
      }
    } elseif ($line -match "npm http fetch GET .*https://registry\.npmjs\.org/") {
      $metadataFetchCount += 1
      $label = "fetching package metadata ($metadataFetchCount)"
    } elseif ($line -match "npm http cache https://registry\.npmjs\.org/") {
      $metadataCacheCount += 1
      if ($metadataFetchCount -gt 0) {
        $label = "fetching package metadata ($metadataFetchCount)"
      } else {
        $label = "checking cached metadata ($metadataCacheCount)"
      }
    } elseif ($line -like "npm info run *") {
      $rest = $line.Substring("npm info run ".Length)
      $parts = $rest -split " "
      $package = $parts[0]
      $script = if ($parts.Length -gt 1) { $parts[1] } else { "script" }
      $package = $package -replace "@[^@]*$", ""
      if ($line -like "*{ code:*") {
        $label = "finished $script for $package"
      } else {
        $label = "running $script for $package"
      }
    } elseif (($line -like "changed *") -or ($line -like "added *") -or ($line -like "removed *") -or ($line -like "updated *") -or ($line -like "up to date *")) {
      $label = $line
    }
  }

  if ($label.Length -gt 64) {
    $label = $label.Substring(0, 61) + "..."
  }
  return $label
}

function Get-VisibleTextLength {
  param([string]$Text)

  $escapedEsc = [regex]::Escape([string]$FuzzyEsc)
  $visibleText = [regex]::Replace($Text, "${escapedEsc}\[[0-9;?]*[ -/]*[@-~]", "")
  return $visibleText.Length
}

function Write-InstallProgress {
  param([int]$Step, [string]$Frame, [string]$Label, [string]$Title)

  $reset = "${FuzzyEsc}[0m"
  $dim = "${FuzzyEsc}[2m"
  $cyan = "${FuzzyEsc}[38;2;71;217;250m"
  $red = "${FuzzyEsc}[38;2;216;59;48m"
  $green = "${FuzzyEsc}[38;2;102;247;65m"
  $orange = "${FuzzyEsc}[38;2;246;155;49m"
  $bold = "${FuzzyEsc}[1m"
  $width = 28
  $trail = 8
  $head = $Step % ($width + $trail)
  $bar = ""

  for ($i = 0; $i -lt $width; $i += 1) {
    $age = $head - $i
    if (($age -ge 0) -and ($age -lt $trail)) {
      switch ($age) {
        { $_ -in 0, 1 } { $cell = "${green}#${reset}"; break }
        { $_ -in 2, 3 } { $cell = "${cyan}#${reset}"; break }
        { $_ -in 4, 5 } { $cell = "${red}#${reset}"; break }
        default { $cell = "${orange}#${reset}" }
      }
    } else {
      $cell = "${dim}-${reset}"
    }
    $bar += $cell
  }

  $line = "  ${orange}${Frame}${reset} $bar ${bold}${Title}${reset} $Label"
  $visibleWidth = Get-VisibleTextLength $line
  $lastWidth = [int]$script:FuzzyLastProgressWidth
  $padWidth = [Math]::Max(0, $lastWidth - $visibleWidth)

  [Console]::Write("`r$line" + (" " * $padWidth))
  $script:FuzzyLastProgressWidth = [Math]::Max($lastWidth, $visibleWidth)
}

function Finish-InstallProgress {
  $lastWidth = [int]$script:FuzzyLastProgressWidth
  if ($lastWidth -gt 0) {
    [Console]::Write("`r" + (" " * $lastWidth) + "`r")
  } else {
    [Console]::Write("`r")
  }
  [Console]::Write("${FuzzyEsc}[?25h")
  $script:FuzzyLastProgressWidth = 0
}

function Write-StaticLogo {
  if (Test-InstallerInteractiveOutput) {
    $block = [string][char]0x2588
  } else {
    $block = "#"
  }

  Write-Host ""
  Write-Host ("  " + ($block * 6))
  Write-Host ("  " + ($block * 2) + "  " + ($block * 2))
  Write-Host ("  " + ($block * 4) + "  " + ($block * 2))
  Write-Host ("  " + ($block * 2) + "    " + ($block * 2))
  Write-Host ""
}

function Get-LogoCellColor {
  param([int]$Phase, [string]$Active, [int]$ActiveX, [int]$ActiveY, [int]$Flash, [int]$White, [int]$Y, [int]$X)

  if ($X -ge $Phase) { return "panel" }
  if ($White -eq 1) { return "white" }
  if ($Flash -eq 1) { return "flash" }

  switch ($X) {
    0 { return "orange" }
    1 { return "cyan" }
    2 { return "red" }
    3 { return "green" }
    4 { return "white" }
    default { return "panel" }
  }
}

function Write-LogoFrame {
  param([string]$Clear, [string]$Reset, [int]$Phase, [string]$Active, [int]$ActiveX, [int]$ActiveY, [int]$Flash, [int]$White)

  $b = [string][char]0x2588
  $segs = @{
    "0:0" = "$b$b$b$b$b$b$b"; "0:1" = "$b$b     "; "0:2" = "$b$b$b$b$b  "; "0:3" = "$b$b     "; "0:4" = "$b$b     "
    "1:0" = "$b$b    $b$b";   "1:1" = "$b$b    $b$b"; "1:2" = "$b$b    $b$b"; "1:3" = "$b$b    $b$b"; "1:4" = " $b$b$b$b$b$b "
    "2:0" = "$b$b$b$b$b$b$b"; "2:1" = "   $b$b$b "; "2:2" = "  $b$b$b  "; "2:3" = " $b$b$b   "; "2:4" = "$b$b$b$b$b$b$b"
    "3:0" = "$b$b$b$b$b$b$b"; "3:1" = "   $b$b$b "; "3:2" = "  $b$b$b  "; "3:3" = " $b$b$b   "; "3:4" = "$b$b$b$b$b$b$b"
    "4:0" = "$b$b    $b$b";   "4:1" = " $b$b  $b$b "; "4:2" = "  $b$b$b$b  "; "4:3" = "   $b$b   "; "4:4" = "   $b$b   "
  }
  $colors = @{
    orange = "${FuzzyEsc}[38;2;246;155;49m"; cyan = "${FuzzyEsc}[38;2;71;217;250m"
    red    = "${FuzzyEsc}[38;2;216;59;48m";  green = "${FuzzyEsc}[38;2;102;247;65m"
    white  = "${FuzzyEsc}[38;2;255;255;255m"; flash = "${FuzzyEsc}[38;2;255;245;180m"
  }
  $panelWidths = @{ 0 = "       "; 1 = "        "; 2 = "       "; 3 = "       "; 4 = "        " }

  $frame = $Clear + "`n"
  foreach ($y in 0..4) {
    $frame += "    "
    foreach ($x in 0..4) {
      $color = Get-LogoCellColor $Phase $Active $ActiveX $ActiveY $Flash $White $y $x
      if ($color -eq "panel") {
        $frame += $panelWidths[$x]
      } else {
        $frame += $colors[$color] + $segs["${x}:${y}"] + $Reset
      }
      if ($x -lt 4) { $frame += " " }
    }
    $frame += "`n"
  }
  [Console]::Write($frame)
}

function Show-FuzzyLogoAnimation {
  if (-not (Test-InstallerAnsiOutput)) {
    Write-StaticLogo
    return
  }

  $esc = "${FuzzyEsc}["
  $reset = "${FuzzyEsc}[0m"
  $clear = "${esc}H"

  [Console]::Write("${esc}?25l${esc}2J${esc}H")

  Write-LogoFrame $clear $reset 1 "none" 0 0 0 0; Start-Sleep -Milliseconds 120
  Write-LogoFrame $clear $reset 2 "none" 0 0 0 0; Start-Sleep -Milliseconds 120
  Write-LogoFrame $clear $reset 3 "none" 0 0 0 0; Start-Sleep -Milliseconds 120
  Write-LogoFrame $clear $reset 4 "none" 0 0 0 0; Start-Sleep -Milliseconds 120
  Write-LogoFrame $clear $reset 5 "none" 0 0 0 0; Start-Sleep -Milliseconds 400

  Write-LogoFrame $clear $reset 5 "none" 0 0 1 0; Start-Sleep -Milliseconds 100
  Write-LogoFrame $clear $reset 5 "none" 0 0 0 0; Start-Sleep -Milliseconds 100
  Write-LogoFrame $clear $reset 5 "none" 0 0 1 0; Start-Sleep -Milliseconds 400

  [Console]::Write("$reset${esc}?25h`n")
}

function Write-OutputLines {
  param([object[]]$Lines)

  foreach ($line in $Lines) {
    Write-Host $line
  }
}

function Test-NodeVersionIsNewEnough {
  param([string]$Version)

  $normalized = $Version.TrimStart("v")
  $parsed = [version]$normalized
  return $parsed -ge $NodeMinimum
}

function Invoke-PreflightChecks {
  $status = 0

  $node = Get-Command node -ErrorAction SilentlyContinue
  if ($node) {
    $nodeVersion = (& node --version).Trim()
    if (-not (Test-NodeVersionIsNewEnough $nodeVersion)) {
      Write-Output "error: Fuzzy requires Node.js 22.19.0 or newer. Found $nodeVersion."
      $status = 1
    }
  } else {
    Write-Output "error: Node.js 22.19.0 or newer is required to install Fuzzy."
    $status = 1
  }

  if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) {
    Write-Output "error: npm is required to install Fuzzy."
    $status = 1
  }

  if ($status -ne 0) {
    Write-Output ""
  }

  $script:FuzzyPreflightStatus = $status
}

# Read user environment values directly from the registry instead of using
# [Environment]::GetEnvironmentVariable. The DoNotExpandEnvironmentNames flag keeps
# entries such as %USERPROFILE% literal so writing PATH back does not accidentally
# expand or rewrite user-managed variables.
function Get-UserEnv {
  param([string]$Key)

  $registerKey = Get-Item -Path "HKCU:"
  $envRegisterKey = $registerKey.OpenSubKey("Environment")
  $envRegisterKey.GetValue($Key, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
}

# Tell Explorer and newly launched terminals that HKCU:\Environment changed.
# Without this broadcast, PATH updates generally require signing out or restarting
# Windows before other processes notice them.
function Publish-EnvChange {
  if (-not ("Win32.NativeMethods" -as [Type])) {
    Add-Type -Namespace Win32 -Name NativeMethods -MemberDefinition @"
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr SendMessageTimeout(
    IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
    uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
"@
  }

  $hwndBroadcast = [IntPtr]0xffff
  $wmSettingChange = 0x1a
  $result = [UIntPtr]::Zero
  [Win32.NativeMethods]::SendMessageTimeout($hwndBroadcast, $wmSettingChange, [UIntPtr]::Zero, "Environment", 2, 5000, [ref]$result) | Out-Null
}

# Preserve ExpandString values when an existing variable uses percent expansion.
# This mirrors how Windows stores PATH and avoids flattening values like %APPDATA%.
function Set-UserEnv {
  param([string]$Key, [string]$Value)

  $registerKey = Get-Item -Path "HKCU:"
  $envRegisterKey = $registerKey.OpenSubKey("Environment", $true)
  if ($null -eq $Value) {
    $envRegisterKey.DeleteValue($Key)
  } else {
    $registryValueKind = if ($Value.Contains("%")) {
      [Microsoft.Win32.RegistryValueKind]::ExpandString
    } elseif ($envRegisterKey.GetValue($Key)) {
      $envRegisterKey.GetValueKind($Key)
    } else {
      [Microsoft.Win32.RegistryValueKind]::String
    }
    $envRegisterKey.SetValue($Key, $Value, $registryValueKind)
  }

  Publish-EnvChange
}

function Add-UserPathEntry {
  param([string]$Directory, [switch]$Prepend)

  # Update both the persisted user PATH and this PowerShell process. The process
  # update lets the remainder of this installer immediately find newly installed
  # node/npm/fuzzy shims without asking the user to restart first.
  $path = (Get-UserEnv -Key "Path") -split ";" | Where-Object { $_ -and ($_ -ne $Directory) }
  if ($Prepend) {
    $path = @($Directory) + $path
  } else {
    $path += $Directory
  }
  Set-UserEnv -Key "Path" -Value ($path -join ";")

  $processPath = $env:PATH -split ";" | Where-Object { $_ -and ($_ -ne $Directory) }
  if ($Prepend) {
    $env:PATH = ((@($Directory) + $processPath) -join ";")
  } else {
    $env:PATH = (($processPath + $Directory) -join ";")
  }

  Add-PathRefreshEntry $Directory
}

function Add-PathRefreshEntry {
  param([string]$Directory)

  if (-not $script:FuzzyPathRefreshEntries) {
    $script:FuzzyPathRefreshEntries = @()
  }
  if ($script:FuzzyPathRefreshEntries -notcontains $Directory) {
    $script:FuzzyPathRefreshEntries += $Directory
  }
}

function Get-InstallerParentShell {
  $currentProcess = Get-CimInstance Win32_Process -Filter "ProcessId = $PID"
  $parentProcess = Get-CimInstance Win32_Process -Filter "ProcessId = $($currentProcess.ParentProcessId)"
  if ($parentProcess.Name -ieq "cmd.exe") {
    return "cmd"
  }
  return "powershell"
}

function Get-PathRefreshCommand {
  param([string[]]$Directories)

  $prefix = ($Directories | Where-Object { $_ } | Select-Object -Unique) -join ";"
  if (-not $prefix) {
    return ""
  }

  if ((Get-InstallerParentShell) -eq "cmd") {
    return "set `"PATH=$prefix;%PATH%`""
  }
  return "`$env:PATH = `"$prefix;`$env:PATH`""
}

function Write-PathRefreshNote {
  if (-not $script:FuzzyPathRefreshEntries -or $script:FuzzyPathRefreshEntries.Count -eq 0) {
    return
  }

  $command = Get-PathRefreshCommand $script:FuzzyPathRefreshEntries
  if (-not $command) {
    return
  }

  Write-Host ""
  Write-Host "If fuzzy is not found in the terminal that launched this installer,"
  Write-Host "restart it or update PATH there now:"
  Write-Host ""
  Write-Host "  $command"
}

function Get-WindowsArch {
  # Use the machine environment registry value rather than process environment
  # variables so ARM64 Windows running an x64 PowerShell still resolves to arm64.
  $arch = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment").PROCESSOR_ARCHITECTURE
  if ($arch -eq "AMD64") {
    return "x64"
  }
  if ($arch -eq "ARM64") {
    return "arm64"
  }

  Write-Host "Unsupported CPU architecture for automatic Node.js install: $arch"
  exit 1
}

function Invoke-DownloadFile {
  param([string]$Url, [string]$OutFile)

  # Use curl.exe explicitly: plain "curl" is an alias for Invoke-WebRequest in
  # Windows PowerShell, and curl.exe is substantially faster on older systems.
  curl.exe "-#SfLo" $OutFile $Url
  if ($LASTEXITCODE -ne 0) {
    Write-Warning "curl.exe failed; trying Invoke-RestMethod..."
    Invoke-RestMethod -Uri $Url -OutFile $OutFile
  }
}

function Assert-NodeDownloadChecksum {
  param([string]$ShasumsPath, [string]$NodeFile, [string]$ZipPath)

  $escapedNodeFile = [regex]::Escape($NodeFile)
  $selected = Get-Content $ShasumsPath | Where-Object { $_ -match "^([a-fA-F0-9]+)\s+$escapedNodeFile$" } | Select-Object -First 1
  if (-not $selected) {
    Write-Host "No checksum was found for $NodeFile."
    exit 1
  }

  $expectedHash = ([regex]::Match($selected, "^([a-fA-F0-9]+)")).Groups[1].Value.ToLowerInvariant()
  $actualHash = (Get-FileHash $ZipPath -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($actualHash -ne $expectedHash) {
    Write-Host "Node.js download checksum verification failed."
    Write-Host "Expected: $expectedHash"
    Write-Host "Actual:   $actualHash"
    exit 1
  }
}

function Install-NodeStandalone {
  $nodeArch = Get-WindowsArch
  $nodeDistBase = "https://nodejs.org/dist/latest-v22.x"
  # Keep the auto-installed Node.js separate from the user's normal Node setup.
  # npm itself still installs Fuzzy globally according to npm's configured prefix.
  $nodeBaseDir = Join-Path $env:LOCALAPPDATA "fuzzy-node"
  $nodeTmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "fuzzy-node-$PID"

  Remove-Item $nodeTmpDir -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $nodeTmpDir, $nodeBaseDir | Out-Null

  $shasumsPath = Join-Path $nodeTmpDir "SHASUMS256.txt"
  Write-Host "Resolving Node.js binary for win-$nodeArch"
  Invoke-DownloadFile "$nodeDistBase/SHASUMS256.txt" $shasumsPath

  $nodeFile = Get-Content $shasumsPath | ForEach-Object {
    if ($_ -match "\s+(node-v.+-win-$nodeArch\.zip)$") { $Matches[1] }
  } | Select-Object -First 1

  if (-not $nodeFile) {
    Write-Host "No Node.js binary is available for win-$nodeArch."
    exit 1
  }

  $zipPath = Join-Path $nodeTmpDir $nodeFile
  Write-Host "Downloading Node.js $($nodeFile -replace '\.zip$', '')"
  Invoke-DownloadFile "$nodeDistBase/$nodeFile" $zipPath
  Write-Host "Verifying Node.js download"
  Assert-NodeDownloadChecksum $shasumsPath $nodeFile $zipPath

  Write-Host "Extracting Node.js to $nodeBaseDir"
  Expand-Archive $zipPath $nodeTmpDir -Force

  $extractedDir = Join-Path $nodeTmpDir ($nodeFile -replace "\.zip$", "")
  $currentDir = Join-Path $nodeBaseDir "current"
  Remove-Item $currentDir -Recurse -Force -ErrorAction SilentlyContinue
  Move-Item $extractedDir $currentDir -Force
  Remove-Item $nodeTmpDir -Recurse -Force

  Add-UserPathEntry $currentDir -Prepend
  Write-Host "Node.js installed at $currentDir"
}

function Install-NodeNpmInteractive {
  if (-not (Test-InstallerInteractiveInput)) {
    Write-Host "No terminal detected; install Node.js 22.19.0 or newer and npm, then run this installer again."
    return $false
  }

  $answer = Read-Host "Fuzzy needs Node.js 22.19.0 or newer and npm. Install standalone Node.js now? [Y/n]"
  if ($answer -match "^(n|no)$") {
    Write-Host ""
    Write-Host "Install Node.js 22.19.0 or newer and npm, then run this installer again."
    return $false
  }

  Write-Host ""
  Install-NodeStandalone
  Write-Host ""
  return $true
}

function Get-NpmGlobalPrefix {
  $prefix = (& npm.cmd prefix -g 2>$null).Trim()
  if ($prefix) {
    return $prefix
  }

  return (& npm.cmd config get prefix 2>$null).Trim()
}

function Test-PathWritableOrCreatable {
  param([string]$Path)

  $checkPath = $Path
  while (-not (Test-Path $checkPath)) {
    $parent = Split-Path $checkPath -Parent
    if (-not $parent -or $parent -eq $checkPath) {
      return $false
    }
    $checkPath = $parent
  }

  if (-not (Test-Path $checkPath -PathType Container)) {
    return $false
  }

  $probe = Join-Path $checkPath ".fuzzy-write-test-$PID"
  try {
    New-Item -ItemType File -Path $probe -Force | Out-Null
    Remove-Item $probe -Force
    return $true
  } catch [System.UnauthorizedAccessException] {
    return $false
  } catch [System.Management.Automation.ActionPreferenceStopException] {
    if ($_.Exception.InnerException -is [System.UnauthorizedAccessException]) {
      return $false
    }
    throw
  }
}

function Test-NpmPrefixSupportsGlobalInstall {
  param([string]$Prefix)

  return (Test-PathWritableOrCreatable (Join-Path $Prefix "node_modules")) -and (Test-PathWritableOrCreatable $Prefix)
}

function Get-FuzzyBinDir {
  if ($env:FUZZY_NPM_INSTALL_PREFIX) {
    return $env:FUZZY_NPM_INSTALL_PREFIX
  }

  return Get-NpmGlobalPrefix
}

function Get-FuzzyInstalledPaths {
  $binDir = Get-FuzzyBinDir
  if ($binDir) {
    return @((Join-Path $binDir "fuzzy.cmd"), (Join-Path $binDir "fuzzy.ps1"))
  }

  return @()
}

function Select-NpmInstallPrefix {
  $npmPrefix = Get-NpmGlobalPrefix
  if ($npmPrefix -and (Test-NpmPrefixSupportsGlobalInstall $npmPrefix)) {
    return ""
  }

  # If an existing global fuzzy is present but npm's prefix is not writable, do not
  # install a second copy elsewhere: PATH would likely continue resolving to the
  # old shim, making the successful install look broken.
  $existingGlobalFuzzy = @((Join-Path $npmPrefix "fuzzy.cmd"), (Join-Path $npmPrefix "fuzzy.ps1")) | Where-Object { Test-Path $_ } | Select-Object -First 1
  if ($npmPrefix -and $existingGlobalFuzzy) {
    Write-Host "npm's global directory is not writable: $npmPrefix"
    Write-Host "Fuzzy is already installed at: $existingGlobalFuzzy"
    Write-Host ""
    Write-Host "Installing another copy under your profile could leave your shell using the old global fuzzy, so this installer stopped."
    exit 1
  }

  $userPrefix = Join-Path $env:APPDATA "npm"
  New-Item -ItemType Directory -Force -Path $userPrefix | Out-Null
  return $userPrefix
}

function Select-NpmUninstallPrefix {
  param([string]$ExistingFuzzyPath)

  # On Windows npm creates command shims directly in the prefix directory
  # (fuzzy.cmd / fuzzy.ps1), unlike Unix where shims live under prefix/bin.
  if (-not $ExistingFuzzyPath) {
    return ""
  }

  $npmPrefix = Get-NpmGlobalPrefix
  if ($npmPrefix -and (($ExistingFuzzyPath -eq (Join-Path $npmPrefix "fuzzy.cmd")) -or ($ExistingFuzzyPath -eq (Join-Path $npmPrefix "fuzzy.ps1")))) {
    return ""
  }

  if ($env:FUZZY_NPM_INSTALL_PREFIX -and (($ExistingFuzzyPath -eq (Join-Path $env:FUZZY_NPM_INSTALL_PREFIX "fuzzy.cmd")) -or ($ExistingFuzzyPath -eq (Join-Path $env:FUZZY_NPM_INSTALL_PREFIX "fuzzy.ps1")))) {
    return $env:FUZZY_NPM_INSTALL_PREFIX
  }

  $fileName = Split-Path $ExistingFuzzyPath -Leaf
  if ($fileName -in @("fuzzy.cmd", "fuzzy.ps1", "fuzzy")) {
    return (Split-Path $ExistingFuzzyPath -Parent)
  }

  return ""
}

function Write-NpmInstallCommand {
  if ($env:FUZZY_NPM_INSTALL_PREFIX) {
    Write-Output "npm.cmd install -g --ignore-scripts $NpmMinReleaseAgeArg --prefix `"$env:FUZZY_NPM_INSTALL_PREFIX`" $FuzzyPackage"
  } else {
    Write-Output "npm.cmd install -g --ignore-scripts $NpmMinReleaseAgeArg $FuzzyPackage"
  }
}

function Write-FuzzyActionMenu {
  param([string]$ExistingFuzzyPath)

  $reset = ""
  $dim = ""
  $bold = ""
  $cyan = ""
  $green = ""
  $red = ""
  if (Test-InstallerAnsiOutput) {
    $reset = "${FuzzyEsc}[0m"
    $dim = "${FuzzyEsc}[2m"
    $bold = "${FuzzyEsc}[1m"
    $cyan = "${FuzzyEsc}[38;2;71;217;250m"
    $green = "${FuzzyEsc}[38;2;102;247;65m"
    $red = "${FuzzyEsc}[38;2;216;59;48m"
  }

  if ($ExistingFuzzyPath) {
    Write-Host "${bold}Fuzzy is already installed at:${reset}"
    Write-Host ""
    Write-Host "  $ExistingFuzzyPath"
    Write-Host ""
  }

  if ($env:FUZZY_NPM_INSTALL_PREFIX) {
    Write-Host "npm's global directory is not writable; Fuzzy will be installed under $env:FUZZY_NPM_INSTALL_PREFIX."
    Write-Host ""
  }

  if ($ExistingFuzzyPath) {
    Write-Host "${bold}Reinstall command:${reset}"
  } else {
    Write-Host "${bold}Install command:${reset}"
  }
  Write-Host ""
  Write-Host "  $(Write-NpmInstallCommand)"
  Write-Host ""

  Write-Host "${bold}Choose an action:${reset}"
  Write-Host ""
  if ($ExistingFuzzyPath) {
    Write-Host ("  {0}{1,-4}{2} {3}Reinstall Fuzzy{2} {4}(default){2}" -f $cyan, "y", $reset, $green, $dim)
    Write-Host ("  {0}{1,-4}{2} {3}Uninstall Fuzzy{2}" -f $cyan, "u", $reset, $red)
  } else {
    Write-Host ("  {0}{1,-4}{2} {3}Install Fuzzy{2} {4}(default){2}" -f $cyan, "y", $reset, $green, $dim)
  }
  Write-Host ("  {0}{1,-4}{2} {3}Do nothing{2}" -f $cyan, "n", $reset, $dim)
}

function Read-FuzzyActionKey {
  $keyInfo = [Console]::ReadKey($true)
  if ($keyInfo.Key -eq [ConsoleKey]::Enter) {
    return ""
  }
  if ($keyInfo.Key -eq [ConsoleKey]::Spacebar) {
    return " "
  }
  if ($keyInfo.Key -eq [ConsoleKey]::Escape) {
    return $FuzzyEsc
  }
  return [string]$keyInfo.KeyChar
}

function Get-DefaultFuzzyAction {
  param([string]$ExistingFuzzyPath)

  if ($ExistingFuzzyPath) {
    return "reinstall"
  }
  return "install"
}

function Write-FuzzyActionSelection {
  param([string]$Action)

  switch ($Action) {
    "install" { $message = "Will install Fuzzy." }
    "reinstall" { $message = "Will reinstall Fuzzy." }
    "uninstall" { $message = "Will uninstall Fuzzy." }
    "none" { $message = "Chose to do nothing. Exiting." }
  }
  Write-Host ""
  Write-Host $message
  if ($Action -in @("install", "reinstall")) {
    Write-Host "This will take a while. We're sorry."
  }
  Write-Host ""
}

function Choose-FuzzyAction {
  param([string]$ExistingFuzzyPath)

  Write-FuzzyActionMenu $ExistingFuzzyPath
  Write-Host ""

  if (-not (Test-InstallerInteractiveInput)) {
    Write-Host "No terminal detected; continuing without confirmation."
    $action = Get-DefaultFuzzyAction $ExistingFuzzyPath
    Write-FuzzyActionSelection $action
    return $action
  }

  while ($true) {
    $key = Read-FuzzyActionKey

    if (($key -eq "") -or ($key -eq " ")) {
      $action = Get-DefaultFuzzyAction $ExistingFuzzyPath
      break
    }
    if ($key -match "^(y|Y)$") {
      $action = Get-DefaultFuzzyAction $ExistingFuzzyPath
      break
    }
    if ($ExistingFuzzyPath -and ($key -match "^(u|U)$")) {
      $action = "uninstall"
      break
    }
    if (($key -match "^(n|N)$") -or ($key -eq $FuzzyEsc)) {
      $action = "none"
      break
    }

    Write-Host "Please choose one of the listed keys."
  }

  Write-FuzzyActionSelection $action
  return $action
}

function Get-NpmInstallFuzzyArgs {
  param([string]$LogLevel, [string]$Progress)

  $args = @("install", "-g", "--ignore-scripts", $NpmMinReleaseAgeArg, "--no-fund", "--no-audit", "--loglevel=$LogLevel", "--progress=$Progress")
  if ($env:FUZZY_NPM_INSTALL_PREFIX) {
    $args += @("--prefix", $env:FUZZY_NPM_INSTALL_PREFIX)
  }
  $args += $FuzzyPackage
  return $args
}

function Invoke-NpmInstallFuzzy {
  $args = Get-NpmInstallFuzzyArgs "error" "false"
  & npm.cmd @args
}

function Install-FuzzyPackageWithProgress {
  $logFile = Join-Path ([System.IO.Path]::GetTempPath()) "fuzzy-installer-npm-$PID.log"
  Remove-Item $logFile -Force -ErrorAction SilentlyContinue
  New-Item -ItemType File -Path $logFile -Force | Out-Null

  $npmArgs = [System.Collections.ArrayList]::new()
  $npmArgs.AddRange([string[]](Get-NpmInstallFuzzyArgs "verbose" "false"))
  $job = Start-Job -ScriptBlock {
    param([string[]]$ArgsForNpm, [string]$OutputLog)

    & npm.cmd @ArgsForNpm *> $OutputLog
    $LASTEXITCODE
  } -ArgumentList $npmArgs, $logFile

  [Console]::Write("${FuzzyEsc}[?25l")
  $script:FuzzyLastProgressWidth = 0
  $step = 0
  $label = "starting npm install"
  $lastFrame = $null
  $lastLabel = $null
  $redrawIntervalMs = 180
  while ($job.State -eq "Running") {
    $frame = Get-SpinnerFrame $step
    if (($step % 3) -eq 0) {
      $label = Get-NpmInstallProgressLabel $logFile $label
    }
    if (($frame -ne $lastFrame) -or ($label -ne $lastLabel)) {
      Write-InstallProgress $step $frame $label "Installing Fuzzy"
      $lastFrame = $frame
      $lastLabel = $label
    }
    $step += 1
    Start-Sleep -Milliseconds $redrawIntervalMs
  }

  $status = Receive-Job $job | Select-Object -Last 1
  Remove-Job $job
  Finish-InstallProgress

  if ($status -ne 0) {
    [Console]::Write("${FuzzyEsc}[31mInstallation failed.${FuzzyEsc}[0m`n`n")
    Get-Content $logFile | ForEach-Object { Write-Host $_ }
    Remove-Item $logFile -Force -ErrorAction SilentlyContinue
    exit $status
  }

  Remove-Item $logFile -Force -ErrorAction SilentlyContinue
  Write-Host "  ok npm install complete"
}

function Invoke-NpmUninstallFuzzy {
  $args = @("uninstall", "-g", "--no-fund", "--no-audit", "--loglevel=error", "--progress=false")
  if ($env:FUZZY_NPM_UNINSTALL_PREFIX) {
    $args += @("--prefix", $env:FUZZY_NPM_UNINSTALL_PREFIX)
  }
  $args += $FuzzyPackage
  & npm.cmd @args
}

function Test-NpmPackageInstalledForUninstall {
  $args = @("ls", "-g", "--depth=0")
  if ($env:FUZZY_NPM_UNINSTALL_PREFIX) {
    $args += @("--prefix", $env:FUZZY_NPM_UNINSTALL_PREFIX)
  }
  $args += $FuzzyPackage
  & npm.cmd @args *> $null
  return $LASTEXITCODE -eq 0
}

function Install-FuzzyPackage {
  if (Test-InstallerAnsiOutput) {
    Install-FuzzyPackageWithProgress
  } else {
    Write-Host "Installing Fuzzy..."
    Write-Host ""
    Invoke-NpmInstallFuzzy
    if ($LASTEXITCODE -ne 0) {
      exit $LASTEXITCODE
    }
  }
}

function Uninstall-FuzzyPackage {
  if (-not (Test-NpmPackageInstalledForUninstall)) {
    Write-Host "I found fuzzy at:"
    Write-Host ""
    Write-Host "  $env:FUZZY_EXISTING_PATH"
    Write-Host ""
    Write-Host "but npm does not show $FuzzyPackage installed there."
    Write-Host "Nothing was removed."
    exit 1
  }

  Write-Host "Uninstalling Fuzzy..."
  Write-Host ""
  Invoke-NpmUninstallFuzzy
  if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
  }

  if ((Test-Path $env:FUZZY_EXISTING_PATH) -or (Test-Path $env:FUZZY_EXISTING_PATH -PathType Leaf)) {
    Write-Host ""
    Write-Host "npm uninstall finished, but fuzzy is still present at:"
    Write-Host ""
    Write-Host "  $env:FUZZY_EXISTING_PATH"
    exit 1
  }
}

function Test-InstalledFuzzyIsFirstOnPath {
  $installedFuzzyPaths = Get-FuzzyInstalledPaths
  if (-not $installedFuzzyPaths) {
    return $false
  }

  $activeFuzzy = Get-Command $FuzzyCmd -ErrorAction SilentlyContinue
  return $activeFuzzy -and ($installedFuzzyPaths -contains $activeFuzzy.Source)
}

function Write-FuzzyNotOnPathMessage {
  $fuzzyBinDir = Get-FuzzyBinDir
  $activeFuzzy = Get-Command $FuzzyCmd -ErrorAction SilentlyContinue

  Write-Host "Fuzzy was installed, but your shell is not using that install yet."
  if ($activeFuzzy) {
    Write-Host "Your shell currently resolves fuzzy to: $($activeFuzzy.Source)"
  }

  if ($fuzzyBinDir) {
    $answer = Read-Host "Add $fuzzyBinDir to your user PATH now? [Y/n]"
    if (-not $answer -or $answer -notmatch "^(n|no)$") {
      Add-UserPathEntry $fuzzyBinDir -Prepend
      Write-Host "Added $fuzzyBinDir to your user PATH."
    }
    Write-Host "Restart your shell, then run: fuzzy"
  } else {
    Write-Host "Check npm's global prefix with: npm prefix -g"
    Write-Host "Then add that directory to your PATH."
  }
}

function Invoke-FuzzyInstaller {
  if ([System.Environment]::OSVersion.Platform -ne "Win32NT") {
    Write-Host "This PowerShell installer is for Windows. On Unix, use: curl -fsSL https://fuzzy.dev/install.sh | sh"
    exit 1
  }

  $preflightOutput = Invoke-PreflightChecks
  Show-FuzzyLogoAnimation
  Write-InstallerTitle
  if ($script:FuzzyPreflightStatus -eq 0) {
    Write-OutputLines $preflightOutput
  }

  if ($script:FuzzyPreflightStatus -ne 0) {
    $preflightStatus = $script:FuzzyPreflightStatus
    if (-not (Install-NodeNpmInteractive)) {
      exit $preflightStatus
    }

    $preflightOutput = Invoke-PreflightChecks
    Write-OutputLines $preflightOutput
    if ($script:FuzzyPreflightStatus -ne 0) {
      exit $script:FuzzyPreflightStatus
    }
  }

  $existingFuzzy = Get-Command $FuzzyCmd -ErrorAction SilentlyContinue
  if ($existingFuzzy) {
    $env:FUZZY_EXISTING_PATH = $existingFuzzy.Source
  } else {
    $env:FUZZY_EXISTING_PATH = ""
  }

  $installPrefix = Select-NpmInstallPrefix
  if ($installPrefix) {
    $env:FUZZY_NPM_INSTALL_PREFIX = $installPrefix
  } else {
    $env:FUZZY_NPM_INSTALL_PREFIX = ""
  }

  $uninstallPrefix = Select-NpmUninstallPrefix $env:FUZZY_EXISTING_PATH
  if ($uninstallPrefix) {
    $env:FUZZY_NPM_UNINSTALL_PREFIX = $uninstallPrefix
  } else {
    $env:FUZZY_NPM_UNINSTALL_PREFIX = ""
  }

  $action = Choose-FuzzyAction $env:FUZZY_EXISTING_PATH
  if ($action -eq "uninstall") {
    Uninstall-FuzzyPackage
    Write-Host ""
    Write-Host "Fuzzy was uninstalled successfully."
    exit 0
  }
  if ($action -eq "none") {
    exit 0
  }

  Install-FuzzyPackage
  Write-Host ""
  if ($action -eq "reinstall") {
    Write-Host "Fuzzy was reinstalled successfully."
  } else {
    Write-Host "Fuzzy was installed successfully."
  }

  if (Test-InstalledFuzzyIsFirstOnPath) {
    Write-Host ""
    Write-Host "Run it with: fuzzy"
  } else {
    Write-Host ""
    Write-FuzzyNotOnPathMessage
  }

  Write-PathRefreshNote
}

Invoke-FuzzyInstaller
