# erzeugt eine Objektliste mit allen SuS der Englisch Kurse
# BSP: exportEng | export-excel c:\Temp\eng.xlsx
function exportEng() {
    # Hier ggf. noch Bezeichnung anpassen
    Find-Course -KNAME "IT16_Eng%" |
    ForEach-Object {
        $kname=$_.KNAME
        $kid=$_.id
        $_ | Get-Coursemember | ForEach-Object {
            $out="" | Select-Object -Property KNAME,Kid,VNAME,NNAME,Sid,BBSPLAN_ID,New_KNAME
            $out.KNAME=$kname
            $out.Kid=$kid
            $out.VNAME=$_.VNAME
            $out.NNAME=$_.NNAME
            $out.Sid=$_.id
            $out.BBSPLAN_ID=$_.ID_MMBBS
            $out
        }
    }
}

# Dieses Script noch nicht getestet
# Importiert die sus in die neuen Kurse, diese Kurse müssen bereits angelegt worden sein!
function importEng($csv) {
    $e=Import-Excel $csv
    $out="";
    $counter=0;
    foreach ($line in $e) {
        if ($line.New_KNAME) {
            $course = Find-Course $line.New_KNAME
            if (-not $course) {
                Write-Host "Achtung Kurs ($($line.New_KNAME)) nicht gefunden" -Backgroundcolor Darkred
                $out += "Achtung Kurs ($($line.New_KNAME)) nicht gefunden.`r`n";
            }
            else {
                $p = Get-Pupil -id $line.Sid
                if ($p) {
                    Add-Coursemember -id $line.Sid -klassenid $course.id -Verbose 
                    $counter++
                }
                else {
                    Write-Warning "Achtung kann Schüler $($line.VNAME) $($line.NNAME) mit ID $($line.Sid) nicht gefunden"
                }
            }
        }
        else {
        }
    }
    Write-Host "Es wurden $counter Schüler, den Kursen zugewiesen" -BackgroundColor DarkGreen
    return $out;
}

