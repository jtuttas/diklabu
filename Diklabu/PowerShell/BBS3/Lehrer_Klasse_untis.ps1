$datei = Read-Host "Pfad zur CSV Datei" 
$data = Import-Csv $datei 
$obj = @{}
$data | ForEach-Object {
    if (-not ($obj[$_.Klasse] -contains $_.Lehrer)) {
        Write-Host "Füge $($_.Lehrer) zur Klasse $($_.Klasse) hinzu" -ForegroundColor DarkGreen
        if (-not $obj[$_.Klasse]) {
            $obj[$_.Klasse]=@($_.Lehrer)
        }
        else {
            $obj[$_.Klasse]+=$_.Lehrer
        }
    }
    else {
     Write-Host "Lehrre $($_.Lehrer) bereits in Klasse  $($_.Klasse)" -ForegroundColor DarkRed
    }
}
$obj.Keys | ForEach-Object {$course=Find-Course -KNAME $_;Write-Host "Bearbeite Course ($course)" -ForegroundColor Yellow;$obj.Item($_) | Sync-CourseTeacher -ID_COURSE $course.id -Verbose }