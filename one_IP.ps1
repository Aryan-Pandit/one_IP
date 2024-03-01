$location = Get-Location 
$file = "$location\one_IP.csv" 
if (Test-Path $file) { 
    Remove-Item $file 
} 
else { 
    Write-Host "" 
}

# Automatically retrieve the local IP address
$ipConfigOutput = ipconfig | Select-String -Pattern 'IPv4 Address.*: (\d+\.\d+\.\d+\.\d+)' -AllMatches
$ipAddress = $ipConfigOutput.Matches[0].Groups[1].Value

# Check if an IP address was found
if ($ipAddress -eq $null) {
    Write-Host "No local IP address found"
    exit
}

# Split the IP address into an array 
$ipArray = $ipAddress.Split(".") 
$ip = $ipArray[3]

Write-Host "Pinging $ipAddress..." 
$ping = New-Object System.Net.NetworkInformation.Ping

$pingReply = $ping.Send($ipAddress) 
$hostname = "" 
if ($pingReply.Status -eq 'Success') { 
    try { 
        $hostname = [System.Net.Dns]::GetHostEntry($ipAddress).HostName
        $adminGroupMembers = Get-LocalGroupMember -Group "Administrators"
        $membersFound = $adminGroupMembers.Name 
    } 
    catch { 
        Write-Host "No hostname found for $ipAddress" 
        $hostname = 'NOT AVAILABLE'
        $membersFound = 'NOT AVAILABLE' 
    } 
    $IP = [PSCustomObject]@{ 
        'IP Address' = $ipAddress 
        'Hostname' = $hostname
        'Users' = $membersFound -join ', ' 
    } 
} 
else { 
    $IP = [PSCustomObject]@{ 
        'IP Address' = $ipAddress 
        'Hostname' = "FREE IP"
        'USERS' = "N/A" 
    } 
}

$IP | Export-Csv -Path $file -NoTypeInformation