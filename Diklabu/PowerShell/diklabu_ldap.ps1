
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
   Abfrage eines Schülers
.DESCRIPTION
   Abfrage eines Schülers
.EXAMPLE
   Get-LDAPPupil -ID 1234
   Abfrage des Users mit der Pager Nr. 1234
.EXAMPLE
   Get-LDAPPupil -ID 1234*
   Abfrage der User deren IDs mit 1234 beginnen
.EXAMPLE
   "1234","5678" | Get-LDAPPupil
   Abfrage der User mit den ID 1234 und 5678
#>
function Get-LDAPPupil
{
    [CmdletBinding()]
   
    Param
    (
        # EMail des Users
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$ID,
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
        $in=Get-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Filter {Pager -like $ID} -Properties EmailAddress,GivenName,Surname,Pager -SearchBase $searchbase
        foreach ($i in $in) {
            $user = "" | Select-Object -Property "EMAIL","VNAME","NNAME","ID"
            $user.EMAIL = $i.EmailAddress
            $user.VNAME = $i.GivenName
            $user.NNAME = $i.Surname
            $user.ID=$i.Pager
            $user
        }
    }
}

<#
.Synopsis
   Synchronisieren der Schüler
.DESCRIPTION
   Synchronisieren der Schüler
.EXAMPLE
   Sync-LDAPPupil -ID 1234,1235 -NNAME "Mustermann","Müller" -VNAME "Max",$null
.EXAMPLE
    Get-Coursemember -id 90369 | Sync-LDAPPupil -searchbase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose
    legt die Benutzer des Kurses mit der id 90369 in der AD an (und löscht alle anderen)


#>
function Sync-LDAPPupil
{
    [CmdletBinding()]
   
    Param
    (
        # ID des Users
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String[]]$ID,

        # Nachname des Users
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        [String[]]$NNAME,

        # Vorname des Users
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=2)]
        [String[]]$VNAME,

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
        $ist=@{}
        $in = Get-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Filter {Pager -like "*"} -Properties EmailAddress,GivenName,Surname,Pager,DistinguishedName -SearchBase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de"
        foreach ($i in $in) {
            $ist[$i.pager]=$i
        }
    }
    Process {
        $n=0;
        $ID | ForEach-Object {

            $user=Get-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Filter {Pager -like $_} -Properties EmailAddress,GivenName,Surname,Pager -SearchBase $searchbase            
            if (-not $user) {
                Write-Verbose "Benutzer mit ID $_ nicht gefunden und wird angelegt ($($VNAME[$n]) $($NNAME[$n]))"
                Write-Warning "Benutzer mit ID $_ nicht gefunden und wird angelegt ($($VNAME[$n]) $($NNAME[$n]))"
                if (-not $whatif) {
                    if (-not $force) {
                        $q = Read-Host "Doll der Benutzer mit ID $_  ($($VNAME[$n]) $($NNAME[$n])) angelegt werden? (J/N)"
                        if ($q -eq "j") {
                            $u=New-LDAPPupil -ID $_ -VNAME $VNAME[$n] -NNAME $NNAME[$n] -searchbase $searchbase -Verbose
                        }
                    }
                    else {
                        $u=New-LDAPPupil -ID $_ -VNAME $VNAME[$n] -NNAME $NNAME[$n] -searchbase $searchbase -Verbose
                    }
                }
            }
            else {
                Write-Verbose "Benutzer mit ID $_  ($($user.GivenName) $($user.Surname)) bereits vorhanden, Daten werden aktualisiert!"
                $name = Get-LDAPAccount -ID $_ -NNAME $NNAME[$n]  -VNAME $VNAME[$n]
                $user | Set-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -GivenName $VNAME[$n] -Surname $NNAME[$n] 
                #Rename-ADObject -Identity $user.DistinguishedName -NewName $name.AccountName -Credential $global:ldapcredentials -Server $global:ldapserver 
                
            }
            $ist.Remove($_)
            $n++;
        }
    }
    End {
        $ist.Keys | ForEach-Object {
            $b=$ist.Item($_)
            Write-Verbose "Der User  $($b.GivenName) $($b.Surname)  wird entfernt!"          
            if (-not $whatif) {
                if (-not $force) {
                    $q = Read-Host "Soll der User $($b.GivenName) $($b.Surname) entfernt werden? (J/N)"          
                    if ($q -eq "j") {
                        $u=Delete-LDAPPupil -ID $b.Pager -searchbase $searchbase
                    }
                }
                else {
                    $u=Delete-LDAPPupil -ID $b.Pager -searchbase $searchbase
                }
            }
        }
    }
}


