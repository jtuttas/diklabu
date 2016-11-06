$global:moodle
$global:token

<#
.Synopsis
   Anmelden an Moodel
.DESCRIPTION
   Anmelden an Moodel
.EXAMPLE
   login-moodle -url http://localhost/moodle -credentails (get-cretendials admin)

#>
function Login-Moodle
{
    [CmdletBinding()]
   
    Param
    (
        # URL des Moodle Systems
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String]$url,

        # Credentials f. das Moodle Systems
        [Parameter(Mandatory=$true,
                   Position=1)]
        [PSCredential]$credential,

        # Webservice Name
        [String]$service="diklabu"
    )

    Begin
    {
        $global:moodle = $url+"webservice/rest/server.php"
        $data=echo "" | Select-Object -Property "benutzer","kennwort"
        $data.benutzer=$credential.userName
        $data.kennwort=$credential.GetNetworkCredential().Password  
        $url=$url+"login/token.php?username=$($data.benutzer)&password=$($data.kennwort)&service=$service"
        $r=Invoke-RestMethod -Method GET -Uri $url -ContentType "application/json; charset=iso-8859-1"             
        $global:token=$r.token
        $r
    }
}

<#
.Synopsis
   Liste der Kurse
.DESCRIPTION
   Liste der Kurse
.EXAMPLE
   Get-MoodleCourses

#>
function Get-MoodleCourses
{
    [CmdletBinding()]
    Param
    (
    )
    Begin
    {
        if (-not $global:token) {
            write-Error "Sie sind nicht angemeldet, probieren Sie login-moodle!"
        }
        else {
            Write-Verbose "Get-MoodleCourses"
            $postParams = @{wstoken=$token;wsfunction='core_course_get_courses';moodlewsrestformat='json'}
            $courses=Invoke-RestMethod -Method POST -Uri $global:moodle -Body $postParams -ContentType "application/x-www-form-urlencoded"     
            $courses
        }
    }
    
}

<#
.Synopsis
   Liste der Kategorien
.DESCRIPTION
   Liste der Kategorien
.EXAMPLE
   Get-MoodleCategories

#>
function Get-MoodleCategories
{
    [CmdletBinding()]
    Param
    (
    )
    Begin
    {
        if (-not $global:token) {
            write-Error "Sie sind nicht angemeldet, probieren Sie login-moodle!"
        }
        else {
            Write-Verbose "Get-MoodleCategories"
            $postParams = @{wstoken=$token;wsfunction='core_course_get_categories';moodlewsrestformat='json'}
            $courses=Invoke-RestMethod -Method POST -Uri $global:moodle -Body $postParams -ContentType "application/x-www-form-urlencoded"     
            $courses  
        }
    }
    
}
<#
.Synopsis
   Liste der gloablen Gruppen
.DESCRIPTION
   Liste der globalen Gruppen
.EXAMPLE
   Get-MoodleCohorts

#>
function Get-MoodleCohorts
{
    [CmdletBinding()]
    Param
    (
    )
    Begin
    {
        if (-not $global:token) {
            write-Error "Sie sind nicht angemeldet, probieren Sie login-moodle!"
        }
        else {
            Write-Verbose "Get-MoodleCohorts"
            $postParams = @{wstoken=$token;wsfunction='core_cohort_get_cohorts';moodlewsrestformat='json'}
            $courses=Invoke-RestMethod -Method POST -Uri $global:moodle -Body $postParams -ContentType "application/x-www-form-urlencoded"     
            $courses  
        }
    }
    
}

<#
.Synopsis
   Liste der Mitglieder einer Kurses
.DESCRIPTION
   Liste der Mitglieder einer Kurses
.EXAMPLE
   Get-MoodleCoursemember -id 3
   Listet die Mitgleider des Kurses mit der ID 3
.EXAMPLE
   2,3,5 | Get-MoodleCoursemember 
   Listet die Mitgleider der Kurses mit den IDs 2,3,5
