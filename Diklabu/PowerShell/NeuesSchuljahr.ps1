# Neues Schuljahr
Write-Host "WPKs löschen"
$c=Get-Courses -id_kategorie 1
foreach ($course in $c) {
    $m = Get-Coursemember -id $course.id
    foreach ($member in $m) {
        Remove-Coursemember -id $member.id -klassenid $course.id
    }
    Delete-Course -id $course.id
}

do {
  $q= read-Host "Noten gelöscht? (j/n)"
}
while ($q -ne "j")
do {
  $q= read-Host "Neues Schuljahr angelegt? (j/n)"
}
while ($q -ne "j")
# Jetzt kann ein neues Schuljahr in der Datenbank angelegt werden

# Neuen WPK anlegen und Schüler eintragen
$wpk=New-Course -KNAME "AB neu WPK" -ID_LEHRER TU -TITEL "ein nuer WPK" -NOTIZ "Dieses ist ein super WPK" -ID_KATEGORIE 1 
Find-Pupil -VNAME "Jörg" -NNAME "Tuttas" -GEBDAT "1968-04-11" | ForEach-Object {$_.id} | add-Coursemember -klassenid $wpk.id
# Neuen CCNA Kurs anlegen und Schüler eintragen
$wpk=New-Course -KNAME "AB neu CCNNA" -ID_LEHRER TU -TITEL "ein nuer WPK" -NOTIZ "Dieses ist ein spannénder CCNA Kurs" -ID_KATEGORIE 9
Find-Pupil -VNAME "Jörg" -NNAME "Tuttas" -GEBDAT "1968-04-11" | ForEach-Object {$_.id} | add-Coursemember -klassenid $wpk.id
