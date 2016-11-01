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

#>
function Sync-MoodleCourses
{
    [CmdletBinding()]
    Param
    (
        # ID der Kategorie unter der die Klassenkurse angelegt werden
        [Parameter(Mandatory=$true,
                   Position=0)]
        [int]$categoryid,

        # Pfad zur UNTIS CSV Datei
        [Parameter(Mandatory=$true,
                   Position=1)]
        [String]$untisexport,
        [int]$templateid=-1,
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
        
        $lehrer=@{}  
        <#
              
        $config=Get-Content "$PSScriptRoot/config.json" | ConvertFrom-json
        $l = $config.ldaphost
        $k=$l.Split(":");
        $ip=$k[1].Substring(2)
        $password = $config.bindpassword | ConvertTo-SecureString -asPlainText -Force
        $credentials = New-Object System.Management.Automation.PSCredential -ArgumentList "ldap-user", $password
        $u=Get-ADGroupMember -Identity Lehrer -Server $ip -Credential $credentials | Get-ADUser -Properties Mail,Initials -Server $ip -Credential $credentials        
        foreach ($user in $u) {
            if ($user.Initials) {
                Write-Verbose  "Lese ein $($user.GivenName) $($user.Name) ($($user.Initials))" 
                $lehrer[$user.Initials]=$user
            }
            else {
                Write-Warning "Achtung der Lehrer $($user.GivenName) $($user.Name) hat keine Initialen (Kürzel)!"  
            }    
        } 
        #>              
        # Zum Testen ohne AD
        
        $obj = "" | Select-Object "email"
        $obj.email = "tuttas@mmbbs.de"
        $lehrer["TU"]=$obj
        $obj = "" | Select-Object "email"
        $obj.email = "zimmler@mmbbs.de"
        $lehrer["ZM"]=$obj
        


        $coh = Get-MoodleCohorts
        $cohorts=@{}
        foreach ($c in $coh) {
            $cohorts[$c.name]=$c
        }
        $mc = Get-MoodleCourses  | Where-Object {$_.categoryid -eq $categoryid}
        $moodelCourses=@{}
        foreach ($c in $mc) {
                $moodelCourses[$c.shortname]=$c
        }
        
        $n=1
        foreach ($line in $untis) {
            Write-Verbose "Bearbeite Zeile $($n): Klasse $($line.klasse)"
            $n++;
            if (-not $moodelCourses[$line.klasse] -and -not $moodelCourses[$line.klasse].categoryid -eq $categoryid) {
                Write-Verbose " Klassenkurs existiert nicht in Moodle, und wird angelegt"
                if (-not $whatif) {
                    if ($templateid -eq -1) {
                        $c=New-MoodleCourse -fullname $line.klasse -shortname $line.klasse -categoryid $categoryid
                    }
                    else {
                        $c=Copy-MoodleCourse -fullname $line.klasse -shortname $line.klasse -categoryid $categoryid -courseid $templateid
                    }
                    if (-not $c) {
                        $c = "" | Select-Object -Property id
                        $c.id=-1
                    }
                    $c | Add-Member -MemberType NoteProperty -Name categoryid -Value $categoryid
                    $moodelCourses[$line.klasse]=$c                    
                }  
                else {
                    $obj = "" | Select-Object id,categoryid;
                    $obj.id=-1;
                    $obj.categoryid=$categoryid;
                    $moodelCourses[$line.klasse]=$obj
                }     
            }            

            if (-not $moodelCourses[$line.klasse].lehrer) {
                $l = @{}
                $moodelCourses[$line.klasse] | Add-Member -MemberType NoteProperty -Name lehrer -Value $l
                $coursemember = Get-MoodleCoursemember -id $moodelCourses[$line.klasse].id
                
                if ($coursemember.errorcode.Length -gt 0) {
                    Write-Warning $coursemember.message
                }
                else {
                    $com=@{}
                    $com2=@{}
                    foreach ($co in $coursemember) {
                        $com[$co.id]=$co
                        $com2[$co.id]=$co
                    }
                    $moodelCourses[$line.klasse] | Add-Member -MemberType NoteProperty -Name member -Value $com
                    $moodelCourses[$line.klasse].member=$com
                    $moodelCourses[$line.klasse] | Add-Member -MemberType NoteProperty -Name unusedMember -Value $com2
                    $moodelCourses[$line.klasse].unusedMember=$com2
                }
            }
            #$moodelCourses[$line.klasse] 
            
            if (-not $cohorts[$line.klasse].bearbeitet) {                
                if ($cohorts[$line.klasse]) {
                    $cohorts[$line.klasse] | Add-Member -MemberType NoteProperty -Name bearbeitet -Value $true
                    Write-Verbose " Globale Gruppe $($line.klasse) gefunden, füge Schüler in den Kurs ein"
                    # Schüler der Gloablen Gruppe in die Klass einfügen
                    $member = Get-MoodleCohortMember $cohorts[$line.klasse].id
                    
                    foreach ($id in $member.userids) {
                        if (-not $moodelCourses[$line.klasse].member[$id]) {
                            Write-Verbose " Trage den Moodle Nutzer mit der ID $id in den Kurs $($moodelCourses[$line.klasse].id) ein!"
                            if (-not $whatif) {
                                    Add-MoodleCourseMember -userid $id -courseid $moodelCourses[$line.klasse].id -role STUDENT
                            }
                        }
                        else {
                           Write-Verbose " Der Moodle Nutzer mit der ID $id ist bereits im Kurs $($moodelCourses[$line.klasse].id)!"
                        }
                        $moodelCourses[$line.klasse].unusedMember.Remove($id)
                    }
                }
                else {
                    Write-Warning " Es existiert keine globale Gruppe mit dem Namen $($line.klasse)"
                    $obj = "" | Select-Object -Property bearbeitet
                    $obj.bearbeitet=$true
                    $cohorts[$line.klasse]=$obj
                }
            }
            if (-not $moodelCourses[$line.klasse].lehrer[$line.lol]) {
                
                if ($line.fach -eq "LF" -or $line.fach -eq "PO" -or $line.fach -eq "DE" -or $line.fach -eq "RE") {
                    $moodelCourses[$line.klasse].lehrer[$line.lol]=$line.lol
                    if ($line.lol) {
                    Write-Verbose " Suchen den Lehrer mit dem Kürzel $($line.lol)"
                    if ($lehrer[$line.lol]) {
                        Write-Verbose " Suchen den Moodle Benutzer mit der EMAIL $($lehrer[$line.lol].email)"
                        $muser = Get-MoodleUser -property $lehrer[$line.lol].email -PROPERTYTYPE EMAIL
                        if ($muser) {
                            if (-not $whatif) {
                                if (-not $moodelCourses[$line.klasse].member[$muser.id]) {
                                    Write-Verbose " Trage den Moodle Benutzer in den Kurs $($line.klasse) ein!"                
                                    if (-not $whatif) {
                                        $r = Add-MoodleCourseMember -userid $muser.id -courseid $moodelCourses[$line.klasse].id -role TEACHER
                                    }
                                }
                                else {
                                   Write-Verbose " Der Moodle Benutzer ist bereits im Kurs $($line.klasse)!"                
                                }
                                $moodelCourses[$line.klasse].unusedMember.Remove($muser.id)
                            }
                        }
                        else {
                            Write-Warning "Der Lehrer mit dem Kürzel $($line.lol) und der EMail Adresse $($lehrer[$line.lol].email) kann nicht in Moodle gefunden werden!"
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
        
        Write-Verbose "Lösche die Teilnehmer aus den Kursen, die im Kurs noch sind, aber weder in cohorts noch als Lehrer dort eingetragen sind"
        
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
    }
}