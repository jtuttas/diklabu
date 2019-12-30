$datei = Read-Host "Pfad zur Export Datei" 
$head='"Klasse","a1","a2","a3","k","a4","a5","a6","a7","a8","a9","a10","a11","a12","a13","a14","a15","a16","a17","a18","a19","a20","a21","a22","a23","a24","a25","a26","a27","Lehrer","a28","a29",'
Write-Warning "Ergänze HEAD Zeile"
$ftext = get-content $datei
$head|out-file -filepath $env:TEMP/untis.csv
$ftext|out-file -filepath $env:TEMP/untis.csv -Append 
$data = Import-Csv $env:TEMP/untis.csv 
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