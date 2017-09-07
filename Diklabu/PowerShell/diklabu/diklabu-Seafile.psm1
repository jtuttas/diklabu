
$global:sftoken

<#
.Synopsis
   Anmelden an Seafile
.DESCRIPTION
   Anmelden an Seafile
.EXAMPLE
   login-Seafile -url http://localhost:8000 -credentails (get-cretendials admin)

#>
function Login-Seafile
{
    [CmdletBinding()]
   
    Param
    (
        # URL des Moodle Systems
        [Parameter(Position=0)]
        [String]$url,

        # Credentials f. das Moodle Systems
        [Parameter(Position=1)]
        [PSCredential]$credential

    )

    Begin
    {

        if (-not $url -or -not $credential) {
            if ($Global:logins["seafile"]) {
                $url=$Global:logins["seafile"].location;
                $password = $Global:logins["seafile"].password | ConvertTo-SecureString 
                $credential = New-Object System.Management.Automation.PsCredential($Global:logins["seafile"].user,$password)
            }
            else {
                Write-Error "Bitte url und credentials angeben!"
                return;
            }
        }
        $base=$url
        $url = $url+"api2/auth-token/"
        $data=echo "" | Select-Object -Property "username","password"
        $data.username=$credential.userName
        $data.password=$credential.GetNetworkCredential().Password  
        $out="username=$($data.username)&password=$($data.password)"
        $r=Invoke-RestMethod -Method POST -Uri $url -Body $out   
        if ($r.token) {
            Write-Verbose "Login erfolgreich"
            $global:seafile=$base
        }
        else {
            Write-Verbose "Login fehlgeschlagen"
        }  
        Set-Keystore -key "seafile" -server $base -credential $credential       
        $global:sftoken=$r.token         
        $r
    }
}

<#
.Synopsis
   Abfrage des Seafile Servers
.DESCRIPTION
   Abfrage des Seafile Servers
.EXAMPLE
   get-Seafile 

