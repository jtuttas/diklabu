<#
    Schüler auf Abgang setzten, die CSV Datei enthält folgende Einträge
    "NNAME","VNAME","GEBDAT"
#>
Import-Csv C:\Users\jtutt_000\Temp\abgänger.csv | ForEach-Object {Search-Pupil -VNAMENNAMEGEBDAT $($_.VNAME+$_.NNAME+$_.GEBDAT) -LDist 3} | Set-Pupil -ABGANG "J"

# Aus Untis die KuK und Klassen extrahieren, in denen Sie einsatz haben

import-csv C:\Temp\untis-fi.csv -Delimiter ";" | Select-Object -Property lol,klasse,fach | Where-Object {$_.fach -eq "LF" -or $_.fach -eq "PO" -or $_.fach -eq "DE" -or $_.fach -eq "RE"} | Get-Unique -AsString

# Kurse aus dem KLassenbuch in der AD Anlegen
get-courses | Sync-LDAPCourse -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force
90263,90396 | get-course | Sync-LDAPCourse -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force

# Schüler aus dem Klassenbuch in der AD Anlegen
get-courses | Get-Coursemember  | Sync-LDAPPupil -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force
90263,90396 | Get-Coursemember  | Sync-LDAPPupil -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force


# Schüler hinzufügen zu AD Gruppen
get-courses | ForEach-Object {$kname=$_.KNAME;$m=Get-Coursemember -id $_.id;$m} | Sync-LDAPCourseMember -KNAME $kname -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force
90263,90396 | Get-Course | ForEach-Object {$kname=$_.KNAME;Get-Coursemember -id $_.id | Sync-LDAPCourseMember -KNAME $kname -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force}

# Anpassen des Namens an den Gruppennamen
90263,90396 | Get-Course | Where-Object {$_.ID_KATEGORIE -eq 0} | Select-Object -Property KNAME | Rename-LDAPCourseMember -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force
