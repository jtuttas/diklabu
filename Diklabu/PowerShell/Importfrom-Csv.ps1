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

        [switch]$force,
        [switch]$whatif
    )

    Begin
    {
        try {
            $c=Import-Csv $csv -ErrorAction SilentlyContinue -ErrorVariable e
        }
        catch {
            Write-Host "Kann CSV Datei $csv nicht finden" -BackgroundColor DarkRed
            break;
        }                 
        $zeile=0;
        $klasseMap=@{}
        foreach ($line in $c) {
            #$line
            $bname=$line.BETRNAM1+$line.BETRNAM2
            $bname=$bname.Trim()
            if ($bname.length -gt 0) {
                
                Write-Host "Suche Betrieb ($bname)"
                $comp=Find-Company -NAME ($bname)
                if ($comp.length -gt 1) {
                    Write-Host "Mehr als einen Betrieb mit dem Namen gefunden, wähle den ersten!" -BackgroundColor DarkYellow
                    $comp=$comp[0]
                }
                if ($comp) {
                    Write-Host "Bekannter Betrieb $bname (ID="$comp.ID") aktualisiere Daten PLZ="$line.BETRPLZ"ORT="$line.BETRORT"Strasse="$line.BETRSTR  -BackgroundColor DarkGreen
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
                    Write-Host "Neuer Betrieb $bname PLZ="$line.BETRPLZ"ORT="$line.BETRORT"Strasse="$line.BETRSTR"ID="$comp.ID -BackgroundColor DarkRed
                }
                 Write-Host "Suche Ausbilder "$line.BETRANSPR
                 if (-not $line.BETRANSPR) {
                    Write-Host "Kein Ausbilder angegeben, ersetze durch Betrieb!" -BackgroundColor DarkYellow
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
                            $ins=Set-Instructor -NNAME $line.BETRANSPR -EMAIL $email -FAX $line.FAX -TELEFON $line.TELEFON -ID $aus.ID
                        }
                        $found=$true
                        Write-Host "Bekannter Ausbilder"$line.BETRANSPR"($email) aktualisiere Daten EMAIL=$email FAX="$line.FAX"Telefon="$line.TELEFON" ID_Betrieb="$comp.ID -BackgroundColor DarkGreen
                        break;
                    }
                 }                 
                if ($found -eq $false) {
                   $email=$line.BETRONLINE
                   $email=$email.Replace(" ",";")
                   if (-not $whatif) {
                        $ins= New-Instructor -NNAME $line.BETRANSPR -EMAIL $email -FAX $line.FAX -TELEFON $line.TELEFON -ID_BETRIEB $comp.id
                   }
                   else {
                        $ins="" | Select-Object "ID_BETRIEB","ID"
                        $ins.ID_BETRIEB=$comp.ID
                        $ins.ID=0

                   }
                   Write-Host "Neuer Ausbilder"$line.BETRANSPR"EMAIL=$email FAX="$line.FAX"Telefon="$line.TELEFON"ID_BETRIEB="$comp.id"ID="$ins.id -BackgroundColor DarkRed
                   
                }
            }
            else {
                Write-Host "Kein Betrieb angegeben!" -BackgroundColor DarkYellow
                $comp=$null;
                $ins=$null;
            }
            if ($line.KL_LEHRER) {
                Write-Host "Suche Lehrer "$line.KL_LEHRER
                $teacher = Get-Teacher -ID $line.KL_LEHRER
                if ($teacher) {
                    Write-Host "Bekannter Lehrer"$line.KL_LEHRER"aktualisiere Daten VNAME="$line.'LVUEL.VNAME'"NNAME="$line.'LVUEL.NNAME' -BackgroundColor DarkGreen
                    if (-not $whatif) {
                        $teacher=Set-Teacher -ID $line.KL_LEHRER -NNAME $line.'LVUEL.NNAME' -VNAME $line.'LVUEL.VNAME'
                    }
                }
                else {
                    Write-Host "Neuer Lehrer"$line.KL_LEHRER"ID="$line.KL_LEHRER"VNAME="$line.'LVUEL.VNAME'"NNAME="$line.'LVUEL.NNAME' -BackgroundColor DarkRed
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
                Write-Host "Achtung f. die Klasse "$line.KL_NAME" ist kein Lehrer eingetragen" -BackgroundColor DarkRed
            }
            Write-Host "Suche Klasse ("$line.KL_NAME")"
                
            $course = Find-Course -KNAME ($line.KL_NAME)
            if ($course.length -gt 1) {
                Write-Host "Mehr als eine Klasse mit dem Namen gefunden, wähle die erste!" -BackgroundColor DarkYellow
                $course=$course[0]
            }
            if ($course) {
                Write-Host "Bekannte Klasse"$line.KL_NAME"aktualisiere Daten ID_LEHRER="$line.KL_LEHRER -BackgroundColor DarkGreen
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
                
                Write-Host "Neue Klasse"$line.KL_NAME" ID_LEHRER="$line.KL_LEHRER"ID="$course.ID -BackgroundColor DarkRed
            }      
            #$line  
            
            if ($line.GEBDAT -ne "") {
                $gdat = Get-Date -Date $line.GEBDAT -Format "yyyy-MM-dd"      
                Write-Host "Suche Schüler "$line.'SIL.VNAME'$line.'SIL.NNAME'" Geb."$gdat
                $searchString = $line.'SIL.VNAME'+$line.'SIL.NNAME'+$gdat
                $schueler=Search-Pupil -VNAMENNAMEGEBDAT $searchString -LDist 3
            }
            else {
                Write-Host "Achtung der Schüler hat kein Geburtsdatum, suche mit erhöhter Levensthein Distanz" -ForegroundColor Red
                Write-Host "Suche Schüler "$line.'SIL.VNAME'$line.'SIL.NNAME'
                $searchString = $line.'SIL.VNAME'+$line.'SIL.NNAME'+"19xx-xx-xx"
                $schueler=Search-Pupil -VNAMENNAMEGEBDAT $searchString -LDist 12
            }
            if ($schueler.Length -gt 1) {
                Write-Host "Mehr als einen Schüler gefunden, wähle den mit der geringsten Levenshtein Distanz!" -BackgroundColor DarkYellow
                $schueler = $schueler[0];
                $p=Get-Pupil -id $schueler.id
                Write-Host "Wähle "$schueler.name" "$schueler.vorname" "$p.gebDatum
            }        
            if ($schueler.ldist -eq 3) {
                if (-not $force) {
                     $p=Get-Pupil -id $schueler.id  
                     $p                   
                     Write-Host "Gefunden Wurde "$schueler.vorname" "$schueler.name" "$p.gebDatum -BackgroundColor DarkMagenta                    
                    $i=Read-Host "Achtung Levenshtein Distanz ist am Maximum! (Return = bekannter Schüler (weiter), e=break, n=neuer Schueler)" 
                    if ($i -eq "e") {
                        break;
                    }
                    elseif ($i -eq "n") {
                        $schueler=$null
                    }

                }
                else {
                    Write-Host "Achtung Levenshtein Distanz ist am Maximum!" -BackgroundColor DarkMagenta                    
                   
                }
            }
            if ($schueler) {
                Write-Host "Bekannter Schueler"$schueler.vorname$schueler.name" Geb."$line.GEBDAT"("$schueler.id") aktualisiere Daten" -BackgroundColor DarkGreen
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
                Write-Host "Neuer Schueler"$line.'SIL.VNAME'$line.'SIL.NNAME'" Geb."$line.GEBDAT -BackgroundColor DarkRed
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
                                    Write-Host $r.msg -BackgroundColor DarkYellow
                                }
                            }
                        }
                        else {
                             if (-not $whatif) {
                                $r=Remove-Coursemember -id $schueler.id -klassenid $klasse.ID                         
                                 Write-Host "Schüler aus "$klasse.KNAME" entfernt!" -BackgroundColor DarkYellow
                             }
                             else {
                                Write-Host "Schüler aus "$klasse.KNAME" entfernt!" -BackgroundColor DarkYellow
                             }
                             
                        }
                    }
                    if ($klasse.KNAME -like $course.KNAME) {
                        $inKlasse=$true;
                    }
                }
            }
            if (-not $inKlasse) {
                Write-Host "Schüler "$line.'SIL.VNAME'$line.'SIL.NNAME'"wird in die Klasse "$course.KNAME"eingetragen" -BackgroundColor DarkRed
                if (-not $whatif) {
                    $r=Add-Coursemember -id $schueler.id -klassenid $course.id 
                }
            }
            else {
                Write-Host "Schüler "$line.'SIL.VNAME'$line.'SIL.NNAME'"ist bereits in der Klasse "$course.KNAME -BackgroundColor DarkGreen
            }
            if ($klasseMap[$course.id]) {
                Write-Host "Klasseobjekt existiert mit "$course.id
                $klasseMap[$course.id].schueler[$schueler.id]=$line.'SIL.VNAME'+$line.'SIL.NNAME'
            }
            else {
                Write-Host "Klasseobjekt anlegen mit mit "$course.id
                $klasseMap[$course.id]=$course.KNAME | Select-Object "schueler","kname"
                $klasseMap[$course.id].kname=$course.KNAME
                $klasseMap[$course.id].schueler=@{}
                $klasseMap[$course.id].schueler[$schueler.id]=$line.'SIL.VNAME'+$line.'SIL.NNAME'
            }
            #$klasseMap
            $zeile++;
            Write-Host "------ Zeile:$zeile -----------"
            
        }
        
        if (-not $force) {
            $ask=Read-Host "Klassen (löschen) und Schüler auf Abgang setzten die nicht im csv enthalten sind (j/n)"
            if ($ask -eq "n") {
                break;
            }
        }
        $courses = Get-Courses -id_kategorie 0
        foreach ($course in $courses) {
            Write-Host "Bearbeite Klasse "$course.KNAME
            if ($klasseMap[$course.id]) {
                Write-Host "Klasse "$course.KNAME"gefunden, überprüfe Schüler!" -BackgroundColor DarkGreen
                $pupil = Get-Coursemember -id $course.id
                foreach ($p in $pupil) {
                    if ($klasseMap[$course.id].schueler[$p.id]) {
                        Write-Host "Schüler "$p.VNAME$p.NNAME"gefunden!" -BackgroundColor DarkGreen   
                    }
                    else {
                        Write-Host "Schüler "$p.VNAME$p.NNAME"nicht gefunden!" -BackgroundColor DarkRed
                        if (-not $force) {
                            $ask = Read-Host "Schüler "$p.VNAME$p.NNAME"auf Abgang setzten? (j/n)"
                            if ($ask -eq "j") {
                                if (-not $whatif) {
                                    $r=Set-Pupil -id $p.id -ABGANG "J"
                                }
                                Write-Host "Schüler "$p.VNAME$p.NNAME" auf Abgang gesetzt!"
                            }
                        }
                        else {
                            if (-not $whatif) {
                                $r=Set-Pupil -id $p.id -ABGANG "J"
                            }
                            Write-Host "Schüler "$p.VNAME$p.NNAME" auf Abgang gesetzt!"
                        }
                    }
                }
            }
            else {                
                Write-Host "Klasse "$course.KNAME"nicht gefunden!" -BackgroundColor DarkRed
                if (-not $force) {
                    $ask=Read-Host "Klasse löschen? (j/n)";
                    if ($ask -eq "j") {
                        if (-not $whatif) {
                            $r=Get-Coursemember -id $course.id | ForEach-Object {$_.id} | Remove-Coursemember -klassenid $course.id
                            $r=Delete-Course -id $course.id 
                        }
                        Write-Host "Klasse "$course.KNAME"gelöscht!"
                    }
                }
                else {
                    if (-not $whatif) {
                        $r=Get-Coursemember -id $course.id | ForEach-Object {$_.id} | Remove-Coursemember -klassenid $course.id
                        $r=Delete-Course -id $course.id 
                    }
                    Write-Host "Klasse "$course.KNAME"gelöscht!"
                }
            }
        }
    }
}