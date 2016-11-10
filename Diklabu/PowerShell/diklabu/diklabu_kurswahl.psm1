﻿<#
    VERBEN:
        *add ..... fügt einen Kurs (oder mehrere) zur Kurswahl hinzu
        *remove .. löscht einen (oder mehrere) Kurse aus der Kurswahl
        *enable .. schaltet die Kurswahl frei
        *disable . sperrt die Kurswahl
        *clear ... löscht die Kurswünsche nach Rückfrage (oder Schalter -force ist gesetzt)
        *reset ... Löscht den Kurswunsch für einen (oder mehrere) Schüler
        *new ..... Eine Kurswahl für einen (oder mehrere) Schüler durchführen
        *Stop .... Einen Wurswunsch als gebucht setzten
        get ...... Liste der Schüler, die einen Kurs gewählt haben
        list ..... Zeigt die Kurse an, die zur Wahl stehen

    *) nur als Admin möglich

    NOMEN:
        Coursevoting
#>

<#
.Synopsis
   Einen oder mehrere Kurse zur Wahl hinzufügen
.DESCRIPTION
   Fügt einen oder mehrere Kurs zur Kurswahl hinzu
.EXAMPLE
   Add-Coursevoting -id 612 
.EXAMPLE
   Add-Coursevoting -kid 612 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   11234,5678,7654 | Add-Coursevoting 
.EXAMPLE
   Find-Course -KNAME "WPK%lila" | Add-Coursevoting 
   Fügt alle Kurse, die mit "WPK" beginnen und mit "lila" enden der Kurswahl hinzu

#>
function Add-Coursevoting
{
    [CmdletBinding()]
    Param
    (
        # id der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
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
            $r=Invoke-RestMethod -Method Post -Uri ($uri+"coursevoting/admin/"+$id) -Headers $headers 
          }
          Write-Verbose "Der Kurs mit der ID $ID wird zur Kurswahl hinzugefügt!"
          return $r;
        } catch {
            Write-Error "Add-Coursevoting: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }   
}

<#
.Synopsis
   Kurs(e) von der Wahl entfernen
.DESCRIPTION
   Entfernt einen oder mehrere Kurs aus der Kurswahl. Dieses ist nur möglich, sofern der Kurs nicht schon gewählt wurde!
.EXAMPLE
   Remove-Coursevoting -id 612 
.EXAMPLE
   Remove-Coursevoting -id 612 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   11234,5678,7654 | Remove-Coursevoting 
.EXAMPLE
   Find-Course -KNAME "%WPK%lila" | Remove-Coursevoting
#>
function Remove-Coursevoting
{
    [CmdletBinding()]
    Param
    (
         # id der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
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
                $r=Invoke-RestMethod -Method Delete -Uri ($uri+"coursevoting/admin/"+$id) -Headers $headers 
           }
           Write-Verbose "Der Kurs mit der ID $id wird aus der Kurswahl entfernt!"
            return $r;
        } catch {
            Write-Error "Remove-Coursevoting: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }

    }
}


<#
.Synopsis
   Kurswahl freigeben
.DESCRIPTION
   Gibt die Kurswahl frei
.EXAMPLE
   Enable-Coursevoting 
.EXAMPLE
   Enable-Coursevoting -uri http://localhost:8080/Diklabu/api/v1/
