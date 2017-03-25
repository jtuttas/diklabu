<#
    Comandlets zum Auslesen der AD via LDAP
    - login-LDAP
    - get-LDAPTeachers
    - get-LDAPTeacher
    - get-LDAPCourses
    - get-LDAPCourse
    - get-LDAPCourseMember

#>


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
        [Parameter(Position=0)]
        [String]$server,

        # Credentials f. das Moodle Systems
        [Parameter(Position=1)]
        [PSCredential]$credential

    )

    Begin
    {
        if (-not $server -or -not $credential) {
            if ($Global:logins["ldap"]) {
                $server=$Global:logins["ldap"].location;
                $password = $Global:logins["ldap"].password | ConvertTo-SecureString 
                $credential = New-Object System.Management.Automation.PsCredential($Global:logins["ldap"].user,$password)
            }
            else {
                Write-Error "Bitte server und credentials angeben!"
            }
        }
        $in=Get-ADDomain -Credential $credential -Server $server
        if ($in) {
            $global:ldapserver=$server
            $global:ldapcredentials=$credential
            Write-Verbose "Login erfolgreich"
            Set-Keystore -key "ldap" -server $server -credential $credential
        }
        else {
            Write-Verbose "Login fehlgeschlagen"
        }  
        $in
    }
}

<#
.Synopsis
   Abfragen des LDAP Servers
.DESCRIPTION
   Abfragen des LDAP Servers
.EXAMPLE
   Get-Ldap 

#>
function Get-LDAP
{
    [CmdletBinding()]   
    Param
    (
    )

    Begin
    {
        $Global:logins["ldap"]
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
   Abfrage eines Users
.DESCRIPTION
   Abfrage eines Users
.EXAMPLE
   Get-LDAPUser -EMAIL FIAE14H.Dell@mm-bbs.de
   Abfrage des Users mit der EMAIL tuttas@mmbbs.de
.EXAMPLE
   Get-LDAPUser -EMAIL FIAE14H*
   Abfrage der User deren Email Adressen mit FIAE14H beginnen
.EXAMPLE
   "fiae14h.dell@mm-bbs.de","fiae14h.Hoelzer@mm-bbs.de" | Get-LDAPUser
   Abfrage der User mit den Email Adressen
#>
function Get-LDAPUser
{
    [CmdletBinding()]
   
    Param
    (
        # EMail des Users
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$EMAIL

    )

    Begin
    {
        if (-not $global:ldapcredentials) {
            Write-Error "Sie sind nicht am LDAP angemeldet, versuchen Sie Login-LDAP"
            break
        }
    }
    Process {
        $in=Get-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Filter {EmailAddress -like $EMAIL} -Properties EmailAddress,GivenName,Surname
        foreach ($i in $in) {
            $user = "" | Select-Object -Property "EMAIL","VNAME","NNAME"
            $user.EMAIL = $i.EmailAddress
            $user.VNAME = $i.GivenName
            $user.NNAME = $i.Surname
            $user
        }
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

<#
.Synopsis
   Einen User zu einer Gruppe hinzufügen
.DESCRIPTION
   Einen User zu einer Gruppe hinzufügen
.EXAMPLE
   Add-LDAPCourseMember -KNAME FIAE14H -EMAIL kemmries@tuttas.de
.EXAMPLE
   "kemmries@tuttas.de","bahrke@tuttas.de" | Add-LDAPCourseMember -KNAME FIAE14H

#>
function Add-LDAPCourseMember
{
    [CmdletBinding()]
   
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,Position=0)]
        [String]$KNAME,

        # EMail Adresse des Users
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        [String]$EMAIL,
        # Searchbase (Unterordner in denen sich die Klassen befinden)
        [Parameter(Position=2)]
        [String]$searchbase="OU=Schüler,DC=mmbbs,DC=local",
        [switch]$force,
        [switch]$whatif


    )
    Begin
    {
        if (-not $global:ldapcredentials) {
            Write-Error "Sie sind nicht am LDAP angemeldet, versuchen Sie Login-LDAP"
            break
        }
    }
    Process {
        $user=Get-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Filter {EmailAddress -like $EMAIL} 
        if ($user -eq $null) {
            Write-Warning "Can not find User with EMail $EMAIL"
        }
        else {
            try {
                Write-Verbose "Der Benutzer $EMAIL wird zur Gruppe $KNAME hinzugefügt"
                if (-not $whatif) {
                    if (-not $force) {
                        $q = Read-Host "Soll der Benutzer $EMAIL zur Gruppe $KNAME hinzugefügt werden? (J/N)"
                        if ($q -eq "j") {
                            $in=Add-ADGroupMember -Credential $global:ldapcredentials -Server $global:ldapserver -Identity $KNAME -Members $user
                        }
                    }
                    else {
                        $in=Add-ADGroupMember -Credential $global:ldapcredentials -Server $global:ldapserver -Identity $KNAME -Members $user
                    }
                    $user
                }
            }
            catch {
                Write-Error $_.Exception.Message
            }
        }
    }
}

<#
.Synopsis
   Einen User aus einer Gruppe entfernen
.DESCRIPTION
   Einen User aus einer Gruppe entfernen
.EXAMPLE
   Remove-LDAPCourseMember -KNAME FIAE14H -EMAIL kemmries@tuttas.de 
.EXAMPLE
   "kemmries@tuttas.de","bahrke@tuttas.de" | Remove-LDAPCourseMember -KNAME FIAE14H 

#>
function Remove-LDAPCourseMember
{
    [CmdletBinding()]
   
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,Position=0)]
        [String]$KNAME,

        # EMail Adresse des Users
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        [String]$EMAIL,
        # Searchbase (Unterordner in denen sich die Klassen befinden)
        [Parameter(Position=2)]
        [String]$searchbase="OU=Schüler,DC=mmbbs,DC=local",
        [switch]$force,
        [switch]$whatif

    )
    Begin
    {
        if (-not $global:ldapcredentials) {
            Write-Error "Sie sind nicht am LDAP angemeldet, versuchen Sie Login-LDAP"
            break
        }
    }
    Process {
        $user=Get-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Filter {EmailAddress -like $EMAIL} 
        if ($user -eq $null) {
            Write-Warning "Can not find User with EMail $EMAIL"
        }
        else {
            try {
                Write-Verbose "Benutzer $EMAIL aus der Gruppe $KNAME entfernt"
                if (-not $whatif) {
                    if (-not $force) {
                        $q = Read-Host "Soll der Benutzer $EMAIL aus der Gruppe $KNAME entfernt werden? (J/N)"
                        if ($q -eq "j") {
                            $in=Remove-ADGroupMember -Credential $global:ldapcredentials -Server $global:ldapserver -Identity $KNAME -Members $user  -Confirm:$false
                        }
                    }
                    else {
                        $in=Remove-ADGroupMember -Credential $global:ldapcredentials -Server $global:ldapserver -Identity $KNAME -Members $user  -Confirm:$false
                    }
                    $user
                }
            }
            catch {
                Write-Error $_.Exception.Message
            }
        }
    }
}

