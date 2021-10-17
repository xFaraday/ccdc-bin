<#
Attempt to automatically configure DC's DNS so that they aren't robbed 
by slutty red teamers.  

1.Get zones
    1a.Filter zones
2.Get domain controllers or other dns servers
3.Only allow zone transfer by domain controllers
#>

$allowedtransfers = (Get-ADDomainController).Name
#maybe we dont need zones because it applies everywhere
$zones = (Get-DNSServerZone | Where {$_.IsAutoCreated -ne "True"}).ZoneName

$builtfilter = ""

$allowedtransfers | % {$builtfilter = $builtfilter + ' -ComputerName ' + $_ + ' -Condition ' + "'OR'"}

Add-DNSServerZoneTransferPolicy -Name "OnlyAllowDomainControllers" -Action DENY $builtfilter -PassThru