$csvFileName = "\\192.168.131.10\b2kcy\Software\inventory\" + $env:computername +"_" + $env:UserName + ".csv"

$results = @()
if (Test-Path $csvFileName)
{
    Remove-Item $csvFileName
    #$results += Import-Csv -Path $csvFileName
}

function Decode {
     If ($args[0] -is [System.Array]) {
         [System.Text.Encoding]::ASCII.GetString($args[0])
     }
     Else {
         "Not Found"
     }
 } 


$env:HostIP = (
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected"
    }
).IPv4Address.IPAddress

$env:HostMacAddress = (
Get-WmiObject win32_networkadapterconfiguration |  
    Where-Object {
        $_.IPAddress -NE $null
    }
).MacAddress

$details = @{            
            AssetID=$env:computername
            Username=$env:UserName
            ComputerName = $env:computername
            IP      = $env:HostIP 
            MacAddress      = $env:HostMacAddress
            DeviceType = "Laptop"
            Manufacturer = Invoke-Command {gwmi Win32_ComputerSystem | Select –ExpandProperty Manufacturer} 
            Model = Invoke-Command {gwmi Win32_ComputerSystem | Select –ExpandProperty Model} 
            SerialNo = Invoke-Command {gwmi win32_bios | Select –ExpandProperty SerialNumber}
        }  
        
$results += New-Object PSObject -Property $details


$i =0
 ForEach ($Monitor in Get-WmiObject WmiMonitorID -Namespace root\wmi) {  
     $serialNo = Decode $Monitor.SerialNumberID -notmatch 0
     $manufacturer= (Decode $Monitor.ManufacturerName -notmatch 0 | out-string).trim()

     $details = @{            
            AssetID=$manufacturer + "_" +  $serialNo + "_" + $i.ToString()
            Username=$env:UserName
            ComputerName = $env:computername
            IP = ""
            MacAddress=""
            DeviceType = "Monitor" 
            Manufacturer = Decode $Monitor.ManufacturerName -notmatch 0
            Model =Decode $Monitor.UserFriendlyName -notmatch 0
            SerialNo = $serialNo
        }  
    $results += New-Object PSObject -Property $details
    $i++
 }

$results | Select-Object "AssetID","Username", "ComputerName", "IP","MacAddress","DeviceType","Manufacturer","Model" ,"SerialNo" | export-csv  -NoTypeInformation -Force -Path $csvFileName
Get-Content -Path $csvFileName 

