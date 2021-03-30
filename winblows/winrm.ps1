$host = $args[0]
$scriptpath = $args[1]

#C:\Users\Administrator\scripts\Inventory.ps1
Invoke-command -ComputerName $host -FilePath $scriptpath

#$s = New-PSSession -ComputerName $host
#
#Invoke-Command -Session $s {$h = Get-HotFix}