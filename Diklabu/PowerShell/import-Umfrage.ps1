#$file=Read-Host "Umfrage CSV File?"
$r=Read-Host "Umfrage auf Grundlage einer existierenden Umfrage (J/N)"
if ($r -eq "J") {
    do {
        $r2=Read-Host "ID der Umfrage oder (? .. Zeigt alle Umfragen an)"
        if ($r2 -eq "?") {
            Get-Polls            
        }
    }
    while ($r2 -eq "?")
    $poll=Get-Poll -ID $r2
    $r3=Read-Host "Titel der neuen Umfrage Verbotene Zeichen (*/)"
    $r4=Read-Host "Bei privaten Umfragen das Kürzel des Lehrers angeben (sonst Return)"
    if ($r4) {
        $newpoll=New-Poll -TITEL $r3 -OWNER $r4
    }
    else {
        $newpoll=New-Poll -TITEL $r3 
    }
    Write-Host "Fragen aus der Unfrage $($poll.titel) werden zur Umfrage $r3 hinzugefügt"
    $fragen = $poll.fragen
    foreach ($f in $fragen) {
        Add-PollQuestion -IDFrage $f.id -IDUmfrage $newpoll.id
    }
}
else {
    $r5=Read-Host "Name der CSV Datei"
    $file="$PSScriptRoot\$r5"
    $csv=Import-Csv $file 
    if ($csv) {
        $r3=Read-Host "Titel der neuen Umfrage Verbotene Zeichen (*/)"
        $r4=Read-Host "Bei privaten Umfragen das Kürzel des Lehrers angeben (sonst Return)"
        if ($r4) {
            $newpoll=New-Poll -TITEL $r3 -OWNER $r4
        }
        else {
            $newpoll=New-Poll -TITEL $r3 
        }
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
            Add-PollQuestion -IDFrage $q.id -IDUmfrage $newpoll.id
        }
    }
}

# Schüler hinzufügen
#Find-Course "FISI14%" | Get-Coursemember | New-PollSubscriber -ID_UMFRAGE 12284 -TYPE SCHÜLER

# Eine Klasse einladen
<#
$ps=Get-PollSubscribers -ID_UMFRAGE 4367
$cousemember = Find-Coursemember -KNAME FISI14A
foreach ($pupil in $ps) {
    foreach ($cm in $cousemember) {
        if ($cm.id -eq $pupil.idSchueler) {
            Invite-PollSubscriber -KEY $pupil.key -whatif -Verbose
            Write-Host "Lade ein "$pupil.key". Das ist "$cm.VNAME" "$cm.NNAME
        }
    }
}
#>

# alle Schüler einer Umfrage einladen
#Get-PollSubscribers 12284 | Invite-PollSubscriber 
