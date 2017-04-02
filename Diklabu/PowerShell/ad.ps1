90263,90396 | get-course | Sync-LDAPCourse -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force
# Schüler aus dem Klassenbuch in der AD Anlegen
90263,90396 | Get-Coursemember  | Sync-LDAPPupil -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force
# Schüler hinzufügen zu AD Gruppen
90263,90396 | Get-Course | ForEach-Object {$kname=$_.KNAME;Get-Coursemember -id $_.id | Sync-LDAPCourseMember -KNAME $kname -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force | ForEach-Object {$global:user=$_;Get-MoodleUser -property $_.ID -PROPERTYTYPE IDNUMBER | ForEach-Object {Set-MoodleUser -moodleid $_.id -email $global:user.EMAIL  -username $global:user.EMAIL.ToLower().subString(0,$global:user.EMAIL.IndexOf("@")) -Verbose}}}
# Anpassen des Namens an den Gruppennamen
90263,90396 | Get-Course | Where-Object {$_.ID_KATEGORIE -eq 0} | Select-Object -Property KNAME | Rename-LDAPCourseMember -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force
