function Get-RegistrySubKeyNames {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string]$Hive,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Default', 'Registry32', 'Registry64')]
        [string]$View,

        [Parameter(Mandatory = $true)]
        [string]$KeyName)

    Write-Host "Checking: hive '$Hive', view '$View', key name '$KeyName'"
    if ($View -eq 'Registry64' -and !([System.Environment]::Is64BitOperatingSystem)) {
        Write-Host "Skipping."
        return
    }

    $baseKey = $null
    $subKey = $null
    try {
        # Open the base key.
        $baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($Hive, $View)

        # Open the sub key as read-only.
        $subKey = $baseKey.OpenSubKey($KeyName, $false)

        # Check if the sub key was found.
        if (!$subKey) {
            Write-Host "Key not found."
            return
        }

        # Get the sub-key names.
        $subKeyNames = $subKey.GetSubKeyNames()
        Write-Host "Sub keys:"
        foreach ($subKeyName in $subKeyNames) {
            Write-Host "  '$subKeyName'"
        }

        return $subKeyNames
    } finally {
        # Dispose the sub key.
        if ($subKey) {
            $null = $subKey.Dispose()
        }

        # Dispose the base key.
        if ($baseKey) {
            $null = $baseKey.Dispose()
        }
    }
}

function Get-RegistryValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string]$Hive,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Default', 'Registry32', 'Registry64')]
        [string]$View,

        [Parameter(Mandatory = $true)]
        [string]$KeyName,

        [string]$ValueName)

    Write-Host "Checking: hive '$Hive', view '$View', key name '$KeyName', value name '$ValueName'"
    if ($View -eq 'Registry64' -and !([System.Environment]::Is64BitOperatingSystem)) {
        Write-Host "Skipping."
        return
    }

    $baseKey = $null
    $subKey = $null
    try {
        # Open the base key.
        $baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($Hive, $View)

        # Open the sub key as read-only.
        $subKey = $baseKey.OpenSubKey($KeyName, $false)

        # Check if the sub key was found.
        if (!$subKey) {
            Write-Host "Key not found."
            return
        }

        # Get the value.
        $value = $subKey.GetValue($ValueName)

        # Check if the value was not found or is empty.
        if ([System.Object]::ReferenceEquals($value, $null) -or
            ($value -is [string] -and !$value)) {

            Write-Host "Value not found or is empty."
            return
        }

        # Return the value.
        Write-Host "Found $($value.GetType().Name) value: '$value'"
        return $value
    } finally {
        # Dispose the sub key.
        if ($subKey) {
            $null = $subKey.Dispose()
        }

        # Dispose the base key.
        if ($baseKey) {
            $null = $baseKey.Dispose()
        }
    }
}

