[CmdletBinding()]
param()

# See http://msdn.microsoft.com/en-us/library/hh925568(v=vs.110).aspx for details on how to detect framework versions
# Also see http://support.microsoft.com/kb/318785

function Add-Versions {
    [CmdletBinding()]
    param(
        [string]$NameFormat,

        [Parameter(Mandatory = $true)]
        [string]$View,

        [Parameter(Mandatory = $true)]
        [ref]$LatestValue)

    # Get the install root from the registry.
    $installRoot = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName 'Software\Microsoft\.NETFramework' -ValueName 'InstallRoot'
    if (!$installRoot) {
        return
    }

    # Get the version sub key names.
    $ndpKeyName = 'Software\Microsoft\NET Framework Setup\NDP'
    $versionSubKeyNames =
        Get-RegistrySubKeyNames -Hive 'LocalMachine' -View $View -KeyName $ndpKeyName |
        Where-Object { $_ -like 'v*' }
    foreach ($versionSubKeyName in $versionSubKeyNames) {
        # Get the version.
        $versionKeyName = "$ndpKeyName\$versionSubKeyName"
        $version = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $versionKeyName -ValueName 'Version'
        if ($version) {
            # Check if installed.
            $install = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $versionKeyName -ValueName 'Install'
            if ($install -ne 1) {
                continue
            }

            # Verify the expected install path.
            $version
            $installPath = [System.IO.Path]::Combine($installRoot, $versionSubKeyName)
            if (!(Test-Container -LiteralPath $installPath)) {
                continue
            }

            # Parse the version from the sub key name.
            $versionObject = [System.Version]::Parse($versionSubKeyName.Substring(1))
            $capabilityName = ($NameFormat -f "$($versionObject.Major).$($versionObject.Minor)")

            # Add the capability.
            Write-Capability -Name $capabilityName -Value $installPath
            $LatestValue.Value = $installPath
            continue
        }

        # Check if deprecated.
        $default = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $versionKeyName -ValueName ''
        if ($default -eq 'deprecated') {
            continue
        }

        # Get the profile key names.
        $profileKeyNames =
            Get-RegistrySubKeyNames -Hive 'LocalMachine' -View $View -KeyName $versionKeyName |
            ForEach-Object { "$versionKeyName\$_" }
        foreach ($profileKeyName in $profileKeyNames) {
            # Skip if version not found.
            $version = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $profileKeyName -ValueName 'Version'
            if (!$version) {
                continue
            }

            # Skip if not installed.
            $install = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $profileKeyName -ValueName 'Install'
            if ($install -ne 1) {
                continue
            }

            # Skip if install path value not found.
            $installPath = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $profileKeyName -ValueName 'InstallPath'
            $installPath = "$installPath".TrimEnd([System.IO.Path]::DirectorySeparatorChar)
            if (!$installPath) {
                continue
            }

            # Determine the version string.
            $release = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $profileKeyName -ValueName 'Release'
            $versionString = switch ($release) {
                # We put the releaseVersion into version range, since customer might install beta/preview version .NET Framework.
                # These magic values come from: https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
                378389 { "4.5.0" }
                { $_ -gt 378389 -and $_ -le 378758 } { "4.5.1" }
                { $_ -gt 378758 -and $_ -le 379893 } { "4.5.2" }
                { $_ -gt 379893 -and $_ -le 380995 } { "4.5.3" }
                { $_ -gt 380995 -and $_ -le 393297 } { "4.6.0" }
                { $_ -gt 393297 -and $_ -le 394271 } { "4.6.1" }
                { $_ -gt 394271 -and $_ -le 394806 } { "4.6.2" }
                { $_ -gt 394806 -and $_ -le 460805 } { "4.7.0" }
                { $_ -gt 460805 -and $_ -le 461310 } { "4.7.1" }
                { $_ -gt 461310 -and $_ -le 461814 } { "4.7.2" }
                { $_ -gt 461814 } { "4.8.0"}
            }

            if (!$versionString) {
                continue
            }

            Write-Capability -Name ($NameFormat -f $versionString) -Value $installPath
            $LatestValue.Value = $installPath
        }
    }
}

$latest = $null
Add-Versions -NameFormat 'DotNetFramework_{0}' -View 'Registry32' -LatestValue ([ref]$latest)
Add-Versions -NameFormat 'DotNetFramework_{0}_x64' -View 'Registry64' -LatestValue ([ref]$latest)
if ($latest) {
    Write-Capability -Name 'DotNetFramework' -Value $latest
}

