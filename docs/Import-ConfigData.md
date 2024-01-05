# Import-ConfigData

Load configuration data from multiple file types. The returned object should look the same regardless of the source format.

## Parameters

### Parameter Set 1

- `[String]` **Path** _Specifies a path to a configuration file with an extention of psd1, toml, json, yaml, or yml._ Mandatory, ValueFromPipeline

## Examples

### Example 1

Return an object representing the contents of a PowerShell Data File.

```powershell
$config = Import-ConfigData -Path config.psd1
$config.DriveName
data
```
### Example 2

Return an object representing the contents of a TOML File.

```powershell
$config = Import-ConfigData -Path config.toml
$config.DriveName
data
```
### Example 3

Return an object representing the contents of a YAML File.

```powershell
$config = Import-ConfigData -Path config.yaml
$config.DriveName
data
```

## Links

- [https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_data_files?view=powershell-7.4](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_data_files?view=powershell-7.4)
- [https://toml.io/](https://toml.io/)
- [https://yaml.org/](https://yaml.org/)
- [https://github.com/cloudbase/powershell-yaml](https://github.com/cloudbase/powershell-yaml)
