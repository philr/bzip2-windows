# Download and build bzip2 for Windows using Visual Studio.

# Requires Git, PowerShell Community Extensions (https://pscx.codeplex.com/) 
# and Visual Studio 2015 on 64-bit Windows.

Param (
  [string]$GitPath = 'git',
  [string]$VisualStudioDir = 'C:\Program Files (x86)\Microsoft Visual Studio 14.0'  
)

$Version = '1.0.8'
$ExpectedHash = 'AB5A03176EE106D3F0FA90E381DA478DDAE405918153CCA248E682CD0C4A2269'
$PackageVersion = '1.0.8.0'

$ErrorActionPreference = 'Stop'

Import-Module -Name 'Pscx'

# Download bzip2 source if not already in source directory.
$SourceDir = Join-Path -Path $PSScriptRoot -ChildPath 'source'
$GzipFile = "bzip2-$Version.tar.gz"
$GzipPath = Join-Path -Path $SourceDir -ChildPath $GzipFile

New-Item -ItemType Directory -Force -Path $SourceDir | Out-Null

if (-not (Test-Path -LiteralPath $GzipPath)) {
    Write-Host "Downloading $SourceFile"
    Invoke-WebRequest -Uri "https://www.sourceware.org/pub/bzip2/$GzipFile" -Method Get -OutFile $GzipPath

    $ActualHash = Get-FileHash -LiteralPath $GzipPath -Algorithm SHA256
    if ($ExpectedHash -ne $ActualHash.Hash) {
        throw "Downloaded hash check failed, expected $ExpectedHash, found $($ActualHash.Hash)."
    }
}

# Delete any existing extracted sources and then extract the tar.bz2 file.
$TarFile = ([IO.FileInfo]$GzipFile).BaseName
$TarPath = Join-Path -Path $SourceDir -ChildPath $TarFile
$ExtractedDir = Join-Path -Path $SourceDir -ChildPath (([IO.FileInfo]$TarFile).BaseName)

if (Test-Path -LiteralPath $TarPath) {
    Remove-Item -LiteralPath $TarPath
}

if (Test-Path -LiteralPath $ExtractedDir) {
    Remove-Item -LiteralPath $ExtractedDir -Recurse
}

Write-Host 'Extracting archive'

Expand-Archive -LiteralPath $GzipPath -OutputPath $SourceDir -ShowProgress
Expand-Archive -LiteralPath $TarPath -OutputPath $SourceDir -ShowProgress

Remove-Item -LiteralPath $TarPath

Push-Location $ExtractedDir
try {
    # Copy version.rc resource script, which will be used to add version information to the built DLLs and EXEs.
    Copy-Item -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath 'version.rc') -Destination $ExtractedDir

    # Apply patches from the patches directory.
    Write-Host 'Applying patches'

    Get-ChildItem -File -Filter '*.diff' -Path (Join-Path -Path $PSScriptRoot -ChildPath 'patches') | Sort-Object -Property Name | ForEach-Object {
        Write-Host "Applying patch $($_.Name)"
        
        & $GitPath apply -p1 $_.FullName
        
        if (-not $?) {
            throw "Failed to apply patch $($_.Name)"
        }
    }
    
    # Setup directories to copy built outputs and packaged zip files to (deleting and recreating if they already exist).
    $OutputsRootDir = Join-Path -Path $PSScriptRoot -ChildPath 'outputs'
    $OutputsDir = Join-Path -Path $OutputsRootDir -ChildPath $PackageVersion
    $PackagesRootDir = Join-Path -Path $PSScriptRoot -ChildPath 'packages'
    $PackagesDir = Join-Path -Path $PackagesRootDir -ChildPath $PackageVersion

    New-Item -ItemType Directory -Force -Path $OutputsRootDir | Out-Null
    
    if (Test-Path -LiteralPath $OutputsDir) {
        Remove-Item -LiteralPath $OutputsDir -Recurse
    }
    
    New-Item -ItemType Directory -Force -Path $PackagesRootDir | Out-Null

    if (Test-Path -LiteralPath $PackagesDir) {
        Remove-Item -LiteralPath $PackagesDir -Recurse
    }

    New-Item -ItemType Directory -Force -Path $PackagesDir | Out-Null

    $VcVarsAllPath = Join-Path -Path (Join-Path -Path $VisualStudioDir -ChildPath 'VC') -ChildPath 'vcvarsall.bat'
    
    # For both x86 and x64 architectues, build then copy and zip the outputs.
    ('x86', 'x86'), ('x64', 'amd64') | ForEach-Object {
        $Architecture = $_[0]
        $VcVars = $_[1]

        Write-Host "Building $Architecture"

        # Build, using vcvarsall.bat to setup the build environment for the current architecture.
        cmd /C "`"$VcVarsAllPath`" $VcVars & nmake -f makefile.msc all"

        if (-not $?) {
            throw "Failed to build $Architecture"
        }

        # Copy outputs to a directory for the current architecture.
        $OutputsArchDir = Join-Path -Path $OutputsDir -ChildPath $Architecture
        New-Item -ItemType Directory -Force -Path $OutputsArchDir | Out-Null

        'libbz2.lib', 'libbz2.dll', 'libbz2.exp', 'libbz2-static.lib', 'bzip2.exe', 'bzip2recover.exe' | ForEach-Object {
            Copy-Item -LiteralPath $_ -Destination $OutputsArchDir
        }

        # Create zip files containing different sets of files.
        ('', ('libbz2.dll', 'bzip2.exe', 'bzip2recover.exe')), ('-dll', ('libbz2.dll')), ('-dev', ('bzlib.h', 'libbz2.lib', 'libbz2.exp', 'libbz2-static.lib')) | ForEach-Object {
            $Suffix = $_[0]
            $Files = $_[1]
            $ZipFile = "bzip2$Suffix-$PackageVersion-win-$Architecture.zip"

            Write-Host "Creating zip $zipFile"

            $Files | Get-Item | Write-Zip -Level 9 -OutputPath (Join-Path -Path $PackagesDir -ChildPath $ZipFile)
        }

        # Clean the source tree.
        cmd /C "`"$VcVarsAllPath`" $VcVars & nmake -f makefile.msc clean"

        if (-not $?) {
            throw "Failed to clean $Architecture"
        }
    }
}
finally {
    Pop-Location
}