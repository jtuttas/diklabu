<#
.Synopsis
   Moodle Klassen Kurs anlegen und Benutzer (Schüler und Lehrer eintragen)
.DESCRIPTION
   Moodle Klassen Kurs anlegen und Benutzer (Schüler und Lehrer eintragen)
.EXAMPLE
   Sync-MoodleClasses -categoryid 3 -untisexport c:\Temp\untis.csv
   Legt Moodle Kurse unter der Kategorie 3 für jede Klasse aus untis.csv in Moodle an und fügt die Schüler der 
   globalen Gruppe mit dem Namen Klasse als STUDENT in den Kurs ein und fügt die Lehrer der Klasse als TEACHER
   in den Kurs ein!

#>
function Sync-MoodleClasses
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
        # Zum Testen ohne AD
        <#
        $obj = "" | Select-Object "email"
        $obj.email = "tuttas@mmbbs.de"
        $lehrer["TU"]=$obj
        $obj = "" | Select-Object "email"
        $obj.email = "zimmler@mmbbs.de"
        $lehrer["ZM"]=$obj
        #>


        $coh = Get-MoodleCohorts
        $cohorts=@{}
        foreach ($c in $coh) {
            $cohorts[$c.name]=$c
        }
        $moodelCourses = Get-MoodleCourses
        $n=1
        foreach ($line in $untis) {
            Write-Verbose "Bearbeite Zeile $($n): Klasse $($line.klasse)"
            $n++;
            if (-not $moodelCourses[$line.klasse] -and -not $moodelCourses[$line.klasse].categoryid -eq $categoryid) {
                Write-Verbose " Klassenkurs existiert nicht in Moodle, und wird angelegt"
                if (-not $whatif) {
                    $c=New-MoodleCourse -fullname $line.klasse -shortname $line.klasse -categoryid $categoryid
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
                $moodelCourses[$line.klasse] | Add-Member -MemberType NoteProperty -Name member -Value $coursemember
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
                    }
                }
                else {
                    Write-Warning " Es existiert keine gloable Gruppe mit dem Namen $($line.klasse)"
                    $obj = "" | Select-Object -Property bearbeitet
                    $obj.bearbeitet=$true
                    $cohorts[$line.klasse]=$obj
                }
            }
            if (-not $moodelCourses[$line.klasse].lehrer[$line.lol]) {
                $moodelCourses[$line.klasse].lehrer[$line.lol]=$line.lol
                if ($line.lol) {
                    Write-Verbose " Suchen den Lehrer mit dem Kürzel $($line.lol)"
                    if ($lehrer[$line.lol]) {
                        Write-Verbose " Suchen den Moodle Benutzer mit der EMAIL $($lehrer[$line.lol].email)"
                        $muser = Get-MoodleUser -property $lehrer[$line.lol].email -PROPERTYTYPE EMAIL
                        if ($muser) {
                            if (-not $moodelCourses[$line.klasse].member[$muser.id]) {
                                Write-Verbose " Trage den Moodle Benutzer in den Kurs $($line.klasse) ein!"                
                                if (-not $whatif) {
                                    $r = Add-MoodleCourseMember -userid $muser.id -courseid $moodelCourses[$line.klasse].id -role TEACHER
                                }
                            }
                            else {
                               Write-Verbose " Der Moodle Benutzer ist bereits im Kurs $($line.klasse)!"                
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
                Write-Verbose "Doppeleinsatz! Den Lehrer mit Kürzel $($line.lol) bereits für die Klasse $($line.klasse) berücksichtigt"
            }
        }        
    }
}