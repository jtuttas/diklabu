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
get-courses | ForEach-Object {$kname=$_.KNAME;Get-Coursemember -id $_.id | Sync-LDAPCourseMember -KNAME $kname -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force | ForEach-Object {$global:user=$_;Get-MoodleUser -property $_.ID -PROPERTYTYPE IDNUMBER | ForEach-Object {Set-MoodleUser -moodleid $_.id -email $global:user.EMAIL  -username $global:user.EMAIL.ToLower().subString(0,$global:user.EMAIL.IndexOf("@")) -Verbose}}}
90263,90396 | Get-Course | ForEach-Object {$kname=$_.KNAME;Get-Coursemember -id $_.id | Sync-LDAPCourseMember -KNAME $kname -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force | ForEach-Object {$global:user=$_;Get-MoodleUser -property $_.ID -PROPERTYTYPE IDNUMBER | ForEach-Object {Set-MoodleUser -moodleid $_.id -email $global:user.EMAIL  -username $global:user.EMAIL.ToLower().subString(0,$global:user.EMAIL.IndexOf("@")) -Verbose}}}


# Anpassen des Namens an den Gruppennamen
90263,90396 | Get-Course | Where-Object {$_.ID_KATEGORIE -eq 0} | Select-Object -Property KNAME | Rename-LDAPCourseMember -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force

# Für alle Klassen die Login Namen ausgaben
get-courses | Where-Object {$_.idKategorie -eq 0} | ForEach-Object {$KNAME=$_.KNAME; Get-Coursemember -id $_.ID | ForEach-Object {Get-LDAPAccount -ID $_.ID -NNAME $_.NNAME -VNAME $_.VNAME -KNAME $KNAME} | Select-Object -Property LoginName | Export-Excel "C:\Temp\$KNAME.xlsx"}

# Alle Kurs-Lehrer als Mitglied in ihrem Kurs eintrage 
Get-Courses | Where-Object {$_.idKategorie -ne 0 -and $_.ID_LEHRER} | ForEach-Object {Sync-CourseTeacher -ID $_.ID_LEHRER -ID_COURSE $_.id -Verbose} 

# Alle Klassen-Team Lehrer aus UNTIS Export ihrer Klasse zuordnen
$obj = Import-Untis -path C:\Temp\GPU-mmbbs-sj17-18_05082017.csv -prefix "" 
$obj.Keys | ForEach-Object {$course=Find-Course -KNAME $_;$obj.Item($_) | Sync-CourseTeacher -ID_COURSE $course.id -Verbose }

# Klassenlisten erzeugen aus XLSX Datei
import-excel C:\Temp\WPK_18_19.xlsx | Find-Course  | ForEach-Object {$kname=$_.KNAME;Get-Coursemember -id $_.id  | ForEach-Object {Add-Member -InputObject $_ -MemberType NoteProperty -Name KNAME -Value $kname;$_ | Select-Object -Property VNAME,NNAME,KNAME}| Export-Excel "c:\Temp\Klassen\$($_.KNAME).xlsx"}

import-excel C:\Temp\WPK_18_19.xlsx | Find-Course  | ForEach-Object {$wpkname=$_.KNAME;Get-Coursemember -id $_.id  | ForEach-Object {
    $p=get-pupil -id $_.id
    $klasse=""

    foreach ($k in $p.klassen) {
        if ($k.ID_KATEGORIE -eq 0) {
            $Klasse=$k.KNAME
            Write-Host "Klasse gefunden $klasse"
        }
    }
    Add-Member -InputObject $_ -MemberType NoteProperty -Name KNAME -Value $Klasse;$_ | Select-Object -Property VNAME,NNAME,KNAME}| Export-Excel "c:\Temp\Klassen\$wpkname.xlsx"}

get-courses | Where-Object {$_.idKategorie -eq 11}  | ForEach-Object {$wpkname=$_.KNAME;Get-Coursemember -id $_.id  | ForEach-Object {
    $p=get-pupil -id $_.id
    $klasse=""

    foreach ($k in $p.klassen) {
        if ($k.ID_KATEGORIE -eq 0) {
            $Klasse=$k.KNAME
            Write-Host "Klasse gefunden $klasse"
        }
    }
    Add-Member -InputObject $_ -MemberType NoteProperty -Name KNAME -Value $Klasse;$_ | Select-Object -Property VNAME,NNAME,KNAME}| Export-Excel "c:\Temp\Klassen\$wpkname.xlsx"}


# Klassen leeren