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

2. Vorher noch  Tabellen leeren:
   
    SQL Statement:
    UPDATE SCHUELER set ID_AUSBILDER=null,ID_UMSCHUL=null,ID_MMBBS=null;
    DELETE FROM AUSBILDER;
    DELETE FROM BETRIEB;
    INSERT INTO BETRIEB (ID,NAME,PLZ,ORT,STRASSE,NR) Values (99999," "," "," "," "," ");
    INSERT INTO AUSBILDER (ID,ID_BETRIEB,ANREDE,NNAME,EMAIL,TELEFON,FAX) Values(99999,99999," "," "," "," "," ");
    DELETE FROM ANWESENHEIT;
    DELETE FROM VERLAUF;
    DELETE FROM SCHUELER_KLASSE;
    DELETE FROM KURSWUNSCH;
    DELETE FROM BUCHUNGSFREIGABE;
    DELETE FROM KLASSE;
    DELETE FROM NOTEN_ALL;
    DELETE FROM NOTEN;


3. Dann das Script wie folgt starten:

$report=Export-BBSPlanung -mode SYNC -log  -newyear -deletepupil -verbose



Im Dauerbetrieb drüfen die Klassen (z.B. WPKs) nicht gelöscht werden, auch werden Schüler im diklabu
angelegt, die nicht in BBS Planung vorhanden sind, daher muss das Skript wie folgt gestartet werden.

$report=Export-BBSPlanung -mode ONEWAY -log -verbose

#>
$report=Export-BBSPlanung -mode SYNC -log -verbose
$body+="Das Synchronisationsscript BBS-Planung -> Diklabu beendet um "+(Get-Date)+"! `r`n";
$body+="`r`n`r`nDie Änderungen befinden sich im Anhang!";
$report | Set-Content "$Home/syncreport.txt"
if (-not $Global:logins["smtp"]) {
    Write-Error "Keine SMTP Credentials gefunden. Bitte zunächst mit Login-SMTP Verbindung herstellen"
    break;
}
else {
    send-mailreport -from tuttas@mmbbs.de -to jtuttas@gmx.net -subject "Synchronisationsscript BBS-Planung -> Diklabu durchgelaufen" -body $body -attachment "$Home/syncreport.txt"
    send-mailreport -from tuttas@mmbbs.de -to Heinrich@mmbbs.de -subject "Synchronisationsscript BBS-Planung -> Diklabu durchgelaufen" -body $body -attachment "$Home/syncreport.txt"
}
sleep 30