<#
.Synopsis
   Synchronisiert die Benutzer in einer LDAP Gruppe
.DESCRIPTION
   Synchronisiert die Benutzer in einer LDAP Gruppe
.EXAMPLE
   Sync-LDAPCourseMember -KNAME FIAE14H -EMAIL "kemmries@tuttas.de","barke@tuttas.de"
.EXAMPLE
   "kemmries@tuttas.de","bahrke@tuttas.de" | Sync-LDAPCourseMember -KNAME FIAE14H 

#>
function Sync-LDAPCourseMember
{
    [CmdletBinding()]
   
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,Position=0)]
        [String]$KNAME,

        # EMail Adressen der User
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        [String[]]$EMAIL,
        # Searchbase (Unterordner in denen sich die Klassen befinden)
        [Parameter(Position=2)]
        [String]$searchbase="OU=Schüler,DC=mmbbs,DC=local",
        [switch]$force,
        [switch]$whatif

    )
    Begin
    {
        if (-not $global:ldapcredentials) {
            Write-Error "Sie sind nicht am LDAP angemeldet, versuchen Sie Login-LDAP"
            break
        }
        $gm = Get-LDAPCourseMember -KNAME $KNAME
        $ist=@{}
        foreach ($m in $gm) {
            $ist[$m.EMAIL]=$m
        }
    }
    Process {
        $EMAIL | ForEach-Object {
            if (-not $ist[$_]) {
                Write-Verbose "Der Benutzer $_ existiert nicht in der Gruppe $KNAME und wird dort hinzugefügt"
                if (-not $whatif) {
                    if (-not $force) {
                        $q=Read-Host "Soll der Benutzer $_ in die Gruppe $KNAME aufgenommen werden? (J/N)"
                        if ($q -eq "j") {
                            $u=add-LDAPCourseMember -KNAME $KNAME -EMAIL $_
                        }
                    }
                    else {
                        $u=add-LDAPCourseMember -KNAME $KNAME -EMAIL $_
                    }
                }
            }
            else {
                Write-Verbose "Der Benutzer $_ existiert bereits in der Gruppe $KNAME!"
            }
            $ist.Remove($_)
        }
    }
    End {
        $ist.Keys | ForEach-Object {
            $b=$ist.Item($_)
            Write-Verbose "Der Benutzer $($b.EMAIL) wird aus der Gruppe $KNAME entfernt!"          
            if (-not $whatif) {
                if (-not $force) {
                    $q = Read-Host "Soll der Benutzer $($b.EMAIL) aus der Gruppe $KNAME entfernt werden? (J/N)"          
                    if ($q -eq "j") {
                        $u=Remove-LDAPCourseMember -KNAME $KNAME -EMAIL $b.EMAIL
                    }
                }
                else {
                    $u=Remove-LDAPCourseMember -KNAME $KNAME -EMAIL $b.EMAIL
                }
            }
        }
    }
}




