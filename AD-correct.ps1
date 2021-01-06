Import-Module ActiveDirectory
Add-Type -Assembly System.Web

function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}
 
function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}
 
function passchangeREG() {
$adGroupMemberList = Get-ADUser -Filter *

foreach($user in $adGroupMemberList) {
    $password = Get-RandomCharacters -length 5 -characters 'abcdefghiklmnoprstuvwxyz'
    $password += Get-RandomCharacters -length 2 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
    $password += Get-RandomCharacters -length 2 -characters '1234567890'
    $password += Get-RandomCharacters -length 1 -characters '!@$%&'
    $password = Scramble-String $password
    $newPassword = $password
    Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $newPassword -Force)
    $sam = ($user).SamAccountName
    Write-Output "$($sam),$($newPassword)"`n|FT -AutoSize >>PassChangeNew.csv
    }
}

passchangeREG