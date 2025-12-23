<#
	validate-paths.ps1

	Validates that directory and file path segments (excluding drive letter)
	in a provided list conform to PascalCase: start with an uppercase letter,
	followed by letters or digits, no spaces or special characters.

	Usage examples:
		pwsh -NoProfile -File .\scripts\validate-paths.ps1 -PathsFile .\changed-files.txt
		pwsh -NoProfile -File .\scripts\validate-paths.ps1 -Paths 'Source\MyFile.cs','Tests\BarTest.cs'

	The script reads CICD\Configs\PathConfigs.ini if present. Supported formats:
		- New style with section keys as paths:
				[GlobalIncludePaths]
				Source = ""
				Prototypes = ""

		- Legacy single-line keys:
				Include=Source,Tests
				Exclude=ThirdParty,Docs

	Exit codes:
		0 - all checked paths valid
		1 - validation failures found
		2 - script error (missing files, etc.)
#>

Param(
	[string[]] $Paths,
	[string] $PathsFile
)

try {
	$root = (Get-Location).ProviderPath
} catch {
	Write-Error "Failed to determine repository root: $_"
	exit 2
}

Write-Host "Repository root: $root"

$invalid = New-Object System.Collections.Generic.List[string]
$skipNames = @('.git', '.github', 'node_modules')

function Test-Segment($segment) {
	if ($skipNames -contains $segment) { return $true }
	if ($segment.StartsWith('.')) { return $true }
	return ($segment -match '^[A-Z][A-Za-z0-9]*$')
}

# Build list of target relative paths to validate
if ($PathsFile) {
	if (-not (Test-Path $PathsFile)) {
		Write-Error "Paths file not found: $PathsFile"
		exit 2
	}
	$targetPaths = Get-Content -Path $PathsFile -ErrorAction Stop -Encoding UTF8 | ForEach-Object { $_.ToString().Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
} elseif ($Paths) {
	$targetPaths = $Paths
} else {
	# No paths provided: fallback to scanning the entire repo (files only)
	$targetPaths = Get-ChildItem -Recurse -Force -File | ForEach-Object { $_.FullName.Substring($root.Length).TrimStart('\\','/') }
}

# Read include/exclude config if present (support new key-as-path format and legacy Include/Exclude)
$configPath = Join-Path $root 'CICD\Configs\PathConfigs.ini'
$includeList = @()
$excludeList = @()
if (Test-Path $configPath) {
	Write-Host "Loading path config: $configPath"
	$content = Get-Content -Path $configPath -ErrorAction SilentlyContinue
	$section = ''
	foreach ($lineRaw in $content) {
		$line = $lineRaw.Trim()
		if (-not $line) { continue }
		if ($line.StartsWith(';')) { continue }
		if ($line -match '^\[(.+)\]') { $section = $matches[1].Trim(); continue }

		# New format: section keys are path names (e.g. "Source = "")
		if ($section -ieq 'GlobalIncludePaths') {
			if ($line -match '^(?<key>[^=]+)') { $includeList += ($matches.key.Trim().TrimStart('./','\\','/')) }
			continue
		}
		if ($section -ieq 'GlobalExcludePaths') {
			if ($line -match '^(?<key>[^=]+)') { $excludeList += ($matches.key.Trim().TrimStart('./','\\','/')) }
			continue
		}

		# Legacy format support: Include=.. or Exclude=..
		if ($line -match '^Include\s*=\s*(.+)$') { $includeList = ($matches[1] -split ',') | ForEach-Object { $_.Trim().TrimStart('./','\\','/') } | Where-Object { $_ -ne '' }; continue }
		if ($line -match '^Exclude\s*=\s*(.+)$') { $excludeList = ($matches[1] -split ',') | ForEach-Object { $_.Trim().TrimStart('./','\\','/') } | Where-Object { $_ -ne '' }; continue }
	}
	if ($includeList.Count -gt 0) { Write-Host "Include paths: $($includeList -join ', ')" }
	if ($excludeList.Count -gt 0) { Write-Host "Exclude paths: $($excludeList -join ', ')" }
} else {
	Write-Host "No path config found at $configPath — validating provided paths without include/exclude filtering."
}

function Test-InScope($rel) {
	# normalize to backslashes
	$relNorm = $rel -replace '/','\\'
	# If include list present, require match (prefix match)
	if ($includeList.Count -gt 0) {
		$matched = $false
		foreach ($inc in $includeList) {
			$incNorm = ($inc -replace '/','\\').TrimEnd('\\')
			if ($relNorm -ieq $incNorm -or $relNorm.StartsWith($incNorm + '\\')) { $matched = $true; break }
		}
		if (-not $matched) { return $false }
	}
	# If exclude list present, reject any match
	if ($excludeList.Count -gt 0) {
		foreach ($exc in $excludeList) {
			$excNorm = ($exc -replace '/','\\').TrimEnd('\\')
			if ($relNorm -ieq $excNorm -or $relNorm.StartsWith($excNorm + '\\')) { return $false }
		}
	}
	return $true
}

foreach ($rel in $targetPaths) {
	if (-not (Test-InScope $rel)) { continue }
	# Normalize separators and trim
	$relNorm = $rel -replace '/','\\'
	$parts = $relNorm -split '\\+'

	# Validate each directory segment (all except final file segment)
	if ($parts.Length -gt 1) {
		$dirs = $parts[0..($parts.Length - 2)]
		$dirFailed = $false
		foreach ($p in $dirs) {
			if (-not (Test-Segment $p)) { $dirFailed = $true; break }
		}
		if ($dirFailed) {
			$full = Join-Path $root $rel
			$invalid.Add($full)
			continue
		}
	}

	# Validate filename (without extension)
	$fileSeg = $parts[-1]
	$fileNameNoExt = [System.IO.Path]::GetFileNameWithoutExtension($fileSeg)
	if (-not (Test-Segment $fileNameNoExt)) {
		$full = Join-Path $root $rel
		$invalid.Add($full)
		continue
	}
}

if ($invalid.Count -gt 0) {
	Write-Host 'Invalid paths found:'
	$invalid | Sort-Object -Unique | ForEach-Object { Write-Host " - $_" }
	exit 1
} else {
	Write-Host 'All paths conform to PascalCase rules.'
	exit 0
}

