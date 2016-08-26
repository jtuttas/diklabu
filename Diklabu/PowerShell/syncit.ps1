. "$PSScriptRoot/LoadModule.ps1"
. "$PSScriptRoot/send-Mail.ps1"
. "$PSScriptRoot/sync_lehrer.ps1"
. "$PSScriptRoot/set-emails.ps1"

Set-Diklabuserver -uri https://diklabu.mm-bbs.de:8080/Diklabu/api/v1/
# Anmelden am Diklabu Server
$config=Get-Content "$PSScriptRoot/config.json" | ConvertFrom-json
$password = $config.tupassword | ConvertTo-SecureString -asPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList "Tuttas", $password
$l=Login-Diklabu -credential $credentials

#$r1=Sync-Teachers  -force 
#$r1.msg > "$PSScriptRoot/../../../out_lehrer.txt"
$body="Das Synchronisationsscript ist am "+(Get-Date)+" durchgelaufen!! `r`n";
#$body+="`r`nsync_lehrer.ps1`r`n";
#$body+="Es wurden "+$r1.new+" neue Lehrer angelegt!`r`n";
#$body+="Es wurden "+$r1.update+" Lehrer aktualisiert!`r`n";
#$body+="Es wurden "+$r1.delete+" Lehrer geloescht!`r`n";
#$body+="Es traten "+$r1.error+" Fehler auf (siehe Protokoll im Anhang)`r`n";
#$body+="`r`n";
$body+="set-emails.ps1`r`n";
$r2=set-emails -force
$body+="Es wurden "+$r2.total+" Schueler bearbeitet`r`n";
$body+="Es wurden "+$r2.update+" Schuelermails aktualisiert`r`n";
$body+="Es wurden "+$r2.error+" Schueler aus dem Klassenbuch nicht in der AD gefunden!`r`n";
$r2.msg > "$PSScriptRoot/../../../out_schueler.txt"

send-mailreport -from tuttas@mmbbs.de -to jtuttas@gmx.net -subject "Synchronisationsscript durchgelaufen" -body $body -attachment "$PSScriptRoot/../../../out_lehrer.txt","$PSScriptRoot/../../../out_schueler.txt"