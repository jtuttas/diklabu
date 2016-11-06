$global:seafile
$global:sftoken

<#
.Synopsis
   Anmelden an Seafile
.DESCRIPTION
   Anmelden an Seafile
.EXAMPLE
   login-Seafile -url http://localhost/moodle -credentails (get-cretendials admin)

#>
function Login-Seafile
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
        [PSCredential]$credential

    )

    Begin
    {
        $global:seafile = $url
        $url = $url+"api2/auth-token/"
        $data=echo "" | Select-Object -Property "username","password"
        $data.username=$credential.userName
        $data.password=$credential.GetNetworkCredential().Password  
        $data="username=$($data.username)&password=$($data.password)"
        $r=Invoke-RestMethod -Method POST -Uri $url -Body $data  
        if ($r.token) {
            Write-Verbose "Login erfolgreich"
        }
        else {
            Write-Verbose "Login fehlgeschlagen"
        }  
        $global:sftoken=$r.token         
        $r
    }
}

<#
.Synopsis
   Neue Gruppen anlegen
.DESCRIPTION
   Neue Gruppen anlegen
.EXAMPLE
   New-SFGroup -name Test
   Legt eine neue Gruppe mit dem Namen Test an!
.EXAMPLE
   "Test","Test2" | New-SFGroup
   Legt eine neue Gruppen mit den Namen Test und Test2 an!

