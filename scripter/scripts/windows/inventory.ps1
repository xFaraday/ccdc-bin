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