<#
.Synopsis
   Akkount Informationen erzeugen
.DESCRIPTION
   Akkount Informationen erzeugen
.EXAMPLE
   Get-LDAPAccount -ID 1234 -NNAME "Mustermann" -VNAME "Max"
#>
function Get-LDAPAccount
{
    [CmdletBinding()]
   
    Param
    (
        # ID des Users
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$ID,

        # Nachname des Users
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        [String]$NNAME,

        # Klasse des Users
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=2)]
        [String]$KNAME,

        # Vorname des Users
        [Parameter(ValueFromPipelineByPropertyName=$true,Position=3)]
        [String]$VNAME

    )

    Begin
    {
        $out = "" | Select-Object "AccountName","LoginName"
        $aname=$NNAME+"."+$VNAME
        if ($aname.Length -gt 10) {
            $aname=$aname.Substring(0,10);
        }
        $aname=$aname+"."+$ID

        $out.AccountName=$aname
        if ($KNAME) {
            $nachname=$NNAME.ToLower();
            $nachname=$nachname.Trim();
            $nachname=$nachname.Replace(" ","");      
            $nachname=$nachname.Replace("-","");      
            $nachname=$nachname.Replace("ä","ae");
            $nachname=$nachname.Replace("ö","oe");
            $nachname=$nachname.Replace("ü","ue");
            $nachname=$nachname.Replace("ß","ss");
            $vorname=$VNAME.ToLower();
            $vorname=$vorname.Trim();
            $vorname=$vorname.Replace(" ","");      
            $vorname=$vorname.Replace("-","");      
            $vorname=$vorname.Replace("ä","ae");
            $vorname=$vorname.Replace("ö","oe");
            $vorname=$vorname.Replace("ü","ue");
            $vorname=$vorname.Replace("ß","ss");

            if ($vorname) {
                $name=$KNAME+"."+$vorname.Substring(0,1)+$nachname
            }
            else {
                $name=$KNAME+"."+$nachname
            }
            if ($name.Length -gt 16) {
                $name=$name.Substring(0,16);
            }
            $out.LoginName=$name
        }
        $out
    }
}

<#
.Synopsis
   Löschen eines Schülers
.DESCRIPTION
   Löschen Eines Schülers
.EXAMPLE
   Delete-LDAPPupil -ID 1234
   Löschen des Users mit der Pager Nr. 1234
.EXAMPLE
   Delete-LDAPPupil -ID 1234*
   Löschen der User deren IDs mit 1234 beginnen
.EXAMPLE
   "1234","5678" | Delete-LDAPPupil
   Löschen der User mit den ID 1234 und 5678
#>
function Delete-LDAPPupil
{
    [CmdletBinding()]
   
    Param
    (
        # EMail des Users
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$ID,
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
        $in=Get-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Filter {Pager -like $ID} -Properties EmailAddress,GivenName,Surname,Pager -SearchBase $searchbase
        $in | Remove-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Confirm:$false
        Write-Verbose "Schüler mit der ID $ID gelöscht"
        $user = "" | Select-Object -Property "EMAIL","VNAME","NNAME","ID"
        $user.EMAIL = $in.EmailAddress
        $user.VNAME = $in.GivenName
        $user.NNAME = $in.Surname
        $user.ID=$in.Pager
        $user
    }
}

<#
.Synopsis
   Anlegen eines Schülers
.DESCRIPTION
   Anlegen eines Schülers
.EXAMPLE
   New-LDAPPupil -ID 1234 -VNAME Thomas -NNAME Müller -passwort geheim 