#>
function Get-MoodleCoursemember
{
    [CmdletBinding()]
    Param
    (
        # Kurs ID
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine=$true,
                   Position=0)]
        [int]$id
    )
    Begin
    {
        if (-not $global:token) {
            write-Error "Sie sind nicht angemeldet, probieren Sie login-moodle!"
            break;
        }
        else {
            $postParams = @{wstoken=$token;wsfunction='core_enrol_get_enrolled_users';moodlewsrestformat='json'}
        }

    }
    Process
    {
        Write-Verbose "Get-MoodleCourseMember IDCourse=$id"
        $postParams["courseid"]=$id
        $r=Invoke-RestMethod -Method POST -Uri $global:moodle -Body $postParams -ContentType "application/x-www-form-urlencoded"     
        $r
    }  
}

<#
.Synopsis
   Einen Moodle Teilnehmer abfragen
.DESCRIPTION
   Einen Moodle Teilnehmer abfragen
.EXAMPLE
   Get-MoodleUser -property "jtuttas@gmx.net" -PROPERTYTYPE EMAIL
   Sucht den Benutzer mit der email jtuttas@gmx.net
.EXAMPLE
   Get-MoodleUser -property admin -PROPERTYTYPE USERNAME
   Sucht den Benutzer mit dem Anmeldenamen admin
.EXAMPLE
   "jtuttas@gmx.net","test@home.de" | Get-MoodleUser-PROPERTYTYPE EMAIL
   Sucht den Benutzer mit dem Anmeldenamen admin
#>
function Get-MoodleUser
{
    [CmdletBinding()]
    Param
    (
        # EMail des Benutzers
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine=$true,
                   Position=0)]
        $property,

        
        [Parameter(Mandatory=$true,
                   Position=1)]
       
        [ValidateSet('EMAIL','USERNAME',"ID")]
        [String]$PROPERTYTYPE
    )
    Begin
    {
        if (-not $global:token) {
            write-Error "Sie sind nicht angemeldet, probieren Sie login-moodle!"
            break;
        }
        else {
            $postParams = @{wstoken=$token;wsfunction='core_user_get_users_by_field';moodlewsrestformat='json'}
        }
        $n=0;

    }
    Process
    {
        if ($PROPERTYTYPE -eq "EMAIL") {
            $postParams['field']='email'
            $postParams['values['+$n+']']=$property
            $n++;
        }
        elseif ($PROPERTYTYPE -eq "USERNAME") {
            $postParams['field']='username'
            $postParams['values['+$n+']']=$property
            $n++;
        }
        elseif ($PROPERTYTYPE -eq "ID") {
            $postParams['field']='id'
            $postParams['values['+$n+']']=$property
            $n++;
        }
        Write-Verbose "Get-MoodleUser property=$property"
    }  
    End
    {
        
        $r=Invoke-RestMethod -Method POST -Uri $global:moodle -Body $postParams -ContentType "application/x-www-form-urlencoded"     
        $r
    }
}

<#
.Synopsis
   Neuen Moodle Kurs anlegen
.DESCRIPTION
   Neuen Moodle Kurs anlegen
.EXAMPLE
   New-MoodleCourse -fullname "Mein neuer Kurs" -shortname "kn2" -categoryid 4
   Legt einen neuen Kurs in der Kategorie 4 an
