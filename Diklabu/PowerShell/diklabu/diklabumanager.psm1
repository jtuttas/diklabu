<#
    VERBEN:
        find ... findet einen oder mehrere Objekte nach Namen. '%' ist WildCard
        get .... findet ein Objekt durch angabe des PK
        set .... ändert Attribute eines Objektes durch angabe des PK
        new .... erzeugt ein neuen Eintrag
        delete . ein Objekt löschen
        
     NOMEN
        pupil ........ Schüler
        course ....... Klasse
        company ...... Firma
        instructor ... Ausbilder 
        coursemember . Kursmitgliedschaft        

#>


$global:auth_token

function getKeys() {
    $logins=@{}
    if (Test-Path "$HOME\diklabu2.conf") {
        $lf = Get-Content "$HOME\diklabu2.conf" | ConvertFrom-Json

        $lf.PSObject.Properties | ForEach-Object {
            $logins[$_.Name]=$_.Value
        }         
    }
    return $logins;
}

$global:logins=getKeys

function setKey([String]$key,[String]$url,[PSCredential]$cred) {
    $global:logins=getKeys   
    $login = "" | Select-Object "location","user","password"
    $login.location = $url
    if ($cred -ne $null) {
        $login.user = $cred.UserName
        $login.password = $cred.Password | ConvertFrom-SecureString
    }
    $global:logins[$key]=$login
    $global:logins | ConvertTo-Json -Compress | Set-Content "$HOME\diklabu2.conf"
}


<#
.Synopsis
   Server URL Setzen
.DESCRIPTION
   Setzt global die Server URL
.EXAMPLE
   Set-Diklabuserver -uri http://localhost:8080/Diklabu/api/v1/
#>
function Set-Diklabuserver
{
    Param
    (
        # Hilfebeschreibung zu Param1
        [Parameter(Mandatory=$true,Position=0)]
        [String]$uri

    )

    Begin
    {
        setKey "diklabu" $uri $null
    }
   
}

<#
.Synopsis
   Abfrage des Diklabuservers
.DESCRIPTION
   Abfrage des Diklabuservers
.EXAMPLE
   Get-Diklabuserver
#>
function Get-Diklabuserver
{
    Begin
    {
        return $global:logins["diklabu"].location
    }
   
}

<#
.Synopsis
   Anmelden am Klassenbuch
.DESCRIPTION
   Anmelden beim Klassenbuch und Sessionkey beziehen
.EXAMPLE
   login-diklabu -credential (get-Credential)
.EXAMPLE
   login-diklabu -credential (get-Credential) -URI http://localhost:8080/Diklabu/api/v1/
#>
function Login-Diklabu
{
    Param
    (
        # Benutzername
        [Parameter(Position=0)]
        [PSCredential]$credential,

        # URI des Diklabu Servers
        [Parameter(Position=1)]
        [String]$uri

    )

    Begin
    {
        if (-not $uri) {
            if ($Global:logins["diklabu"]) {
                $uri=$Global:logins["diklabu"].location;
            }
            else {
                Write-Error "Bitte uri und oder Serveradresse mittels Set-DiklabuServer angeben!"
                break;
            }
        }
        if (-not $credential) {
            if (-not $Global:logins["diklabu"].password) {
                Write-Error "Bitte  credentials angeben!"
                break;
            }
            else {
                $password = $Global:logins["diklabu"].password | ConvertTo-SecureString 
                $credential = New-Object System.Management.Automation.PsCredential($Global:logins["diklabu"].user,$password)
            }    
        } 
        $data=echo "" | Select-Object -Property "benutzer","kennwort"
        $data.benutzer=$credential.userName
        $data.kennwort=$credential.GetNetworkCredential().Password        
        $headers=@{}
        $headers["content-Type"]="application/json"
        $headers["service_key"]=$user+"f80ebc87-ad5c-4b29-9366-5359768df5a1";
        Write-Verbose "Anmelden am Diklabuserver unter $uri"
        $r=Invoke-RestMethod -Method Post -Uri ($uri+"auth/login") -Headers $headers -Body (ConvertTo-Json $data)
        $global:auth_token=$r.auth_token
        $global:server=$uri
        setKey "diklabu" $uri $credential
        return $r;
    }
}

<#
.Synopsis
   Abfragen der Anmeldedaten
.DESCRIPTION
   Abfragen der Anmeldedaten
.EXAMPLE
   get-diklabu 
#>
function Get-Diklabu
{
    Param
    (
    )

    Begin
    {
        $Global:logins["diklabu"]
    }
}