#>
function New-LDAPPupil
{
    [CmdletBinding()]
   
    Param
    (
        # ID des Schülers
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$ID,

        # Nachname des Schülers
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        [String]$NNAME,

        # Vorname des Schülers
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=3)]
        [String]$VNAME,
        
        # Kennwort des Schülers
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=4)]
        [String]$PASSWORD="Gehe1m1!",

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
        $name=Get-LDAPAccount -ID $ID -NNAME $NNAME -VNAME $VNAME
        try {
            New-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver  -GivenName $VNAME -Surname $NNAME -Path $searchbase -Name $name.AccountName -OtherAttributes @{pager=$ID} -Enabled $true  -accountPassword (ConvertTo-SecureString -AsPlainText $PASSWORD -Force) -UserPrincipalName $name.LoginName
            Write-Verbose "Neuer Schüler ID=$ID angelegt"
        }
        catch {
             Write-Warning $_.Exception.Message
        }
        $user = "" | Select-Object -Property "EMAIL","VNAME","NNAME","ID"
        $user.EMAIL = $email
        $user.VNAME = $VNAME
        $user.NNAME = $NNAME
        $user.ID=$ID
        $user
    }
}

<#
.Synopsis
   Ändern der Attribute eines Schülers
.DESCRIPTION
   Ändern der Attribute eines Schülers
.EXAMPLE
   Set-LDAPPupil -ID 1234 -VNAME Thomas -NNAME Müller -passwort geheim
#>
function Set-LDAPPupil
{
    [CmdletBinding()]
   
    Param
    (
        # ID des Schülers
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$ID,

        # Nachname des Schülers
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        [String]$NNAME,

        # Vorname des Schülers
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=3)]
        [String]$VNAME,
        
        # Kennwort des Schülers
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=4)]
        [String]$PASSWORD,
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
        
        $name=Get-LDAPAccount -ID $ID -NNAME $NNAME -VNAME $VNAME 

        try {
            $in=Get-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Filter {Pager -like $ID} -Properties EmailAddress,GivenName,Surname,Pager,DistinguishedName -SearchBase $searchbase
            if ($in) {
                if ($PASSWORD) {
                    $in | Set-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver  -GivenName $VNAME -Surname $NNAME -Enabled $true  -accountPassword (ConvertTo-SecureString -AsPlainText $PASSWORD -Force)  -SamAccountName $name.AccountName
                }
                else {
                    $in | Set-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver  -GivenName $VNAME -Surname $NNAME 
                }
                Rename-ADObject -Identity $in.DistinguishedName -NewName $name.AccountName -Credential $global:ldapcredentials -Server $global:ldapserver 
                Write-Verbose "Daten Schüler ID=$ID geändert"
            }
            else {
                Write-Warning "Benutzer mit der ID $ID nicht gefunden!"
                break;
            }
        }
        catch {
             Write-Warning $_.Exception.Message
        }
        $user = "" | Select-Object -Property "EMAIL","VNAME","NNAME"
        $user.EMAIL = $email
        $user.VNAME = $VNAME
        $user.NNAME = $NNAME
        $user
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
   Abfrage ob eine Klasse existiert
.DESCRIPTION
   Abfrage ob eine Klasse existiert
.EXAMPLE
   Test-LDAPCourse -KNAME FISI15A
.EXAMPLE
   "FISI15A","FISI15B" | Test-LDAPCourse 

#>
function Test-LDAPCourse
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
        try {
            $in=Get-ADGroup -Credential $global:ldapcredentials -Server $global:ldapserver -Filter * -SearchBase $searchbase | Where-Object {$_.name -eq $KNAME}
            if ($in) {
                return $true
            }
            else {
                return $false
            }
        }
        catch  {
            return $false
        }
    }
}

<#
.Synopsis
   Neue Klasse anlegen
.DESCRIPTION
   Neue Klasse anlegen
.EXAMPLE
   New-LDAPCourse -KNAME FISI15A
.EXAMPLE
   "FISI15A","FISI15B" | New-LDAPCourse 

