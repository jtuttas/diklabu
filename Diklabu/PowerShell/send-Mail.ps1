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
        $attachment

    )

    Begin
    {
        # Email Senden via Powershell
        $config=Get-Content "$PSScriptRoot/config.json" | ConvertFrom-json
        $password = $config.pass | ConvertTo-SecureString -asPlainText -Force
        $credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $config.user, $password
        if ($attachment) {
            Send-MailMessage -Body $body -From $from -To $to -SmtpServer $config.smtphost -Credential $credentials -Subject $subject -UseSsl -Port $config.port -Attachments $attachment
        }
        else {
            Send-MailMessage -Body $body -From $from -To $to -SmtpServer $config.smtphost -Credential $credentials -Subject $subject -UseSsl -Port $config.port

        }


    }
}