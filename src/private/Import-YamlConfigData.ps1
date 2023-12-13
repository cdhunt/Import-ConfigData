function Import-YamlConfigData {
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

        $content = Get-Content -Path $Path -Raw

        ConvertFrom-Yaml -Yaml $content

    }

    end {

    }
}