# SIG # Begin signature block
# MIIW7gYJKoZIhvcNAQcCoIIW3zCCFtsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1Dxt1r1tK+ZiR4l25jrUMWKQ
# ok6gghEnMIIDKDCCAhCgAwIBAgIQbcORmQk2LI9Kiyce7UQ+CzANBgkqhkiG9w0B
# AQsFADAsMSowKAYDVQQDDCFCMkNZIENlcnRpZmljYXRlIEFUQSBBdXRoZW50aWNv
# ZGUwHhcNMjEwOTAzMDgxMTU0WhcNMjIwOTAzMDgzMTU0WjAsMSowKAYDVQQDDCFC
# MkNZIENlcnRpZmljYXRlIEFUQSBBdXRoZW50aWNvZGUwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQDWoVWoE9c9ghc20n31sgUHW72yAT95DBScVNYTFt+b
# ZtbuJZ6Mh0MMex1ItSdp9jamWNTSiRURo6yWxveKO8idpih6biMhRu+RBqme+0zg
# xLRcquvX/jDLz9Jqnwn3RHZPFIE8rfMqoU3qK2IUTdsSVUYE9jk1fldBD61fE6MS
# AzTdIN6AcPC0JI/zphGDM/NKfhroOLhSvRAgg+c9tIFZuPaBt7/hsGtVR07soyx3
# 27hq3qJTjHq2JrSzq9dQkKJkmZqp3xh568k1Ef3aKuP42a7k1SV3xs/YGfiLcCsQ
# PXFDxLajrphfD2U7R1o5cNdtHtRnBrz8yxBAmee/cLt9AgMBAAGjRjBEMA4GA1Ud
# DwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUTTjOAsvf
# xZYHqMvEM2SAjSyDp4UwDQYJKoZIhvcNAQELBQADggEBADfEla0oh33QWsUCgbI1
# q7Wziqd5GoZMNclmzxS2hjPlj4Kh8q05D4TrBpPZ+V7FR4TR5BlHM6DgGNu+/m/R
# CJ9JYG3sabykfEs3jJgfx3HUep2O606rYr+swLNNHkOSz5kvds0poURc/Awyda1s
# voouVFj5w8De88F5zUNw7OJ1qBZIvlNp2Sz/qIQ6abk8dcnGQtJ2cM6PO1ulzzBJ
# cQLbmQOKuoQy7f5MxPIfDCjIKtOUeJ7LPXXiHxht1BHbnZBu0qY7McOIIoSW8tfV
# ZCxDjK5heuadP70GKVdtYkd+Zwi3x/ZzESQ21iVZW1l7qPissMTW17Xkv6SuesYn
# wmMwggbsMIIE1KADAgECAhAwD2+s3WaYdHypRjaneC25MA0GCSqGSIb3DQEBDAUA
# MIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNleTEUMBIGA1UEBxML
# SmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEuMCwG
# A1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0x
# OTA1MDIwMDAwMDBaFw0zODAxMTgyMzU5NTlaMH0xCzAJBgNVBAYTAkdCMRswGQYD
# VQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNV
# BAoTD1NlY3RpZ28gTGltaXRlZDElMCMGA1UEAxMcU2VjdGlnbyBSU0EgVGltZSBT
# dGFtcGluZyBDQTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMgbAa/Z
# LH6ImX0BmD8gkL2cgCFUk7nPoD5T77NawHbWGgSlzkeDtevEzEk0y/NFZbn5p2QW
# Jgn71TJSeS7JY8ITm7aGPwEFkmZvIavVcRB5h/RGKs3EWsnb111JTXJWD9zJ41OY
# Oioe/M5YSdO/8zm7uaQjQqzQFcN/nqJc1zjxFrJw06PE37PFcqwuCnf8DZRSt/wf
# lXMkPQEovA8NT7ORAY5unSd1VdEXOzQhe5cBlK9/gM/REQpXhMl/VuC9RpyCvpSd
# v7QgsGB+uE31DT/b0OqFjIpWcdEtlEzIjDzTFKKcvSb/01Mgx2Bpm1gKVPQF5/0x
# rPnIhRfHuCkZpCkvRuPd25Ffnz82Pg4wZytGtzWvlr7aTGDMqLufDRTUGMQwmHSC
# Ic9iVrUhcxIe/arKCFiHd6QV6xlV/9A5VC0m7kUaOm/N14Tw1/AoxU9kgwLU++Le
# 8bwCKPRt2ieKBtKWh97oaw7wW33pdmmTIBxKlyx3GSuTlZicl57rjsF4VsZEJd8G
# EpoGLZ8DXv2DolNnyrH6jaFkyYiSWcuoRsDJ8qb/fVfbEnb6ikEk1Bv8cqUUotSt
# QxykSYtBORQDHin6G6UirqXDTYLQjdprt9v3GEBXc/Bxo/tKfUU2wfeNgvq5yQ1T
# gH36tjlYMu9vGFCJ10+dM70atZ2h3pVBeqeDAgMBAAGjggFaMIIBVjAfBgNVHSME
# GDAWgBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUGqH4YRkgD8NBd0Uo
# jtE1XwYSBFUwDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwEwYD
# VR0lBAwwCgYIKwYBBQUHAwgwEQYDVR0gBAowCDAGBgRVHSAAMFAGA1UdHwRJMEcw
# RaBDoEGGP2h0dHA6Ly9jcmwudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RSU0FDZXJ0
# aWZpY2F0aW9uQXV0aG9yaXR5LmNybDB2BggrBgEFBQcBAQRqMGgwPwYIKwYBBQUH
# MAKGM2h0dHA6Ly9jcnQudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RSU0FBZGRUcnVz
# dENBLmNydDAlBggrBgEFBQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0LmNvbTAN
# BgkqhkiG9w0BAQwFAAOCAgEAbVSBpTNdFuG1U4GRdd8DejILLSWEEbKw2yp9KgX1
# vDsn9FqguUlZkClsYcu1UNviffmfAO9Aw63T4uRW+VhBz/FC5RB9/7B0H4/GXAn5
# M17qoBwmWFzztBEP1dXD4rzVWHi/SHbhRGdtj7BDEA+N5Pk4Yr8TAcWFo0zFzLJT
# MJWk1vSWVgi4zVx/AZa+clJqO0I3fBZ4OZOTlJux3LJtQW1nzclvkD1/RXLBGyPW
# wlWEZuSzxWYG9vPWS16toytCiiGS/qhvWiVwYoFzY16gu9jc10rTPa+DBjgSHSSH
# LeT8AtY+dwS8BDa153fLnC6NIxi5o8JHHfBd1qFzVwVomqfJN2Udvuq82EKDQwWl
# i6YJ/9GhlKZOqj0J9QVst9JkWtgqIsJLnfE5XkzeSD2bNJaaCV+O/fexUpHOP4n2
# HKG1qXUfcb9bQ11lPVCBbqvw0NP8srMftpmWJvQ8eYtcZMzN7iea5aDADHKHwW5N
# WtMe6vBE5jJvHOsXTpTDeGUgOw9Bqh/poUGd/rG4oGUqNODeqPk85sEwu8CgYyz8
# XBYAqNDEf+oRnR4GxqZtMl20OAkrSQeq/eww2vGnL8+3/frQo4TZJ577AWZ3uVYQ
# 4SBuxq6x+ba6yDVdM3aO8XwgDCp3rrWiAoa6Ke60WgCxjKvj+QrJVF3UuWp0nr1I
# rpgwggcHMIIE76ADAgECAhEAjHegAI/00bDGPZ86SIONazANBgkqhkiG9w0BAQwF
# ADB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAw
# DgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJTAjBgNV
# BAMTHFNlY3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcgQ0EwHhcNMjAxMDIzMDAwMDAw
# WhcNMzIwMTIyMjM1OTU5WjCBhDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0
# ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMSwwKgYDVQQDDCNTZWN0aWdvIFJTQSBUaW1lIFN0YW1waW5nIFNp
# Z25lciAjMjCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAJGHSyyLwfEe
# oJ7TB8YBylKwvnl5XQlmBi0vNX27wPsn2kJqWRslTOrvQNaafjLIaoF9tFw+VhCB
# NToiNoz7+CAph6x00BtivD9khwJf78WA7wYc3F5Ok4e4mt5MB06FzHDFDXvsw9nj
# l+nLGdtWRWzuSyBsyT5s/fCb8Sj4kZmq/FrBmoIgOrfv59a4JUnCORuHgTnLw7c6
# zZ9QBB8amaSAAk0dBahV021SgIPmbkilX8GJWGCK7/GszYdjGI50y4SHQWljgbz2
# H6p818FBzq2rdosggNQtlQeNx/ULFx6a5daZaVHHTqadKW/neZMNMmNTrszGKYog
# wWDG8gIsxPnIIt/5J4Khg1HCvMmCGiGEspe81K9EHJaCIpUqhVSu8f0+SXR0/I6u
# P6Vy9MNaAapQpYt2lRtm6+/a35Qu2RrrTCd9TAX3+CNdxFfIJgV6/IEjX1QJOCpi
# 1arK3+3PU6sf9kSc1ZlZxVZkW/eOUg9m/Jg/RAYTZG7p4RVgUKWx7M+46MkLvsWE
# 990Kndq8KWw9Vu2/eGe2W8heFBy5r4Qtd6L3OZU3b05/HMY8BNYxxX7vPehRfnGt
# JHQbLNz5fKrvwnZJaGLVi/UD3759jg82dUZbk3bEg+6CviyuNxLxvFbD5K1Dw7dm
# ll6UMvqg9quJUPrOoPMIgRrRRKfM97gxAgMBAAGjggF4MIIBdDAfBgNVHSMEGDAW
# gBQaofhhGSAPw0F3RSiO0TVfBhIEVTAdBgNVHQ4EFgQUaXU3e7udNUJOv1fTmtuf
# AdGu3tAwDgYDVR0PAQH/BAQDAgbAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAww
# CgYIKwYBBQUHAwgwQAYDVR0gBDkwNzA1BgwrBgEEAbIxAQIBAwgwJTAjBggrBgEF
# BQcCARYXaHR0cHM6Ly9zZWN0aWdvLmNvbS9DUFMwRAYDVR0fBD0wOzA5oDegNYYz
# aHR0cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0aWdvUlNBVGltZVN0YW1waW5nQ0Eu
# Y3JsMHQGCCsGAQUFBwEBBGgwZjA/BggrBgEFBQcwAoYzaHR0cDovL2NydC5zZWN0
# aWdvLmNvbS9TZWN0aWdvUlNBVGltZVN0YW1waW5nQ0EuY3J0MCMGCCsGAQUFBzAB
# hhdodHRwOi8vb2NzcC5zZWN0aWdvLmNvbTANBgkqhkiG9w0BAQwFAAOCAgEASgN4
# kEIz7Hsagwk2M5hVu51ABjBrRWrxlA4ZUP9bJV474TnEW7rplZA3N73f+2Ts5YK3
# lcxXVXBLTvSoh90ihaZXu7ghJ9SgKjGUigchnoq9pxr1AhXLRFCZjOw+ugN3poIC
# kMIuk6m+ITR1Y7ngLQ/PATfLjaL6uFqarqF6nhOTGVWPCZAu3+qIFxbradbhJb1F
# CJeA11QgKE/Ke7OzpdIAsGA0ZcTjxcOl5LqFqnpp23WkPnlomjaLQ6421GFyPA6F
# Yg2gXnDbZC8Bx8GhxySUo7I8brJeotD6qNG4JRwW5sDVf2gaxGUpNSotiLzqrnTW
# gufAiLjhT3jwXMrAQFzCn9UyHCzaPKw29wZSmqNAMBewKRaZyaq3iEn36AslM7U/
# ba+fXwpW3xKxw+7OkXfoIBPpXCTH6kQLSuYThBxN6w21uIagMKeLoZ+0LMzAFiPJ
# keVCA0uAzuRN5ioBPsBehaAkoRdA1dvb55gQpPHqGRuAVPpHieiYgal1wA7f0GiU
# eaGgno62t0Jmy9nZay9N2N4+Mh4g5OycTUKNncczmYI3RNQmKSZAjngvue76L/Hx
# j/5QuHjdFJbeHA5wsCqFarFsaOkq5BArbiH903ydN+QqBtbD8ddo408HeYEIE/6y
# ZF7psTzm0Hgjsgks4iZivzupl1HMx0QygbKvz98xggUxMIIFLQIBATBAMCwxKjAo
# BgNVBAMMIUIyQ1kgQ2VydGlmaWNhdGUgQVRBIEF1dGhlbnRpY29kZQIQbcORmQk2
# LI9Kiyce7UQ+CzAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKA
# ADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYK
# KwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU3TqphDpXhFraSUblQOMPndfz/g8w
# DQYJKoZIhvcNAQEBBQAEggEAIi5vIcIV8osvt3sfZB4n45WG5hf7mZ9RBKq1me8r
# NAdc+I5GGRVVmkulUbt4vE/KCBbrGxW2c042R6zus+4IvVovah4xjOE+EAeJBhxp
# 10rP1NlwB1Zdvio9at4FSJp2MJdI+4bWuLkfWGZA9kTkrIPCa5IufZPc01cxf5xh
# 6z27COUvb/R906XQup/quhNY92Xp/sifJacVJhH5bKGrskRRs2dKCWR2ug9spxoX
# FkkhKvLR2daGbbVreMe1/SrY0Ak8wHp1wg9UKLG68Nu5dXNWmp/GkhRM7FSdQqLp
# BN6EUKvgEMDdoJXpCSvHaQeOVa2xHS/81XfO8fbblYwh06GCA0wwggNIBgkqhkiG
# 9w0BCQYxggM5MIIDNQIBATCBkjB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3Jl
# YXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0
# aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcg
# Q0ECEQCMd6AAj/TRsMY9nzpIg41rMA0GCWCGSAFlAwQCAgUAoHkwGAYJKoZIhvcN
# AQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMjEwOTAzMDgyMzE5WjA/
# BgkqhkiG9w0BCQQxMgQwlBwI5o9o+z+DG0JWvYV/BulCnC8/gABR7rm65bGhqgGr
# 5y9YCF2yff2lwEwBVkzrMA0GCSqGSIb3DQEBAQUABIICAAW/dLfUqW3gIn9Z0I/F
# 6Na0jUEHJ/9nQvqG0MIALw5VR5ellU2zmPuKYkRX3cfUrhEFqkf64teuIhOyKHl9
# pXFd+oRmHB7zb1PPSVm/xqpCzN+iZjlR8PxFzVu0pKC8YC3H9B0AoMr23nIInjhe
# gc9FuHlo2pRATYKeeogwhYlx0Doz3wjobcaHbGVkLnKj3v+Ew1348oSquo0s4N9L
# j4nL3BljvMTstxAsAvPHA2epoEysxZLcl1HEins75pwIXgA2LK0eq2L3EwHjPiqC
# Ht4Nvwh2N+QDZovjl6wRunL8WMrqUVjJd645GpwdH4NDI+6VoFHezuU2GdN3X7qF
# W6AqSsADvND4O94p3Wbfk3bLJKs1DIL2W9xBJqV7bY25Wk3cjd6YPnGnWaD4aDPv
# YCPJcjiOO9XDqGjokOTRvRuz6VYdnuxCCDwOGYMP4QjEg+Rv8deRA/F+8XJNPWSW
# XC8YeNiVh9shh5F4VkNv22C2pmQNWIEb19ppweTk1IbGywR8luqDr62001RcHCVe
# /JLXG3EWqAKuJUrsXkq1VipTfsQ51sQUtBb1P3ezRzxRy3cbYdPuE/3IhpRbafPa
# U2eqHlQzyxThKWyGeCN/n5Oqzcv9djdoh/WJi7dfmS84aNauo/S5HhOMFpqLqYSJ
# sMJ0SQejpfdMrW6xVaWKxCA6
# SIG # End signature block
