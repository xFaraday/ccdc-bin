function Invoke-Inventory {
<#
.SYNOPSIS

CCDC windows inventory script CSUSB.  Collects variety of useful forensics information.

.PARAMETER runtime

defines what functions to run in the script.  The default is to run all functions.
Avaliable options are:
All(default)
sysinfo
ports
users
startup
services
firewall
tasks
files

option: sysinfo
Collects hostname, ip, domain, and patches installed.

option: ports
Collects listening ports and the processes attached to them.

option: users
Collects local users, domain users, and their privileges.

option: startup
Collects startup programs and their arguments.

option: services
Collects service information.

option: shares
Collects network share information

option: firewall
Collects firewall information

option: tasks
Collects scheduled tasks.

option: files
Attempts to collect interesting files and their locations.

.PARAMETER csvstore

Store collected artifacts in a csv file specified by this parameter.
#>

[CmdletBinding(DefaultParameterSetName="default")]
Param(
    [Parameter(Mandatory=$true, ParameterSetName="runtime")]
        [string]$runtime,
    [Parameter(Mandatory=$false, ParameterSetName="csvstore")]
        [string]$csvstore
)

$hostinfo = @()

function banner {
    Write-Host "CCDC Windows Inventory Script CSUSB"
    Write-Host "Version: 1.0"
    Write-Host "Author: Ethan Michalak"
    Write-Host " "

"
                 /C.   C\.
                /SS.   SS\.
               /UUU.   UUU\.
              /SSSS.   SSSS\.
             /BBBBB.   BBBBB\.
          /CSUSBCSUSBCSUSBCSUSB\.
       /CSUSBCSUSBCSUSBCSUSBCSUSBC\.
    /CSUSBCSUSBCSUSBCSUSBCSUSBCSUSBCS\.
 \CSUSBCSUS   USBCSUSBCSUSBC   BCSUSBCSU/.
  \CSUSBCSUS   USBCSUSBCSUS   USBCSUSBC/.
   \CSUSBCSUS   USBCSUSBCS   CSUSBCSUS/.
    \CSUSBCSUS   USBCSUSB   SBCSUSBCS/.
     \CSUSBCSUS   CSUSBC   SUSBCSUSB/.
      \CSUSBCSUSBCSUSBCSUSBCSUSBCSU/.
       \CSUSBCSUSBCSUSBCSUSBCSUSBC/.
             \CSUSBCSUSBCSUS/.
              \CSUSBCSUSBCS/.
               \CSUSBCSUSB/.
                \CSUSBCSU/.
                 \CSUSBC/.
                  \CSUS/.
                   \**/.
" 
}

function sysinfo {
    '
    ########################################################
    #                     SYSTEM INFO                      #
    ########################################################
    '
    #hostname, IP, DOMAIN, and patches
    #systeminfo
    $name = hostname
    '
    Hostname:
    '
    $name

    $ip = (Get-NetIPAddress -AddressFamily IPv4).IPAddress
    '
    IP Addresses:
    '
    $ip
    $domain = (Get-WmiObject Win32_ComputerSystem).Domain
    '
    domain:
    '
    $domain
    $os= (gwmi win32_operatingsystem).version

    $os

    $patches = (Get-WmiObject Win32_QuickFixEngineering).HotFixID

    $patches

    $hostinfo += [PSCustomObject]@{
        Name = $name
        IP = $ip
        Domain = $domain
        OS = $os
    }
}

function ports {
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
            $procpath = (Get-Process -PID $proc).Path
    	    $port = (Get-NetTCPConnection | ? {$_.OwningProcess -eq $proc}).LocalPort
    	    $tcpcon += [PSCustomObject]@{
        	    'Name' = $procname
        	    'ProcessId' = $proc
        	    'Port' = $port
                'Path to bin' = $procpath
    	    } 
            $i++
        }
        $tcpcon | sort Name | ft -AutoSize
        $hostinfo += [PSCustomObject]@{
            TcpConnection = $tcpcon
        }
    } else {
        $tcpcon = netstat -ano | findstr LISTENING
        $hostinfo += [PSCustomObject]@{
            TcpConnection = $tcpcon
        }
    }
}

function startup {
    '
    ########################################################
    #                   STARTUP COMMANDS                   #
    ########################################################
    '

    $startup = gwmi win32_startupcommand
    $hostinfo += [PSCustomObject]@{
        StartupCommands = $startup
    }    
}

function users {
    '
    ########################################################
    #                      LOCAL USERS                     #
    ########################################################
    '
    #users
    $users=(gwmi win32_useraccount).Name
    $hostinfo += [PSCustomObject]@{
        Users = $users
    }
}

function services {
    '
    ########################################################
    #                      Services                        #
    ########################################################
    '
    $serv = get-service | ? {$_.Status -eq 'Running'} | sort Name
    $hostinfo += [PSCustomObject]@{
        Services = $serv
    }
}

function shares {
    '
    ########################################################
    #                      Shares                          #
    ########################################################
    '
    $shares = Get-WmiObject Win32_Share | Where-Object {(@('Remote Admin','Default share','Remote IPC') -notcontains $_.Description)}
    $hostinfo += [PSCustomObject]@{
        Shares = $shares
    }
}

function firewall {
    '
    ########################################################
    #                      Firewall                        #
    ########################################################
    '
    $fire = get-netfirewallprofile
    $fire
}

function tasks {
    '
    ########################################################
    #                   Scheduled Tasks                    #
    ########################################################
    '
    $Tasks = schtasks /query /v /fo csv | ConvertFrom-Csv
    $ScheduledTasks = $Tasks | Where-Object { $_.HostName -eq $env:COMPUTERNAME -and $_.Author -ne "N/A" -and $_.'Next Run Time' -ne "N/A" -and $_.Author -notmatch "Microsoft" -and $_.TaskName -notmatch "User_Feed_Synchronization" }
    $hostinfo += [PSCustomObject]@{
        ScheduledTasks = $ScheduledTasks
    }
}

switch($runtime) {
    "All" {
        banner
        sysinfo
        ports
        startup
        users
        services
        shares
        firewall
        tasks
    }
    "Sysinfo" {
        sysinfo
    }
    "Ports" {
        ports
    }
    "Startup" {
        startup
    }
    "Users" {
        users
    }
    "Services" {
        services
    }
    "Shares" {
        shares
    }
    "Firewall" {
        firewall
    }
    "Tasks" {
        tasks
    }
}

if ($csvstore -eq $NULL) {
    $hostinfo
} else {
    $hostinfo | Export-Csv -NoTypeInformation -Append -Path "C:\$csvstore.csv"
}

}

#Invoke-Inventory -runtime All -csvstore allinventory