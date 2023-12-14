function Import-TomlConfigData {
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

    $content = Get-Content -Path $Path -Raw

    $tomlModel = [Tomlyn.Toml]::ToModel($content)

    foreach ($key in $tomlModel.Keys) {
        if ($tomlModel[$key].GetType().IsValueType -or $tomlModel[$key].GetType().Name -eq 'String') {
            $top = @{$key = $tomlModel[$key] }
            break;
        }
        else {
            $top = @{$key = [Collections.Generic.List[Object]]::new() }
            foreach ($prop in $tomlModel[$key]) {

                $next = @{}
                foreach ($pk in $prop.Keys) {
                    $pv = $prop[$pk]
                    $pvtype = $pv.GetType()

                    if ($pvtype.IsValueType) {
                        $cleanpv = $pv
                    }
                    elseif ($pvtype.Name -eq 'TomlTable') {
                        $cleanpv = @{}
                        $pv.ForEach({ $cleanpv.Add($_.Key, $_.Value) })
                    }
                    elseif ($pvtype.Name -eq 'TomlArray') {
                        $cleanpv = @()
                        $pv.ForEach({ $cleanpv += $_ })
                    }
                    else {
                        $cleanpv = $pv.ToString()
                    }
                    $next.Add($pk, $cleanpv)
                }

                $top[$key].Add($next)
            }
        }
    }

    $top | Write-Output
}