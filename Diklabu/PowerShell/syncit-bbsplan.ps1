$PSScriptRoot
[Environment]::Is64BitProcess
. "$PSScriptRoot/LoadModule.ps1"
. "$PSScriptRoot/send-Mail.ps1"
"Get Keystore"
Get-Keystore -file C:\Users\Tuttas\keystore.json
#Get-Keystore C:\Users\jtutt_000\diklabu2.conf
Connect-BbsPlan
Login-Diklabu
$body="Das Synchronisationsscript BBS-Planung -> Diklabu gestartet um "+(Get-Date)+"! `r`n";
<# Bei einem neuen Schuljahr dürfen die Schüler nicht gelöscht werden, um die Bilder zu behalten. Ferner
kann es sein, dass sich die BBSPLanung ID der Schüler geändert haben, daher werden die Schüler gesucht
nach VornameNachNameGebDatum mit Levensthein Distanz (Option NewYear).

Vorgehen:
1. Neues Schuljahr in Schuljahr Anlegen

2. Vorher noch folgende Tabellen leeren:
    Schueler_Klasse, Klasse

    z.B. mittels folgenden Codezeilen
    New-Company -ID 99999 -NAME " " -PLZ  " " -ORT " " -STRASSE " " -NR " "
    New-Instructor -ID 99999 -NNAME " " -EMAIL " " -ANREDE " " -FAX " " -TELEFON " " -ID_BETRIEB 99999
    Get-Pupils | Set-Pupil -ID_AUSBILDER 99999
    Get-Instructors | Delete-Instructor
    Get-Companies | Delete-Company (ggf. Schüler Löschen die eine ID_UMSCHUL eingetragen haben)
    get-courses | ForEach-Object {$klid=$_.id; Get-Coursemember -id $klid | Remove-Coursemember -klassenid $klid}
    Get-Courses | Delete-Course

3. Manuell müssen noch die folgenden Tabellen geleert werden:
    Anwesenheit, Noten, Verlauf

4. Dann das Script wie folgt starten:

$report=Export-BBSPlanung -mode SYNC -log  -newyear -deletepupil



Im Dauerbetrieb drüfen die Klassen (z.B. WPKs) nicht gelöscht werden, auch werden Schüler im diklabu
angelegt, die nicht in BBS Planung vorhanden sind, daher muss das Skript wie folgt gestartet werden.

$report=Export-BBSPlanung -mode ONEWAY -log 

#>
$report=Export-BBSPlanung -mode ONEWAY -log 
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