#>
function Get-Seafile
{
    [CmdletBinding()]   
    Param
    (
    )

    Begin
    {
        $Global:logins["seafile"]
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
        
        $url = $global:seafile+"api/v2.1/groups/$id/members/"
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
                Write-Error "400: Die Gruppe mit der ID $id existiert nicht, oder Benutzer mit EMail $email nicht gefunden, oder ist bereits in der Gruppe";
            }
            elseif ($errorcode -eq 403) {
                Write-Error "403: Nur Administratoren können Gruppenmitglieder hinzufügen";
            }
            elseif ($errorcode -eq 404) {
                Write-Error "404: Die Gruppe mit der ID $id existiert nicht, oder Benutzer mit EMail $email nicht gefunden";
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

<#
.Synopsis
   Neuen Seafile Benutzer anlegen
.DESCRIPTION
   Legt einen neuen Seafile Benutzer an
.EXAMPLE
   New-SFUser -email s3@mmbbs.de -password mmbbs
   Legt einen neuen Benutzer mit der EMail Adresse s3@mmbbs.de und dem Kennwort mmbbs an!
.EXAMPLE
   "s3@mmbbs.de","s4@mmbbs.de" | New-SFUser -password mmbbs
   Legt die genannten Benutzer mit der EMAIL Adressen an und vergibt das Kennwort "mmbbs"

#>
function New-SFUser
{
    [CmdletBinding()]   
    Param
    (
      [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
      [String]$email,
      [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
      [String]$password,
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
        
        $url = $global:seafile+"/api2/accounts/$email/"
        try {
            if (-not $whatif) {
                if (-not $force) {
                    $q = Read-Host "Soll neuer Benutzer mit EMail $email angelegt werden? (J/N)"
                    if ($q -ne "J") {
                        return;
                    }
                }
                $body = "password=$password"
                $r=Invoke-RestMethod -Method PUT -Body $body -Uri $url -Headers $headers  
                Write-Verbose "Erzeuge neuen User $email und dem Kennwoprt $password"
                $r
            }
            else {
                Write-Verbose "Würde neuen User $email und dem Kennwoprt $password erzeugen"
            }
        }
        catch {
            $errorcode = $_.Exception.Response.StatusCode.value__ 
            Write-Error $_
        }
    }
}

<#
.Synopsis
   Seafile Benutzer löschen
.DESCRIPTION
   Löscht einen Seafile Benutzer 
.EXAMPLE
   Delete-SFUser -email s3@mmbbs.de 
   Löscht Benutzer mit der EMail Adresse s3@mmbbs.de !
.EXAMPLE
   "s3@mmbbs.de","s4@mmbbs.de" | Delete-SFUser 
   Löscht die genannten Benutzer mit der EMAIL Adressen

#>
function Delete-SFUser
{
    [CmdletBinding()]   
    Param
    (
      [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
      [String]$email,
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
        
        $url = $global:seafile+"/api2/accounts/$email/"
        try {
            if (-not $whatif) {
                if (-not $force) {
                    $q = Read-Host "Soll neuer Benutzer mit EMail $email angelegt werden? (J/N)"
                    if ($q -ne "J") {
                        return;
                    }
                }
                $r=Invoke-RestMethod -Method DELETE -Uri $url -Headers $headers  
                Write-Verbose "Lösche User $email !"
                $r
            }
            else {
                Write-Verbose "Würde User $email löschen"
            }
        }
        catch {
            $errorcode = $_.Exception.Response.StatusCode.value__ 
            Write-Error $_
        }
    }
}

<#
.Synopsis
   Zeigt die Seafile Benutzer an
.DESCRIPTION
   Zeigt alle Seafile Benutzer an
.EXAMPLE
   Get-SFUsers 
   Zeigt die Seafile Benutzer an
#>
function Get-SFUsers
{
    [CmdletBinding()]   
    Param
    (
      [Parameter(Position=0)]
      [int]$start=-1,
      [Parameter(Position=1)]
      [int]$limit=-1,
      [Parameter(Position=2)]
      [ValidateSet('LDAP','DB','LDAPImport')]
      [String]$scope
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
        $url = $global:seafile+"/api2/accounts/"
        $url+="?start=$start&limit=$limit"
        if ($scope) {
            $url+="&scope=$scope"
        }
        try {
            $r=Invoke-RestMethod -Method GET -Uri $url -Headers $headers  
            Write-Verbose "Abfrage aller Seafilebenutzer"
            $r
        }
        catch {
            $null
        }
    }
}

<#
.Synopsis
   Zeigt Informationen zu einem User
.DESCRIPTION
   Zeigt Informationen zu einem User
.EXAMPLE
   Get-SFUser -email tuttas@mmbbs.de
   Zeigt die Informationen zum SF User tuttas@mmbbs.de an
.EXAMPLE
   "tuttas@mmbbs.de","kemmries@mmbbs.de" | Get-SFUser 
   Zeigt die Informationen zu den SF User tuttas@mmbbs.de und kemmries@mmbbs.de an
#>
function Get-SFUser
{
    [CmdletBinding()]   
    Param
    (
     [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
      [String]$email
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
        $url = $global:seafile+"api2/accounts/$email/"        
        try {
            $r=Invoke-RestMethod -Method GET -Uri $url -Headers $headers  
            Write-Verbose "Abfrage des Seafilebenutzers $email"
            $r
        }
        catch {
            $null
        }

    }
}

<#
.Synopsis
   Synchonisiert die Seafilebenutzer mit einer Gruppe
.DESCRIPTION
   Synchronisiert die Seafile Benutzer mit der Gruppe, d.h. Wenn Benutzer bereits in der Gruppe ist wird nichts
   unternommen. Ist der Benutzer nicht in der , wird er eingetragen. Benutzer die in der Gruppe sind, jedoch 
   nicht hinzugefügt wurden, werden gelöscht.
.EXAMPLE
   Sync-SFGroupMenber -groupid 12 -usermails tuttas@mmbbs.de,hecht@mmbbs.de
   Die  Gruppe mit der ID 12 enthält die Benutzer tuttas und hecht
.EXAMPLE
   "tuttas@mmbbs.de","hecht@mmbbs.de" | Sync-SFGroupMember -groupid 9 
   Die Gruppe mit der ID 9 enthält die Benutzer tuttas und hecht

#>
function Sync-SFGroupMember
{
    [CmdletBinding()]     
    Param
    (
        # Cohort ID
        [Parameter(Mandatory=$true,
                   Position=0)]
        [int]$groupid,

         # ID der Benutzers
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine=$true,
                   Position=1)]
        [String[]]$usermails,
        [switch]$force,
        [switch]$whatif
    )    
    Begin
    {
       
        if (-not $global:sftoken) {
            Write-Error "Sie sind nicht an Seafile angemeldet, veruchen Sie es mit Login-Seafile"
            break;
        }
        $headers=@{}      
        $headers["content-Type"]="application/x-www-form-urlencoded"  
        $headers["Authorization"]="TOKEN "+$global:sftoken;

        try {
            $members= Get-SFGroupmember -id $groupid | where-Object {-not $_.is_admin}| Select-Object -Property email | Get-SFUser
            $istMember = @{};
            foreach ($m in $members) {
                $istMember[$m.email]=$m
            }
        }
        catch {
            Write-Error "$($_.Exception.GetType().FullName) $($_.Exception.Message)"
            break;
        }
    }    
    Process
    {
        $usermails | ForEach-Object {
            $usermail = $_
            if ($istMember[$usermail]) {
                Write-Verbose "Der Benutzer mit der Email $usermail befindet sich bereits in der Gruppe mit der ID $groupid"
                $istMember.Remove($usermail)
            }
            else {
                if (!$force) {
                    $q=Read-Host "Soll der Benutzer mit der EMail $usermail in die Gruppe mit der ID $groupid aufgenommen werden? (J/N)"
                    if ($q -eq "J") {
                        Write-Verbose "Benutzer mit EMail $usermail wird in Gruppe mit ID $groupid aufgenommen" 
                        $r=Add-SFGroupmember -email $usermail -id $groupid -force
                    }
                }
                else {
                    Write-Verbose "Benutzer mit EMail $usermail wird in Gruppe mit ID $groupid aufgenommen" 
                    $r=Add-SFGroupmember -email $usermail -id $groupid -force
                }
            }
        }
    }  
    End {
        if (!$whatif) {
            if ($istMember.Count -ne 0) {
                if ($force) {
                   $r=$istMember.Values | Remove-SFGroupmember -id $groupid -force
                }
                else {
                   $r=$istMember.Values | Remove-SFGroupmember -id $groupid
                }
            }
        }
    }
}

<#
.Synopsis
   Synchonisiert die Seafile Gruppen
.DESCRIPTION
   Synchronisiert die Seafile Gruppe, d.h. Wenn eine Gruppe nicht existiert wird diese angeleght. Wenn eine Gruppe existiert, aber nicht mehr benötigt wird, 
   wird diese gelöscht
.EXAMPLE
   Sync-SFGroups -groups FIAE17J,FIAE17K
   Die  Gruppen FIAE17J und FIAE17K werden angelegt, falls sie nicht bereits existierem, alle anderen Gruppen werden gelöscht
.EXAMPLE
   "FIAE17J,FIAE17K" | Sync-SFGroupMember -nodelete
   Die  Gruppen FIAE17J und FIAE17K werden angelegt, falls sie nicht bereits existierem, alle anderen Gruppen bleiben erhalten

#>
function Sync-SFGroups
{
    [CmdletBinding()]     
    Param
    (
         # LIste mit Gruppennamen
        [Parameter(Mandatory=$true,
                   ValueFromPipeLine=$true,
                   Position=0)]                    
        [String[]]$groups,
        [switch]$force,
        [switch]$whatif,
        [switch]$nodelete
    )    
    Begin
    {
       
        if (-not $global:sftoken) {
            Write-Error "Sie sind nicht an Seafile angemeldet, veruchen Sie es mit Login-Seafile"
            break;
        }
        $headers=@{}      
        $headers["content-Type"]="application/x-www-form-urlencoded"  
        $headers["Authorization"]="TOKEN "+$global:sftoken;

        try {
            $ist= Get-SFGroups
            $istGroups = @{};
            foreach ($m in $ist) {
                $istGroups[$m.id]=$m
            }
        }
        catch {
            Write-Error "$($_.Exception.GetType().FullName) $($_.Exception.Message)"
            break;
        }
    }    
    Process
    {
        $groups | ForEach-Object {
            $group=$_
            $gr=$istGroups.Keys | % { if ($istGroups.Item($_).name -eq $group) {$istGroups.Item($_)} }
            if ($gr){
                Write-Verbose "Die Gruppe $($gr.name) existiert bereits in Seafile mit der ID $($gr.id)"
                $istGroups.Remove($gr.id);
            }
            else {
                Write-Verbose "Die Gruppe $group existiert noch nicht in Seafile und wird dort angelegt !"
                $g=New-SFGroup -name $group -force:$force
            }
        }
    }  
    End {
        if (!$whatif) {
            if (!$nodelete) {
                Write-Verbose "Lösche Gruppen die nicht in der Soll-Liste enthalten sind"
                if ($istGroups.Count -ne 0) {
                    $istGroups.Keys | % {
                        if (-not $force) {
                            $q = Read-Host "Soll die Gruppe $($istGroups.Item($_).name) mit der id $($istGroups.Item($_).id) aus Seafile gelöscht werden? (J/N)"
                            if ($q -eq "J") {
                                $r=Delete-SFGroup -id $($istGroups.Item($_).id) -force 
                            }
                        }
                        else {
                            $r=Delete-SFGroup -id $($istGroups.Item($_).id) -force
                            Write-Verbose "Lösche die Gruppe $($istGroups.Item($_).name) mit der id $($istGroups.Item($_).id) aus Seafile!"
                        }
                    }
                }
            }
        }
    }
}
