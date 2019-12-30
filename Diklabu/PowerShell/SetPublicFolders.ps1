Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

<#
.Synopsis
   Erzeugt in Exchange Public Folder und setzt die entsprechenden Permissions
.DESCRIPTION
   Erzeugt in Exchange Public Folder und setzt die entsprechenden Permissions
.EXAMPLE
   Set-CourseFolder -Course FIAE15A -teachers TU,KE -administration bahrke@tuttas.de
   Setzt TU und KE auf ReadItems und Bahrke auf ReadItems,CreateItems,EditAllItems,DeleteAllItems
#>
function Set-CourseFolder
{
    [CmdletBinding()]
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [alias("id","KNAME")]
        $course,

        # Kürzel der Lehrer
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String[]] $teachers,
        # EMail Adressen der Verwaltungsbenutzer
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String[]] $administration


    )

    Begin
    {
    }
    Process
    {
        # Public Folder anlegen
        try {
            New-PublicFolder -Name $course -ErrorAction SilentlyContinue
        }
        catch {
        }
        # Berechtigungen entfernen
        Get-PublicFolderClientPermission -Identity "\$course" | Remove-PublicFolderClientPermission -Confirm:$false

        # Lehrerberechtigungen setzen
        foreach ($t in $teachers) {
            $u=Get-ADUser -Filter {initials -like $t}
            Add-PublicFolderClientPermission -Identity "\$course" -User $($u.UserPrincipalName) -AccessRights ReadItems
        }

        # Verwaltungsberechtigungen setzen
        foreach ($vwl in $administration) {
            Add-PublicFolderClientPermission -Identity "\$course" -User $vwl -AccessRights ReadItems,CreateItems,EditAllItems,DeleteAllItems

        }
    }
    End
    {
    }
}