#$file=Read-Host "Umfrage CSV File?"
$file="$PSScriptRoot\umfrage.csv"
$csv=Import-Csv $file 
if ($csv) {
    $pops = $c[0].PSObject.Properties
    $i=0
    
    $answers=@();
    foreach ($p in $pops) {
        if ($i -gt 0) {
            $answer=$p.Name
            $answers+=New-PollAnswer -ANTWORT $answer            
        }
        $i++;
    }

    $questions=@();
    foreach ($q in $csv) {
        $questions+=New-PollQuestion -frage $q.Frage
    }
    foreach ($q in $questions) {
        foreach ($a in $answers) {
            Add-PollAnswer -IDFrage $q.id -IDAntwort $a.id
        }
    }
}