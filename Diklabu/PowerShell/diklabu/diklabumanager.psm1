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


$global:server="http://localhost:8080/Diklabu/api/v1/"
$global:auth_token="1234"

if (Test-Path "$home\diklabu.conf") {
    [xml]$d=Get-Content "$home\diklabu.conf";
    $global:server=$d.diklabu.server;
}
else {
    "<diklabu><server>"+$global:server+"</server></diklabu>" | Set-Content "$home\diklabu.conf"
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
        $global:server=$uri;
        "<diklabu><server>"+$global:server+"</server></diklabu>" | Set-Content "$home\diklabu.conf"

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
        return $global:server
    }
   
}

<#
.Synopsis
   Anmelden am Klassenbuch
.DESCRIPTION
   Anmleden beim Klassenbuch und Sessionkey beziehen
.EXAMPLE
   login-diklabu -user Benutzername -password password 
.EXAMPLE
   login-diklabu -user Benutzername -password password -URI http://localhost:8080/Diklabu/api/v1/
#>
function Login-Diklabu
{
    Param
    (
        # Benutzername
        [Parameter(Mandatory=$true,Position=0)]
        [String]$user,

        # Kennwort
        [Parameter(Mandatory=$true,Position=1)]
        [String]$password,

        # URI des Diklabu Servers
        [Parameter(Position=2)]
        [String]$uri=$global:server

    )

    Begin
    {
        $data=echo "" | Select-Object -Property "benutzer","kennwort"
        $data.benutzer=$user
        $data.kennwort=$password        
        $headers=@{}
        $headers["content-Type"]="application/json"
        $headers["service_key"]=$user+"f80ebc87-ad5c-4b29-9366-5359768df5a1";
        $r=Invoke-RestMethod -Method Post -Uri ($uri+"auth/login") -Headers $headers -Body (ConvertTo-Json $data)
        $global:auth_token=$r.auth_token
        return $r;
    }
}

