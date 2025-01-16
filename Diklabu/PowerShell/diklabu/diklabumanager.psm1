$global:keys = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43) 

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
<#
.Synopsis
   Liest die Server, Benutzernamen und Kennworte aus
.DESCRIPTION
   Liest die Server, Benutzernamen und Kennworte aus
.EXAMPLE
   Get-Keystore
.EXAMPLE
   Get-Keystore -file c:\Temp\keys
#>
function Get-Keystore
{
    [CmdletBinding()]
    Param
    (
        # Hilfebeschreibung zu Param1
        [Parameter(Position=0)]
        $file=$Global:keystore

    )

    Begin
    {
        $logins=@{}
        if ($file -ne $Global:keystore) {
            if (-not $global:keystore -and -not $file) {
                $file = Read-Host "Bitte Keystore file angeben"
            }
            if ($global:logins) {
                $global:logins.Clear()
            }
            $global:keystore=$file
            $file
        }
        if (Test-Path $file) {
            $lf = Get-Content $global:keystore | ConvertFrom-Json

            $lf.PSObject.Properties | ForEach-Object {
                $logins[$_.Name]=$_.Value
            }         
        }
        $global:logins=$logins;
        $logins;
    }
}

$global:logins=Get-Keystore -file "$env:TEMP\keystore.json"

<#
.Synopsis
   Setzte einen Schlüssel bestehend aus Server, Benutzernamen und Kennworte aus
.DESCRIPTION
   Setzte einen Schlüssel bestehend aus Server, Benutzernamen und Kennworte aus
.EXAMPLE
   Set-Keystore -url http://xyz.de -credential $cred -key seafile
.EXAMPLE
   Set-Keystore -file keys.txt -url http://xyz.de -credential $cred -key seafile
#>
function Set-Keystore
{
    [CmdletBinding()]
    Param
    (
        # Hilfebeschreibung zu Param1
        [Parameter(Position=0)]
        $file=$global:keystore,

        [Parameter(Mandatory=$true,
                   Position=1)]
        $key,
        [Parameter(Mandatory=$true,
                   Position=2)]
        $server,

        [Parameter(Position=3)]
        [PSCredential]$credential


    )

    Begin
    {
        $global:logins=Get-Keystore -file $file
        $login = "" | Select-Object "location","user","password"
        $login.location = $server
        $login.user =  $credential.UserName
        if ($credential.password) {
            try {
                $login.password = $credential.Password | ConvertFrom-SecureString -Key $global:keys
            }
            catch {
                $login.password = ""
            }
        }
        $global:logins[$key]=$login
        $global:logins | ConvertTo-Json -Compress | Set-Content $file
        $file
    }
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
        Set-Keystore -key "diklabu" -server $uri
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
                $password = $Global:logins["diklabu"].password | ConvertTo-SecureString -Key $global:keys
                $credential = New-Object System.Management.Automation.PsCredential($Global:logins["diklabu"].user,$password)
            }    
        } 
        
        try {
            $data=echo "" | Select-Object -Property "benutzer","kennwort"
            $data.benutzer=$credential.userName
            $data.kennwort=$credential.GetNetworkCredential().Password        
            $headers=@{}
            $headers["content-Type"]="application/json"
            #$headers["service_key"]=$user+"f80ebc87-ad5c-4b29-9366-5359768df5a1";
            Write-Verbose "Anmelden am Diklabuserver unter $uri"
            $r=Invoke-RestMethod -Method Post -Uri ($uri+"auth/login") -Headers $headers -Body (ConvertTo-Json $data)
            $global:auth_token=$r.auth_token
            $global:server=$uri
            Set-Keystore -key "diklabu" -server $uri -credential $credential
            return $r;
        }
        catch {
            Write-Error $_.Exception.Message
        }
        
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
<#
.Synopsis
   Ausgeben einer Bildschirmmeldung und Zeitdifferenz
.DESCRIPTION
   Ausgeben einer Bildschirmmeldung mit write-verbose und bei Bedarf Anzeigen einer Zeitdifferenz,
   um die Dauer einer Programmausführung anzeigen zu können. Wenn eine Protokolldatei angegeben wird,
   wird die Meldung auch in die Protokolldatei geschrieben.
.EXAMPLE
   write-msg "Hallo"
.EXAMPLE
   $now = get-date 
   write-msg "Die aktuelle Zeitdifferenz zu jetzt ist: " $now
.EXAMPLE
   write-msg "Hallo" $null "c:\temp\protokoll.txt"
#>
function write-msg{
    param(
     [Parameter(Mandatory=$true, Position=0)]
     [String]$msg,
     [Parameter(Mandatory=$false, Position=1)]
     [datetime]$time,
     [Parameter(Mandatory=$false, Position=2)]
     [String]$path_prot
    )
   
    if($time){
      # Zeitdifferenz ausgeben, wenn eine Zeit übergeben wurde (für Dauer einer Befehlsausführung)
      [datetime]$end = get-date
      $msg+=": "
    $msg+=[math]::Round((new-timespan -start $time -end $end).totalSeconds)
      $msg+=" Sekunden"
    }
    if ($path_prot) {write-prot $msg $path_prot}
    write-host $msg
    # Zeit nur zurückgeben, wenn keine Zeit übergeben wurde 
    # (so kann vor einer Befehlsausführung die Anfangszeit ermittelt werden durch Ausgabe einer Meldung, 
    # dass der Befehl gestartet wird)
    if(!$time) {return (get-date)}
   }
######################### ende write-msg #######################################

#####                         write-prot                                   #####
<#
.Synopsis
   Protokollieren einer Meldung in der Protokolldatei
.DESCRIPTION
   Protokollieren einer Meldung in der Protokolldatei
.EXAMPLE
   write-prot "Hallo" "C:\protokoll.txt"
#>   
function write-prot{
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
            [String]$text, # Text, der gespeichert werden soll
        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
            [String]$path_prot # Name und Pfad zur Protokolldatei
    )
    $text=(get-date -format "hh:mm:ss") +": "+ $text
    $text|out-file -filepath $path_prot -Append   
}
######################### ende write-prot #######################################
