# Import-ConfigData

Load configuration data from multiple file types.

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
