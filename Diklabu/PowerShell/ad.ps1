Connect-BbsPlan
Login-Diklabu
Login-LDAP
Login-Moodle
Export-BBSPlanung -mode SYNC -Verbose -deletepupil 

get-courses | Sync-LDAPCourse -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force
# Schüler aus dem Klassenbuch in der AD Anlegen
get-courses| Get-Coursemember  | Sync-LDAPPupil -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force 
# Schüler hinzufügen zu AD Gruppen
get-courses | Get-Course | ForEach-Object {$kname=$_.KNAME;Get-Coursemember -id $_.id | Sync-LDAPCourseMember -KNAME $kname -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force | ForEach-Object {$global:user=$_;Get-MoodleUser -property $_.ID -PROPERTYTYPE IDNUMBER | ForEach-Object {Set-MoodleUser -moodleid $_.id -email $global:user.EMAIL  -username $global:user.EMAIL.ToLower().subString(0,$global:user.EMAIL.IndexOf("@")) -Verbose}}}
# get-courses | Get-Course | ForEach-Object {$kname=$_.KNAME;Get-Coursemember -id $_.id | Sync-LDAPCourseMember -KNAME $kname -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force }
# Anpassen des Namens an den Gruppennamen
get-courses | Get-Course | Where-Object {$_.ID_KATEGORIE -eq 0} | Select-Object -Property KNAME | Rename-LDAPCourseMember -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force
# Moodle Cohorts anlegen und Benutzer Syncronisiren
# Achtung hier kommt es zur Warnuen wenn der Kurs Bereits existiert
Write-Host "Erzeuge Moodle Cohorts" -BackgroundColor DarkGreen
Get-Courses | foreach-Object {New-MoodleCohort -name $_.KNAME -idnumber $_.KNAME -force}
Write-Host "Syncronisiere Moodle Cohorts Member" -BackgroundColor DarkGreen
Get-MoodleCohorts | ForEach-Object {$cid=$_.id;$kname=$_.name;Find-Course -KNAME $_.name | Get-Coursemember | Get-MoodleUser -PROPERTYTYPE IDNUMBER  | Sync-MoodleCohortMember -cohortid $cid -force -Verbose}
