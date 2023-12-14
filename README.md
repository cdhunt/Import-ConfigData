# Import-ConfigData

Load configuration data from multiple file types.

## CI Status

[![PowerShell](https://github.com/cdhunt/Import-ConfigData/actions/workflows/powershell.yml/badge.svg)](https://github.com/cdhunt/Import-ConfigData/actions/workflows/powershell.yml)

## Install

[powershellgallery.com/packages/Import-ConfigData](https://www.powershellgallery.com/packages/Import-ConfigData)

`Install-Module -Name Import-ConfigData` or `Install-PSResource -Name Import-ConfigData`

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
