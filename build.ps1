#! /usr/bin/pwsh

[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [ValidateSet('clean', 'build', 'test', 'changelog', 'publish', 'docs')]
    [string[]]
    $Task,

    [Parameter(Position = 1)]
    [int]
    $Major,

    [Parameter(Position = 2)]
    [int]
    $Minor,

    [Parameter(Position = 3)]
    [int]
    $Build,

    [Parameter(Position = 4)]
    [int]
    $Revision,

    [Parameter(Position = 5)]
    [string]
    $Prerelease
)

if ( (Get-Command 'nbgv' -CommandType Application -ErrorAction SilentlyContinue) ) {
    if (!$PSBoundParameters.ContainsKey('Major')) { $Major = $(nbgv get-version -v VersionMajor) }
    if (!$PSBoundParameters.ContainsKey('Minor')) { $Minor = $(nbgv get-version -v VersionMinor) }
    if (!$PSBoundParameters.ContainsKey('Build')) { $Build = $(nbgv get-version -v BuildNumber) }
    if (!$PSBoundParameters.ContainsKey('Revision')) { $Revision = $(nbgv get-version -v VersionRevision) }
}

$parent = $PSScriptRoot
$parent = [string]::IsNullOrEmpty($parent) ? $pwd.Path : $parent
$src = Join-Path $parent -ChildPath "src"
$docs = Join-Path $parent -ChildPath "docs"
$publish = Join-Path $parent -ChildPath "publish" -AdditionalChildPath 'Import-ConfigData'
$csproj = Join-Path -Path $src -ChildPath "dotnet" -AdditionalChildPath "dependencies.csproj"
$bin = Join-Path -Path $src -ChildPath "dotnet" -AdditionalChildPath "bin"
$obj = Join-Path -Path $src -ChildPath "dotnet" -AdditionalChildPath "obj"
$lib = Join-Path -Path $publish -ChildPath "lib"

Write-Host "src: $src"
Write-Host "docs: $docs"
Write-Host "publish: $publish"
Write-Host "lib: $lib"
Write-Host "dotnet: $([Environment]::Version)"
Write-Host "ps: $($PSVersionTable.PSVersion)"

$manifest = @{
    Path                 = Join-Path -Path $publish -ChildPath 'Import-ConfigData.psd1'
    Author               = 'Chris Hunt'
    CompanyName          = 'Chris Hunt'
    Copyright            = 'Chris Hunt'
    CompatiblePSEditions = @("Desktop", "Core")
    Description          = 'Load configuration data from multiple file types.'
    LicenseUri           = 'https://github.com/cdhunt/Import-ConfigData/blob/main/LICENSE'
    FunctionsToExport    = @()
    ModuleVersion        = [version]::new($Major, $Minor, $Build, $Revision)
    PowerShellVersion    = '5.1'
    #ProjectUri            = 'https://github.com/cdhunt/Import-ConfigData'
    RootModule           = 'Import-ConfigData.psm1'
    Tags                 = @('development', 'configuration', 'settings', 'storage', 'yaml', 'toml')
    RequiredModules      = @( @{ModuleName = 'powershell-yaml'; ModuleVersion = '0.4.7' } )
}

function Clean {
    param ()

    if (Test-Path $publish) {
        Remove-Item -Path $publish -Recurse -Force
    }
}

function Dependencies {
    param ()

    if ($null -eq (Get-Module -Name 'powershell-yaml' -ListAvailable)) {
        Install-Module 'powershell-yaml' -Scope CurrentUser -Confirm:$false -Force
    }

}

