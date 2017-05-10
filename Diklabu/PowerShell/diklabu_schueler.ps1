<#
    VERBEN:
        find ... findet einen oder mehrere Schüler nach Namen und Geburtsdatum. '%' ist WildCard
        search . sucht einen oder mehrere Schüler
        get .... findet einen  Schüler durch Angabe des PK (Schueler ID)
        set .... ändert Attribute eines Schülers durch angabe des PK
        new .... erzeugt ein neuen Schüler Eintrag
        delete . löscht einen Schüler

    NOMEN:
        pupil
#>
<#
.Synopsis
   Informationen zu einem Schüler abfragen
.DESCRIPTION
   Informationen zu einem Schüler abfragen. Die Schülerdaten können dabei aus einer CSV Datei kommen mit folgenden Einträge
        "GEBDAT","NNAME","VNAME"
        "1968-04-11","Tuttas","Jörg"
.EXAMPLE
   Find-Pupil -VNAME Joerg -NNAME Tuttas -GEBDAT 1968-04-11
.EXAMPLE
   Find-Pupil -VNAME Joerg -NNAME Tuttas -GEBDAT 1968-04-11 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   Find-Pupil -VNAME % -NNAME % -GEBDAT 1968-04-11 
   Findet alle Schüler, die an dem Tag Geburtstag haben
.EXAMPLE
   Import-Csv schueler.csv | Find-Pupil 

#>
function Find-Pupil
{
    [CmdletBinding()]
    Param
    (    
        # Vorname des Schülers
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$VNAME,

        # Nachname des Schülers
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        [String]$NNAME,

        # Geburtsdatum im SQL Format yyyy-mm-dd
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=2)]
        [String]$GEBDAT,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server

    )

    Begin
    {
        if (-not $global:auth_token) {
            Write-Error "Sie sind nicht am diklabu angemeldet, versuchen Sie login-diklabu"
            return;
        }
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
    }
    Process
    {
        $schueler=echo "" | Select-Object -Property "GEBDAT","NNAME","VNAME"
        $schueler.GEBDAT=$GEBDAT
        $schueler.NNAME=$NNAME
        $schueler.VNAME=$VNAME
        try {
            $r=Invoke-RestMethod -Method Post -Uri ($uri+"schueler/info") -Headers $headers -Body (ConvertTo-Json $schueler)  -ContentType "application/json; charset=iso-8859-1"             
            Write-Verbose "Find Schüler $schueler ! Ergebnis: $r"
            return $r;
        } catch {
            Write-Error "Find-Pupil: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }
}

<#
.Synopsis
   Einen Schüler anhand von Vorname, Nachname und Geb. Datum suchen (unter Angabe der Levensthein Distanz)
.DESCRIPTION
   Einen Schüler anhand von Vorname, Nachname und Geb. Datum suchen (unter Angabe der Levensthein Distanz)
.EXAMPLE
   Search-Pupil -VNAMENNAMEGEBDAT JörgTuttas1968-04-11 -LDist=4
.EXAMPLE
   Search-Pupil -VNAMENNAMEGEBDAT JörgTuttas1968-04-11 -LDist=4 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   "JörgTuttas1968-04-11" | Search-Pupil -LDist=4
.EXAMPLE
   Import-Csv schueler.csv | Search-Pupil -LDist=4
#>
function Search-Pupil
{
    [CmdletBinding()]
    Param
    (    
        # Suchstring gebildet aus VornameNachNameGebDatum des Schülers
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$VNAMENNAMEGEBDAT,

        # Levensthein Distanz
        [Parameter(Mandatory=$true,Position=1)]
        [String]$LDist,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server
    )

    Begin
    {
        if (-not $global:auth_token) {
            Write-Error "Sie sind nicht am diklabu angemeldet, versuchen Sie login-diklabu"
            return;
        }
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
    }
    Process
    {
        $Encode = [uri]::EscapeDataString($VNAMENNAMEGEBDAT)
        try {
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"schueler/"+$Encode+"/"+$LDist) -Headers $headers -ContentType "application/json; charset=iso-8859-1"             
            Write-Verbose "Suche Schüler (Suchmuster: $VNAMENNAMEGEBDAT ) mit Levensheindistanz $LDist : Ergebnis: $r"
            return $r;
        } catch {
            Write-Error "Search-Pupil: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription
        }
    }
}

