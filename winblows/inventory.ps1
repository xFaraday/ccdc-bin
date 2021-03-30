#ip
'
########################################################
#                     SYSTEM INFO                      #
########################################################
'
#hostname, IP, DOMAIN, and patches
#systeminfo
$name = hostname
$ip = (Get-NetIPAddress -AddressFamily IPv4).IPAddress
$domain = (Get-WmiObject Win32_ComputerSystem).Domain
$os= (gwmi win32_operatingsystem).version
#ports
'
########################################################
#                   LISTENING PORTS                    #
########################################################
'

if (Get-command Get-NetTCPConnection -errorAction SilentlyContinue) {
$proclist = (get-nettcpconnection | ? {$_.State -eq 'Listen'}).OwningProcess

$tcpcon = @()
$i = 1
foreach ($proc in $proclist) {
    Write-Progress -Activity "TcpConnection" -Status "Filling New Object tcpcon" -PercentComplete (($i / $proclist.Count) * 100)
    $procname = (Get-Process -PID $proc).ProcessName
    $port = (Get-NetTCPConnection | ? {$_.OwningProcess -eq $proc}).LocalPort
    $tcpcon += [PSCustomObject]@{
        'Name' = $procname
        'ProcessId' = $proc
        'Port' = $port
    }
    $i++
}

$tcpcon | sort Name | ft -AutoSize

} else {
    $tcpcon = netstat -ano | findstr LISTENING
}

'
########################################################
#                      LOCAL USERS                     #
########################################################
'
#users
$users=(gwmi win32_useraccount).Name


'
########################################################
#                      Services                        #
########################################################
'
#Services

#in case powershell be mad
#cmd.exe /c 'sc query'

$serv = get-service | ? {$_.Status -eq 'Running'} | sort Name


'
########################################################
#                      Shares                          #
########################################################
'
if (Get-command get-smbshare -errorAction SilentlyContinue) {
    $shares = get-smbshare | ? {$_.Description -ne 'Default share'}
} else {
    $shares = net share
}


'
########################################################
#                      Firewall                        #
########################################################
'


$fire = get-netfirewallprofile

#if powershell big gay
#netsh advfirewall show allprofiles state

#inventory object
#name, ip, OSversion, Openports, users, services, shares, firewallrules
#Write-Output "$($name),$($ip),$($domain),$($tcpcon),$($users),$($serv),$($shares),$($fire)"`n| FT -AutoSize >> "Inventory:$time"

$inventoryobj = New-Object -TypeName psobject
$time= Get-Date -Format "HH:mm"
$filename = "$($PWD)\Inventory:$time.csv"
$spacer=' '
#name
$inventoryobj | Add-Member -MemberType NoteProperty "Hostname" -Value $name
write-Output "$($name)" >> Invent.csv 
#ip
$inventoryobj | Add-Member -MemberType NoteProperty "IPs" -Value $null
foreach($address in $ip) {
    $inventoryobj.IPs += "$address "
    write-output "$($spacer)$($address)" >> Invent.csv
}
#OSversion
$inventoryobj | Add-Member -MemberType NoteProperty "OSVersion" -Value $os
write-output "$($spacer)$($spacer)$($os)" >> Invent.csv
#openports
$inventoryobj | Add-Member -MemberType NoteProperty "OpenPorts" -Value $null
foreach($p in $tcpcon.Port) {
    $inventoryobj.OpenPorts += "$p "
    write-output "$($spacer)$($spacer)$($spacer)$($p)" >> Invent.csv
}
#users
$inventoryobj | Add-Member -MemberType NoteProperty "Users" -Value $null
foreach($user in $users) {
    $inventoryobj.Users += "$user "
    write-output "$($spacer)$($spacer)$($spacer)$($spacer)$($user)" >> Invent.csv
}
#services
$inventoryobj | Add-Member -MemberType NoteProperty "Services" -Value $null
foreach($service in $serv.Name) {
    $inventoryobj.Services += "$service "
    write-output "$($spacer)$($spacer)$($spacer)$($spacer)$($spacer)$($service)" >> Invent.csv
}

Function Show-Object
{
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [Object]
        $InputObject,

        $Title
    )

    if (!$Title) { $Title = "Inventory" }
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $Form = New-Object "System.Windows.Forms.Form"
    $Form.Size = New-Object System.Drawing.Size @(600,600)
    $PropertyGrid = New-Object System.Windows.Forms.PropertyGrid
    $PropertyGrid.Dock = [System.Windows.Forms.DockStyle]::Fill
    $Form.Text = $Title
    $PropertyGrid.SelectedObject = $InputObject
    $PropertyGrid.PropertySort = 'Alphabetical'
    $Form.Controls.Add($PropertyGrid)
    $Form.TopMost = $true
    $null = $Form.ShowDialog()
} 


$inventoryobj | Show-Object