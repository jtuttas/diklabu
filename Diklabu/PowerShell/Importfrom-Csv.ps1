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

        foreach ($line in $c) {
            #$line
            if ($line.BETRNAM1) {
                Write-Host "Suche Betrieb "$line.BETRNAM1
                $comp=Find-Company -NAME $line.BETRNAM1 
                if ($comp) {
                    Write-Host "Bekannter Betrieb"$line.BETRNAM1" (ID="$comp.ID") aktualisiere Daten PLZ="$line.BETRPLZ"ORT="$line.BETRORT"Strasse="$line.BETRSTR  -BackgroundColor DarkGreen
                    if (-not $whatif) {
                        $comp=Set-Company -ID $comp.id -PLZ $line.BETRPLZ -ORT $line.BETRORT -STRASSE $line.BETRSTR 
                    }
                }
                else {
                    if (-not $whatif) {
                        $comp=New-Company -NAME $line.BETRNAM1  -PLZ $line.BETRPLZ -ORT $line.BETRORT -STRASSE $line.BETRSTR 
                    }
                    else {
                        $comp="" | Select-Object "ID"
                        $comp.ID=0
                    }
                    Write-Host "Neuer Betrieb"$line.BETRNAM1"PLZ="$line.BETRPLZ"ORT="$line.BETRORT"Strasse="$line.BETRSTR"ID="$comp.ID -BackgroundColor DarkRed
                }
                 Write-Host "Suche Ausbilder "$line.BETRANSPR
                 $ausb=Find-Instructor -NNAME $line.BETRANSPR
                 $found=$false;
                 foreach ($aus in $ausb) {
                    if ($aus.ID_BETRIEB -eq $comp.ID) {
                       
                        $email=$line.BETRONLINE
                        $email=$email.Replace(" ",";")
                        #Write-Host "Asubilder EMail=$email"
                        if (-not $whatif) {   
                            $ins=Set-Instructor -NNAME $line.BETRANSPR -EMAIL $email -FAX $line.FAX -TELEFON $line.TELEFON -ID $comp.ID
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
            Write-Host "Suche Klasse "$line.KL_NAME
                
            $course = Find-Course -KNAME $line.KL_NAME
            if ($course) {
                Write-Host "Bekannte Klasse"$line.KL_NAME"aktualisiere Daten ID_LEHRER="$line.KL_LEHRER -BackgroundColor DarkGreen
                if (-not $whatif) {
                    $course=Set-Course -id $course.id -ID_LEHRER $line.KL_LEHRER 
                }
            }
            else {
                
                if (-not $whatif) {
                    $course=New-Course -KNAME $line.KL_NAME -ID_LEHRER $line.KL_LEHRER -ID_KATEGORIE 0 
                }
                else {
                    $course="" | Select-Object "ID"
                    $course.ID=0
                }
                Write-Host "Neue Klasse"$line.KL_NAME" ID_LEHRER="$line.KL_LEHRER"ID="$course.ID -BackgroundColor DarkRed
            }      
            #$line    
            $gdat = Get-Date -Date $line.GEBDAT -Format "yyyy-MM-dd"      
            Write-Host "Suche Schüler "$line.'SIL.VNAME'$line.'SIL.NNAME'" Geb."$gdat
            $searchString = $line.'SIL.VNAME'+$line.'SIL.NNAME'+$gdat
            $schueler=Search-Pupil -VNAMENNAMEGEBDAT $searchString -LDist 4            
            if ($schueler) {
                Write-Host "Bekannter Schueler"$line.'SIL.VNAME'$line.'SIL.NNAME'" Geb."$line.GEBDAT"aktualisiere Daten" -BackgroundColor DarkGreen
                if (-not $whatif) {
                    $schueler=Set-Pupil -id $schueler.id -VNAME $line.'SIL.VNAME' -NNAME $line.'SIL.NNAME' -GEBDAT $gdat -EMAIL $line.EMAIL -ID_AUSBILDER $ins.ID -ABGANG "N" 
                }
            }
            else {
                Write-Host "Neuer Schueler"$line.'SIL.VNAME'$line.'SIL.NNAME'" Geb."$line.GEBDAT -BackgroundColor DarkRed
                if (-not $whatif) {
                    $schueler=New-Pupil -VNAME $line.'SIL.VNAME' -NNAME $line.'SIL.NNAME' -GEBDAT $gdat -EMAIL $line.EMAIL -ID_AUSBILDER $ins.ID -ABGANG "N" 
                }
            }
            $pupil = Get-Pupil  -id $schueler.ID
            $klassen = $pupil.klassen
            $inKlasse=$false
            foreach ($klasse in $klassen) {
                if ($klasse.ID_KATEGORIE -eq 0) {
                    if ($klasse.KNAME -notlike $course.KNAME) {
                        if (-not $force) {
                            $q=Read-Host "Der Schüler befindet sich in der Klasse "$klasse.KNAME", Schüler aus der Klasse entfernen? (j/n)" 
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
                                Write-Host $r.msg -BackgroundColor DarkYellow
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

            Write-Host "-----------------"
        }
    }
}