<#
.Synopsis
   Einen oder mehrere Schüler abfragen und dateilierte Informationen ausgeben
.DESCRIPTION
   Fragt einen oder mehrere Schüler ab und gibt detailierte Informationen, wie Klassenzugehörigkeit Ausbilder und Ausbildungsbetrieb aus. 
.EXAMPLE
   Get-Pupil -id 1234
.EXAMPLE
   Get-Pupil -id 1234 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   1234,5678 | Get-Pupil 
.EXAMPLE
   Find-Pupil -VNAME % -NNAME % -GEBDAT 1993-12-30 | Get-Pupil 
   Zeit Schülerdaten an der Schüler, die an dem Tag geburtstag habenb
.EXAMPLE
   Find-Coursemember -KNAME FISI13A | Get-Pupil 
   Zeit Schülerdaten der Klasse Fisi13A an
#>
function Get-Pupil
{
    [CmdletBinding()]
    Param
    (       
        # ID des Schülers
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParameterSetName = "Set 1")]
        [int]$id,

        # BBS-PLan ID des Schülers
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParameterSetName = "Set 2")]
         [alias("ID_MMBBS")]
        [int]$bbsplanid,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server
    )
    Begin
    {
        if (-not $global:auth_token) {
            Write-Error "Sie sind nicht am diklabu angemeldet, versuchen Sie login-diklabu"
            return;
        }
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
    }
    Process
    {
        try {
            if ($id) {
                $r=Invoke-RestMethod -Method Get -Uri ($uri+"schueler/"+$id) -Headers $headers -ContentType "application/json; charset=iso-8859-1"     
                Write-Verbose "Suche Schüler mit der ID $id"
            }
            else {
                $r=Invoke-RestMethod -Method Get -Uri ($uri+"schueler/bbsplan/"+$bbsplanid) -Headers $headers -ContentType "application/json; charset=iso-8859-1"     
                Write-Verbose "Suche Schüler mit der BBS PLan ID $bbsplanid"
            }
            return $r;
        } catch {
            Write-Error "Get-Pupil: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }
}

<#
.Synopsis
   Alle Schüler abfragen 
.DESCRIPTION
   Fragt alle Schüler ab
.EXAMPLE
   Get-Pupils
.EXAMPLE
   Get-Pupils -uri http://localhost:8080/Diklabu/api/v1/
#>
function Get-Pupils
{
    [CmdletBinding()]
    Param
    (       

        # Adresse des Diklabu Servers
        [String]$uri=$global:server
    )
    Begin
    {
        if (-not $global:auth_token) {
            Write-Error "Sie sind nicht am diklabu angemeldet, versuchen Sie login-diklabu"
            return;
        }
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
    }
    Process
    {
        try {
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"schueler/") -Headers $headers -ContentType "application/json; charset=iso-8859-1"     
            Write-Verbose "Liste aller Schüler !"
            return $r;
        } catch {
            Write-Error "Get-Pupils: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }
}

<#
.Synopsis
   Einen oder mehrere Schüler hinzufügen
.DESCRIPTION
   Fügt einen Schüler zur Tabelle Schueler hinzu. Die Daten können dabei auch aus einer CSV Datei stammen, die folgendes Aussehen hat
       "GEBDAT","NNAME","VNAME"
       "1968-04-11","Tuttas","Jörg"
       "1968-04-11","Tuttas","Joerg"
       "1968-04-12","Tuttas","Frank"
.EXAMPLE
   New-Pupil -VNAME Joerg -NNAME Tuttas -GEBDAT 1968-04-11
.EXAMPLE
   New-Pupil -VNAME Joerg -NNAME Tuttas -GEBDAT 1968-04-11 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   New-Pupil -VNAME Jörg -NNAME Tuttas -GEBDAT 1968-04-11 -EMAIL jtuttas@gmx.net -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   New-Pupil -VNAME Joerg -NNAME Tuttas -GEBDAT 1968-04-11 -uri http://localhost:8080/Diklabu/api/v1/ -ID_AUSBILDER=4711
.EXAMPLE
   Import-Csv schueler.csv  | New-Pupil
#>
function New-Pupil
{
    [CmdletBinding()]
    Param
    (
        # Vorname des Schülers
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String]$VNAME,

        # Nachname des Schülers
        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [String]$NNAME,

        # Geburtsdatum im SQL Format yyyy-mm-dd
        [Parameter(Position=2,ValueFromPipelineByPropertyName=$true)]
        [String]$GEBDAT,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        # EMail Adresse des Schülers
        [String]$EMAIL,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        # ID Des Ausbilders
        [int]$ID_AUSBILDER,

        # Abgang
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$ABGANG="N",

        # Info
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$INFO,

        # BBS Plan ID
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$bbsplanid,

        # Info
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$id,

        [switch]$whatif


    )

    Begin
    {
        if (-not $global:auth_token) {
            Write-Error "Sie sind nicht am diklabu angemeldet, versuchen Sie login-diklabu"
            return;
        }
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
    }
    Process
    {
        $schueler=echo "" | Select-Object -Property "EMAIL","GEBDAT","VNAME","NNAME","ID_AUSBILDER","ABGANG","INFO","id","ID_MMBBS"
        if ($VNAME) {
          $schueler.VNAME=$VNAME
        }
        if ($NNAME) {
          $schueler.NNAME=$NNAME
        }
        if ($GEBDAT) {
          $schueler.GEBDAT=$GEBDAT
        }
        if ($EMAIL) {
          $schueler.EMAIL=$EMAIL
        }
        if ($id -ne 0) {
          $schueler.id=$id
        }
        if ($ID_AUSBILDER -ne 0) {
            $schueler.ID_AUSBILDER=$ID_AUSBILDER
         }
         if ($ABGANG) {
          $schueler.ABGANG=$ABGANG
        }
        if ($INFO) {
          $schueler.INFO=$INFO
        }
        if ($bbsplanid -ne 0) {
          $schueler.ID_MMBBS=$bbsplanid
        }
        
        try {
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Post -Uri ($uri+"schueler/admin") -Headers $headers -Body (ConvertTo-Json $schueler)
            }
            Write-Verbose "Neuer Schüler $schueler wird angelegt!"
            return $r;
        } catch {
            Write-Error "New-Pupil: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }
}

<#
.Synopsis
   Attribute eines oder mehrerer Schüler ändern
.DESCRIPTION
   Ändert Attribute eines oder mehrerer Schüler
.EXAMPLE
   Set-Pupil -id 1234 -VNAME Joerg -NNAME Tuttas -GEBDAT 1968-04-11
.EXAMPLE
   Set-Pupil -id 1234 -VNAME Joerg -NNAME Tuttas -GEBDAT 1968-04-11 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   Set-Pupil -id 1234 -VNAME Jörg -NNAME Tuttas -GEBDAT 1968-04-11 -EMAIL jtuttas@gmx.net -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   Set-Pupil -id 1234 -VNAME Joerg -NNAME Tuttas -GEBDAT 1968-04-11 -uri http://localhost:8080/Diklabu/api/v1/ -ID_AUSBILDER=4711
.EXAMPLE
   1234,5678 | Set-Pupil -ABGANG "J"
.EXAMPLE
   Find-Pupil -VNAME % -NNAME % -GEBDAT 1993-12-30 | Set-Pupil -INFO "Im Dezember Geburtstag"
   Alle Schüler die am 30.12.1993 Geburtstag haben, wird die Bemerkung "Im Dezember Geburtstag" zugewiesen
.EXAMPLE
   Find-Coursemember FISI13B | Set-Pupil -ABGANG "J"
   Alle Schüler der Klasse FISI13B erhalten das Attribut ABGANG=J
#>
function Set-Pupil
{
    [CmdletBinding()]
    Param
    (
        # ID des Schülers
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [int]$id,

        # Vorname des Schülers
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$VNAME,

        # Nachname des Schülers
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$NNAME,

        # Geburtsdatum im SQL Format yyyy-mm-dd
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$GEBDAT,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server,

        # EMail Adresse des Schülers
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$EMAIL,

        # ID Des Ausbilders
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$ID_AUSBILDER=-1,

        # Abgang
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$ABGANG,

        # Info
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$INFO,

        # BBS PLan ID
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$bbsplanid,

        [switch]$whatif

    )

    Begin
    {
        if (-not $global:auth_token) {
            Write-Error "Sie sind nicht am diklabu angemeldet, versuchen Sie login-diklabu"
            return;
        }
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
        
    }
    Process
    {
        $schueler=echo "" | Select-Object -Property "EMAIL","GEBDAT","VNAME","NNAME","ID_AUSBILDER","ABGANG","INFO","ID_MMBBS"
        if ($VNAME) {
            $schueler.VNAME=$VNAME
        }
        if ($NNAME) {
            $schueler.NNAME=$NNAME
        }
        if ($GEBDAT) {
            $schueler.GEBDAT=$GEBDAT
            }
        if ($EMAIL) {
            $schueler.EMAIL=$EMAIL
        }
        if ($ID_AUSBILDER -ne -1) {
            $schueler.ID_AUSBILDER=$ID_AUSBILDER
        }
        if ($ABGANG) {
            $schueler.ABGANG=$ABGANG
        }
        if ($INFO) {
            $schueler.INFO=$INFO
        }
        if ($bbsplanid -ne 0) {
            $schueler.ID_MMBBS=$bbsplanid
        }

        try {
            $r=Invoke-RestMethod -Method Post -Uri ($uri+"schueler/verwaltung/"+$id) -Headers $headers -Body (ConvertTo-Json $schueler)
            Write-Verbose "Daten des Schülers mit der ID $id geändert auf $schueler"
            return $r;
        } catch {
            Write-Error "Set-Pupil: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }    
}


<#
.Synopsis
   Einen oder mehrere Schüler löschen
.DESCRIPTION
   Entfernt einen oder mehrere Schüler aus der Tabelle Schüler, sofern er/sie nocht nicht einer Klasse zugerodnet ist
.EXAMPLE
   Delete-Pupil -id 1234 
.EXAMPLE
   Delete-Pupil -id 1234 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   1234,5678 | Delete-Pupil 
.EXAMPLE
   Find-Pupil -VNAME % -NNAME % -GEBDAT 1968-04-11 | Delete-Pupil 
   Löscht alle Schüler, die am 11.4.1968 geboren sind
.EXAMPLE
   Import-Csv schueler.csv | Find-Pupil | Delete-Pupil 
   Löscht alle Schüler, die in der CSV Datei sich befinden, die CSV Datei hat dabei folgendes Format
    "GEBDAT","NNAME","VNAME"
    "1968-04-11","Tuttas","Jörg"
    "1968-04-11","Tuttas","Joerg"
    "1968-04-12","Tuttas","Frank"
#>
function Delete-Pupil
{
    [CmdletBinding()]
    Param
    (        
        # ID des Schülers
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [int]$id,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [switch]$whatif
    )

    Begin
    {
        if (-not $global:auth_token) {
            Write-Error "Sie sind nicht am diklabu angemeldet, versuchen Sie login-diklabu"
            return;
        }
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
        
    }
    Process
    {
        try {
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Delete -Uri ($uri+"schueler/admin/"+$id) -Headers $headers 
            }
            Write-Verbose "Lösche Schüler mit der ID $id"
            return $r;
        } catch {
            Write-Error "Delete-Pupil: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }
}


