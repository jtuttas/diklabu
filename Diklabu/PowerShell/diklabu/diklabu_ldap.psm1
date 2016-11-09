<#
    Comandlets zum Auslesen der AD via LDAP
    - login-LDAP
    - get-LDAPTeachers
    - get-LDAPTeacher
    - get-LDAPCourses
    - get-LDAPCourse
    - get-LDAPCourseMember

#>

$global:ldapserver
$global:ldapcredentials

<#
.Synopsis
   Anmelden an LDAP
.DESCRIPTION
   Anmelden an LDAP
.EXAMPLE
   login-Ldap -server 192.168.178.53 -credentail (get-cretendials Administrator)

#>
function Login-LDAP
{
    [CmdletBinding()]
   
    Param
    (
        # URL des Moodle Systems
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String]$server,

        # Credentials f. das Moodle Systems
        [Parameter(Mandatory=$true,
                   Position=1)]
        [PSCredential]$credential

    )

    Begin
    {
        $in=Get-ADDomain -Credential $credential -Server $server
        if ($in) {
            $global:ldapserver=$server
            $global:ldapcredentials=$credential
            Write-Verbose "Login erfolgreich"
        }
        else {
            Write-Verbose "Login fehlgeschlagen"
        }  
        $in
    }
}

<#
.Synopsis
   Abfrage allen Lehrer
.DESCRIPTION
   Abfrage allen Lehrer
.EXAMPLE
   Get-LDAPTeachers 

#>
function Get-LDAPTeachers
{
    [CmdletBinding()]
   
    Param
    (
        # Name für die Lehrergruppe
        [Parameter(Position=0)]
        [String]$groupname="Lehrer"

    )

    Begin
    {
        if (-not $global:ldapcredentials) {
            Write-Error "Sie sind nicht am LDAP angemeldet, versuchen Sie Login-LDAP"
            break
        }
        $in=Get-ADGroupMember -Credential $global:ldapcredentials -Server $global:ldapserver -Identity $groupname  | Get-ADUser -Properties Mail,Initials -Server $global:ldapserver -Credential $global:ldapcredentials
        $teachers=@();

        foreach ($i in $in) {
            $teacher = "" | Select-Object -Property "id","EMAIL","VNAME","NNAME"
            $teacher.id=$i.Initials
            $teacher.EMAIL = $i.Mail
            $teacher.VNAME = $i.GivenName
            $teacher.NNAME = $i.Name
            $teachers+=$teacher
        }
        $teachers
    }
}

<#
.Synopsis
   Abfrage eines Lehrers
.DESCRIPTION
   Abfrage eines Lehrer
.EXAMPLE
   Get-LDAPTeacher -id TU
   Abfrage des Lehrers mit dem Kürzel TU
.EXAMPLE
   "TU","BK" | Get-LDAPTeacher 
   Abfrage der Lehrer mit den Kürzel TU und BK
#>
function Get-LDAPTeacher
{
    [CmdletBinding()]
   
    Param
    (
        # ID des Lehrers (Kürzel)
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$id,

        # Name für die Lehrergruppe
        [Parameter(Position=3)]
        [String]$groupname="Lehrer"
    )

    Begin
    {
        if (-not $global:ldapcredentials) {
            Write-Error "Sie sind nicht am LDAP angemeldet, versuchen Sie Login-LDAP"
            break
        }
    }
    Process {
        $in=Get-ADGroupMember -Credential $global:ldapcredentials -Server $global:ldapserver -Identity $groupname  | Get-ADUser -Properties Mail,Initials -Server $global:ldapserver -Credential $global:ldapcredentials | Where-Object {$_.Initials -eq $id}
        $teacher = "" | Select-Object -Property "id","EMAIL","VNAME","NNAME"
        $teacher.id=$in.Initials
        $teacher.EMAIL = $in.Mail
        $teacher.VNAME = $in.GivenName
        $teacher.NNAME = $in.Name
        $teacher
    }
}

<#
.Synopsis
   Abfrage der Klassen
.DESCRIPTION
   Abfrage der Klassen
.EXAMPLE
   Get-LDAPCourses 

#>
function Get-LDAPCourses
{
    [CmdletBinding()]
   
    Param
    (
        # Searchbase (Unterordner in denen sich die Klassen befinden)
        [Parameter(Position=2)]
        [String]$searchbase="OU=Schüler,DC=mmbbs,DC=local"

    )

    Begin
    {
        if (-not $global:ldapcredentials) {
            Write-Error "Sie sind nicht am LDAP angemeldet, versuchen Sie Login-LDAP"
            break
        }
        $in=Get-ADGroup -Credential $global:ldapcredentials -Server $global:ldapserver -Filter * -SearchBase $searchbase
        $courses=@()
        foreach ($i in $in) {
            $course = "" | Select-Object -Property "KNAME","DistinguishedName"
            $course.KNAME=$i.Name
            $course.DistinguishedName = $i.DistinguishedName
            $courses+=$course
        }
        $courses
    }
}
<#
.Synopsis
   Abfrage einer Klasse
.DESCRIPTION
   Abfrage einer Klasse
.EXAMPLE
   Get-LDAPCourse -KNAME FISI15A
.EXAMPLE
   "FISI15A","FISI15B" | Get-LDAPCourse 

#>
function Get-LDAPCourse
{
    [CmdletBinding()]
   
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$KNAME,
        # Searchbase (Unterordner in denen sich die Klassen befinden)
        [Parameter(Position=2)]
        [String]$searchbase="OU=Schüler,DC=mmbbs,DC=local"

    )

    Begin
    {
        if (-not $global:ldapcredentials) {
            Write-Error "Sie sind nicht am LDAP angemeldet, versuchen Sie Login-LDAP"
            break
        }
    }
    Process {
        $in=Get-ADGroup -Credential $global:ldapcredentials -Server $global:ldapserver -Filter * -SearchBase $searchbase | Where-Object {$_.name -eq $KNAME}
        $in
        $course = "" | Select-Object -Property "KNAME","DistinguishedName"
        $course.KNAME=$in.Name
        $course.DistinguishedName = $in.DistinguishedName
        $courses
    }
}

<#
.Synopsis
   Abfrage der Mitglieder einer Klasse
.DESCRIPTION
   Abfrage der Mitglieder einer Klasse
.EXAMPLE
   Get-LDAPCourseMember -KNAME FISI15A
.EXAMPLE
   "FISI15A","FISI15B" | Get-LDAPCourseMember 

#>
function Get-LDAPCourseMember
{
    [CmdletBinding()]
   
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$KNAME,
        # Searchbase (Unterordner in denen sich die Klassen befinden)
        [Parameter(Position=2)]
        [String]$searchbase="OU=Schüler,DC=mmbbs,DC=local"

    )
    Begin
    {
        if (-not $global:ldapcredentials) {
            Write-Error "Sie sind nicht am LDAP angemeldet, versuchen Sie Login-LDAP"
            break
        }
    }
    Process {
        $in=Get-ADGroupMember -Identity $KNAME -Server $global:ldapserver -Credential $global:ldapcredentials | Get-ADUser -Properties Mail -Server $global:ldapserver -Credential $global:ldapcredentials
        $pupils=@()
        foreach ($i in $in) {
            $pupil = "" | Select-Object -Property "EMAIL","NNAME","VNAME"
            $pupil.VNAME=$i.GivenName
            $pupil.NNAME=$i.Surname
            $pupil.EMAIL=$i.Mail
            $pupils+=$pupil
        }
        $pupils
    }
}