function Get-RegistryValueNames {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('CurrentUser', 'LocalMachine')]
        [string]$Hive,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Default', 'Registry32', 'Registry64')]
        [string]$View,

        [Parameter(Mandatory = $true)]
        [string]$KeyName)

    Write-Host "Checking: hive '$Hive', view '$View', key name '$KeyName', value name '$ValueName'"
    if ($View -eq 'Registry64' -and !([System.Environment]::Is64BitOperatingSystem)) {
        Write-Host "Skipping."
        return
    }

    $baseKey = $null
    $subKey = $null
    try {
        # Open the base key.
        $baseKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey($Hive, $View)

        # Open the sub key as read-only.
        $subKey = $baseKey.OpenSubKey($KeyName, $false)

        # Check if the sub key was found.
        if (!$subKey) {
            Write-Host "Key not found."
            return
        }

        # Get the value names.
        $valueNames = $subKey.GetValueNames()
        Write-Host "Value names:"
        foreach ($valueName in $valueNames) {
            Write-Host "  '$valueName'"
        }

        return $valueNames
    } finally {
        # Dispose the sub key.
        if ($subKey) {
            $null = $subKey.Dispose()
        }

        # Dispose the base key.
        if ($baseKey) {
            $null = $baseKey.Dispose()
        }
    }
}
# SIG # Begin signature block
# MIIoLQYJKoZIhvcNAQcCoIIoHjCCKBoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAGP4rSt8KJtfMH
# IAqrdcafNlUt9FW/c+5zs2b3MQm06qCCDXYwggX0MIID3KADAgECAhMzAAAEBGx0
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
# /Xmfwb1tbWrJUnMTDXpQzTGCGg0wghoJAgEBMIGVMH4xCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBIDIwMTECEzMAAAQEbHQG/1crJ3IAAAAABAQwDQYJYIZIAWUDBAIB
# BQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEO
# MAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIHTyV3S7+7oqoDEF7oYiSL1b
# umvpNNWDjWZZZDWdG+ZSMEIGCisGAQQBgjcCAQwxNDAyoBSAEgBNAGkAYwByAG8A
# cwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20wDQYJKoZIhvcNAQEB
# BQAEggEAXlEDnsvpPbGnyyM9wCvrqGABWxbjsmf0jLYCgNcEi81PU38DdGWZibGW
# hyWZY9XZHYH5R4Sv1GnInZcnONC74SJ76PCWvCLdsFaGo7oFCjMzs74FxCI4LLkZ
# HwrM28pNBXf4PY2R5ZmT1k/Zd7edfy8Lw8Msh60belbEg7mM9SBsjbR0ygHSVL6K
# d+HDXStYDDBnra4Oy4idqIcw+VgCHvQYGJN0FSnaGJNml7LndYRwvPkVgARqatzh
# 2K6ItYPfYu5bjmlF+Qb/X/XGpfZS0UNsGB35RJb6pRzdhZdhpqwT8KktI+001WDN
# JqrcIwg2yr2x62a5SMoynAd686jXTqGCF5cwgheTBgorBgEEAYI3AwMBMYIXgzCC
# F38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZIAWUDBAIBBQAwggFSBgsq
# hkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGEWQoDATAxMA0GCWCGSAFl
# AwQCAQUABCAHvOwzyGP1L29jJX7Bcjdn9PhUT6yUmUqrb0F3FDh+EwIGZ/fJL2hB
# GBMyMDI1MDQxNTA4MDY1Ni45MDFaMASAAgH0oIHRpIHOMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046OTIwMC0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Wg
# ghHtMIIHIDCCBQigAwIBAgITMwAAAgkIB+D5XIzmVQABAAACCTANBgkqhkiG9w0B
# AQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYD
# VQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMDAeFw0yNTAxMzAxOTQy
# NTVaFw0yNjA0MjIxOTQyNTVaMIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25z
# MScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046OTIwMC0wNUUwLUQ5NDcxJTAjBgNV
# BAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2UwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDClEow9y4M3f1S9z1xtNEETwWL1vEiiw0oD7SXEdv4
# sdP0xsVyidv6I2rmEl8PYs9LcZjzsWOHI7dQkRL28GP3CXcvY0Zq6nWsHY2QamCZ
# FLF2IlRH6BHx2RkN7ZRDKms7BOo4IGBRlCMkUv9N9/twOzAkpWNsM3b/BQxcwhVg
# sQqtQ8NEPUuiR+GV5rdQHUT4pjihZTkJwraliz0ZbYpUTH5Oki3d3Bpx9qiPriB6
# hhNfGPjl0PIp23D579rpW6ZmPqPT8j12KX7ySZwNuxs3PYvF/w13GsRXkzIbIyLK
# EPzj9lzmmrF2wjvvUrx9AZw7GLSXk28Dn1XSf62hbkFuUGwPFLp3EbRqIVmBZ42w
# cz5mSIICy3Qs/hwhEYhUndnABgNpD5avALOV7sUfJrHDZXX6f9ggbjIA6j2nhSAS
# Iql8F5LsKBw0RPtDuy3j2CPxtTmZozbLK8TMtxDiMCgxTpfg5iYUvyhV4aqaDLwR
# BsoBRhO/+hwybKnYwXxKeeOrsOwQLnaOE5BmFJYWBOFz3d88LBK9QRBgdEH5CLVh
# 7wkgMIeh96cH5+H0xEvmg6t7uztlXX2SV7xdUYPxA3vjjV3EkV7abSHD5HHQZTrd
# 3FqsD/VOYACUVBPrxF+kUrZGXxYInZTprYMYEq6UIG1DT4pCVP9DcaCLGIOYEJ1g
# 0wIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFEmL6NHEXTjlvfAvQM21dzMWk8rSMB8G
# A1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8GA1UdHwRYMFYwVKBSoFCG
# Tmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUy
# MFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBsBggrBgEFBQcBAQRgMF4w
# XAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2Vy
# dHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUyMDIwMTAoMSkuY3J0MAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwDgYDVR0PAQH/BAQD
# AgeAMA0GCSqGSIb3DQEBCwUAA4ICAQBcXnxvODwk4h/jbUBsnFlFtrSuBBZb7wSZ
# fa5lKRMTNfNlmaAC4bd7Wo0I5hMxsEJUyupHwh4kD5qkRZczIc0jIABQQ1xDUBa+
# WTxrp/UAqC17ijFCePZKYVjNrHf/Bmjz7FaOI41kxueRhwLNIcQ2gmBqDR5W4TS2
# htRJYyZAs7jfJmbDtTcUOMhEl1OWlx/FnvcQbot5VPzaUwiT6Nie8l6PZjoQsuxi
# asuSAmxKIQdsHnJ5QokqwdyqXi1FZDtETVvbXfDsofzTta4en2qf48hzEZwUvbkz
# 5smt890nVAK7kz2crrzN3hpnfFuftp/rXLWTvxPQcfWXiEuIUd2Gg7eR8QtyKtJD
# U8+PDwECkzoaJjbGCKqx9ESgFJzzrXNwhhX6Rc8g2EU/+63mmqWeCF/kJOFg2eJw
# 7au/abESgq3EazyD1VlL+HaX+MBHGzQmHtvOm3Ql4wVTN3Wq8X8bCR68qiF5rFas
# m4RxF6zajZeSHC/qS5336/4aMDqsV6O86RlPPCYGJOPtf2MbKO7XJJeL/UQN0c3u
# ix5RMTo66dbATxPUFEG5Ph4PHzGjUbEO7D35LuEBiiG8YrlMROkGl3fBQl9bWbgw
# 9CIUQbwq5cTaExlfEpMdSoydJolUTQD5ELKGz1TJahTidd20wlwi5Bk36XImzsH4
# Ys15iXRfAjCCB3EwggVZoAMCAQICEzMAAAAVxedrngKbSZkAAAAAABUwDQYJKoZI
# hvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAw
# DgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24x
# MjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eSAy
# MDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIyNVowfDELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRp
# bWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXIyjVX9gF/bErg4r25Phdg
# M/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjoYH1qUoNEt6aORmsHFPPF
# dvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1yaa8dq6z2Nr41JmTamDu6
# GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v3byNpOORj7I5LFGc6XBp
# Dco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pGve2krnopN6zL64NF50Zu
# yjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viSkR4dPf0gz3N9QZpGdc3E
# XzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYrbqgSUei/BQOj0XOmTTd0
# lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlMjgK8QmguEOqEUUbi0b1q
# GFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSLW6CmgyFdXzB0kZSU2LlQ
# +QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AFemzFER1y7435UsSFF5PA
# PBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIurQIDAQABo4IB3TCCAdkw
# EgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQUKqdS/mTEmr6CkTxG
# NSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMFwGA1UdIARV
# MFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAK
# BggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMC
# AYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV9lbLj+iiXGJo0T2UkFvX
# zpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20v
# cGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAxMC0wNi0yMy5jcmwwWgYI
# KwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIzLmNydDANBgkqhkiG
# 9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv6lwUtj5OR2R4sQaTlz0x
# M7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZnOlNN3Zi6th542DYunKmC
# VgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1bSNU5HhTdSRXud2f8449
# xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4rPf5KYnDvBewVIVCs/wM
# nosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU6ZGyqVvfSaN0DLzskYDS
# PeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDFNLB62FD+CljdQDzHVG2d
# Y3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/HltEAY5aGZFrDZ+kKNxn
# GSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdUCbFpAUR+fKFhbHP+Crvs
# QWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKiexcdFYmNcP7ntdAoGokL
# jzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTmdHRbatGePu1+oDEzfbzL
# 6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZqELQdVTNYs6FwZvKhggNQ
# MIICOAIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJpY2EgT3BlcmF0aW9uczEn
# MCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjkyMDAtMDVFMC1EOTQ3MSUwIwYDVQQD
# ExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMKAQEwBwYFKw4DAhoDFQB8
# 762rPTQd7InDCQdb1kgFKQkCRKCBgzCBgKR+MHwxCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1w
# IFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA66g2DTAiGA8yMDI1MDQxNTAxMzQw
# NVoYDzIwMjUwNDE2MDEzNDA1WjB3MD0GCisGAQQBhFkKBAExLzAtMAoCBQDrqDYN
# AgEAMAoCAQACAhTHAgH/MAcCAQACAhHdMAoCBQDrqYeNAgEAMDYGCisGAQQBhFkK
# BAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAIAgEAAgMBhqAwDQYJ
# KoZIhvcNAQELBQADggEBAI05FfW7xohzS4m9dV2dI0q35SvwQNi0DGV+aVKBSIXL
# nxhWbrZEJzXMUPXAJBy9eXzVmYETisUTboonWmwY+KNLHxCanWKoGfrFRIMjDWqN
# Shvftc7D8v7Utj5wjta2AAdgHfg9CnMSbvC/+3GS0t4yEIpGf0q6F3snmaa7lMke
# 4hs79JfkyUDp1sz21AAO2Jmev/KX/XuWtwvKmAieUuPpMLmQQ8hVhkPkbY8VUuFy
# ZUppnExoLLrO8dz4nYUont1DN7pjBIlPzQjCWbQH7Lqe49e7aMADMcB0lt8azLG/
# rWnO9wnSpqXG8kKXoaTco3lY9RotvYSKsR19Iy7S84oxggQNMIIECQIBATCBkzB8
# MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVk
# bW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1N
# aWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAAAgkIB+D5XIzmVQABAAAC
# CTANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEE
# MC8GCSqGSIb3DQEJBDEiBCBxmvAuyh5WLvuKpsoUczzH/1WNY1WoBAj/CiIWBB54
# vzCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIGgbLB7IvfQCLmUOUZhjdUqK
# 8bikfB6ZVVdoTjNwhRM+MIGYMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgT
# Cldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29m
# dCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENB
# IDIwMTACEzMAAAIJCAfg+VyM5lUAAQAAAgkwIgQgrqEX+3RuPGnURAeJhJ9oHb6j
# 7hXhUTUVxAJNnQN6FZAwDQYJKoZIhvcNAQELBQAEggIAFnyGDVFcFyaBDS6KFtg5
# zodgywPGkVnLX+3agR7aqU2Bff34z34wuD/haq8t3Upms2+NzietdlcLlezwgOGd
# qdnQzvXPkB5nJ+XYlBw4VplmFyk4J/0UjV0pwRNEzQ58yswu83Xzuz0IjONt2/Zn
# kDF7fxViGyNTAScPj/OWv7J3UMTbFWgM+2cvXSs3ZtMbrjpG18ioW4i60t162rIr
# Ki2JvVD6DFoCtayhT9GLAbxtAdNkT/2NY8v/GtdtwPhyRh7ffnpMiSRzMAqSnNPx
# 28CeTlssP0fbih7O5lipr5hIiN/vhbVWhe7Og6BXHWj2J5hHsKpt47E60T+NDkbg
# IXExhY+W6EFblnFZbkVhImxWnKw605XVuxjEdm0II4VO/z1zJYWvND9v+4wIJrZU
# kq9xI/RwIeDlgkGsg/L9D9qrMAV1YlPuOVkXneYvAh3AUONKUb9dRTfNKCE+V+dU
# SuyEj4dJsalloH+SfGOb3Gh/Wt3lYN0VJS8aGqYjxDRyWkA6Qcp2PNicx7O32rbB
# kdRZDZE2r68k0szVsuqsUfmSgZHFyvkG0TUgIJ5sBUylFpy7hkfSqR5sK6ujo+1N
# cOQEHj/+13tGnUI5+z133gy4P/44D5PfZet/BCGv4U/4Odb7gMkVFTqzloYVM9d9
# 5izO69PVuCZj2OF2NpiJ0ro=
# SIG # End signature block
