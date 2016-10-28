<#
.Synopsis
   Moodle Klassen Kurs anlegen und Benutzer (Schüler und Lehrer eintragen)
.DESCRIPTION
   Moodle Klassen Kurs anlegen und Benutzer (Schüler und Lehrer eintragen)
.EXAMPLE
   Sync-MoodleClasses -categoryid 3

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
        [switch]$force,
        [switch]$whatif
       
    )

    Begin
    {
        $config=Get-Content "$PSScriptRoot/config.json" | ConvertFrom-json
        $password = $config.bindpassword | ConvertTo-SecureString -asPlainText -Force
        $credentials = New-Object System.Management.Automation.PSCredential -ArgumentList "ldap-user", $password
        $u=Get-ADGroupMember -Identity Lehrer -Server 172.31.0.1 -Credential $credentials | Get-ADUser -Properties Mail,Initials -Server 172.31.0.1 -Credential $credentials
        $lehrer=@{}
        foreach ($user in $u) {
            if ($user.Initials) {
                Write-Verbose  "Lese ein $($user.GivenName) $($user.Name) ($($user.Initials))" 
                $lehrer[$user.Initials]=$user
            }
            else {
                Write-Warning "Achtung der Lehrer $($user.GivenName) $($user.Name) hat keine Initialen (Kürzel)!"  
            }    
        }
        $lehrer

        $moodlecourse = Get-MoodleCourses 

        $diklabucourses = Get-Courses -id_kategorie 1
        foreach ($c in $diklabucourses) {
            # Überprüfen ob die Klasse bereits in Moodle angelegt wurde
            Write-Verbose "Überpüfe ob es den Kurs f. die Klasse $($c.KNAME) schon gibt" 
            if ($moodlecourse[$c.KNAME].categoryid -eq $categoryid) {
                Write-Verbose "  Klasse existiert bereits als Kurs"
            }
            else {
                Write-Verbose "  Klasse existiert nicht als Kurs und wird angelegt"
            }
        }

        
    }
}