<#
    ToDo:
    1.) GEBDAT in yyyy-mm-tt wandeln
    2.) Format UTF8 speichern mit " als Texttrenner

#>


<#
.Synopsis
   Aufbau des Klassenbuches via CSV Datei
.DESCRIPTION
   Aufbau des Klassenbuches via CSV Datei
.EXAMPLE
   Importfrom-Csv test.csv
#>
function Importfrom-Csv
{
    Param
    (
        # Hilfebeschreibung zu Param1
        [Parameter(Mandatory=$true,Position=0)]
        $csv,

        # Es wird ohne Benutzerinteraktionen (Rückfragen) gearbeitet
        [switch]$force,
        # Es werden keine Schreibvorgänge ausgeführt
        [switch]$whatif,
        # Es werden keine Klassen / Schüler gelöscht (Bietet sich an, wenn die zu importierende Tabelle nich vollständig ist !)
        [switch]$nodelete
    )

    Begin
    {
        try {
            $c=Import-Csv $csv -ErrorAction SilentlyContinue -ErrorVariable e
        }
        catch {
            Write-error "Kann CSV Datei $csv nicht finden" 
            break;
        }                 
        $zeile=0;
        $klasseMap=@{}
        foreach ($line in $c) {
            #$line
            $bname=$line.BETRNAM1+$line.BETRNAM2
            if ($bname.length -gt 0) {
                $bname=$bname.Trim()
                
                Write-Verbose "Suche Betrieb ($bname)"
                $comp=Find-Company -NAME ($bname)
                if ($comp.length -gt 1) {
                    Write-warning "Mehr als einen Betrieb mit dem Namen gefunden, wähle den ersten!" 
                    $comp=$comp[0]
                }
                if ($comp) {
                    Write-Verbose "Bekannter Betrieb $bname (ID=$($comp.ID)) aktualisiere Daten PLZ=$($line.BETRPLZ) ORT=$($line.BETRORT) Strasse=$($line.BETRSTR)"
                    if (-not $whatif) {
                        $comp=Set-Company -ID $comp.id -PLZ $line.BETRPLZ -ORT $line.BETRORT -STRASSE $line.BETRSTR 
                    }
                }
                else {
                    if (-not $whatif) {
                        $comp=New-Company -NAME $bname  -PLZ $line.BETRPLZ -ORT $line.BETRORT -STRASSE $line.BETRSTR 
                    }
                    else {
                        $comp="" | Select-Object "ID"
                        $comp.ID=0
                    }
                    Write-Warning "Neuer Betrieb $bname PLZ=$($line.BETRPLZ) ORT=$($line.BETRORT) Strasse=$($line.BETRSTR) ID=$($comp.ID)" 
                }
                 Write-Verbose "Suche Ausbilder $($line.BETRANSPR)"
                 if (-not $line.BETRANSPR) {
                    Write-Warning "Kein Ausbilder angegeben, ersetze durch Betrieb!"
                    if ($bname.length -gt 49) {
                        $bname = $bname.SubString(0,49)
                    }
                    $line.BETRANSPR=$bname

                 }
                 
                 $ausb=Find-Instructor -NNAME $line.BETRANSPR
                 $found=$false;
                 foreach ($aus in $ausb) {
                    if ($aus.ID_BETRIEB -eq $comp.ID) {
                       
                        $email=$line.BETRONLINE
                        $email=$email.Replace(" ",";")
                        #Write-Host "Asubilder EMail=$email"
                        if (-not $whatif) {   
                            $ins=Set-Instructor -NNAME $line.BETRANSPR -EMAIL $email -FAX $line.BETRFAX -TELEFON $line.BETRTEL -ID $aus.ID
                        }
                        $found=$true
                        Write-Verbose "Bekannter Ausbilder $($line.BETRANSPR) ($email) aktualisiere Daten EMAIL=$email FAX=$($line.BETRFAX) Telefon=$($line.BETRTEL) ID_Betrieb=$($comp.ID) "
                        break;
                    }
                 }                 
                if ($found -eq $false) {
                   $email=$line.BETRONLINE
                   $email=$email.Replace(" ",";")
                   if (-not $whatif) {
                        $ins= New-Instructor -NNAME $line.BETRANSPR -EMAIL $email -FAX $line.BETRFAX -TELEFON $line.BETRTEL -ID_BETRIEB $comp.id
                   }
                   else {
                        $ins="" | Select-Object "ID_BETRIEB","ID"
                        $ins.ID_BETRIEB=$comp.ID
                        $ins.ID=0

                   }
                   Write-Warning "Neuer Ausbilder $($line.BETRANSPR) EMAIL=$email FAX=$($line.BETRFAX) Telefon=$($line.BETRTEL) ID_BETRIEB=$($comp.id) ID=$($ins.id)" 
                   
                }
            }
            else {
                Write-Warning "Kein Betrieb angegeben!" 
                $comp=$null;
                $ins=$null;
            }
            if ($line.KL_LEHRER) {
                Write-Verbose "Suche Lehrer $($line.KL_LEHRER)"
                $teacher = Get-Teacher -ID $line.KL_LEHRER
                if ($teacher) {
                    Write-Verbose "Bekannter Lehrer $($line.KL_LEHRER) aktualisiere Daten VNAME=$($line.'LVUEL.VNAME') NNAME=$($line.'LVUEL.NNAME')" 
                    if (-not $whatif) {
                        $teacher=Set-Teacher -ID $line.KL_LEHRER -NNAME $line.'LVUEL.NNAME' -VNAME $line.'LVUEL.VNAME'
                    }
                }
                else {
                    Write-Warning "Neuer Lehrer $($line.KL_LEHRER) ID=$($line.KL_LEHRER) VNAME=$($line.'LVUEL.VNAME') NNAME=$($line.'LVUEL.NNAME')" 
                    if (-not $whatif) {
                        $teacher=New-Teacher -ID $line.KL_LEHRER -NNAME $line.'LVUEL.NNAME' -VNAME $line.'LVUEL.VNAME'
                    }
                    else {
                        $teacher="" | Select-Object "ID"
                        $teacher.ID=$line.KL_LEHRER
                    }
                }
            }
            else {
                Write-Warning "Achtung f. die Klasse $($line.KL_NAME) ist kein Lehrer eingetragen" 
            }
            Write-Verbose "Suche Klasse ($($line.KL_NAME)"
                
            $course = Find-Course -KNAME ($line.KL_NAME)
            if ($course.length -gt 1) {
                Write-Warning "Mehr als eine Klasse mit dem Namen gefunden, wähle die erste!" 
                $course=$course[0]
            }
            if ($course) {
                Write-Verbose "Bekannte Klasse $($line.KL_NAME) aktualisiere Daten ID_LEHRER=$($line.KL_LEHRER)"
                if (-not $whatif) {
                    $course=Set-Course -id $course.id -ID_LEHRER $line.KL_LEHRER -KNAME $line.KL_NAME
                }
            }
            else {
                
                if (-not $whatif) {
                    $course=New-Course -KNAME $line.KL_NAME -ID_LEHRER $line.KL_LEHRER -ID_KATEGORIE 0 
                }
                else {
                    $course="" | Select-Object "ID","KNAME"
                    $course.ID=Get-Random -Maximum 10000
                    $course.KNAME=$line.KL_NAME
                }
                
                Write-Warning "Neue Klasse $($line.KL_NAME) ID_LEHRER=$($line.KL_LEHRER) ID=$($course.ID)"
            }      
            #$line  
            
            if ($line.GEBDAT -ne "") {
                $gdat = Get-Date -Date $line.GEBDAT -Format "yyyy-MM-dd"      
                Write-Verbose "Suche Schüler $($line.'SIL.VNAME') $($line.'SIL.NNAME') Geb.$gdat"
                $searchString = $line.'SIL.VNAME'+$line.'SIL.NNAME'+$gdat
                $schueler=Search-Pupil -VNAMENNAMEGEBDAT $searchString -LDist 3
            }
            else {
                Write-Warning "Achtung der Schüler hat kein Geburtsdatum, suche mit erhöhter Levensthein Distanz" 
                Write-Verbose "Suche Schüler $($line.'SIL.VNAME') $($line.'SIL.NNAME')"
                $searchString = $line.'SIL.VNAME'+$line.'SIL.NNAME'+"19xx-xx-xx"
                $schueler=Search-Pupil -VNAMENNAMEGEBDAT $searchString -LDist 12
            }
            if ($schueler.Length -gt 1) {
                Write-Warning "Mehr als einen Schüler gefunden, wähle den mit der geringsten Levenshtein Distanz!" 
                $schueler = $schueler[0];
                $p=Get-Pupil -id $schueler.id
                Write-Warning "Wähle $($schueler.name) $($schueler.vorname) $($p.gebDatum)"
            }        
            if ($schueler.ldist -eq 3) {
                if (-not $force) {
                     $p=Get-Pupil -id $schueler.id  
                     $p                   
                     Write-Verbose "Gefunden Wurde $($schueler.vorname) $($schueler.name) $($p.gebDatum)"
                    $i=Read-Host "Achtung Levenshtein Distanz ist am Maximum! (Return = bekannter Schüler (weiter), e=break, n=neuer Schueler)" 
                    if ($i -eq "e") {
                        break;
                    }
                    elseif ($i -eq "n") {
                        $schueler=$null
                    }

                }
                else {
                    Write-Warning "Achtung Levenshtein Distanz ist am Maximum!" 
                   
                }
            }
            if ($schueler) {
                Write-Verbose "Bekannter Schueler $($schueler.vorname) $($schueler.name) Geb.$($line.GEBDAT) ($($schueler.id)) aktualisiere Daten" 
                if (-not $whatif) {
                    if ($ins) {
                        $schueler=Set-Pupil -id $schueler.id -VNAME $line.'SIL.VNAME' -NNAME $line.'SIL.NNAME' -GEBDAT $gdat -EMAIL $line.EMAIL -ID_AUSBILDER $ins.ID -ABGANG "N" 
                    }
                    else {                        
                        $schueler=Set-Pupil -id $schueler.id -VNAME $line.'SIL.VNAME' -NNAME $line.'SIL.NNAME' -GEBDAT $gdat -EMAIL $line.EMAIL -ABGANG "N" 
                    }
                }
            }
            else {
                Write-Warning "Neuer Schueler $($line.'SIL.VNAME') $($line.'SIL.NNAME') Geb.$($line.GEBDAT)"
                if (-not $whatif) {
                    if ($ins) {
                        $schueler=New-Pupil -VNAME $line.'SIL.VNAME' -NNAME $line.'SIL.NNAME' -GEBDAT $gdat -EMAIL $line.EMAIL -ID_AUSBILDER $ins.ID -ABGANG "N" 
                    }
                    else {
                        $schueler=New-Pupil -VNAME $line.'SIL.VNAME' -NNAME $line.'SIL.NNAME' -GEBDAT $gdat -EMAIL $line.EMAIL  -ABGANG "N" 
                    }
                }
                else {
                    $schueler = "" | Select-Object "id"
                    $schueler.id=Get-Random -Maximum 10000
                }
            }
            $pupil = Get-Pupil  -id $schueler.ID
            $klassen = $pupil.klassen
            $inKlasse=$false
            foreach ($klasse in $klassen) {
                if ($klasse.ID_KATEGORIE -eq 0) {
                    if ($klasse.KNAME -notlike $course.KNAME) {
                        if (-not $force) {
                            $q=Read-Host "Der Schüler ("$schueler.id")befindet sich in der Klasse "$klasse.KNAME" ("$klasse.ID"), Schüler aus der Klasse entfernen? (j/n)" 
                            if ($q -eq "j") {
                                if (-not $whatif) {
                                    $r=Remove-Coursemember -id $schueler.id -klassenid $klasse.ID
                                    Write-Warning $r.msg 
                                }
                            }
                        }
                        else {
                             if (-not $whatif) {
                                $r=Remove-Coursemember -id $schueler.id -klassenid $klasse.ID                         
                                 Write-Warning "Schüler aus $($klasse.KNAME) entfernt!" 
                             }
                             else {
                                Write-Warning "Schüler aus $($klasse.KNAME) entfernt!" 
                             }
                             
                        }
                    }
                    if ($klasse.KNAME -like $course.KNAME) {
                        $inKlasse=$true;
                    }
                }
            }
            if (-not $inKlasse) {
                Write-Verbose "Schüler $($line.'SIL.VNAME') $($line.'SIL.NNAME') wird in die Klasse $($course.KNAME) eingetragen"
                if (-not $whatif) {
                    $r=Add-Coursemember -id $schueler.id -klassenid $course.id 
                }
            }
            else {
                Write-Verbose "Schüler $($line.'SIL.VNAME') $($line.'SIL.NNAME') ist bereits in der Klasse $($course.KNAME)"
            }
            if ($klasseMap[$course.id]) {
                Write-Verbose "Klasseobjekt existiert mit $($course.id)"
                $klasseMap[$course.id].schueler[$schueler.id]=$line.'SIL.VNAME'+$line.'SIL.NNAME'
            }
            else {
                Write-Verbose "Klasseobjekt anlegen mit mit $($course.id)"
                $klasseMap[$course.id]=$course.KNAME | Select-Object "schueler","kname"
                $klasseMap[$course.id].kname=$course.KNAME
                $klasseMap[$course.id].schueler=@{}
                $klasseMap[$course.id].schueler[$schueler.id]=$line.'SIL.VNAME'+$line.'SIL.NNAME'
            }
            #$klasseMap
            $zeile++;
            Write-Verbose "------ Zeile:$zeile -----------"
            
        }
        
        if ($nodelete) {
            break;
        }
        if (-not $force) {
            $ask=Read-Host "Klassen (löschen) und Schüler auf Abgang setzten die nicht im csv enthalten sind (j/n)"
            if ($ask -eq "n") {
                break;
            }
        }
        $courses = Get-Courses -id_kategorie 0
        foreach ($course in $courses) {
            Write-Verbose "Bearbeite Klasse $($course.KNAME)"
            if ($klasseMap[$course.id]) {
                Write-Verbose "Klasse $($course.KNAME) gefunden, überprüfe Schüler!"
                $pupil = Get-Coursemember -id $course.id
                foreach ($p in $pupil) {
                    if ($klasseMap[$course.id].schueler[$p.id]) {
                        Write-Verbose "Schüler $($p.VNAME) $($p.NNAME) gefunden!"
                    }
                    else {
                        Write-Warning "Schüler $($p.VNAME) $($p.NNAME) nicht gefunden!" 
                        if (-not $force) {
                            $ask = Read-Host "Schüler "$p.VNAME$p.NNAME"auf Abgang setzten? (j/n)"
                            if ($ask -eq "j") {
                                if (-not $whatif) {
                                    $r=Set-Pupil -id $p.id -ABGANG "J"
                                }
                                Write-Verbose "Schüler $($p.VNAME) $($p.NNAME) auf Abgang gesetzt!"
                            }
                        }
                        else {
                            if (-not $whatif) {
                                $r=Set-Pupil -id $p.id -ABGANG "J"
                            }
                            Write-Warning "Schüler $($p.VNAME) $($p.NNAME) auf Abgang gesetzt!"
                        }
                    }
                }
            }
            else {                
                Write-Warning "Klasse $($course.KNAME) nicht gefunden!" 
                if (-not $force) {
                    $ask=Read-Host "Klasse löschen? (j/n)";
                    if ($ask -eq "j") {
                        if (-not $whatif) {
                            $r=Get-Coursemember -id $course.id | ForEach-Object {$_.id} | Remove-Coursemember -klassenid $course.id
                            $r=Delete-Course -id $course.id 
                        }
                        Write-Warning "Klasse $($course.KNAME) gelöscht!"
                    }
                }
                else {
                    if (-not $whatif) {
                        $r=Get-Coursemember -id $course.id | ForEach-Object {$_.id} | Remove-Coursemember -klassenid $course.id
                        $r=Delete-Course -id $course.id 
                    }
                    Write-Warning "Klasse $($course.KNAME) gelöscht!"
                }
            }
        }
    }
}