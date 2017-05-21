. "$PSScriptRoot/LoadModule.ps1"
. "$PSScriptRoot/send-Mail.ps1"
. "$PSScriptRoot/sync_lehrer.ps1"
. "$PSScriptRoot/set-emails.ps1"
. "$PSScriptRoot/sync_MoodleCohortsWithSeafile.ps1"

$ks=Get-Keystore C:\diklabuApp\diklabu.conf

$body="Das Synchronisationsscript ist am "+(Get-Date)+" durchgelaufen!! `r`n";
try {
    $db=Login-Diklabu 
    #$r1=Sync-Teachers  -force 
    #$r1.msg > "$PSScriptRoot/../../../out_lehrer.txt"
    #$body+="`r`nsync_lehrer.ps1`r`n";
    #$body+="Es wurden "+$r1.new+" neue Lehrer angelegt!`r`n";
    #$body+="Es wurden "+$r1.update+" Lehrer aktualisiert!`r`n";
    #$body+="Es wurden "+$r1.delete+" Lehrer geloescht!`r`n";
    #$body+="Es traten "+$r1.error+" Fehler auf (siehe Protokoll im Anhang)`r`n";
    #$body+="`r`n";
    $body+="`r`n`r`nset-emails.ps1`r`n";
    $r2=set-emails -force -Verbose
    $body+="Es wurden "+$r2.total+" Schueler bearbeitet`r`n";
    $body+="Es wurden "+$r2.update+" Schuelermails aktualisiert`r`n";
    $body+="Es wurden "+$r2.error+" Schueler aus dem Klassenbuch nicht in der AD gefunden!`r`n";
    $r2.msg > "$PSScriptRoot/../../../out_schueler.txt"
}
catch {
    Write-Error $_.Exception.Message
    $body+=$_.Exception.Message
}
try {
    ## Moodle gloable gruppe Sync
    $body+="`r`n`r`nSynchronisiere Moodle Cohorts with Seafile CSV"
    Login-Moodle
    $body+="`r`nLogin Moodle OK"
    Sync-MoodleTeams -url https://seafile.mm-bbs.de/f/a743d75f83/?raw=1 -Verbose
    $body+="`r`nSynchronisation erfolgt"
}
catch {
    Write-Error $_.Exception.Message
    $body+=$_.Exception.Message
}

if (-not $Global:logins["smtp"]) {
    Write-Error "Keine SMTP Credentials gefunden. Bitte zunächst mit Login-SMTP Verbindung herstellen"
    break;
}
else {
    #send-mailreport -from tuttas@mmbbs.de -to jtuttas@gmx.net -subject "Synchronisationsscript durchgelaufen" -body $body -attachment "$PSScriptRoot/../../../out_lehrer.txt","$PSScriptRoot/../../../out_schueler.txt"
    if (Test-Path "$PSScriptRoot/../../../out_schueler.txt") {
        send-mailreport -from tuttas@mmbbs.de -to jtuttas@gmx.net -subject "Synchronisationsscript durchgelaufen" -body $body -attachment "$PSScriptRoot/../../../out_schueler.txt"
    }
    else {
        send-mailreport -from tuttas@mmbbs.de -to jtuttas@gmx.net -subject "Synchronisationsscript durchgelaufen" -body $body -attachment "$PSScriptRoot/../../../out_schueler.txt"
    }
}