#>
function New-LDAPCourse
{
    [CmdletBinding()]
   
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$KNAME,
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
        try {
            Write-Verbose "Klasse $KNAME angelegt in $searchbase"
            if (-not $whatif) {
                if (-not $force) {
                    $q=Read-Host "Klasse $KNAME in $searchbase anlegen? (J/N)"
                    if ($q -eq "j") {
                        $ou = New-ADOrganizationalUnit -Credential $global:ldapcredentials -Server $global:ldapserver -Name $KNAME -Path $searchbase -ProtectedFromAccidentalDeletion $false
                        $in=New-ADGroup -Credential $global:ldapcredentials -Server $global:ldapserver -GroupScope Global -Path "OU=$KNAME,$searchbase" -Name $KNAME
                        $lin=New-ADGroup -Credential $global:ldapcredentials -Server $global:ldapserver -GroupScope Global -Path "OU=$KNAME,$searchbase" -Name "Lehrer-$KNAME"
                        Add-ADGroupMember -Identity $KNAME -Members "Lehrer-$KNAME" -Credential $global:ldapcredentials -Server $global:ldapserver                     }
                }
                else {
                    $ou = New-ADOrganizationalUnit -Credential $global:ldapcredentials -Server $global:ldapserver -Name $KNAME -Path $searchbase -ProtectedFromAccidentalDeletion $false
                    $in=New-ADGroup -Credential $global:ldapcredentials -Server $global:ldapserver -GroupScope Global -Path "OU=$KNAME,$searchbase" -Name "$KNAME"
                    $lin=New-ADGroup -Credential $global:ldapcredentials -Server $global:ldapserver -GroupScope Global -Path "OU=$KNAME,$searchbase" -Name "Lehrer-$KNAME"
                    Add-ADGroupMember -Identity $KNAME -Members "Lehrer-$KNAME" -Credential $global:ldapcredentials -Server $global:ldapserver 
                }
            }
        }
        catch  {
            Write-Error $_.Exception.Message
        }
    }
}

<#
.Synopsis
   Klassen synchronisieren
.DESCRIPTION
   Klassen synchronisieren
.EXAMPLE
   Sync-LDAPCourse -KNAME FISI15A,FISI15B
.EXAMPLE
   "FISI15A","FISI15B" | Sync-LDAPCourse 

#>
function Sync-LDAPCourse
{
    [CmdletBinding()]
   
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String[]]$KNAME,
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
        $is = Get-LDAPCourses -searchbase $searchbase
        $ist = @{}
        foreach ($i in $is) {
            if ($i.KNAME -notlike "Lehrer*") {
                $ist[$i.KNAME]=$i
            }
        }
    }
    Process {
        $KNAME | ForEach-Object {
            if (-not $ist[$_]) {
                try {
                    Write-Verbose "Klasse $_ angelegt in $searchbase"
                    if (-not $whatif) {
                        if (-not $force) {
                            $q=Read-Host "Klasse $_ in $searchbase anlegen? (J/N)"
                            if ($q -eq "j") {
                                $ou = New-ADOrganizationalUnit -Credential $global:ldapcredentials -Server $global:ldapserver -Name $_ -Path $searchbase -ProtectedFromAccidentalDeletion $false
                                $in=New-ADGroup -Credential $global:ldapcredentials -Server $global:ldapserver -GroupScope Global -Path "OU=$_,$searchbase" -Name $_
                                $lin=New-ADGroup -Credential $global:ldapcredentials -Server $global:ldapserver -GroupScope Global -Path "OU=$_,$searchbase" -Name "Lehrer-$_"
                                Add-ADGroupMember -Identity $_ -Members "Lehrer-$_" -Credential $global:ldapcredentials -Server $global:ldapserver                     }
                        }
                        else {
                            $ou = New-ADOrganizationalUnit -Credential $global:ldapcredentials -Server $global:ldapserver -Name $_ -Path $searchbase -ProtectedFromAccidentalDeletion $false
                            $in=New-ADGroup -Credential $global:ldapcredentials -Server $global:ldapserver -GroupScope Global -Path "OU=$_,$searchbase" -Name "$_"
                            $lin=New-ADGroup -Credential $global:ldapcredentials -Server $global:ldapserver -GroupScope Global -Path "OU=$_,$searchbase" -Name "Lehrer-$_"
                            Add-ADGroupMember -Identity $_ -Members "Lehrer-$_" -Credential $global:ldapcredentials -Server $global:ldapserver 
                        }
                    }
                }
                catch  {
                    Write-Error $_.Exception.Message
                }
            }
            $ist.Remove($_)
        }
    }
    End {
       
        $ist.Keys | ForEach-Object {
            $b=$ist.Item($_)
            Write-Verbose "Die Klasse  $($b.KNAME) wird entfernt!"          
            if (-not $whatif) {
                if (-not $force) {
                    $q = Read-Host "Soll die Klasse $($b.KNAME) entfernt werden? (J/N)"          
                    if ($q -eq "j") {
                        $u=Delete-LDAPCourse -KNAME $($b.KNAME) -searchbase $searchbase -force
                    }
                }
                else {
                    $u=Delete-LDAPCourse -KNAME $($b.KNAME) -searchbase $searchbase -force
                }
            }
        }
    }
}