#>
function Enable-Coursevoting
{
    [CmdletBinding()]
    Param
    (
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
        try {
          if (-not $whatif) {
            $r=Invoke-RestMethod -Method post -Uri ($uri+"coursevoting/admin/voting/1") -Headers $headers 
          }
          Write-Verbose "Kurswahl freigeschaltet!"
          return $r;
        } catch {
            Write-Error "Enable-Coursevoting: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }
}

<#
.Synopsis
   Kurswahl sperren
.DESCRIPTION
   Sperrt die Kurswahl
.EXAMPLE
   Disable-Coursevoting 
.EXAMPLE
   Disable-Coursevoting -uri http://localhost:8080/Diklabu/api/v1/
#>
function Disable-Coursevoting
{
    [CmdletBinding()]
    Param
    (
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
        try {
          if (-not $whatif) {
            $r=Invoke-RestMethod -Method post -Uri ($uri+"coursevoting/admin/voting/0") -Headers $headers 
          }
          Write-Verbose "Kurswahl gesperrt!"
          return $r;
        } catch {
            Write-Error "Disable-Coursevoting: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }
}

<#
.Synopsis
   Löscht die Kurswahl von einem oder mehreren Schülern
.DESCRIPTION
   Löscht die Kurswahl von einem oder mehreren Schülern
.EXAMPLE
   Reset-Coursevoting -id 612 
.EXAMPLE
   Reset-Coursevoting -id 612 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   11234,5678,7654 | Reset-Coursevoting 
.EXAMPLE
   Find-Coursemember -KNAME FISI13A | Reset-Coursevoting 
   Löscht die Kurswahl der Schüler aus der Klasse Fisi13A
.EXAMPLE
   import-Csv schueler.csv | Find-Pupil | Reset-Coursevoting 
   Löscht die Kurswahl der in der CSV Datei enthaltenen Schüler 
.EXAMPLE
   Find-Pupil -VNAME Jörg -NNAME Tuttas -GEBDAT 1968-04-11 | Reset-Coursevoting 
   Löscht die Kurswahl des angegebenen Schülers Schüler 

#>
function Reset-Coursevoting
{
    [CmdletBinding()]
    Param
    (
          # ID des Schülers
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
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
                $r=Invoke-RestMethod -Method Delete -Uri ($uri+"coursevoting/admin/schueler/"+$id) -Headers $headers 
            }
            Write-Verbose "Die Kurswahl für den Schülker mit der ID $id wurde zurückgesetzt: Ergebnis $r"
            return $r;
         } catch {
            Write-Error "Reset-Coursevoting: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }

    }
}

<#
.Synopsis
   Löscht alle Kurswahlen
.DESCRIPTION
   Löscht alle getätigten Kurswahlen. Löscht die Tabelle Kurswunsch
.EXAMPLE
   Reset-Coursevoting 
.EXAMPLE
   Reset-Coursevoting -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   Reset-Coursevoting -force
#>
function Clear-Coursevoting
{
    [CmdletBinding()]
    Param
    (
        # force        
        [switch]$force,
        

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
        if (!$force) {
          $s=Read-Host "Wollen Sie alle Kurswünsche zurück setzten? (J/N)"
          if ($s -eq "J") {
              $force=$true
          }
        }
        if ($force) {
          $headers=@{}
          $headers["content-Type"]="application/json;charset=iso-8859-1"
          $headers["auth_token"]=$global:auth_token;
          try {
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Delete -Uri ($uri+"coursevoting/admin/") -Headers $headers 
            }
            Write-Verbose "Alle Kurswahlen wurden zurückgesetzt (gelöscht!)";
            return $r;
          } catch {
              Write-Error "Clear-Coursevoting: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
        }
    }
}
 
<#
.Synopsis
   Abfrage der Kurswahl
.DESCRIPTION
   Zeigt die Schüler an, die einen (oder mehrere) Kurs gewählt haben. Dabei werden nur nicht gebuchte Kurse gelistet (siehe Option gebucht)
.EXAMPLE
   Get-Coursevoting -id 123 -priotity 2
.EXAMPLE
   Get-Coursevoting -id 123 -gebucht
   Zeigt die Schüler an, die einen (oder mehrere) Kurs gewählt haben. Dabei werden nur gebuchte Kurse gelistet!
.EXAMPLE
   Get-Coursevoting  -id 123 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   1234,5678 | get-Coursevoting -priority 1
.EXAMPLE
   Find-Course -KNAME "WPK%lila"| get-Coursevoting -priority 1
   Zeigt die alle Schüler an, die einen WPK Kurs mit der Priorität 1 gewählt haben, dessen Namen mit WPK beginnt und mit lila endet!

#>
function Get-Coursevoting
{
    [CmdletBinding()]
    Param
    (
         # ID der Klasse
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Position=0)]
        [int]$id,


        # Priorität des Kurswunsches
        [String]$priority=1,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server,

        # Schalter (nur gebuchte Kurse anzeigen)
        [switch]$gebucht=$false


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
    Process {
        try {            
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"coursevoting/"+$id+"/"+$priority+"/"+$gebucht) -Headers $headers 
            Write-Verbose "Abfrage der Kurswahl für den Kurs mit der ID $id und der priorität $priority (gebucht = $gebucht)"
            return $r;
        } catch {
            Write-Error "Get-Coursevoting: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }

    }
}

<#
.Synopsis
   Setzten einer Kurswahl
.DESCRIPTION
   Ein Schüler wählt Drei Kurse aus
.EXAMPLE
   New-Coursevoting -id 123 -course1 1234 -course2 4567 -course3 891
.EXAMPLE
   1234,5678 | New-Coursevoting -course1 1234 -course2 4567 -course3 891
.EXAMPLE
   Import-Csv schueler.csv | Find-Pupil | New-Coursevoting -course1 1234 -course2 4567 -course3 891
   Alle Schüler die in der CSV Datei enthalten sind, wählen die genannten Kurse

#>
function New-Coursevoting
{
    [CmdletBinding()]
    Param
    (
          # ID des Schülers
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [int]$id,

        [Parameter(Mandatory=$true)]
        # Priorität 1 des Kurswunsches
        [String]$course1,
        [Parameter(Mandatory=$true)]
        # Priorität 2 des Kurswunsches
        [String]$course2,
        [Parameter(Mandatory=$true)]
        # Priorität 3 des Kurswunsches
        [String]$course3,

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
    Process {
        try {
            $wunsch=echo "" | Select-Object -Property "ID_SCHUELER","ID_KURS","PRIORITAET","GEBUCHT"
            $wunsch.ID_SCHUELER=$id
            $wunsch.ID_KURS=$course1
            $wunsch.PRIORITAET="1";
            $wunsch.GEBUCHT="0";
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method POST -Uri ($uri+"coursevoting/admin/schueler/") -Headers $headers  -Body (ConvertTo-Json $wunsch)     
            }
            Write-Verbose "Buche einen Kurswunsch $wunsch . Ergebnis:$r"

            $wunsch=echo "" | Select-Object -Property "ID_SCHUELER","ID_KURS","PRIORITAET","GEBUCHT"
            $wunsch.ID_SCHUELER=$id
            $wunsch.ID_KURS=$course2
            $wunsch.PRIORITAET="2";
            $wunsch.GEBUCHT="0";
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method POST -Uri ($uri+"coursevoting/admin/schueler/") -Headers $headers  -Body (ConvertTo-Json $wunsch)     
            }
            Write-Verbose "Buche einen Kurswunsch $wunsch . Ergebnis:$r"
            $wunsch=echo "" | Select-Object -Property "ID_SCHUELER","ID_KURS","PRIORITAET","GEBUCHT"
            $wunsch.ID_SCHUELER=$id
            $wunsch.ID_KURS=$course3
            $wunsch.PRIORITAET="3";
            $wunsch.GEBUCHT="0";
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method POST -Uri ($uri+"coursevoting/admin/schueler/") -Headers $headers  -Body (ConvertTo-Json $wunsch)     
            }
            Write-Verbose "Buche einen Kurswunsch $wunsch . Ergebnis:$r"
        } catch {
            Write-Error "New-Coursevoting: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }

    }
}

<#
.Synopsis
   Beendet die Kurswahl für einen oder mehrere Schüler
.DESCRIPTION
   Beendet die Kurswahl für einen oder mehrere Schüler, das Attribut GEBUCHT wird in der Tabelle Kurswunsch auf "1" gesetzte!
.EXAMPLE
   Stop-Coursevoting -id 123
.EXAMPLE
   1234,5678 | Stop-Coursevoting 
.EXAMPLE
   Import-Csv schueler.csv | Find-Pupil | Stop-Coursevoting 
   Alle Schüler die in der CSV Datei enthalten sind, werden in der Kurswahl auf gebucht gesetzt

#>
function Stop-Coursevoting
{
    [CmdletBinding()]
    Param
    (
          # ID des Schülers
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [int]$id,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [whatif]$whatif

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
    Process {
        try {
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Put -Uri ($uri+"coursevoting/admin/schueler/$id") -Headers $headers      
            }
            Write-Verbose "Beende die Kurswahl für Schüler mit der ID $id . Ergebnis: $r";
            return $r
        } catch {
            Write-Error "Stop-Coursevoting: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }

    }
}

<#
.Synopsis
   Listet die Kurse die zur Wahl stehen
.DESCRIPTION
   Zeigt alle Kurse an, die zur Wahl stehen
.EXAMPLE
   Get-Coursevotings 
.EXAMPLE
   Get-Coursevotings  -uri http://localhost:8080/Diklabu/api/v1/
#>
function Get-Coursevotings
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
          
          try {
              $r=Invoke-RestMethod -Method Get -Uri ($uri+"coursevoting/") -Headers $headers 
              Write-Verbose "Liste der Kurs die zur Wahl stehen!"
              return $r;
          } catch {
            Write-Error "Get-Coursevoting: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }   
}