#>
function New-SFGroup
{
    [CmdletBinding()]
   
    Param
    (
      [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
      [String]$name,
      [switch]$force,
      [switch]$whatif
    )

    Begin
    {
        if (-not $global:sftoken) {
            Write-Error "Sie sind nicht an Seafile angemeldet, veruchen Sie es mit Login-Seafile"
            return
        }
        $headers=@{}      
        $headers["content-Type"]="application/x-www-form-urlencoded"  
        $headers["Authorization"]="Token "+$global:sftoken;
    }
    Process {
        $body="name=$name"
        $url = $global:seafile+"api/v2.1/groups/"
        try {
            if (-not $whatif) {
                if (-not $force) {
                    $q = Read-Host "Soll eine neue Gruppe mit dem Namen $name angelegt werden? (J/N)"
                    if ($q -ne "J") {
                        return
                    }
                }
                $r=Invoke-RestMethod -Method POST -Body $body -Uri $url -Headers $headers  
                Write-Verbose "Erzeuge neue Gruppe mit dem Namen $name"
                $r
            }
            else {
                Write-Verbose "Würde neue Gruppe mit dem Namen $name erzeugen"
            }
        }
        catch {
            $errorcode = $_.Exception.Response.StatusCode.value__ 
            if ($errorcode -eq 400) {
                Write-Error "400: Die Gruppe mit dem Namen $name existiert bereits";
            }
            else {
                Write-Error $_
            }
        }
    }
}

<#
.Synopsis
   Gruppen abfragen
.DESCRIPTION
   Gruppen abfragen
.EXAMPLE
   Get-SFGroups

#>
function Get-SFGroups
{
    [CmdletBinding()]
   
    Param
    (
      [Parameter(Position=0)]
      [int]$perPage=100
    )

    Begin
    {
        if (-not $global:sftoken) {
            Write-Error "Sie sind nicht an Seafile angemeldet, veruchen Sie es mit Login-Seafile"
            return
        }
        $headers=@{}        
        $headers["Authorization"]="TOKEN "+$global:sftoken;
        $url = $global:seafile+"api/v2.1/groups/?page=1&per_page=$perPage"
        $r=Invoke-RestMethod -Method GET -Uri $url -Headers $headers  
        Write-Verbose "Abfrage alles SF Gruppen"  
        $r
    }
}

<#
.Synopsis
    Gruppen löschen
.DESCRIPTION
   Gruppen in Seafile löschen
.EXAMPLE
   Delete-SFGroup -id 1
   Löscht die Gruppe mit der ID 1
.EXAMPLE
   1,2,3 | Delete-SFGroup 
   Löscht die Gruppen mit denb IDs 1,2,3

#>
function Delete-SFGroup
{
    [CmdletBinding()]   
    Param
    (
      [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
      [int]$id,
       [switch]$force,
      [switch]$whatif
    )

    Begin
    {
        if (-not $global:sftoken) {
            Write-Error "Sie sind nicht an Seafile angemeldet, veruchen Sie es mit Login-Seafile"
            return
        }
        $headers=@{}      
        $headers["content-Type"]="application/x-www-form-urlencoded"  
        $headers["Authorization"]="TOKEN "+$global:sftoken;
    }
    Process {
        
        $url = $global:seafile+"api/v2.1/groups/$id/"
        try {
            if (-not $whatif) {
                if (-not $force) {
                    $q = Read-Host "Soll die SF Gruppe mit ID $id gelöscht werden? (J/N)?"
                    if ($q -ne "J") {
                        return
                    }
                }
                $r=Invoke-RestMethod -Method DELETE -Uri $url -Headers $headers  
                Write-Verbose "Lösche Gruppe mit ID $id"
                $r
            }
            else {
                Write-Verbose "Würde Gruppe mit ID $id löschen"
            }
        }
        catch {
            $errorcode = $_.Exception.Response.StatusCode.value__ 
            if ($errorcode -eq 400) {
                Write-Error "400: Die Gruppe mit der ID $id existiert nicht";
            }
            elseif ($errorcode -eq 404) {
                Write-Error "404: Die Gruppe mit der ID $id existiert nicht";
            }
            elseif ($errorcode -eq 403) {
                Write-Error "403: Die Gruppe mit der ID $id kann nicht gelöscht werden";
            }

            else {
                Write-Error $_
            }
        }
    }
}


<#
.Synopsis
   Benutzer zu einer Gruppe hinzufügen
.DESCRIPTION
   Fügt Benutzer zu einer Seafile Gruppe hinzu
.EXAMPLE
   Add-SFGroupmember -email tuttas@mmbbs.de -id 1
   Fügt den Benutzer tuttas@mmbbs.de der Gruppe mit der ID 1 hinzu
.EXAMPLE
   "tuttas@mmbbs.de","kemmries@mmbbs.de" | Add-SFGroupmember -id 1 
   Fügt die Benutzer der Gruppe mit der ID 1 hinzu

#>
function Add-SFGroupmember
{
    [CmdletBinding()]   
    Param
    (
      [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
      [String]$email,
      [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
      [int]$id,
       [switch]$force,
      [switch]$whatif
    )

    Begin
    {
        if (-not $global:sftoken) {
            Write-Error "Sie sind nicht an Seafile angemeldet, veruchen Sie es mit Login-Seafile"
            return
        }
        $headers=@{}      
        $headers["content-Type"]="application/x-www-form-urlencoded"  
        $headers["Authorization"]="TOKEN "+$global:sftoken;
    }
    Process {
        
        $url = $global:seafile+"/api/v2.1/groups/$id/members/"
        $body="email=$email"
        try {
            if (-not $whatif) {
                if (-not $force) {
                    $q = Read-Host "Soll Benutzer $email zur Gruppe mit ID $id hinzugefügt werden? (J/N)"
                    if ($q -ne "J") {
                        return
                    }
                }
                $r=Invoke-RestMethod -Method POST -Uri $url -Body $body -Headers $headers  
                Write-Verbose "Füge $email zur Gruppe mit ID $id hinzu"
                $r
            }
            else {
                Write-Verbose "Würde $email zur Gruppe mit ID $id hinzufügen!"
            }
        }
        catch {
            $errorcode = $_.Exception.Response.StatusCode.value__ 
            if ($errorcode -eq 400) {
                Write-Error "400: Die Gruppe mit der ID $id existiert nicht, oder Benutzer mit EMail $email nicht gefunden";
            }
            elseif ($errorcode -eq 403) {
                Write-Error "403: Nur Administratoren können Gruppenmitglieder hinzufügen";
            }
            elseif ($errorcode -eq 404) {
                Write-Error "400: Die Gruppe mit der ID $id existiert nicht, oder Benutzer mit EMail $email nicht gefunden";
            }
            else {
                Write-Error $_
            }
        }
    }
}

<#
.Synopsis
   Benutzer aus einer Gruppe entfernen
.DESCRIPTION
   Entfernt einen Benutzer aus einer Seafile Gruppe
.EXAMPLE
   Remove-SFGroupmember -email tuttas@mmbbs.de -id 1
   Löscht den Benutzer tuttas@mmbbs.de aus der Gruppe mit der ID 1 
.EXAMPLE
   "tuttas@mmbbs.de","kemmries@mmbbs.de" | Remove-SFGroupmember -id 1 
   Löscht die Benutzer aus der Gruppe mit der ID 1 

#>
function Remove-SFGroupmember
{
    [CmdletBinding()]   
    Param
    (
      [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
      [String]$email,
      [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
      [int]$id,
       [switch]$force,
      [switch]$whatif

    )

    Begin
    {
        if (-not $global:sftoken) {
            Write-Error "Sie sind nicht an Seafile angemeldet, veruchen Sie es mit Login-Seafile"
            return
        }
        $headers=@{}      
        $headers["content-Type"]="application/x-www-form-urlencoded"  
        $headers["Authorization"]="TOKEN "+$global:sftoken;
    }
    Process {
        
        $url = $global:seafile+"/api/v2.1/groups/$id/members/$email/"
        try {
            if (-not $whatif) {
                if (-not $force) {
                    $q = Read-Host "Soll Benutzer $email aus der Gruppe mit der ID $id entfernt werden? (J/N)"
                    if ($q -ne "J") {
                        return;
                    }
                }
                $r=Invoke-RestMethod -Method DELETE -Uri $url -Headers $headers
                Write-Verbose "Lösche $email aus Gruppe mit ID = $id"  
                $r
            }
            else {
                Write-Verbose "Würde $email aus Gruppe mit ID = $id entfernen!"  
            }
        }
        catch {
            $errorcode = $_.Exception.Response.StatusCode.value__ 
            if ($errorcode -eq 400) {
                Write-Error "400: Die Gruppe mit der ID $id existiert nicht, oder Benutzer mit EMail $email nicht gefunden";
            }
            elseif ($errorcode -eq 403) {
                Write-Error "403: Nur Administratoren können Gruppenmitglieder hinzufügen";
                $_
            }
            elseif ($errorcode -eq 404) {
                Write-Error "400: Die Gruppe mit der ID $id existiert nicht";
            }
            else {
                Write-Error $_
            }
        }
    }
}


<#
.Synopsis
   Benutzer eine Gruppe anzeigen
.DESCRIPTION
   Zeigt die Seafile Benutzer in einer Gruppe an
.EXAMPLE
   Get-SFGroupmember -id 1
   Zeit die Mitglieder der Gruppe mit der ID 1 
.EXAMPLE
   1,2 | Get-SFGroupmember 
   Zeit die Mitglieder der Gruppe mit den IDs 1 u. 2 

#>
function Get-SFGroupmember
{
    [CmdletBinding()]   
    Param
    (
      [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
      [int]$id
    )

    Begin
    {
        if (-not $global:sftoken) {
            Write-Error "Sie sind nicht an Seafile angemeldet, veruchen Sie es mit Login-Seafile"
            return
        }
        $headers=@{}      
        $headers["content-Type"]="application/x-www-form-urlencoded"  
        $headers["Authorization"]="TOKEN "+$global:sftoken;
    }
    Process {
        
        $url = $global:seafile+"/api/v2.1/groups/$id/members/"
        try {
            $r=Invoke-RestMethod -Method GET -Uri $url -Headers $headers  
            Write-Verbose "Abfrage der Gruppenmitglieder der Gruppe ID=$id"
            $r
        }
        catch {
            $errorcode = $_.Exception.Response.StatusCode.value__ 
             if ($errorcode -eq 404) {
                Write-Error "404: Die Gruppe mit der ID $id existiert nicht!";
            }
            else {
                Write-Error $_
            }
        }
    }
}

