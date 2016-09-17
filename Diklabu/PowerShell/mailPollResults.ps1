param(
    [int]$pollid,
    [String]$group1,
    [String]$group2,
    [String]$email
)
."$PSScriptRoot/send-Mail.ps1"
$p=Get-Poll -ID $pollid
$result = "" | Select-Object success,msg,warning,warningmsg
$result.warning=$false;
try{
   $toadr = new-object net.mail.mailaddress($email)
    if ($p) {
        $d=Get-Date
        $dest="C:\Temp\$($p.titel)_$($d.Ticks).xlsx"
        $src="C:\Temp\$($p.titel).xlsx"
        if (Test-Path $src) {
            Copy-Item $src -Destination $dest
        }
        else {
            $result.warning=$true;
            $result.warningmsg="Kann Template $($p.titel).xlsx nicht finden"

        }
        Get-Pollresults -ID $pollid -KNAME $group1 | Export-Excel $dest -WorkSheetname Hauptgruppe
        Get-Pollresults -ID $pollid -KNAME $group2 | Export-Excel $dest -WorkSheetname Vergleichsgruppe
        send-mailreport -from tuttas@mmbbs.de -to $email -subject "Ihre Auswertung für die Umfrage $($p.titel)" -body "Ihre Auswertung für die Umfrage $($p.titel)" -attachment $dest
        Remove-Item $dest
        $result.success=$true;
        $result.msg="Ergebnisse der Umfrage $($p.titel) gesendet an $email"
    }
    else {
        $result.success=$false;
        $result.msg="Kann Umfrage mit ID $pollid nicht finden"
    }
}
catch {
    $result.success=$false;
    $result.msg="Ungültige EMail Adresse $email"
}
ConvertTo-Json $result