<#
.Synopsis
   Klasse löschen
.DESCRIPTION
   Klasse löschen
.EXAMPLE
   Delete-LDAPCourse -KNAME FISI15A
.EXAMPLE
   "FISI15A","FISI15B" | Delete-LDAPCourse 

#>
function Delete-LDAPCourse
{
    [CmdletBinding()]
   
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$KNAME,
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
        try {
            Write-Verbose "Klasse $KNAME gelöscht in $searchbase"
            if (-not $whatif) {
                if (-not $force) {
                    $q=Read-Host "Klasse $KNAME aus $searchbase löschen? (J/N)"
                    if ($q -eq "j") {
                        $ou = Remove-ADOrganizationalUnit -Credential $global:ldapcredentials -Server $global:ldapserver -Identity "OU=$KNAME,$searchbase"  -Recursive -Confirm:$false
                    }
                }
                else {
                    $ou = Remove-ADOrganizationalUnit -Credential $global:ldapcredentials -Server $global:ldapserver -Identity "OU=$KNAME,$searchbase"  -Recursive -Confirm:$false
                }
            }
        }
        catch  {
            Write-Error $_.Exception.Message
        }
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
        $in=Get-ADGroupMember -Identity $KNAME -Server $global:ldapserver -Credential $global:ldapcredentials | Where-Object {$_.objectClass -ne "group"} | Get-ADUser -Properties Mail,Pager -Server $global:ldapserver -Credential $global:ldapcredentials
        $pupils=@()
        foreach ($i in $in) {
            $pupil = "" | Select-Object -Property "EMAIL","NNAME","VNAME","ID"
            $pupil.VNAME=$i.GivenName
            $pupil.NNAME=$i.Surname
            $pupil.EMAIL=$i.Mail
            $pupil.id=$i.Pager
            $pupils+=$pupil
        }
        $pupils
    }
}

<#
.Synopsis
   Anpassung der Account Namen an den Klassennamen
.DESCRIPTION
   Anpassung der Account Namen an den Klassennamen
.EXAMPLE
   Rename-LDAPCourseMember -KNAME FISI15A
.EXAMPLE
   "FISI15A","FISI15B" | Rename-LDAPCourseMember 

#>
function Rename-LDAPCourseMember
{
    [CmdletBinding()]
   
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$KNAME,
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
        $in=Get-ADGroupMember -Identity $KNAME -Server $global:ldapserver -Credential $global:ldapcredentials | Where-Object {$_.objectClass -ne "group"} | Get-ADUser -Properties Mail,Pager -Server $global:ldapserver -Credential $global:ldapcredentials
        $pupils=@()
        foreach ($i in $in) {
            #$i
            $name = Get-LDAPAccount -ID $i.Pager -NNAME $i.Surname -VNAME $i.givenName -KNAME $KNAME
            Write-Verbose "Anpassung von $( $i.givenName) $($i.Surname) and Klassenname $KNAME"
            if (-not $whatif) {
                if (-not $force) {
                    $q = Read-Host "Soll der Benutzer $( $i.givenName) $($i.Surname) and Klassenname $KNAME angepasst werden (J/N)?"
                    if ($q -eq "j") {
                        $i | Rename-ADObject -NewName $name.LoginName -Server $global:ldapserver -Credential $global:ldapcredentials 
                        $user = Get-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Filter {Pager -like $i.Pager} -Properties EmailAddress,GivenName,Surname,Pager -SearchBase $searchbase
                        $user
                        $user| Move-ADObject -TargetPath "OU=$KNAME,$searchbase" -Server $global:ldapserver -Credential $global:ldapcredentials 
                    }
                }
                else {
                    $i | Rename-ADObject -NewName $name.LoginName -Server $global:ldapserver -Credential $global:ldapcredentials 
                    $user = Get-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Filter {Pager -like $i.Pager} -Properties EmailAddress,GivenName,Surname,Pager -SearchBase $searchbase
                    #$user
                    $user | Move-ADObject  -TargetPath "OU=$KNAME,$searchbase" -Server $global:ldapserver -Credential $global:ldapcredentials 
                }
            }
            $pupil = "" | Select-Object -Property "EMAIL","NNAME","VNAME","ID"
            $pupil.VNAME=$i.GivenName
            $pupil.NNAME=$i.Surname
            $pupil.EMAIL=$i.Mail
            $pupil.id=$i.Pager
            $pupils+=$pupil
        }
        #$pupils
    }
}
<#
.Synopsis
   Einen User zu einer Gruppe hinzufügen
