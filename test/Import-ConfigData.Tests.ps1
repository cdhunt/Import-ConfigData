BeforeAll {

    Import-Module "$PSScriptRoot/../publish/Import-ConfigData" -Force

}

Describe 'ConvertFrom-PSCustomObject' {
    Context 'Object Array' {
        BeforeAll {
            . "$PSScriptRoot/../publish/Import-ConfigData/private/ConvertFrom-PSCustomObject.ps1"
        }

        AfterAll {
            Remove-Item "function:/ConvertFrom-PSCustomObject"
        }

        It 'Should return an array of two objects' {
            $sut = Get-Content -Path "$PSScriptRoot/test2/TestConfig.json" -Raw | ConvertFrom-Json
            $result = ConvertFrom-PSCustomObject $sut
            $result.ObjectArray.Count | Should -Be 2
        }

        It 'Should return an array of one object' {
            $sut = Get-Content -Path "$PSScriptRoot/test3/TestConfig.json" -Raw | ConvertFrom-Json
            $result = ConvertFrom-PSCustomObject $sut
            $result.plan.Count | Should -Be 1
        }
    }
}

Describe 'Import-ConfigData' {
    Context 'Simple Object' {
        It 'Should import a <type> file' -ForEach @(
            @{ config = "$PSScriptRoot/test1/TestConfig.psd1"; type = 'PSD1' }
            @{ config = "$PSScriptRoot/test1/TestConfig.toml"; type = 'TOML' }
            @{ config = "$PSScriptRoot/test1/TestConfig.yml"; type = 'YAML' }
            @{ config = "$PSScriptRoot/test1/TestConfig.json"; type = 'JSON' }
        ) {
            $results = Import-ConfigData -Path $config

            $results.DriveName  | Should -BeExactly 'data'
            $results | Should -BeOfType 'Hashtable'
        }
    }
    Context 'ObjectArray' {

        It 'Should import a <type> file' -ForEach @(
            @{ config = "$PSScriptRoot/test2/TestConfig.psd1"; type = 'PSD1' }
            @{ config = "$PSScriptRoot/test2/TestConfig.toml"; type = 'TOML' }
            @{ config = "$PSScriptRoot/test2/TestConfig.yml"; type = 'YAML' }
            @{ config = "$PSScriptRoot/test2/TestConfig.json"; type = 'JSON' }
        ) {
            $results = Import-ConfigData -Path $config

            $results.ObjectArray.Count | Should -Be 2
            $results.ObjectArray[0].PropertyString | Should -BeExactly 'test_value'
            $results.ObjectArray[0].PropertyInt | Should -Be 1
            $results.ObjectArray[0].PropertyBool | Should -Be $true
            $results.ObjectArray[0].PropertyList.Count | Should -Be 3
            $results.ObjectArray[0].PropertyList[0] | Should -Be 4
            $results.ObjectArray[0].PropertyList[1] | Should -Be 5
            $results.ObjectArray[0].PropertyList[2] | Should -Be 6

            $results.ObjectArray[1].PropertyString | Should -BeExactly 'test_value_2'
            $results.ObjectArray[1].PropertyInt | Should -Be 2
            $results.ObjectArray[1].PropertyBool | Should -Be $false
            $results.ObjectArray[1].PropertyList.Count | Should -Be 2
            $results.ObjectArray[1].PropertyList[0] | Should -Be "one"
            $results.ObjectArray[1].PropertyList[1] | Should -Be "two"
        }
    }
    Context 'httpunitPS Object' {
        It 'Should import a <type> file' -ForEach @(
            @{ config = "$PSScriptRoot/test3/TestConfig.psd1"; type = 'PSD1' }
            @{ config = "$PSScriptRoot/test3/TestConfig.toml"; type = 'TOML' }
            @{ config = "$PSScriptRoot/test3/TestConfig.yml"; type = 'YAML' }
            @{ config = "$PSScriptRoot/test3/TestConfig.json"; type = 'JSON' }
        ) {
            $results = Import-ConfigData -Path $config

            $results.plan.Count | Should -Be 1
            $results.plan[0]['url'] | Should -Be 'https://www.google.com'
            $results.plan[0]['timeout'] | Should -BeExactly '0:0:10'
            $results.plan[0]['headers'] | Should -BeOfType 'Hashtable'
            $results.plan[0]['code'] | Should -Be 200
            $results.plan[0]['label'] | Should -BeExactly 'google'
        }
    }
}

AfterAll {
    Remove-Module Import-ConfigData
}