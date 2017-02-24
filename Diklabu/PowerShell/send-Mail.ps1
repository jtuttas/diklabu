<#
.Synopsis
   Send Mail Report
.DESCRIPTION
   Sendet einen Report via Mail
.EXAMPLE
   Send-Mailreport -from tuttas@mmbbs.de -to jtuttas@gmx.net -subject "Mail Report" -body "Ein Test" -attachment "$PSScriptRoot/antwort.csv"
#>
function send-mailreport
{
    Param
    (
        # Absender
        [Parameter(Mandatory=$true,Position=0)]
        $from,

        # Adressat
        [Parameter(Mandatory=$true,Position=1)]
        $to,

        # betreff
        [Parameter(Mandatory=$true,Position=2)]
        $subject,

        # inhalt
        [Parameter(Mandatory=$true,Position=3)]
        $body,

        # Anhang
        [Parameter(Position=4)]
        [String[]]$attachment

    )

    Begin
    {
        if (-not $global:logins["smtp"]) {
            Write-Error "Keine SMTP Server Konfigurations gefunden, bitte zunächst Login-SMTP ausführen";
            break;
        }
        # Email Senden via Powershell
        $password = $global:logins["smtp"].password | ConvertTo-SecureString 
        $credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $($global:logins["smtp"].user), $password
        $utf8 = New-Object System.Text.utf8encoding
        $server = ($global:logins["smtp"].location).Split(":");
        
        if ($attachment) {
            Send-MailMessage -Encoding $utf8 -Body $body -From $from -To $to -SmtpServer $server[0] -Credential $credentials -Subject $subject -UseSsl -Port $server[1] -Attachments $attachment
        }
        else {
            Send-MailMessage -Encoding $utf8 -Body $body -From $from -To $to -SmtpServer $server[0] -Credential $credentials -Subject $subject -UseSsl -Port $server[1] 

        }
    }
}


<#
.Synopsis
   Anmelden am SMTP Server
.DESCRIPTION
   Anmelden am SMTP Server. Dabei werden die Credentials im diklabu key store gespeichert.
.EXAMPLE
   Login-SMTP -url smtp.mmbbs.de:27 -user tuttas -password xyz
#>
function Login-SMTP
{
    [CmdletBinding()]
    Param
    (
        # Adresse des SMTP Servers
        [Parameter(Mandatory=$true,
                   Position=0)]
        $url,

        # Benutername
        [Parameter(Mandatory=$true,
                   Position=1)]
        $user,

        # Benutername
        [Parameter(Mandatory=$true,
                   Position=1)]
        $kennwort

    )

    Begin
    {
        $password = $kennwort | ConvertTo-SecureString -asPlainText -Force
        $credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $password
        $adr = $url.split(":");
        $utf8 = New-Object System.Text.utf8encoding
        try {
            Send-MailMessage -Encoding $utf8 -Body "works" -From "tuttas@mmbbs.de" -To "jtuttas@gmx.net" -SmtpServer $adr[0] -Credential $credentials -Subject "testmail" -UseSsl -Port $adr[1]
            Set-Keystore -key "smtp" -server $url -credential $credentials
        }
        catch {
            Write-Error $_.Exception.Message;
        }    
    }
}