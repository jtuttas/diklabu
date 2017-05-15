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
    foreach ($line in $e) {
        if ($line.New_KNAME) {
            $course = Find-Course $line.New_KNAME
            if (-not $course) {
                Write-Warning "Achtung Kurse $($line.New_KNAME) nicht gefunden"
            }
            else {
                Add-Coursemember -id $line.Kid -klassenid $course.id -Verbose
            }
        }
        else {
        }
    }
}

