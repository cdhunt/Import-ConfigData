function Import-ConfigData {
    <#
.SYNOPSIS
    Load configuration data from multiple file types.
.DESCRIPTION
    Load configuration data from multiple file types. The returned object should look the same regardless of the source format.
.PARAMETER Path
    Specifies a path to a configuration file with an extention of psd1, toml, yaml, or yml.
.LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_data_files?view=powershell-7.4
.LINK
    https://toml.io/
.LINK
    https://yaml.org/
.LINK
    https://github.com/cloudbase/powershell-yaml
.EXAMPLE
    $config = Import-ConfigData -Path config.psd1
    $config.DriveName
    data

    Return an object representing the contents of a PowerShell Data File.
.EXAMPLE
    $config = Import-ConfigData -Path config.toml
    $config.DriveName
    data

    Return an object representing the contents of a TOML File.
.EXAMPLE
    $config = Import-ConfigData -Path config.yaml
    $config.DriveName
    data

    Return an object representing the contents of a YAML File.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )

    begin {

    }

    process {
        $file = Get-Item -Path $Path -ErrorAction Stop

        switch ($file.Extension) {
            '.psd1' { Import-PowerShellDataFile -Path $Path; break }
            '.toml' { Import-TomlConfigData -Path $Path; break }
            '.yaml' { Import-YamlConfigData -Path $Path; break }
            '.yml' { Import-YamlConfigData -Path $Path; break }
            '.json' {
                $content = Get-Content -Path $Path -Raw
                $content | ConvertFrom-Json; break
            }
        }
    }

    end {

    }
}