#>
function New-MoodleCourse
{
    [CmdletBinding()]
    Param
    (
        # Name des Kurses
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]$fullname,
        # Kurzname des Kurses
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [String]$shortname,

        # Kategorie, wo der Kurs erscheinen soll
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [int]$categoryid,
        [switch]$force,
        [switch]$whatif
    )
    Begin
    {
        if (-not $global:token) {
            write-Error "Sie sind nicht angemeldet, probieren Sie login-moodle!"
            break;
        }
        else {
            $postParams = @{wstoken=$token;wsfunction='core_course_create_courses';moodlewsrestformat='json'}
        }
        $n=0

    }
    Process
    {
        Write-Verbose "New Moodle Course fullname=$fullname shortname=$shortname categoryId=$categoryid"
        $postParams['courses['+$n+'][fullname]']=$fullname
        $postParams['courses['+$n+'][shortname]']=$shortname
        $postParams['courses['+$n+'][categoryid]']=$categoryid
        $n++
    }  
    End
    {
        if (-not $whatif) {
            if (-not $force) {
                $q=Read-Host "Soll der Kurs '$fullname' ($shortname) in der Kategorie ID=$categoryid angelegt werden? (J/N)"
                if ($q -ne "J") {
                    return;
                }
            }
            $r=Invoke-RestMethod -Method POST -Uri $global:moodle -Body $postParams -ContentType "application/x-www-form-urlencoded"     
            Write-Verbose "Kurs '$fullname' ($shortname) wurde in der Kategorie mit der ID $categoryid angelegt"
            $r
        }
    }
}

<#
.Synopsis
   Copy Moodle Kurs anlegen
.DESCRIPTION
   Copy Moodle Kurs anlegen
.EXAMPLE
   Copy-MoodleCourse -fullname "Mein neuer Kurs" -shortname "kn2" -categoryid 4 -courseid 2
   Kopiert den Kurs mit der Kurs id 2 als neuen Kurs in der Kategorie 4 an
#>
function Copy-MoodleCourse
{
    [CmdletBinding()]
    Param
    (
        # Name des Kurses
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]$fullname,
        # Kurzname des Kurses
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [String]$shortname,

        # Kategorie, wo der Kurs erscheinen soll
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [int]$categoryid,

        # ID des Kurses der kopiert werden soll
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [int]$courseid,
        [switch]$force,
        [switch]$whatif
    )
    Begin
    {
        if (-not $global:token) {
            write-Error "Sie sind nicht angemeldet, probieren Sie login-moodle!"
            break;
        }
        else {
            $postParams = @{wstoken=$token;wsfunction='core_course_duplicate_course';moodlewsrestformat='json'}
        }
        $n=0

    }
    Process
    {
        Write-Verbose "New Moodle Course fullname=$fullname shortname=$shortname categoryId=$categoryid"
        $postParams['fullname']=$fullname
        $postParams['shortname']=$shortname
        $postParams['categoryid']=$categoryid
        $postParams['courseid']=$courseid
        if (-not $whatif) {
            if (-not $force) {
                $q=Read-Host "Soll der Kurs '$fullname' ($shortname) in der Kategorie ID=$categoryid als Kopie des Kurses mit der ID $courseid erstellt werden? (J/N)"
                if ($q -ne "J") {
                    return;
                }
            }
            $r=Invoke-RestMethod -Method POST -Uri $global:moodle -Body $postParams -ContentType "application/x-www-form-urlencoded"     
            Write-Verbose "Kurs '$fullname' ($shortname) wurde in der Kategorie mit der ID $categoryid als Kopie des Kurses mit der ID $courseid angelegt!"
            $r
        }      
    }  
    End
    {
 
    }
}

<#
.Synopsis
   Löscht einen oder mehrere Kurse
.DESCRIPTION
   Löscht einen oder mehrere Kurse
.EXAMPLE
   Delete-MoodleCourse -id 12
   Löscht den Kurs mit der ID 12
