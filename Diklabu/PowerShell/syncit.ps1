$org= [Net.ServicePointManager]::SecurityProtocol 
#[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

Write-Host "Script Root:"+$PSScriptRoot

Import-Module -Name ImportExcel
. "$PSScriptRoot/LoadModule.ps1"
. "$PSScriptRoot/send-Mail.ps1"
. "$PSScriptRoot/sync_lehrer.ps1"
. "$PSScriptRoot/set-emails.ps1"
. "$PSScriptRoot/sync_MoodleCohortsWithSeafile.ps1"



$ks=Get-Keystore C:\diklabuApp\diklabu.conf
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
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

    <#
    $body+="`r`n`r`nset-emails.ps1`r`n";
    $r2=set-emails -force -Verbose
    $body+="Es wurden "+$r2.total+" Schueler bearbeitet`r`n";
    $body+="Es wurden "+$r2.update+" Schuelermails aktualisiert`r`n";
    $body+="Es wurden "+$r2.error+" Schueler aus dem Klassenbuch nicht in der AD gefunden!`r`n";
    $r2.msg > "$PSScriptRoot/../../../out_schueler.txt"
    #>
}
catch {
    Write-Error $_.Exception.Message
    $body+=$_.Exception.Message
}

$body+="`r`n`r`nLade Lehrerteams.xlsx"
if (-not $Global:logins["lehrerteams"]) {
    $body+="`r`nAchtung keine URL für Lehrerteams im Keystore gefunden!"
    Write-Warning "Achtung keine URL für Lehrerteams im Keystore gefunden!"
}
else {

    try {
        ## Moodle gloable gruppe Sync
        $body+="`r`n`r`nSynchronisiere Moodle Cohorts"
        Write-Host "Synchronisiere Moodle Cohorts"
        Login-Moodle
        $body+="`r`nLogin Moodle OK"
        Write-Host "Login Moodle OK"
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null
        
        #[Net.ServicePointManager]::SecurityProtocol = $org
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Write-Host "Lade... $($Global:logins["lehrerteams"].location)"
        Invoke-WebRequest -Uri $Global:logins["lehrerteams"].location -OutFile "$env:TMP\teams.xlsx"
        Write-Host "Lehrer Teams geladen"
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

        $obj=Import-Excel "$env:TMP\teams.xlsx"
        Write-Host "Lehrer Teams gelesen"


        Sync-MoodleTeams -obj $obj -Verbose
        $body+="`r`nSynchronisation erfolgt"
    }
    catch {
        Write-Error "Fehler:"
        $_.Exception.Message
        $body+=$_.Exception.Message
    }
    try {
        ## Gruppen in der AD Sync
        $body+="`r`n`r`nSynchronisiere AD Lehrer Gruppen"
        Write-Host "Synchronisiere AD Lehrer Gruppen" -BackgroundColor DarkGray
        Login-LDAP
        $body+="`r`nLogin AD OK"
        . "$PSScriptRoot/sync_ldapTeacherGroups.ps1"
        $obj=Import-Excel "$env:TMP\teams.xlsx"
        Sync-LDAPTeams -obj $obj -Verbose -force -searchbase "OU=Lehrer,DC=int,DC=mm-bbs,DC=de" 
        $body+="`r`nSynchronisation erfolgt"
    }
    catch {
        Write-Error $_.Exception.Message
        $body+=$_.Exception.Message
    }
}


#$body+="`r`n`r`nLade Untisexport.csv"
#if (-not $Global:logins["untisexport"]) {
#    $body+="`r`nAchtung keine URL für Untisexport im Keystore gefunden!"
#    Write-Warning "Achtung keine URL für Untisexport im Keystore gefunden!"
#}
#else {
#    try {
#        ## Klassenteams in der AD Sync
#        $body+="`r`n`r`nSynchronisiere AD Klassenteams"
#        Login-LDAP
#        $body+="`r`nLogin AD OK"
#        . "$PSScriptRoot/gpu2ADGroups.ps1"
#        Invoke-WebRequest -Uri $Global:logins["untisexport"].location -OutFile "$env:TMP\untis.csv"
#        $obj=Import-Untis -path "$env:TMP\untis.csv"
#        Sync-LDAPTeams -map $obj -Verbose -force -searchbase "OU=Klassenteams,OU=Schüler,DC=mmbbs,DC=local"  
#        $body+="`r`nSynchronisation erfolgt"
#    }
#    catch {
#        Write-Error $_.Exception.Message
#        $body+=$_.Exception.Message
#    }
    ## Moodle Klassen-Kurse Synchronisieren
#    $body+="`r`n`r`nSynchronisiere Moodle Klassenteams"
#    Login-Moodle
#    $body+="`r`nLogin Moodel OK"
#    . "$PSScriptRoot/Sync-MoodleClasses.ps1"
#    Invoke-WebRequest -Uri $Global:logins["untisexport"].location -OutFile "$env:TMP\untis.csv"
#    Sync-MoodleCourses -untisexport "$env:TMP\untis.csv" -categoryid 108 -Verbose -templateid 866 
#    $body+="`r`nSynchronisation Moodle Klassen erfolgt"

#}

# Alles Lehrer in Gruppe alleLul eintragen
<#
Write-Host "alle LuL anlegen" -BackgroundColor DarkGreen
if (-not (Test-LDAPCourse "alleLuL" -searchbase "OU=Lehrergruppen,OU=Lehrer,DC=mmbbs,dc=local")) {
    Write-Verbose "Gruppe alleLuL wird angelegt!"
    [String]$gname=$tm.Name
    New-ADGroup -Credential $global:ldapcredentials -Server $global:ldapserver -GroupScope Global -Path "OU=Lehrergruppen,OU=Lehrer,DC=mmbbs,DC=local" -Name "alleLul" -OtherAttributes @{'Mail'="alleLuL@mm-bbs.de"}
}
Get-LDAPTeachers | Where-Object {$_.TEACHER_ID} | Sync-LDAPCourseMember -KNAME alleLul -searchbase "OU=Lehrergruppen,OU=Lehrer,DC=mmbbs,DC=local" -force
#>

if (-not $Global:logins["smtp"]) {
    Write-Error "Keine SMTP Credentials gefunden. Bitte zunächst mit Login-SMTP Verbindung herstellen"
    break;
}
else {
    #send-mailreport -from tuttas@mmbbs.de -to jtuttas@gmx.net -subject "Synchronisationsscript durchgelaufen" -body $body -attachment "$PSScriptRoot/../../../out_lehrer.txt","$PSScriptRoot/../../../out_schueler.txt"
    if (Test-Path "$PSScriptRoot/../../../out_schueler.txt") {
        send-mailreport -from tuttas@mmbbs.de -to tuttas@mmbbs.de -subject "Synchronisationsscript durchgelaufen" -body $body -attachment "$env:TMP\teams.xlsx"
    }
    else {
        send-mailreport -from tuttas@mmbbs.de -to tuttas@mmbbs.de -subject "Synchronisationsscript durchgelaufen" -body $body -attachment "$env:TMP\teams.xlsx"
    }
}
