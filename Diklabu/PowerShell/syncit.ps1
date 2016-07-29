. "$PSScriptRoot/LoadModule.ps1"
. "$PSScriptRoot/send-Mail.ps1"
. "$PSScriptRoot/sync_lehrer.ps1"

# Anmelden am Diklabu Server
$config=Get-Content "$PSScriptRoot/config.json" | ConvertFrom-json
$password = $config.tupassword | ConvertTo-SecureString -asPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList "Tuttas", $password
Login-Diklabu -credential $credentials

Sync-Teachers -whatif -force > "$HOME/out.txt"
$body="Das Syncronisationsscript ist am "+(Get-Date)+" durchgelaufen";
send-mailreport -from tuttas@mmbbs.de -to jtuttas@gmx.net -subject "Syncronisationsscript durchgelaufen" -body $body -attachment "$HOME/out.txt"