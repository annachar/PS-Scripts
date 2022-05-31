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
