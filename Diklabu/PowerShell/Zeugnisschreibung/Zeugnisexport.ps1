
if (-not $global:connectionz) {
    Get-Keystore "$HOME\keys.json"
    do {
        if (-not $Global:logins["bbszeugnis"]) {
            $lo="C:\access\Zeugnis 16_0_0\zeugnis_XP_16_00_08_17_20170828"
            $q = Read-Host "Pfad zu BBS Zeugnis [$lo]"
            if ($q.Length -ne 0) {
                $lo=$q
            }
            try {
                Connect-BbsZeugnis -location $lo
            }
            catch {
                Write-Error "Failed to connect to BBS Zeugnis"
                $Global:logins.Remove("bbszeugnis");
            }
        }
        else {
            try {
                Connect-BbsZeugnis 
            }
            catch {
                Write-Error "Failed to connect to BBS Zeugnis"
                $Global:logins.Remove("bbszeugnis");
            }
        }
    }
    while ($Global:connectionz -and $Global:connectionz.State -ne "Open");
}
$file = "$PSScriptRoot\export.xlsx"
$q = Read-Host "export.xlsx location [$file]" 
if ($q.Length -ne 0) {
    $file=$q
}
$outPath = "$HOME\Seafile\Zeugnisse"
$q = Read-Host "Ausgabepfad [$outPath]" 
if ($q.Length -ne 0) {
    $outPath=$q
}
$passwd = "geheim"
$q = Read-Host "Kennwort [$passwd]" 
if ($q.Length -ne 0) {
    $passwd=$q
}
Import-Excel $file | Get-BZGrade | Export-BZGrade -PATH $outPath -PASSWORD $passwd