function Build {
    param ()

    New-Item -Path $publish -ItemType Directory -ErrorAction SilentlyContinue | Out-Null

    dotnet publish $csproj -o $lib
    Get-ChildItem -Path $lib -filter "*.json" | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $lib -filter "*.pdb" | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $lib -filter "System.Management.Automation.dll" | Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $lib -filter "dependencies.dll" | Remove-Item -Force -ErrorAction SilentlyContinue

    Copy-Item -Path "$src/Import-ConfigData.psm1" -Destination $publish
    Copy-Item -Path @("$parent/LICENSE", "$parent/README.md") -Destination $publish -ErrorAction SilentlyContinue

    $internalFunctions = Get-ChildItem -Path "$src/internal/Add-PackageTypes.ps1"
    $publicFunctions = Get-ChildItem -Path "$src/public/*.ps1"
    $privateFunctions = Get-ChildItem -Path "$src/private/*.ps1" -ErrorAction SilentlyContinue

    New-Item -Path "$publish/internal" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    foreach ($function in $internalFunctions) {
        Copy-Item -Path $function.FullName -Destination "$publish/internal/$($function.Name)"
    }

    New-Item -Path "$publish/public" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    foreach ($function in $publicFunctions) {
        Copy-Item -Path $function.FullName -Destination "$publish/public/$($function.Name)"
        '. "$PSSCriptRoot/public/{0}"' -f $function.Name | Add-Content "$publish/Import-ConfigData.psm1"
        $manifest.FunctionsToExport += $function.BaseName
    }

    New-Item -Path "$publish/private" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    foreach ($function in $privateFunctions) {
        Copy-Item -Path $function.FullName -Destination "$publish/private/$($function.Name)"
        '. "$PSSCriptRoot/private/{0}"' -f $function.Name | Add-Content "$publish/Import-ConfigData.psm1"
    }

    if ($PSBoundParameters.ContainsKey('Prerelease')) {
        $manifest.Add('Prerelease', $PreRelease)
    }

    New-ModuleManifest @manifest

}

function Test {
    param ()

    if ($null -eq (Get-Module Pester -ListAvailable)) {
        Install-Module -Name Pester -Confirm:$false -Force
    }

    Invoke-Pester -Path test -Output detailed
}


function ChangeLog {
    param ()

}

function Commit {
    param ()

    git rev-parse --short HEAD
}

function Publish {
    param ()

    <# Disabled for now
    $docChanges = git status docs -s

    if ($docChanges.count -gt 0) {
        Write-Warning "There are pending Docs change. Run './build.ps1 docs', review and commit updated docs."
    }
    #>

    $repo = if ($env:PSPublishRepo) { $env:PSPublishRepo } else { 'PSGallery' }

    $notes = ChangeLog
    Publish-Module -Path $publish -Repository $repo -NuGetApiKey $env:PSPublishApiKey -ReleaseNotes $notes
}

function Docs {
    param ()

    Import-Module $publish -Force

    $commands = Get-Command -Module Import-ConfigData
    $HelpToMd = Join-Path -Path $src -ChildPath 'internal' -AdditionalChildPath 'Export-HelpToMd.ps1'
    . $HelpToMd

    @('# Import-ConfigData', [System.Environment]::NewLine) | Set-Content -Path "$docs/README.md"
    $($manifest.Description) | Add-Content -Path "$docs/README.md"
    @('## Cmdlets', [System.Environment]::NewLine) | Add-Content -Path "$docs/README.md"

    foreach ($command in $Commands | Sort-Object -Property Verb) {
        $name = $command.Name
        $docPath = Join-Path -Path $docs -ChildPath "$name.md"
        $help = Get-Help -Name $name

        Export-HelpToMd $help | Set-Content -Path $docPath

        "- [$name]($name.md) $($help.Synopsis)" | Add-Content -Path "$docs/README.md"
    }

    ChangeLog | Set-Content -Path "$parent/Changelog.md"
}

switch ($Task) {
    { $_ -contains 'clean' } {
        Clean
    }
    { $_ -contains 'build' } {
        Clean
        Build
    }
    { $_ -contains 'test' } {
        Dependencies
        Test
    }
    { $_ -contains 'changelog' } {
        ChangeLog
    }
    { $_ -contains 'publish' } {
        Dependencies
        Publish
    }
    { $_ -contains 'docs' } {
        Dependencies
        Docs
    }
    Default {
        Clean
        Build
    }
}