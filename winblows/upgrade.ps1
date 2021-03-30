#ps upgrade script
# guide https://docs.microsoft.com/en-us/powershell/scripting/windows-powershell/wmf/setup/install-configure?view=powershell-7.1

$WinServ2012R2= "https://go.microsoft.com/fwlink/?linkid=839516"
$WinServ2012= "https://go.microsoft.com/fwlink/?linkid=839513"
$WinServ2008R2prereq= "https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe"
$WinServ2008R2= "https://go.microsoft.com/fwlink/?linkid=839523"
$Win8= "https://go.microsoft.com/fwlink/?linkid=839521"
$Win7prereq=$WinServ2008R2prereq
$Win7= "https://go.microsoft.com/fwlink/?linkid=839522"

function checkSystemNet() {
    $os= (gwmi win32_operatingsystem).version
    $num= $os.Split("{.}")   
    switch($num[0]) {
        7 {(New-Object Net.WebClient).DownloadFile($Win7prereq,"$($PWD)\Win7net.exe"); (New-Object Net.WebClient).DownloadFile($Win7,"$($PWD)\Win7.zip"); break}
        8 {(New-Object Net.WebClient).DownloadFile($Win8,"$($PWD)\Win8.msu"); break}
        08 {(New-Object Net.WebClient).DownloadFile($WinServ2008R2prereq,"$($PWD)\2008.exe"); (New-Object Net.WebClient).DownloadFile($WinServ2008R2,"$($PWD)\2008.zip"); break}
        12 {(New-Object Net.WebClient).DownloadFile($WinServ2012,"$($PWD)\2012.msu"); break}
    }
}

function checkInvokeWeb() {
    $os= (gwmi win32_operatingsystem).version
    $num= $os.Split("{.}")    
    switch($num[0]) {
        7 {Invoke-WebRequest $Win7prereq -Outfile "Win7net.exe"; Invoke-WebRequest $Win7 -Outfile "Win7.zip"; break }
        8 {Invoke-WebRequest $Win8 -Outfile "Win8.msu"; break}
        08 {Invoke-WebRequest $WinServ2008R2prereq -Outfile "2008.exe"; Invoke-WebRequest $WinServ2008R2 -Outfile "2008.zip"; break}
        12 {Invoke-WebRequest $WinServ2012 -Outfile "2012.msu"; break}
    }
}

function main() {
    if (get-command Invoke-WebRequest -erroraction SilentlyContinue) {
        checkInvokeWeb
    } else {
        checkSystemNet
    }
}