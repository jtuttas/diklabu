Import-Module -Name "$PSScriptRoot/diklabu" -Scope Global
Get-Keystore C:\Users\jtutt\diklabu_conf.json
#Connect-BbsPlan
Login-Diklabu
Login-LDAP
#Login-Moodle

# BBSPlanung
#Write-Host "Synchronisation BBS PLanung -> diklabu" -BackgroundColor DarkGreen
#Export-BBSPlanung -mode ONEWAY -Verbose -deletepupil 

#LDAP
Write-Host "Klassen im LDAP anlegen" -BackgroundColor DarkGreen
get-courses |  Where-Object {$_.KNAME -like "*17*"} | Sync-LDAPCourse -searchbase "OU=Schülerneu,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force
# Schüler aus dem Klassenbuch in der AD Anlegen
Write-Host "Schüler im LDAP anlegen" -BackgroundColor DarkGreen
get-courses |  Where-Object {$_.KNAME -like "*17*"} | Get-Coursemember  | Sync-LDAPPupil -searchbase "OU=Schülerneu,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force -pass "mmbbs"
# Schüler hinzufügen zu AD Gruppen
Write-Host "Füge Nutzer zu AD Gruppen hinzu" -BackgroundColor DarkGreen
get-courses | Where-Object {$_.KNAME -like "*17*"}| Get-Course | ForEach-Object {$kname=$_.KNAME;Get-Coursemember -id $_.id | Sync-LDAPCourseMember -KNAME $kname -searchbase "OU=Schülerneu,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force} 
Write-Host "Lösche Klassenlehrer / Kursleiter aus AD Gruppen " -BackgroundColor DarkGreen
get-courses | Where-Object {$_.KNAME -like "*17*"}| ForEach-Object {$kname="Lehrer-"+$_.KNAME;Get-LDAPCourseMember -KNAME $kname | ForEach-Object {Remove-LDAPCourseMember -KNAME $kname -TEACHER_ID $_.ID -force} } 
Write-Host "Füge Klassenlehrer / Kursleiter zu AD Gruppen hinzu" -BackgroundColor DarkGreen
get-courses | Where-Object {$_.KNAME -like "*17*"}| ForEach-Object {$kname="Lehrer-"+$_.KNAME;Get-Teacher -ID $_.ID_LEHRER | ForEach-Object {$a=Add-LDAPCourseMember -KNAME $kname -TEACHER_ID $_.idplain -searchbase "OU=Schülerneu,OU=mmbbs,DC=tuttas,DC=de" -force -Verbose}}
# Anpassen des Namens an den Gruppennamen
Write-Host "Anpassen der Namen an den Gruppenname" -BackgroundColor DarkGreen
get-courses | Get-Course | Where-Object {$_.ID_KATEGORIE -eq 0} | Select-Object -Property KNAME | Rename-LDAPCourseMember -searchbase "OU=Schülerneu,OU=mmbbs,DC=tuttas,DC=de"  -force

#Write-Host "Anpassung der Moodle Benutzer" -BackgroundColor DarkGreen
#get-Courses | ForEach-Object {Get-LDAPCourseMember -KNAME $_.KNAME -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de"} | ForEach-Object {$global:user=$_;if ($_.ID -ne $null) {Get-MoodleUser -property $_.ID -PROPERTYTYPE IDNUMBER | ForEach-Object {Set-MoodleUser -Verbose -moodleid $_.ID -email $global:user.EMAIL  -username $global:user.EMAIL.ToLower().subString(0,$global:user.EMAIL.IndexOf("@") ) }}}


# Moodle Cohorts anlegen und Benutzer Syncronisiren
# Achtung hier kommt es zur Warnuen wenn der Kurs Bereits existiert
Write-Host "Erzeuge Moodle Cohorts" -BackgroundColor DarkGreen
Get-Courses | foreach-Object {New-MoodleCohort -name $_.KNAME -idnumber $_.KNAME -force}
Write-Host "Syncronisiere Moodle Cohorts Member" -BackgroundColor DarkGreen
Get-MoodleCohorts | ForEach-Object {$cid=$_.id;$kname=$_.name;Find-Course -KNAME $_.name | Get-Coursemember | Get-MoodleUser -PROPERTYTYPE IDNUMBER  | Sync-MoodleCohortMember -cohortid $cid -force -Verbose}