#>
function Delete-MoodleCourse
{
    [CmdletBinding()]
    Param
    (
        # Name des Kurses
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [int]$id,
        [switch]$force,
        [switch]$whatif
    )
    Begin
    {
        if (-not $global:token) {
            write-Error "Sie sind nicht angemeldet, probieren Sie login-moodle!"
            break;
        }
        else {
            $postParams = @{wstoken=$token;wsfunction='core_course_delete_courses';moodlewsrestformat='json'}
        }
        $n=0

    }
    Process
    {
        
        $postParams['courseids['+$n+']']=$id
        $n++
        if (-not $whatif) {
            Write-Verbose "Delete-MoodleCourse ID=$id"
        }
        else {
            Write-Verbose "Würde den Kurs mit der ID=$id löschen!"
        }
    }  
    End
    {
        if (-not $whatif) {
            if (-not $force) {
                $q=Read-Host "Sollen die Kurse wirklich gelöscht werden? (J/N)"
                if ($q -ne "J") {
                    return;
                }
            }
            $r=Invoke-RestMethod -Method POST -Uri $global:moodle -Body $postParams -ContentType "application/x-www-form-urlencoded"     
            Write-Verbose "Kurse  gelöscht"
            $r
        }
    }
}
<#
.Synopsis
   Benutzer einem Kurs hinzufügen
.DESCRIPTION
   Benutzer einem Kurs hinzufügen
.EXAMPLE
   Add-MoodleCourseMember -courseid 41 -userid 47 -role STUDENT
   Fügt den Benutzer mit der ID 47 den Kurs mit der ID 41 hinzu als Stundent
.EXAMPLE
   1,2,3 | Add-MoodleCourseMember -courseid 41 -role STUDENT
   Fügt die Benutzer mit den IDs 1,2,3 den Kurs mit der ID 41 hinzu als Student
#>
function Add-MoodleCourseMember
{
    [CmdletBinding()]
    Param
    (
        # ID des Users
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [int]$userid,
        # ID des Kurses
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [int]$courseid,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
       
        [ValidateSet('STUDENT','TEACHER')]
        [String]$role,
        [switch]$force,
        [switch]$whatif
    )
    Begin
    {
        if (-not $global:token) {
            write-Error "Sie sind nicht angemeldet, probieren Sie login-moodle!"
            break;
        }
        else {
            $postParams = @{wstoken=$token;wsfunction='enrol_manual_enrol_users';moodlewsrestformat='json'}
        }
        $n=0

    }
    Process
    {
        $postParams['enrolments['+$n+'][userid]']=$userid
        $postParams['enrolments['+$n+'][courseid]']=$courseid
        if ($role -eq "STUDENT") {
            $postParams['enrolments['+$n+'][roleid]']=5
            Write-Verbose "Add-MoodleCourseMember userid=$userid courseId=$courseid Role=STUDENT"
        }
        elseif($role -eq "TEACHER") {
           $postParams['enrolments['+$n+'][roleid]']=3
           Write-Verbose "Add-MoodleCourseMember userid=$userid courseId=$courseid Role=TEACHER"
        }
       
        $n++
    }  
    End
    {
        if (-not $whatif) {
            if (-not $force) {
                $q=Read-Host "Benutzer mit Teilnehmen ID=$userid in den Kurs mit ID=$courseid einschreiben? (J/N)"
                if ($q -ne "J") {
                    return;
                } 
            }
            $r=Invoke-RestMethod -Method POST -Uri $global:moodle -Body $postParams -ContentType "application/x-www-form-urlencoded"     
            Write-Verbose "Benutzer mit ID=$userid in den Kurs ID=$courseid eingeschrieben"
            $r
        }
    }
}

<#
.Synopsis
   Benutzer aus einem Kurs entfernen
.DESCRIPTION
   Benutzer aus einem Kurs entfernen
.EXAMPLE
   Remove-MoodleCourseMember -courseid 41 -userid 47 
   Entfernt den Benutzer mit der ID 47 aus den Kurs mit der ID 41 
.EXAMPLE
   1,2,3 | Add-MoodleCourseMember -courseid 41 
   Entfernt die Benutzer mit den IDs 1,2,3 aus den Kurs mit der ID 41 
