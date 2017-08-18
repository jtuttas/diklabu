<#
.Synopsis
   Moodle Klassen Kurs anlegen und Benutzer (Schüler und Lehrer eintragen)
.DESCRIPTION
   Moodle Klassen Kurs anlegen und Benutzer (Schüler und Lehrer eintragen)
.EXAMPLE
   Sync-MoodleClasses -categoryid 3 -untisexport c:\Temp\untis.csv -templateid 2
   Legt Moodle Kurse unter der Kategorie 3 für jede Klasse aus untis.csv in Moodle an (als Kopie des Kurses mit der id 2) und fügt die Schüler der 
   globalen Gruppe mit dem Namen Klasse als STUDENT in den Kurs ein und fügt die Lehrer der Klasse als TEACHER
   in den Kurs ein!

   Sync-MoodleCourses -untisexport C:\Temp\untis.csv -categoryid 108 -Verbose -coursematch "17" -templateid 866 -whatif

#>
function Sync-MoodleCourses {
    [CmdletBinding()]
    Param
    (
        # ID der Kategorie unter der die Klassenkurse angelegt werden
        [Parameter(Mandatory = $true,
            Position = 0)]
        [int]$categoryid,

        # Pfad zur UNTIS CSV Datei
        [Parameter(Mandatory = $true,
            Position = 1)]
        [String]$untisexport,
        # ID des Kurses der kopiert werden soll
        [int]$templateid = -1,
        # Filter für Klassenliste
        [String]$coursematch = "",
        [switch]$force,
        [switch]$whatif       
    )
    Begin {
        Write-Host "Einlesen der Datein $untisexport" -BackgroundColor DarkGreen
        . "$PSScriptRoot/gpu2ADGroups.ps1"
        Import-Untis -path $untisexport
        try {
            $untis = Import-Csv $untisexport -Delimiter ',' 
        }
        catch {
            Write-Error "Konnte die Datei $untisexport nicht finden!"
            return;
        }
        
        Write-Host "Einlesen der Lehrer aus der AD" -BackgroundColor DarkGreen
        $lehrer = @{}  
        $u = Get-ADGroupMember -Identity Lehrer -Server $global:ldapserver -Credential $global:ldapcredentials|Where-Object {$_.objectClass -ne "group" -and  $_.objectClass -ne "computer"} | Get-ADUser -Properties Mail, Initials -Server $global:ldapserver -Credential $global:ldapcredentials        
        foreach ($user in $u) {
            if ($user.Initials) {
                Write-Verbose  "Lese ein $($user.GivenName) $($user.Name) ($($user.Initials))" 
                $lehrer[$user.Initials] = $user
            }
            else {
                Write-Warning "Achtung der Lehrer $($user.GivenName) $($user.Name) hat keine Initialen (Kürzel)!"  
            }    
        } 
        
        <#
        $obj = "" | Select-Object "email"
        $obj.mail = "tuttas@mmbbs.de"
        $lehrer["TU"]=$obj
        $obj = "" | Select-Object "email"
        $obj.mail = "hecht@mmbbs.de"
        $lehrer["HE"]=$obj
        $obj = "" | Select-Object "email"
        $obj.mail = "jordan@mmbbs.de"
        $lehrer["JD"]=$obj
        #>


        Write-Host "Einlesen der globalen Gruppen aus Moodle" -BackgroundColor DarkGreen
        $coh = Get-MoodleCohorts
        $cohorts = @{}
        foreach ($c in $coh) {
            $cohorts[$c.name] = $c
        }
        $mc = Get-MoodleCourses -categorie $categoryid
    
    $moodelCourses = @{}
    $unusedCourse=@{}
    foreach ($c in $mc) {
        $moodelCourses[$c.shortname] = $c
        $unusedCourse[$c.shortname]=$c;
    }
        
    $n = 1
    Write-Host "Verarbeiten der CSV Datei $untisexport" -BackgroundColor DarkGreen
    foreach ($line in $untis) {
        if ($line.klasse -match $coursematch) {
            Write-Verbose "Bearbeite Zeile $($n): Klasse $($line.klasse)"
            $unusedCourse.Remove($line.klasse);
            $n++;
            # Testen ob der Kurse bereits existiert
            if (-not $moodelCourses[$line.klasse] -and -not $moodelCourses[$line.klasse].categoryid -eq $categoryid) {
                Write-Verbose " Klassenkurs existiert nicht in Moodle, und wird angelegt"
                if (-not $whatif) {
                    if ($templateid -eq -1) {
                        $c = New-MoodleCourse -fullname $line.klasse -shortname $line.klasse -categoryid $categoryid -force
                    }
                    else {
                        $c = Copy-MoodleCourse -fullname $line.klasse -shortname $line.klasse -categoryid $categoryid -courseid $templateid -force
                    }
                    if (-not $c) {
                        $c = "" | Select-Object -Property id
                        $c.id = -1
                    }
                    $c | Add-Member -MemberType NoteProperty -Name categoryid -Value $categoryid
                    $c | Add-Member -MemberType NoteProperty -Name existiert -Value $true
                    $moodelCourses[$line.klasse] = $c                    
                }  
                else {
                    $obj = "" | Select-Object id, categoryid,existiert;
                    $obj.id = -1;
                    $obj.categoryid = $categoryid;
                    $obj.existiert=$true;
                    $moodelCourses[$line.klasse] = $obj
                }     
            }            

            if (-not $moodelCourses[$line.klasse].lehrer) {
                $l = @{}
                $moodelCourses[$line.klasse] | Add-Member -MemberType NoteProperty -Name lehrer -Value $l
                $coursemember = Get-MoodleCoursemember -id $moodelCourses[$line.klasse].id
                
                if ($coursemember.PSobject.Properties.name -match "errorcode") {
                    Write-Warning $coursemember.errorcode
                }
                else {
                    $com = @{}
                    $com2 = @{}
                    foreach ($co in $coursemember) {
                        $com[$co.id] = $co
                        $com2[$co.id] = $co
                    }
                    $moodelCourses[$line.klasse] | Add-Member -MemberType NoteProperty -Name member -Value $com
                    $moodelCourses[$line.klasse].member = $com
                    $moodelCourses[$line.klasse] | Add-Member -MemberType NoteProperty -Name unusedMember -Value $com2
                    $moodelCourses[$line.klasse].unusedMember = $com2
                }
            }
            #$moodelCourses[$line.klasse] 
            
            # Benutzer aus globalen Gruppen, die den Klassennamen entsprechen werden als Teilnehmer hinzugefügt
            if (-not $cohorts[$line.klasse].bearbeitet) {                
                if ($cohorts[$line.klasse]) {
                    $cohorts[$line.klasse] | Add-Member -MemberType NoteProperty -Name bearbeitet -Value $true
                    Write-Verbose " Globale Gruppe $($line.klasse) gefunden, füge Schüler in den Kurs ein"
                    # Schüler der Gloablen Gruppe in die Klass einfügen
                    $member = Get-MoodleCohortMember $cohorts[$line.klasse].id
                    
                    foreach ($id in $member.userids) {
                        if (-not $whatif) {
                            if (-not $moodelCourses[$line.klasse].member[$id]) {
                                Write-Verbose " Trage den Moodle Nutzer mit der ID $id in den Kurs $($moodelCourses[$line.klasse].id) ein!"
                                if (-not $whatif) {
                                    Add-MoodleCourseMember -userid $id -courseid $moodelCourses[$line.klasse].id -role STUDENT -force
                                }
                            }
                            else {
                                Write-Verbose " Der Moodle Nutzer mit der ID $id ist bereits im Kurs $($moodelCourses[$line.klasse].id)!"
                            }
                            $moodelCourses[$line.klasse].unusedMember.Remove($id)
                        }
                    }
                }
                else {
                    Write-Warning " Es existiert keine globale Gruppe mit dem Namen $($line.klasse)"
                    $obj = "" | Select-Object -Property bearbeitet
                    $obj.bearbeitet = $true
                    $cohorts[$line.klasse] = $obj
                }
            }
            if (-not $moodelCourses[$line.klasse].lehrer[$line.lol]) {
                # Lehrer in den Kurs Hinzufügen
                if ($line.fach -match "LF" -or $line.fach -eq "PO" -or $line.fach -eq "DE" -or $line.fach -eq "RE") {
                    $moodelCourses[$line.klasse].lehrer[$line.lol] = $line.lol
                    if ($line.lol) {
                        Write-Verbose " Suchen den Lehrer mit dem Kürzel $($line.lol)"
                        if ($lehrer[$line.lol]) {
                            Write-Verbose " Suchen den Moodle Benutzer mit der EMAIL $($lehrer[$line.lol].mail)"
                            $muser = Get-MoodleUser -property $lehrer[$line.lol].mail -PROPERTYTYPE EMAIL
                            if ($muser) {
                                if (-not $whatif) {
                                    # Es kommt vor, dass ein Lehrer mit seiner EMail mehrmals im Moodle System ist
                                    foreach ($lu in $muser) {
                                        if (-not $moodelCourses[$line.klasse].member[$lu.id]) {
                                            Write-Verbose " Trage den Moodle Benutzer $($lehrer[$line.lol].mail) in den Kurs $($line.klasse) ein!"                
                                            if (-not $whatif) {
                                                $r = Add-MoodleCourseMember -userid $lu.id -courseid $moodelCourses[$line.klasse].id -role TEACHER -force
                                            }
                                        }
                                        else {
                                            Write-Verbose " Der Moodle Benutzer ist bereits im Kurs $($line.klasse)!"                
                                        }
                                        $moodelCourses[$line.klasse].unusedMember.Remove($lu.id)
                                    }
                                }
                            }
                            else {
                                Write-Warning "Der Lehrer mit dem Kürzel $($line.lol) und der EMail Adresse $($lehrer[$line.lol].mail) kann nicht in Moodle gefunden werden!"
                            }
                        }
                        else {
                            Write-Warning "Keine Lehrer mit dem Kürzel $($line.lol) in der AD gefunden!"
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
        else {
            Write-Verbose "Klasse $($line.klasse) übersprungen"
        }
    }       
        
    Write-Host "Lösche die Teilnehmer aus den Kursen, die im Kurs noch sind, aber weder in cohorts noch als Lehrer dort eingetragen sind" -BackgroundColor DarkRed
        
    foreach ($u in $moodelCourses.Values[0]) {   
        if (-not $whatif) {         
            if ($moodelCourses[$u.shortname].unusedMember.Count -gt 0) {
                
                foreach ($m in $moodelCourses[$u.shortname].unusedMember) {
                    Write-Verbose "Der Teilnehmer $($m.Values[0].firstname) $($m.Values[0].lastname) ID=$($m.Values[0].id) ist nicht mehr im Klassenkurs $($u.shortname) enthalten und kann gelöscht werden"
                    $m.Values[0] | ForEach-Object {
                        if (-not $whatif) {
                            #Write-Host "Lösche ID $($_.id) aus Kurs $($u.id)"
                            $re=Remove-MoodleCourseMember -userid $_.id -courseid $u.id -force
                        }
                    }
                }
            }
        }
    }   
    Write-Host "Lösche Kurse in Kategorie $categoryid die nicht im Untis Export genannt werden!" -BackgroundColor DarkRed
    
    
     $unusedCourse.Keys | % { 
        
         Write-Verbose "Lösche Kurs $_ mit id=$($unusedCourse.Item($_).id)"
         if (-not $whatif) {
            $res=Delete-MoodleCourse -id $unusedCourse.Item($_).id -force
         }
        
     }
     
}
}
#Write-Host "Anmeldung an Moodle"
#Login-Moodle -url https://moodle.mm-bbs.de/moodle/ -credential (Get-Credential)