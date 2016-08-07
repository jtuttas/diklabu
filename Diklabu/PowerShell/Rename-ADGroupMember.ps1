<#
.Synopsis
   Benennt die Benutzer in der Form {Gruppen Name}.{Nachname} um.
.DESCRIPTION
   Lange Beschreibung
.EXAMPLE
   Rename-ADGroupmember -credentials (get-Credentials Administrator) -server 192.168.178.53 -SearchBase "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de"
   Alle Benutzer in und unter Searchbase erhalten den Namen wie ihre Gruppe
#>
function Rename-ADGroupMember
{
    Param
    (
        # Hilfebeschreibung zu Param1
        [Parameter(Mandatory=$true,Position=0)]
        [PSCredential]$credential,

        # AD server
        [String]$server="localhost",
        
        # Search Base
        [String]$searchBase,

        [switch]$whatif,
        [switch]$force
    )

    Begin
    {
        $groups = Get-ADGroup -Filter "*" -SearchBase $searchBase -Credential $credential -Server $server
        foreach ($group in $groups) {
            $members = Get-ADGroupMember -Credential $credential -Server $server -Identity $group.Name
            foreach ($member in $members) {
                $course = $member.name
                if ($course.indexOf(".") -eq -1) {
                    Write-Warning "Der AD Benutzername $($member.name) ist in einer falschen Formatierung (nicht Klasse.Nachname) und kann daher nicht bearbeitet werden!"
                }
                else {
                    
                    $course = $course.substring(0,$course.indexOf("."))
                    if ($course -like $group.Name) {
                        Write-Verbose "Der AD Name des Schülers  $($member.name) stimmt mit dem Gruppennamen $($group.Name) überein"
                    }
                    else {
                       Write-Warning "Der AD Name des Schülers  $($member.name) stimmt mit dem Gruppennamen $($group.Name) NICHT überein"
                       $user=Get-ADUser -Credential $credential -Server $server -Identity $member.distinguishedName
                       $newName=$group.name+"."+$user.Surname
                       if (-not $force) {
                            $r=Read-Host "Soll der AD Name geändert werden in $newName ? (j/n)"
                            if ($r -eq "j") {
                                if (-not $whatif) {
                                    #Set-ADUser -Identity $member.distinguishedName -ServicePrincipalNames $newName -Credential $credential -Server $server
                                    Rename-ADObject -Credential $credential -Server $server -Identity $member.distinguishedName -NewName $newName
                                    Write-Verbose "Schüler AD Namen geändert!"
                                }
                            }
                       }
                       else {
                          if (-not $whatif) {  
                             #Set-ADUser -Identity $member.distinguishedName -SamAccountName $newName -Credential $credential -Server $server
                             Rename-ADObject -Credential $credential -Server $server -Identity $member.distinguishedName -NewName $newName
                             Write-Verbose "Schüler AD Namen geändert!"
                          }
                       }
                    }
                }
            }
        }
    }
}