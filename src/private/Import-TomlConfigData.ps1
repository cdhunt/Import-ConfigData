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
                    $next.Add($pk, $prop[$pk])
                }

                $top[$key].Add($next)
            }
        }
    }

    $top | Write-Output
}