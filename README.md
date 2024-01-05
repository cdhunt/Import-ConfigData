# Import-ConfigData

Load configuration data from multiple file types.

## CI Status

![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/cdhunt/Import-ConfigData/powershell.yml?style=flat&logo=github)
[![Testspace pass ratio](https://img.shields.io/testspace/pass-ratio/cdhunt/cdhunt%3AImport-ConfigData/main)](https://cdhunt.testspace.com/projects/67973/spaces)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/Import-ConfigData.svg?color=%235391FE&label=PowerShellGallery&logo=powershell&style=flat)](https://www.powershellgallery.com/packages/Import-ConfigData)

![Build history](https://buildstats.info/github/chart/cdhunt/Import-ConfigData?branch=main)

## Install

`Install-Module -Name Import-ConfigData` or `Install-PSResource -Name Import-ConfigData`

![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/Import-ConfigData?color=%235391FE&style=flat)

## Docs

[Full Docs](docs)

### Getting Started

Return an object representing the contents of a PowerShell Data File.

```powershell
#config.psd1
@{
    DriveName = "data"
}
```

```powershell
$config = Import-ConfigData -Path config.psd1
$config.DriveName
data
```

These config files all return the same PowerShell object.

```toml
#config.toml
DriveName = "data"
```

```yaml
#config.yml
DriveName: data
```

```json
{
    "DriveName": "data"
}
```
