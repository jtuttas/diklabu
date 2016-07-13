# Email Senden via Powershell
$config=Get-Content "$PSScriptRoot/config.json" | ConvertFrom-json
$password = $config.pass | ConvertTo-SecureString -asPlainText -Force
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $config.user, $password
Send-MailMessage -Body "Ein test" -From "tuttas@mmbbs.de" -To "jtuttas@gmx.net" -SmtpServer $config.smtphost -Credential $credentials -Subject "via Powershell" -UseSsl -Port $config.port -Attachments "$PSScriptRoot/antwort.csv"