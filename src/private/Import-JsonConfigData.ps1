function Import-JsonConfigData {
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

    switch ($PSVersionTable.PSVersion.Major) {
        5 {
            $psObject = $content | ConvertFrom-Json
            ConvertFrom-PSCustomObject $psObject
            break
        }
        Default {
            $content | ConvertFrom-Json -AsHashtable
        }
    }

}