#>
function Remove-MoodleCourseMember
{
    [CmdletBinding()]
    Param
    (
        # ID des Users
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [int]$userid,
        # ID des Kurses
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [int]$courseid,

        [switch]$force,
        [switch]$whatif
    )
    Begin
    {
        if (-not $global:token) {
            write-Error "Sie sind nicht angemeldet, probieren Sie login-moodle!"
            break;
        }
        else {
            $postParams = @{wstoken=$token;wsfunction='enrol_manual_unenrol_users';moodlewsrestformat='json'}
        }
        $n=0

    }
    Process
    {
        Write-Verbose "Remove-MoodleCourseMember userid=$userid courseId=$courseid"
        $postParams['enrolments['+$n+'][userid]']=$userid
        $postParams['enrolments['+$n+'][courseid]']=$courseid
       
        $n++
    }  
    End
    {
        if (-not $whatif) {
            if (-not $force) {
                $q=Read-Host "Benutzer mit Teilnehmen ID=$userid aus dem Kurs mit ID=$courseid entfernen? (J/N)"
                if ($q -ne "J") {
                    return;
                } 
            }
            $r=Invoke-RestMethod -Method POST -Uri $global:moodle -Body $postParams -ContentType "application/x-www-form-urlencoded"     
            Write-Verbose "Benutzer mit ID=$userid aus dem Kurs ID=$courseid entfernt"
            $r
        }
    }
}


<#
.Synopsis
   Benutzer einer globalen Gruppe abfragen
.DESCRIPTION
   Benutzer einer globalen Gruppe abfragen
.EXAMPLE
   Get-MoodleCohortMember -cohortid 5
   Fragt die Mitglieder der Globalen Gruppe mit der ID 5 ab
.EXAMPLE
   1,3,5 | Get-MoodleCohortMember 
   Fragt die Mitglieder der Globalen Gruppe mit den IDs 1,3,5 ab

#>
function Get-MoodleCohortMember
{
    [CmdletBinding()]
    Param
    (
        # ID der globalen Gruppe
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [int]$cohortid
       
    )
    Begin
    {
        if (-not $global:token) {
            write-Error "Sie sind nicht angemeldet, probieren Sie login-moodle!"
            break;
        }
        else {
            $postParams = @{wstoken=$token;wsfunction='core_cohort_get_cohort_members';moodlewsrestformat='json'}
        }
        $n=0

    }
    Process
    {
        Write-Verbose "Get-MoodleCohortMember cohortId=$cohortid"
        $postParams['cohortids['+$n+']']= $cohortid
        $n++
    }  
    End
    {
        $r=Invoke-RestMethod -Method POST -Uri $global:moodle -Body $postParams -ContentType "application/x-www-form-urlencoded"     
        $r
    }
}

<#
.Synopsis
   Neuen Seafile Benutzer anlegen
.DESCRIPTION
   Legt einen neuen Seafile Benutzer an
.EXAMPLE
   Get-MoodleCohortMember -cohortid 5
   Fragt die Mitglieder der Globalen Gruppe mit der ID 5 ab
.EXAMPLE
   1,3,5 | Get-MoodleCohortMember 
   Fragt die Mitglieder der Globalen Gruppe mit den IDs 1,3,5 ab

#>
function Get-MoodleCohortMember
{
    [CmdletBinding()]
    Param
    (
        # ID der globalen Gruppe
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [int]$cohortid
       
    )
    Begin
    {
        if (-not $global:token) {
            write-Error "Sie sind nicht angemeldet, probieren Sie login-moodle!"
            break;
        }
        else {
            $postParams = @{wstoken=$token;wsfunction='core_cohort_get_cohort_members';moodlewsrestformat='json'}
        }
        $n=0

    }
    Process
    {
        Write-Verbose "Get-MoodleCohortMember cohortId=$cohortid"
        $postParams['cohortids['+$n+']']= $cohortid
        $n++
    }  
    End
    {
        $r=Invoke-RestMethod -Method POST -Uri $global:moodle -Body $postParams -ContentType "application/x-www-form-urlencoded"     
        $r
    }
}



