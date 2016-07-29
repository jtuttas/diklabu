. "$PSScriptRoot/LoadModule.ps1"
. "$PSScriptRoot/send-Mail.ps1"
. "$PSScriptRoot/sync_lehrer.ps1"

# Anmelden am Diklabu Server
$config=Get-Content "$PSScriptRoot/config.json" | ConvertFrom-json
$password = $config.tupassword | ConvertTo-SecureString -asPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList "Tuttas", $password
Login-Diklabu -credential $credentials

$r=Sync-Teachers -whatif -force 
$r.msg > "$HOME/out.txt"
$body="Das Synchronisationsscript ist am "+(Get-Date)+" durchgelaufen `r`n";
$body+="Es wurden "+$r.new+" neue Lehrer angeleget! `r`n";
$body+="Es wurden "+$r.update+" Lehrer aktualisiert! `r`n";
$body+="Es wurden "+$r.delete+" Lehrer geloescht! `r`n";
$body+="Es traten "+$r.error+" Fehler auf (siehe Protokoll im Anhang) `r`n";



send-mailreport -from tuttas@mmbbs.de -to jtuttas@gmx.net -subject "Synchronisationsscript durchgelaufen" -body $body -attachment "$HOME/out.txt"