# SIG # Begin signature block
# MIIoRQYJKoZIhvcNAQcCoIIoNjCCKDICAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC0aaovVM6v0u2o
# XGzrZZhCY6U1OHc037uwZhTto6AUmKCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
# Bv9XKydyAAAAAAQEMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjQwOTEyMjAxMTE0WhcNMjUwOTExMjAxMTE0WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQC0KDfaY50MDqsEGdlIzDHBd6CqIMRQWW9Af1LHDDTuFjfDsvna0nEuDSYJmNyz
# NB10jpbg0lhvkT1AzfX2TLITSXwS8D+mBzGCWMM/wTpciWBV/pbjSazbzoKvRrNo
# DV/u9omOM2Eawyo5JJJdNkM2d8qzkQ0bRuRd4HarmGunSouyb9NY7egWN5E5lUc3
# a2AROzAdHdYpObpCOdeAY2P5XqtJkk79aROpzw16wCjdSn8qMzCBzR7rvH2WVkvF
# HLIxZQET1yhPb6lRmpgBQNnzidHV2Ocxjc8wNiIDzgbDkmlx54QPfw7RwQi8p1fy
# 4byhBrTjv568x8NGv3gwb0RbAgMBAAGjggFzMIIBbzAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQU8huhNbETDU+ZWllL4DNMPCijEU4w
# RQYDVR0RBD4wPKQ6MDgxHjAcBgNVBAsTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEW
# MBQGA1UEBRMNMjMwMDEyKzUwMjkyMzAfBgNVHSMEGDAWgBRIbmTlUAXTgqoXNzci
# tW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3JsMGEG
# CCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDExXzIwMTEtMDctMDguY3J0
# MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIBAIjmD9IpQVvfB1QehvpC
# Ge7QeTQkKQ7j3bmDMjwSqFL4ri6ae9IFTdpywn5smmtSIyKYDn3/nHtaEn0X1NBj
# L5oP0BjAy1sqxD+uy35B+V8wv5GrxhMDJP8l2QjLtH/UglSTIhLqyt8bUAqVfyfp
# h4COMRvwwjTvChtCnUXXACuCXYHWalOoc0OU2oGN+mPJIJJxaNQc1sjBsMbGIWv3
# cmgSHkCEmrMv7yaidpePt6V+yPMik+eXw3IfZ5eNOiNgL1rZzgSJfTnvUqiaEQ0X
# dG1HbkDv9fv6CTq6m4Ty3IzLiwGSXYxRIXTxT4TYs5VxHy2uFjFXWVSL0J2ARTYL
# E4Oyl1wXDF1PX4bxg1yDMfKPHcE1Ijic5lx1KdK1SkaEJdto4hd++05J9Bf9TAmi
# u6EK6C9Oe5vRadroJCK26uCUI4zIjL/qG7mswW+qT0CW0gnR9JHkXCWNbo8ccMk1
# sJatmRoSAifbgzaYbUz8+lv+IXy5GFuAmLnNbGjacB3IMGpa+lbFgih57/fIhamq
# 5VhxgaEmn/UjWyr+cPiAFWuTVIpfsOjbEAww75wURNM1Imp9NJKye1O24EspEHmb
# DmqCUcq7NqkOKIG4PVm3hDDED/WQpzJDkvu4FrIbvyTGVU01vKsg4UfcdiZ0fQ+/
# V0hf8yrtq9CkB8iIuk5bBxuPMIIHejCCBWKgAwIBAgIKYQ6Q0gAAAAAAAzANBgkq
# hkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEwOTA5WjB+MQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYDVQQDEx9NaWNyb3NvZnQg
# Q29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIIC
# CgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+laUKq4BjgaBEm6f8MMHt03
# a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc6Whe0t+bU7IKLMOv2akr
# rnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4Ddato88tt8zpcoRb0Rrrg
# OGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+lD3v++MrWhAfTVYoonpy
# 4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nkkDstrjNYxbc+/jLTswM9
# sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6A4aN91/w0FK/jJSHvMAh
# dCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmdX4jiJV3TIUs+UsS1Vz8k
# A/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL5zmhD+kjSbwYuER8ReTB
# w3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zdsGbiwZeBe+3W7UvnSSmn
# Eyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3T8HhhUSJxAlMxdSlQy90
# lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS4NaIjAsCAwEAAaOCAe0w
# ggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRIbmTlUAXTgqoXNzcitW2o
# ynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYD
# VR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBDuRQFTuHqp8cx0SOJNDBa
# BgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2Ny
# bC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3JsMF4GCCsG
# AQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFfMDNfMjIuY3J0MIGfBgNV
# HSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEFBQcCARYzaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1hcnljcHMuaHRtMEAGCCsG
# AQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkAYwB5AF8AcwB0AGEAdABl
# AG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn8oalmOBUeRou09h0ZyKb
# C5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7v0epo/Np22O/IjWll11l
# hJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0bpdS1HXeUOeLpZMlEPXh6
# I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/KmtYSWMfCWluWpiW5IP0
# wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvyCInWH8MyGOLwxS3OW560
# STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBpmLJZiWhub6e3dMNABQam
# ASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJihsMdYzaXht/a8/jyFqGa
# J+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYbBL7fQccOKO7eZS/sl/ah
# XJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbSoqKfenoi+kiVH6v7RyOA
# 9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sLgOppO6/8MO0ETI7f33Vt
# Y5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtXcVZOSEXAQsmbdlsKgEhr
# /Xmfwb1tbWrJUnMTDXpQzTGCGiUwghohAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIGlscItQe4dbGbFjDJcHXKEz
# ijT3xBBsb/V8KoQJjkCYMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAe3Kolswj+Sn8BnMfNh2AdeBKy7oUVsgl+T7lwbOkZ/uwRwrh6fDDO3IZ
# eur66uxi4NQYiEuPz69lQY8/tgMzO9M6yGBae1vebWbqVpC2z/y9S6AIdFYotlPq
# pA8RJQGEbXrR26dR6y8wfgRbFoMZGkyvlyzthPrJp+AYz9oPhsSWIBVNNtjoweLM
# GsejDZf6UlOrDGzlNolrLK8XJXqlCwbhATBOiJTikOz5E5pgeMZW9UcUzapUnJzJ
# rmNGMAg/S1O4Hb567PYDG7Dz+6FuaZ5bS2kbZtaSS+QGGg9I/Fr9NcyuO5t/z25Y
# b2CzdODYJ54PyP7tCBcbsTb4VQ1jbqGCF68wgherBgorBgEEAYI3AwMBMYIXmzCC
# F5cGCSqGSIb3DQEHAqCCF4gwgheEAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFZBgsq
# hkiG9w0BCRABBKCCAUgEggFEMIIBQAIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCC2lHLib+oARwA7lnEWXoOjHDjqku+pxCZbWo+KZAa1DQIGZ+0tmNBz
# GBIyMDI1MDQxNTA4MDcxMS44OVowBIACAfSggdmkgdYwgdMxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVs
# YW5kIE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNO
# OjJBMUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNloIIR/jCCBygwggUQoAMCAQICEzMAAAH5H2eNdauk8bEAAQAAAfkwDQYJ
# KoZIhvcNAQELBQAwfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24x
# EDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlv
# bjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwHhcNMjQw
# NzI1MTgzMTA5WhcNMjUxMDIyMTgzMTA5WjCB0zELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEtMCsGA1UECxMkTWljcm9zb2Z0IElyZWxhbmQgT3Bl
# cmF0aW9ucyBMaW1pdGVkMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046MkExQS0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Uw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC0PUwffIAdYc1WyUL4IFOP
# 8yl3nksM+1CuE3tZ6oWFF4L3EpdKOhtbVkfMdTxXYE4lSJiDt8MnYDEZUbKi9S2A
# ZmDb4Zq4UqTdmOOwtKyp6FgixRCuBf6v9UBNpbz841bLqU7IZnBmnF9XYRfioCHq
# ZvaFp0C691tGXVArW18GVHd914IFAb7JvP0kVnjks3amzw1zXGvjU3xCLcpUkthf
# SJsRsCSSxHhtuzMLO9j691KuNbIoCNHpiBiFoFoPETYoMnaxBEUUX96ALEqCiB0X
# dUgmgIT9a7L0y4SDKl5rUd6LuUUa90tBkfkmjZBHm43yGIxzxnjtFEm4hYI57Ign
# VidGKKJulRnvb7Cm/wtOi/TIfoLkdH8Pz4BPi+q0/nshNewP0M86hvy2O2x589xA
# l5tQ2KrJ/JMvmPn8n7Z34Y8JxcRih5Zn6euxlJ+t3kMczii8KYPeWJ+BifOM6vLi
# CFBP9y+Z0fAWvrIkamFb8cbwZB35wHjDvAak6EdUlvLjiQZUrwzNj2zfYPLVMecm
# DynvLWwQbP8DXLzhm3qAiwhNhpxweEEqnhw5U2t+hFVTHYb/ROvsOTd+kJTy77mi
# Wo8/AqBmznuOX6U6tFWxfUBgSYCfILIaupEDOkZfKTUe80gGlI025MFCTsUG+75i
# mLoDtLZXZOPqXNhZUG+4YQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFInto7qclckj
# 16KPNLlCRHZGWeAAMB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8G
# A1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBs
# BggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4ICAQBmIAmAVuR/uN+H
# H+aZmWcZmulp74canFbGzwjv29RvwZCi7nQzWezuLAbYJx2hdqrtWClWQ1/W68iG
# sZikoIFdD5JonY7QG/C4lHtSyBNoo3SP/J/d+kcPSS0f4SQS4Zez0MEvK3vWK61W
# TCjD2JCZKTiggrxLwCs0alI7N6671N0mMGOxqya4n7arlOOauAQrI97dMCkCKjxx
# 3D9vVwECaO0ju2k1hXk/JEjcrU2G4OB8SPmTKcYX+6LM/U24dLEX9XWSz/a0ISiu
# KJwziTU8lNMDRMKM1uSmYFywAyXFPMGdayqcEK3135R31VrcjD0GzhxyuSAGMu2D
# e9gZhqvrXmh9i1T526n4u5TR3bAEMQbWeFJYdo767bLpKLcBo0g23+k4wpTqXgBb
# S4NZQff04cfcSoUe1OyxldoM6O3JGBuowaaR/wojeohUFknZdCmeES5FuH4CCmZG
# f9rjXQOTtW0+Da4LjbZYsLwfwhWT8V6iJJLi8Wh2GdwV60nRkrfrDEBrcWI+AF5t
# FbJW1nvreoMPPENvSYHocv0cR9Ns37igcKRlrUcqXwHSzxGIUEx/9bv47sQ9n7Aw
# fzB2SNntJux1211GBEBGpHwgU9a6tD6yft+0SJ9qiPO4IRqFIByrzrKPBB5M831g
# b1vfhFO6ueSkP7A8ZMHVZxwymwuUzTCCB3EwggVZoAMCAQICEzMAAAAVxedrngKb
# SZkAAAAAABUwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmlj
# YXRlIEF1dGhvcml0eSAyMDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIy
# NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
# AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXI
# yjVX9gF/bErg4r25PhdgM/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjo
# YH1qUoNEt6aORmsHFPPFdvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1y
# aa8dq6z2Nr41JmTamDu6GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v
# 3byNpOORj7I5LFGc6XBpDco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pG
# ve2krnopN6zL64NF50ZuyjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viS
# kR4dPf0gz3N9QZpGdc3EXzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYr
# bqgSUei/BQOj0XOmTTd0lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlM
# jgK8QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSL
# W6CmgyFdXzB0kZSU2LlQ+QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AF
# emzFER1y7435UsSFF5PAPBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIu
# rQIDAQABo4IB3TCCAdkwEgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIE
# FgQUKqdS/mTEmr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWn
# G1M1GelyMFwGA1UdIARVMFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEW
# M2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5
# Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBi
# AEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV
# 9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3Js
# Lm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAx
# MC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2
# LTIzLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv
# 6lwUtj5OR2R4sQaTlz0xM7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZn
# OlNN3Zi6th542DYunKmCVgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1
# bSNU5HhTdSRXud2f8449xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4
# rPf5KYnDvBewVIVCs/wMnosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU
# 6ZGyqVvfSaN0DLzskYDSPeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDF
# NLB62FD+CljdQDzHVG2dY3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/
# HltEAY5aGZFrDZ+kKNxnGSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdU
# CbFpAUR+fKFhbHP+CrvsQWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKi
# excdFYmNcP7ntdAoGokLjzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTm
# dHRbatGePu1+oDEzfbzL6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZq
# ELQdVTNYs6FwZvKhggNZMIICQQIBATCCAQGhgdmkgdYwgdMxCzAJBgNVBAYTAlVT
# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVs
# YW5kIE9wZXJhdGlvbnMgTGltaXRlZDEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNO
# OjJBMUEtMDVFMC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQCqzlaNY7vNUAqYhx3CGqBm/KnpRqCBgzCB
# gKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNV
# BAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUA
# AgUA66gmCzAiGA8yMDI1MDQxNTAwMjU0N1oYDzIwMjUwNDE2MDAyNTQ3WjB3MD0G
# CisGAQQBhFkKBAExLzAtMAoCBQDrqCYLAgEAMAoCAQACAgvYAgH/MAcCAQACAhJ6
# MAoCBQDrqXeLAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAI
# AgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBAKhrQ2AcQpni
# sxM21ANh6s7i17njZPM6dgVBOMgW0ppzZKGbxNjwUeZfrrHOZYv2/GRH9Fy/isqG
# rD4Ov0OED4kNTICVMPmwrAMWSXJrW2aTKdg1N3ZwQMiSfDCxm+ADzIaaPFfKphA+
# B9YazWBeXhqa3eP3V0j6jMRcsz2NPBG44PwJbl/Rv+ZMy5GgYMczgYoTX3+rreYG
# zhLBUf8E6UULnhMxaaa89Fn+B6uQnWrKoi4BZE4OeB7Yb3CUMY4DF0usZcFiW4OQ
# Xa33Qf3rHhttLJ9sdTt53pgQHCVO23qYSAymADkKSICHtXBOA9WZwaBwQ5AYzIv1
# F2q71sTvY38xggQNMIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMAITMwAAAfkfZ411q6TxsQABAAAB+TANBglghkgBZQMEAgEFAKCCAUowGgYJ
# KoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCCMRQBDWOHy
# nhlKDQEyQBLIC4DvRvLapGChia/rPteiQTCB+gYLKoZIhvcNAQkQAi8xgeowgecw
# geQwgb0EIDkjjMge8I37ZPrpFQ4sJmtQRV2gqUqXxV4I7lJsYtgQMIGYMIGApH4w
# fDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1Jl
# ZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMd
# TWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAH5H2eNdauk8bEAAQAA
# AfkwIgQg0b3B3u1gm73klCUM7796/CpIVPBt3CjFwhFy+fqoZZowDQYJKoZIhvcN
# AQELBQAEggIAknu56NPlxcALErwKrGMKh+VaGfeiOyxtytMJSXd6bGZDcl9SHz8S
# +D1+lh5ejTvoVU31C46BGEP2BXAP4sZdmK4cbVE92uSwrsjI3pvgCdfhX0vm8UxB
# HTNMSTGd86hJBvPDVTWe61sriVKJOy72VN2bcZsNehTM3FJ7KFfeNv8XUDmZxEm3
# ch57cvA0UrhCmoGstbCVwSRhEoi/ji8K65vWboSZXcSNeroGg53hLsZgj5dI+twh
# /0mfzdwzQ3y5wXByk4JY2TTfRw5JKvemWRYffzEHPTUVweOgdBoEyoYO9HJ0iVrV
# ChFuE9oIvxX3/+poB13Quf2haS6dHnsQiK667AV4rHizC3g7iDWVcC3uVTTDIsMj
# aLruVYcC/BfFjJoyaHiuc0XxZ7l19fL8KLGwkbP2OS1/K8/NUCqeGDioJUpo1xhJ
# SoSMGO0xtR7Dt/p/Hgu1dhfi8TgombjSPrm/tmDF3+LaGiMLmNUd+WIiytjWEWqg
# nCV4OOR58HGZKUdI413ZPJvPC5X+F1KqZ3Cx1WUvDuTYY/ruDtTP2oHH0ZZl+4Ln
# C60B40t9Y6ifsdYNIsEbSzN2ObdPfc9XGiznLzhlCjdIXWx8p9TlsNl9MqP+P+2w
# BUsTzZO/MdJrtcIWcQg+fYDO124bf2nmHZW9bB6X7fwsnxas+Rc4hFw=
# SIG # End signature block
