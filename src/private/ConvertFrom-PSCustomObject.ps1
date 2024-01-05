function ConvertFrom-PSCustomObject ($Object) {

    foreach ($item in $Object) {

        $itemType = $item.GetType()

        if ($itemType.Name -eq 'PSCustomObject') {
            $keys = $item | Get-Member -MemberType NoteProperty

            $hash = @{}
            foreach ($key in $keys) {
                $name = $key.Name
                $value = @(ConvertFrom-PSCustomObject $item.$name)
                $hash.Add($name, $value)
            }
            $hash | Write-Output
        }

        if ($itemType.IsValueType -or $itemType.Name -eq 'String') {
            $item | Write-Output
        }
    }
}
