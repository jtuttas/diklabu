<#
.Synopsis
   In Seafile Gruppen anlegen und Schüler und Lehrer dort eintragen 
.DESCRIPTION
   SF Gruppen anlegen und Benutzer (Schüler und Lehrer eintragen)
.EXAMPLE
   Sync-SFClasses -untisexport c:\Temp\untis.csv 
   Anhand des Untis Exporrtes werden die Lehrer zu den Klassen Gruppen hinzugefügt. Die Schüler werden aus den Moodle Cohorts 
   (globale Gruppen) den Klassen Kursen hinzugefügt

#>
function Sync-SFCourses
{
    [CmdletBinding()]
    Param
    (
        # Pfad zur UNTIS CSV Datei
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String]$untisexport,
        # Kategorien, die als Kurse angelegt werden (Klassenkurse Kategorie 0) wird immer angelegt!
        [int []]$includeIDKategorie=(1,2,3,9),
        [switch]$force,
        [switch]$whatif       
    )
    Begin
    {
        try {
            $untis = Import-Csv $untisexport -Delimiter ';' 
        }
        catch {
            Write-Error "Konnte die Datei $untisexport nicht finden!"
            return;
        }

        # Lehrer Hash Table aus dem Klassenbuch erzeugen        
        $le=Get-Teachers
        $lehrer=@{}
        foreach ($l in $le) {
            $lehrer[$l.id]=$l
        } 

        # Hash Table f. globale Gruppen erzeugen (Key ist der Name der Gruppe)
        $coh = Get-MoodleCohorts
        $cohorts=@{}
        foreach ($c in $coh) {
            $cohorts[$c.name]=$c
        }

        # Hash Table f. Gruppen in Seafile erzeugen (Key ist Name der Gruppe)
        $sfg = Get-SFGroups
        $sfgroups=@{}
        foreach ($g in $sfg) {
            $sfgroups[$g.name]=$g
        }
        
        $n=1
        foreach ($line in $untis) {
            Write-Verbose "Bearbeite Zeile $($n): Klasse $($line.klasse)"
            $n++;
            if (-not $sfgroups[$line.klasse]) {
                Write-Verbose " Klassen existiert nicht als Gruppe in Seafile, und wird angelegt"
                if (-not $whatif) {
                    if ($force) {
                        $c = New-SFGroup -name $line.klasse -force 
                    }
                    else {
                       $c = New-SFGroup -name $line.klasse 
                    }
                    $sfgroups[$line.klasse]=$c
                }  
            }            

            
            
            if (-not $cohorts[$line.klasse].bearbeitet) {  
                $memberIst=@{};
                $memist = @{};
                $memi = Get-SFGroupmember -id $sfgroups[$line.klasse].id
                foreach ($mi in $memi) {
                    [String]$mail=$mi.email;
                    $memberIst[$mail]=$mail
                    $memist[$mail]=$mail
                }
                $sfgroups[$line.klasse] | Add-Member -MemberType NoteProperty -Name memberIst -Value $memist
                if ($cohorts[$line.klasse]) {
                    $cohorts[$line.klasse] | Add-Member -MemberType NoteProperty -Name bearbeitet -Value $true
                    Write-Verbose " Globale MoodleGruppe $($line.klasse) gefunden, füge Schüler in die SF Gruppe ein!"
                    
                    $mem = Get-MoodleCohortMember $cohorts[$line.klasse].id
                    # Es werden nun die Moodle IDs zurückgegeben, gebraucht werdejn aber die email Adressen
                    $memberSoll=@{};
                    foreach ($m in $mem.userids) {
                        $muser = Get-MoodleUser -property $m -PROPERTYTYPE ID
                        $memberSoll[$muser.email]=[String]$muser.email
                    }
                    
                    foreach ($soll in $memberSoll.Values[0]) {
                        if (-not $whatif) {
                            # Ist Benutzer schon in der Gruppe (ist=soll)
                            Write-Verbose "Bearbeite Gruppenmitglied $soll"
                            if ($memberIst[$soll]) {
                                Write-Verbose "Der Benutzer $($soll) ist bereits in der Gruppe $($line.klasse)"                                
                            }
                            else {
                                Write-Verbose "Der Benutzer $($soll) ist nicht in der Gruppe $($line.klasse) und wird hinzugefügt"                                
                                $u = Get-SFUser -email $soll -ErrorAction SilentlyContinue
                                if ($u) {
                                    Write-Verbose "Nutzer $($soll) gefunden und wird hinzugefügt"
                                    if ($force) {
                                         $m=Add-SFGroupmember -email $soll -id $sfgroups[$line.klasse].id -force
                                    }
                                    else {
                                         $m=Add-SFGroupmember -email $soll -id $sfgroups[$line.klasse].id
                                    }
                                }
                                else {
                                   Write-Verbose "Nutzer $($soll) NICHT gefunden und wird angelegt und hinzugefügt"
                                   if ($force) {
                                   
                                        $m=New-SFUser -email $soll -password mmbbs -force
                                        $m=Add-SFGroupmember -email $soll -id $sfgroups[$line.klasse].id -force
                                   }
                                   else {
                                        $m=New-SFUser -email $soll -password mmbbs 
                                        $m=Add-SFGroupmember -email $soll -id $sfgroups[$line.klasse].id
                                   }
                                }
                            }
                            $memberIst.Remove($soll)
                            
                            $sfgroups[$line.klasse].memberIst.remove($soll)
                        }
                    }
                }
                else {
                    Write-Warning " Es existiert keine globale Gruppe mit dem Namen $($line.klasse)"
                    $obj = "" | Select-Object -Property bearbeitet
                    $obj.bearbeitet=$true
                    $cohorts[$line.klasse]=$obj
                }
                
            }

            if (-not $sfgroups[$line.klasse].lehrer) {
                $l = @{}
                $sfgroups[$line.klasse] | Add-Member -MemberType NoteProperty -Name lehrer -Value $l
            }

            if (-not $sfgroups[$line.klasse].lehrer[$line.lol]) {
                
                if ($line.fach -eq "LF" -or $line.fach -eq "PO" -or $line.fach -eq "DE" -or $line.fach -eq "RE") {
                    $sfgroups[$line.klasse].lehrer[$line.lol]=$line.lol
                    if ($line.lol) {
                    Write-Verbose " Suchen den Lehrer mit dem Kürzel $($line.lol)"
                    if ($lehrer[$line.lol]) {
                        Write-Verbose " Suchen den SF Benutzer mit der EMAIL $($lehrer[$line.lol].email)"
                        $muser = Get-SFUser -email $lehrer[$line.lol].email 
                        if ($muser) {
                            if (-not $whatif) {
                                if (-not $memberIst[$lehrer[$line.lol].email]) {
                                    Write-Verbose " Trage den User in die Gruppe $($line.klasse) ein!"                
                                    if (-not $whatif) {
                                        if ($force) {
                                            $m=Add-SFGroupmember -email $lehrer[$line.lol].email -id $sfgroups[$line.klasse].id -force
                                        }
                                        else {
                                             $m=Add-SFGroupmember -email $lehrer[$line.lol].email -id $sfgroups[$line.klasse].id
                                        }
                                    }
                                }
                                else {
                                    Write-Verbose " Der User ist bereits in der Gruppe  $($line.klasse)!"  
                                    $memberIst.Remove($soll)              
                                }   
                               
                                $sfgroups[$line.klasse].memberIst.remove($lehrer[$line.lol].email)                             
                            }
                        }
                        else {
                            Write-Verbos "Der Lehrer mit dem Kürzel $($line.lol) und der EMail Adresse $($lehrer[$line.lol].email) kann nicht in SF gefunden werden!"
                        }
                    }
                    else {
                        Write-Warning "Keine Lehrer mit dem Kürzel $($line.lol) nicht finden!!"
                    }
                }
                }
                else {
                    Write-Verbose " Zeile enthält das Kursfach $($line.fach)"
                }
            }
            else {
            #$moodelCourses[$line.klasse].lehrer
                Write-Verbose "Doppeleinsatz! Den Lehrer mit Kürzel $($line.lol) bereits für die Klasse $($line.klasse) berücksichtigt"
            }
        }       
        
        <# 
            Kurse bilden f. WPKs etc

            Anhand von $includeIDKategorie werden die Gruppen in Seafile angelegt, Schüler
            werden aus dem diklabu hinzugefügt und der Kursleiter als Lehrer dort eingetragen!

        #>
        # KUrse aus dem Klassenbuch
        $diklabuCourses = Get-Courses | Where-Object {$includeIDKategorie -contains $_.idkategorie} 

        # Kurse in Seafile
        

        foreach ($c in $diklabuCourses) {
            if (-not $sfgroups[$c.KNAME]) {
                Write-Verbose "Der diklabu Kurs $($c.KNAME) existiert nicht und wird angelegt"
                if (-not $whatif) {
                    if ($force) {
                        $g=New-SFGroup -name $c.KNAME -force
                    }
                    else {
                        $g=New-SFGroup -name $c.KNAME 
                    }
                    $sfgroups[$c.KNAME]=$g
                }
            }
            else {#
                Write-Verbose "Der diklabu Kurs $($c.KNAME) gefunden"
            }


            # Schüler in der Kurs eintragen
            
            # Schüler im diklabu
            $coursemem = Get-Coursemember -id $c.id
            # Schüler in Seafile
            $sfm = Get-SFGroupmember -id $sfgroups[$c.KNAME].id
            $grist = @{}
            foreach ($g in $sfm) {
                $grist[$g.email]=$g.email;
            }
            $sfgroups[$c.KNAME] | Add-Member -MemberType NoteProperty -Name memberIst -Value $grist

            foreach ($mem in $coursemem) {
                $le = Get-SFUser -email $mem.EMAIL
                if ($le) {
                   
                    if ( -not $grist[$mem.EMAIL]) {
                        Write-Verbose "Schüler gefunden, weise ihn den Kurs $($c.KNAME) zu!"
                        if (-not $whatif) {
                            if ($force) {
                                $u= Add-SFGroupmember -email $mem.EMAIL -id $sfgroups[$c.KNAME].id -force
                            }
                            else {
                                $u= Add-SFGroupmember -email $mem.EMAIL -id $sfgroups[$c.KNAME].id 
                            }
                        }
                    }
                    else {
                         Write-Verbose "Schüler gefunden, ist bereits im Kurs $($c.KNAME) zu!"
                    }
                    $sfgroups[$c.KNAME].memberIst.remove($mem.EMAIL);

                }
                else {
                    Write-Verbose "Schüler nicht gefunden, wird angelegt!"
                    if (-not $whatif) {
                        if ($force) {
                            $u= New-SFUser -email $mem.EMAIL -password mmbbs -force
                        }
                        else {
                            $u= New-SFUser -email $mem.EMAIL -password mmbbs
                        }
                    }
                    Write-Verbose "Neuer Schüler  $($mem.EMAIL) wird dem Kurs $($c.KNAME) hinzugefügt"
                    if (-not $whatif) {
                        if ($force) {
                            $u= Add-SFGroupmember -email $mem.EMAIL -id $sfgroups[$c.KNAME].id -force
                        }
                        else {
                            $u= Add-SFGroupmember -email $mem.EMAIL -id $sfgroups[$c.KNAME].id 
                        }
                        $sfgroups[$c.KNAME].memberIst.remove($mem.EMAIL);
                    }
                    
                }
            }
            # Noch den Lehrer des Kurses eintragen
            if ($c.ID_LEHRER -eq "") {
                Write-Warning "Achtung der Kurs $($c.KNAME) hat keinen Lehrer zugewiesen bekommen (ID_LEHRER)"
            }
            else {
                $le = Get-SFUser -email $lehrer[$c.ID_LEHRER].email
                if ($le) {
                    if ( -not $grist[$lehrer[$c.ID_LEHRER].email]) {
                        Write-Verbose "Lehrer gefunden, weise ihn den Kurs $($c.KNAME) zu!"
                        if (-not $whatif) {
                            if ($force) {
                                $u= Add-SFGroupmember -email $lehrer[$c.ID_LEHRER].email -id $sfgroups[$c.KNAME].id -force
                            }
                            else {
                                $u= Add-SFGroupmember -email $lehrer[$c.ID_LEHRER].email -id $sfgroups[$c.KNAME].id 
                            }
                        }
                        
                    }
                    else {
                        Write-Verbose "Lehrer ist bereits Mitglied im Kurs $($c.KNAME)"
                    }
                    $sfgroups[$c.KNAME].memberIst.remove($lehrer[$c.ID_LEHRER].email);
                }
                else {
                    Write-Verbose "Lehrer nicht gefunden, wird angelegt!"
                    if (-not $whatif) {
                        if ($force) {
                            $u= New-SFUser -email $lehrer[$c.ID_LEHRER].email -password mmbbs -force
                        }
                        else {
                            $u= New-SFUser -email $lehrer[$c.ID_LEHRER].email -password mmbbs
                        }
                    }
                    Write-Verbose "Neuer Lehrer $($lehrer[$c.ID_LEHRER].email) wird dem Kurs $($c.KNAME) hinzugefügt"
                    if (-not $whatif) {
                        if ($force) {
                            $u= Add-SFGroupmember -email $lehrer[$c.ID_LEHRER].email -id $sfgroups[$c.KNAME].id -force
                        }
                        else {
                            $u= Add-SFGroupmember -email $lehrer[$c.ID_LEHRER].email -id $sfgroups[$c.KNAME].id 
                        }
                    }
                    $sfgroups[$c.KNAME].memberIst.remove($lehrer[$c.ID_LEHRER].email);
                    
                }
            }
        }

        
        Write-Verbose "Lösche die Teilnehmer aus den Kursen, die im Kurs noch sind, aber weder in cohorts noch als Lehrer dort eingetragen sind"
        
        foreach ($course in $sfgroups) {
            Write-Verbose "Folgende Teilnehmer müssen aus der Gruppe $course gelöscht werden!"
            $course.memberIst;
            $course
        }

        <#
        foreach ($u in $moodelCourses.Values[0]) {   
            if (-not $whatif) {         
                if ($moodelCourses[$u.shortname].unusedMember.Count -gt 0) {
                
                   foreach ($m in $moodelCourses[$u.shortname].unusedMember) {
                        Write-Verbose "Der Teilnehmer $($m.Values[0].firstname) $($m.Values[0].lastname) ID=$($m.Values[0].id) ist nicht mehr im Klassenkurs $($u.shortname) enthalten und kann gelöscht werden"
                        if (-not $whatif) {
                            Remove-MoodleCourseMember -userid $m.Values[0].id -courseid $u.id
                        }
                   }
                }
            }
        } 
        #>       
    }
}
Write-Host "Anmeldung an Moodle"
Login-Moodle -url https://moodle.mm-bbs.de/moodle/ -credential (Get-Credential)
Write-Host "Anmeldung an Seafile"
Login-Seafile -url http://service.joerg-tuttas.de:8000/ -credential (Get-Credential)
Write-Host "Anmeldung am diklabu"
Login-Diklabu -credential (Get-Credential)

