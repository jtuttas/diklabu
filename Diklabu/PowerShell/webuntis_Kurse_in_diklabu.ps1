<#
     Script zum Importieren der Kurse aus Webuntis ins Diklabu (fehlende Kurse werden automatisch angelegt !)

    Pfad zur Excel Datei muss ggf. angepasst werden (das geeignete Keystore muss schon geladen sein!)
#>
$path='D:\Temp\Kurslisten 2019_20.xlsx'
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Write-Host $PSScriptRoot
Import-Module -Name "$PSScriptRoot/diklabu" -Scope Global
Login-Untis
Login-Diklabu
$excel=Import-Excel $path
foreach ($row in $excel) {
    Write-Host "New Row doing $($row.kurs)" -BackgroundColor DarkGray
    $course = Find-Course $row.kurs
    if (-not $course) {
        Write-warning "Kurs $($row.kurs) nicht gefunden, wird angelegt"
        New-Course -KNAME $row.Kurs -ID_LEHRER $row.Dozent -ID_KATEGORIE $row.ID_Kategorie -Verbose
        $course = Find-Course $row.kurs
    }

    $date=get-Date $row.datum -Format yyyy-MM-dd    
    $students=Get-UntisCoursemember -id $row.ID -startDate $date -type subject
    $students | Where-Object {$_.stundentGroup -eq $row.student_group} | ForEach-Object {
        $member=$_
        Write-Host "suche Member $($_.Vorname) $($_.Familienname) Klasse $($_.Klasse)" -BackgroundColor DarkYellow
        $klasse = Find-Course $_.Klasse
        if ($klasse) {
            Get-Coursemember -id $klasse.id | Where-Object {$_.VNAME -eq $member.Vorname -and $_.NNAME -eq $member.Familienname} | ForEach-Object {
                Write-Host "Member $($_.VNAME) $($_.NNAME) wird in den Kurs $($row.Kurs) aufgenommen" -BackgroundColor DarkGreen
                Add-Coursemember -id $_.id -klassenid $course.id 
            }
        }
        else {
            Write-Error "Achtung Klasse ($_.Klasse) des Schülers $($_.Vorname) $($_.Familienname) nicht geunden!"
        }
    }
}