$PSScriptRoot
[Environment]::Is64BitProcess
. "$PSScriptRoot/LoadModule.ps1"
. "$PSScriptRoot/send-Mail.ps1"
"Get Keystore"
Get-Keystore -file C:\Users\Tuttas\keystore.json
Connect-BbsPlan
Login-Diklabu
$body="Das Synchronisationsscript BBS-Planung -> Diklabu gestartet um "+(Get-Date)+"! `r`n";
<# Bei einem neuen Schuljahr dürfen die Schüler nicht gelöscht werden, um die Bilder zu behalten (Option DELETEPUPIL). Ferner
kann es sein, dass sich die BBSPLanung ID der Schüler geändert haben, daher werden die Schüler gesucht
nach VornameNachNameGebDatum mit Levensthein Distanz (Option NewYear).
Daher das Script wie folgt starten:

$report=Export-BBSPlanung -mode SYNC -log  -newyear



Im Dauerbetrieb drüfen die Klassen (z.B. WPKs) nicht gelöscht werden, auch werden Schüler im diklabu
angelegt, die nicht in BBS Planung vorhanden sind, daher muss das Skript wie folgt gestartet werden.

$report=Export-BBSPlanung -mode ONEWAY -log 

#>
$report=Export-BBSPlanung -mode SYNC -log -newyear -Verbose
$body+="Das Synchronisationsscript BBS-Planung -> Diklabu beendet um "+(Get-Date)+"! `r`n";
$body+="`r`n`r`nDie Änderungen befinden sich im Anhang!";
$report | Set-Content "$Home/syncreport.txt"
if (-not $Global:logins["smtp"]) {
    Write-Error "Keine SMTP Credentials gefunden. Bitte zunächst mit Login-SMTP Verbindung herstellen"
    break;
}
else {
    send-mailreport -from tuttas@mmbbs.de -to jtuttas@gmx.net -subject "Synchronisationsscript BBS-Planung -> Diklabu durchgelaufen" -body $body -attachment "$Home/syncreport.txt"
}
sleep 30
