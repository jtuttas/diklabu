<#
    Vorbereitung einer neuen Kurswahl
#>
# WPK Kurse anlegen
New-Course -KNAME "WPK_TU_1_lila" -TITEL "Ein toller WPK"
New-Course -KNAME "WPK_TU_2_lila" -TITEL "Ein toller WPK2"
New-Course -KNAME "WPK_BK_1_lila" -TITEL "Ein tollerrer WPK"
New-Course -KNAME "WPK_Ke_lila" -TITEL "Ein ganz toller WPK"
New-Course -KNAME "WPK_We_lila" -TITEL "Spocht"
New-Course -KNAME "WPK_Ws_lila" -TITEL "Rechnen"
New-Course -KNAME "WPK_PK_lila" -TITEL "Malen"
New-Course -KNAME "WPK_vb_lila" -TITEL "Tanzen"


# Kurswahl sperren
Disable-Coursevoting
# Alte Kurswünsche löschen
Clear-Coursevoting -force
# Alte Kurse aus der Kurswahl löschen
List-Coursevoting | Remove-Coursevoting
# Alle WPK Kurse des lila Blocks zur WPK Wahl hinzufügen
Find-Course -KNAME "WPK%lila" | Add-Coursevoting
# Kurswahl freischalten
Enable-Coursevoting
Read-Host "Diese Kurse stehen zur Wahl !Jetzt wird die Kurswahl duchgeführt (Return für weiter)!"
<#
    Es wird gewählt (als Simulation), der WPK_TU_1_lila wird immer als Erstwunsch gewählt, die anderen WPK's zufällig
#>
# Schüler der Klassen FISI14 wählen
$schueler = Find-Coursemember -kname "FISI14%"
# Das sind die zu wählenden Kurse
$kurse = List-Coursevoting
foreach ($s in $schueler) {
    $wunsch2= Get-Random -Maximum $kurse.length -Minimum 1
    do {
        $wunsch3= Get-Random -Maximum $kurse.length -Minimum 1
    }
    while ($wunsch3 -eq $wunsch2)
    $name=$s.VNAME+" "+$s.NNAME
    $kurs1=$kurse[0]
    $kurs2=$kurse[$wunsch2]
    $kurs3=$kurse[$wunsch3]
    $titel1=$kurs1.KNAME
    $titel2=$kurs2.KNAME
    $titel3=$kurs3.KNAME
    Write-Host "Schüler $name wählt Erstwunsch=$titel1  Zweitwunsch=$titel2 Drittwunsch=$titel3"
    $s=Set-Coursevoting -id $s.id -course1 $kurs1.id -course2 $kurs2.id -course3 $kurs3.id
}
Write-Host "Es haben "$schueler.Length" Schüler gewählt !" -BackgroundColor DarkRed
Read-Host "Return Drücken für die Zuordnung der Schüler zu den WPKs"
<#
    Zuteilung der Schüler zu den Kursen, dabei sollen maximal 25 Schüler in einem Kurs sitzen
#>
$n1=0;
$n2=0;
$n3=0;
$n=0;
$kurse = List-Coursevoting
foreach ($k in $kurse) {
    # Ermitteln der Schüler, die diesen Kurs als Erstwunsch hatten
    $schueler = Get-Coursevoting -id $k.id -priority 1
    $n = $n+$schueler.Length
    $nk = Get-Coursemember $k.id | measure 
    Write-Host "Im Kurs "$k.TITEL" sind bisher "$nk.Count" Schüler"
    $m=25-$nk.Count;
    if ($schueler.Length -lt $m) {
        $m=$schueler.Length
    }

    for ($i=0;$i -lt $m;$i++) {
        # Schüler zu dem Kurs hinzufügen
        Add-Coursemember -id $schueler[$i].id -klassenid $k.id 
        # Kurswahl der Schülers entfernen
        Reset-Coursevoting -id $schueler[$i].id
        $name = $schueler[$i].VNAME+" "+$schueler[$i].NNAME
        Write-Host "Erstwunsch berücksichtigt für $name" -BackgroundColor Green
        $n1++;
    }
}
foreach ($k in $kurse) {
    # Ermitteln der Schüler, die diesen Kurs als Erstwunsch hatten
    $schueler = Get-Coursevoting -id $k.id -priority 2
    $nk = Get-Coursemember $k.id | measure 
    Write-Host "Im Kurs "$k.TITEL" sind bisher "$nk.Count" Schüler"
    $m=25-$nk.Count;
    if ($schueler.Length -lt $m) {
        $m=$schueler.Length
    }
    for ($i=0;$i -lt $m;$i++) {
        Add-Coursemember -id $schueler[$i].id -klassenid $k.id 
        Reset-Coursevoting -id $schueler[$i].id
        $name = $schueler[$i].VNAME+" "+$schueler[$i].NNAME
        Write-Host "Zweiwunsch berücksichtigt für $name" -BackgroundColor Yellow
        $n2++;
    }
}
foreach ($k in $kurse) {
    # Ermitteln der Schüler, die diesen Kurs als Erstwunsch hatten
    $schueler = Get-Coursevoting -id $k.id -priority 3
    $nk = Get-Coursemember $k.id | measure 
    Write-Host "Im Kurs "$k.TITEL" sind bisher "$nk.Count" Schüler"
    $m=25-$nk.Count;
    if ($schueler.Length -lt $m) {
        $m=$schueler.Length
    }
    for ($i=0;$i -lt $m;$i++) {
        $a=Add-Coursemember -id $schueler[$i].id -klassenid $k.id 
        $r=Reset-Coursevoting -id $schueler[$i].id
        $name = $schueler[$i].VNAME+" "+$schueler[$i].NNAME
        Write-Host "Drittwunsch berücksichtigt für $name" -BackgroundColor Red
        $n3++;
    }
}
Write-Host "Es haben sich $n Schüler an der Wahl beteiligt! Es wurden $n1 Erstwünsche berücksichtig, $n2 Zweitwünsche und $n3 Drittwünsche"

<#
    Aufräumen (wieder Zurück zum Anfang)
#>
Read-Host "WPK's Wieder löschen!"
# Kurswünsche löschen
Clear-Coursevoting -force
# Schüler aus den Kursen entfernen
foreach ($k in $kurse) {
    Get-Coursemember -id $k.id | Remove-Coursemember -klassenid $k.id
}
# Kurse aus der WPK Wahl entfernen
List-Coursevoting | Remove-Coursevoting
# Kurse wieder löschen
Find-Course -kname "WPK%lila" |  Delete-Course