.DESCRIPTION
   Einen User zu einer Gruppe hinzufügen
.EXAMPLE
   Add-LDAPCourseMember -KNAME FIAE14H -ID 1234
.EXAMPLE
   1234,4567 | Add-LDAPCourseMember -KNAME FIAE14H

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
        [String]$ID,
        # Searchbase (Unterordner in denen sich die Klassen befinden)
        [Parameter(Position=2)]
        [String]$searchbase="OU=Schüler,DC=mmbbs,DC=local",
        [String]$maildomain="mm-bbs.de",
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
        $user=Get-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Filter {Pager -like $ID} -SearchBase $searchbase        
        if ($user -eq $null) {
            Write-Warning "Can not find User with ID $ID"
        }
        else {
            try {
                Write-Verbose "Der Benutzer ID $ID ($($user.GivenName) $($user.Surname)) wird zur Gruppe $KNAME hinzugefügt!"
                $name=Get-LDAPAccount -ID $ID -NNAME $user.Surname -VNAME $user.GivenName -KNAME $KNAME
                if (-not $whatif) {
                    if (-not $force) {
                        $q = Read-Host "Soll der Benutzer ID $ID zur Gruppe $KNAME hinzugefügt werden? (J/N)"
                        if ($q -eq "j") {
                            $in=Add-ADGroupMember -Credential $global:ldapcredentials -Server $global:ldapserver -Identity $KNAME -Members $user 
                            $user | Set-ADUser -EmailAddress "$($name.LoginName)@$maildomain" -Credential $global:ldapcredentials -Server $global:ldapserver -UserPrincipalName $name.LoginName 
                            #$user | Rename-ADObject -NewName $name.LoginName  -Credential $global:ldapcredentials -Server $global:ldapserver
                        }
                    }
                    else {
                        $in=Add-ADGroupMember -Credential $global:ldapcredentials -Server $global:ldapserver -Identity $KNAME -Members $user
                        $user | Set-ADUser -EmailAddress "$($name.LoginName)@$maildomain" -Credential $global:ldapcredentials -Server $global:ldapserver -UserPrincipalName $name.LoginName 
                        #$user | Rename-ADObject -NewName $name.LoginName  -Credential $global:ldapcredentials -Server $global:ldapserver 
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
   Remove-LDAPCourseMember -KNAME FIAE14H -ID 1234
.EXAMPLE
   1234,4567 | Remove-LDAPCourseMember -KNAME FIAE14H 

#>
function Remove-LDAPCourseMember
{
    [CmdletBinding()]
   
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,Position=0)]
        [String]$KNAME,

        # ID des Users
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        [String]$ID,
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
        $user=Get-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Filter {Pager -like $ID} -SearchBase $searchbase
        if ($user -eq $null) {
            Write-Warning "Can not find User with ID $ID"
        }
        else {
            try {
                Write-Verbose "Benutzer ID $ID aus der Gruppe $KNAME entfernt"
                $name=Get-LDAPAccount -ID $ID -VNAME $user.GivenName -NNAME $user.Surname

                if (-not $whatif) {
                    if (-not $force) {
                        $q = Read-Host "Soll der Benutzer ID $ID aus der Gruppe $KNAME entfernt werden? (J/N)"
                        if ($q -eq "j") {
                            $in=Remove-ADGroupMember -Credential $global:ldapcredentials -Server $global:ldapserver -Identity $KNAME -Members $user  -Confirm:$false
                            #$user | Rename-ADObject -NewName $name.AccountName  -Credential $global:ldapcredentials -Server $global:ldapserver
                        }
                    }
                    else {
                        $in=Remove-ADGroupMember -Credential $global:ldapcredentials -Server $global:ldapserver -Identity $KNAME -Members $user  -Confirm:$false
                        #$user | Rename-ADObject -NewName $name.AccountName  -Credential $global:ldapcredentials -Server $global:ldapserver
                    }
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
   Sync-LDAPCourseMember -KNAME FIAE14H -ID 1234,4567
.EXAMPLE
   1234,5678 | Sync-LDAPCourseMember -KNAME FIAE14H 

#>
function Sync-LDAPCourseMember
{
    [CmdletBinding()]
   
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,Position=0)]
        [String]$KNAME,

        # IDsder User
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        [String[]]$ID,
        # Searchbase (Unterordner in denen sich die Klassen befinden)
        [Parameter(Position=2)]
        [String]$searchbase="OU=Schüler,DC=mmbbs,DC=local",
        [String]$maildomain="mm-bbs.de",
        [switch]$force,
        [switch]$whatif

    )
    Begin
    {
        if (-not $global:ldapcredentials) {
            Write-Error "Sie sind nicht am LDAP angemeldet, versuchen Sie Login-LDAP"
            break
        }
        $gm = Get-LDAPCourseMember -KNAME $KNAME -searchbase $searchbase
        $ist=@{}
        foreach ($m in $gm) {
            $ist[$m.ID]=$m
        }
    }
    Process {
        $ID | ForEach-Object {
            if (-not $ist[$_]) {
                Write-Verbose "Der Benutzer ID $_ existiert nicht in der Gruppe $KNAME und wird dort hinzugefügt"
                if (-not $whatif) {
                    if (-not $force) {
                        $q=Read-Host "Soll der Benutzer mit ID $_ in die Gruppe $KNAME aufgenommen werden? (J/N)"
                        if ($q -eq "j") {
                            $u=add-LDAPCourseMember -KNAME $KNAME -ID $_ -searchbase $searchbase -force
                        }
                    }
                    else {
                        $u=add-LDAPCourseMember -KNAME $KNAME -ID $_ -searchbase $searchbase -force
                    }
                }
            }
            else {
                Write-Verbose "Der Benutzer ID $_ ($($ist[$_].VNAME) $($ist[$_].NNAME)) existiert bereits in der Gruppe $KNAME! Anpassung von EMail und Account Name"
                $name = Get-LDAPAccount -ID $_ -NNAME $ist[$_].NNAME -VNAME $ist[$_].VNAME -KNAME $KNAME
                $in=Get-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Filter {Pager -like $_} -Properties EmailAddress,GivenName,Surname,Pager -SearchBase $searchbase                
                $in | Set-ADUser -UserPrincipalName $name.LoginName -EmailAddress "$($name.LoginName)@$maildomain"
                $in | Rename-ADObject -NewName $name.LoginName -Credential $global:ldapcredentials -Server $global:ldapserver
            }
            $ist.Remove($_)
        }
    }
    End {
        $ist.Keys | ForEach-Object {
            $b=$ist.Item($_)
            Write-Verbose "Der Benutzer $($b.ID) wird aus der Gruppe $KNAME entfernt!"          
            if (-not $whatif) {
                if (-not $force) {
                    $q = Read-Host "Soll der Benutzer $($b.ID) aus der Gruppe $KNAME entfernt werden? (J/N)"          
                    if ($q -eq "j") {
                        Remove-LDAPCourseMember -KNAME $KNAME -ID $b.ID -searchbase $searchbase -force 
                    }
                }
                else {
                    Remove-LDAPCourseMember -KNAME $KNAME -ID $b.ID -searchbase $searchbase -force               
                }
            }
        }
    }
}




