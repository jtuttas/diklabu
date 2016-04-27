<#
    VERBEN:
        find ... Listet die Schüler auf, die sich in der / den via Namen angegebenen Klassen befinden
        get .... Listet die Schüler auf, die sich in der / den via ID angegebenen Klassen befinden
        Add .... Fügt einen oder mehrere Schüler einer Klasse Hinzu
        Remove . Entfernt einen oder mehrere Schüler aus einer Klasse
    Nome:
        CourseMember
#>

<#
.Synopsis
   Einen oder mehrere Schüler eine Klasse zuweisen
.DESCRIPTION
   Fügt einen oder mehrere Schüler einer Klasse hinzu.
.EXAMPLE
   Add-Coursemember -id 3623 -klassenid 612 
.EXAMPLE
   Add-Coursemember -id 3623 -klassenid 612 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   11234,5678,7654 | Add-Coursemember -klassenid 612 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   Find-Pupil -VNAME % -NNAME % -GEBDAT 1968-04-12 | Add-Coursemember -klassenid 612 -uri http://localhost:8080/Diklabu/api/v1/
.DESCRIPTION
   Fügt die Schüler die an dem 12.4.1968 geboren wurden der Klasse hinzu
.EXAMPLE
   Import-Csv schueler.csv | Find-Pupil  | Add-Coursemember -klassenid 612 -uri http://localhost:8080/Diklabu/api/v1/
.DESCRIPTION
   Fügt die Schüler in der enthaltenener CSV Datei der Klasse hinzu, die CSV Datei hat dabei folgendes Format:
   "GEBDAT","NNAME","VNAME"
    "1968-04-11","Tuttas","Jörg"
    "1968-04-11","Tuttas","Joerg"
.EXAMPLE
   Find-Coursemember FISI13A  | Add-Coursemember -klassenid 612 -uri http://localhost:8080/Diklabu/api/v1/
   Fügt die Schüler der Klasse Fisi13A in die Klasse mit der id 612 ein
#>
function Add-Coursemember
{
    Param
    (
        # Schülerobjekt
        [Parameter(ValueFromPipeline=$true)]
        $schueler,
        # ID des Schülers
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [int]$id,

        # id der Klasse
        [Parameter(Mandatory=$true,Position=0)]
        [int]$klassenid,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server

    )

    Begin
    {
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
    }
    Process
    {
        $rel=echo "" | Select-Object -Property "ID_SCHUELER","ID_KLASSE"
        $rel.ID_SCHUELER=$id
        $rel.ID_KLASSE=$klassenid
        try {
            $r=Invoke-RestMethod -Method Post -Uri ($uri+"klasse/admin/add") -Headers $headers  -Body (ConvertTo-Json $rel)
            return $r;
        } catch {
            Write-Host "Add-Coursemember: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }

    }
    End
    {
    }
}


<#
.Synopsis
   Schüler einer oder mehrere Klasse abfragen
.DESCRIPTION
   Liefert die Schülerobjekte einer oder mehrere Klasse(n). Dabei ist das %-Zeichen der Wirldcard
.EXAMPLE
   Find-Coursemember  -KNAME FISI13A 
.EXAMPLE
   Find-Coursemember  -KNAME FISI13% -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   "FISI13%","SYK13%" | Find-Coursemember 
.EXAMPLE
   Import-Csv klasse.csv | Find-Coursemember 
   Liefert die Schülerobjekte der in der CSV gelisteten Klassen, die CSV Datei hat dabei folgendes Format
   "KNAME"
   "WPK_TU_lila"
   "FISI13A"
#>
function Find-Coursemember
{
    Param
    (
        # Objekt der Klasse
        [Parameter(ValueFromPipeline=$true)]
        $klasse, 
        # Name der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$KNAME,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server
    )

    Begin
    {
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
    }
    Process
    {
        try {
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"klasse/"+$KNAME) -Headers $headers  
            return  $r;
         } catch {
            Write-Host "Find-Coursemember: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
}

<#
.Synopsis
   Schüler einer oder mehrere Klasse(n) abfragen
.DESCRIPTION
   Liefert die Schülerobjekte einer oder mehrere Klasse(n). 
.EXAMPLE
   Get-Coursemember  -id 1234
.EXAMPLE
   Get-Coursemember  -id 1234 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   1234,5678 | Get-Coursemember 
#>
function Get-Coursemember
{
    Param
    (
        # Objekt der Klasse
        [Parameter(ValueFromPipeline=$true)]
        $klasse, 
        # id der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [int]$id,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server
    )

    Begin
    {
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
    }
    Process
    {
        try {
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"klasse/member/"+$id) -Headers $headers  
            return  $r;
         } catch {
            Write-Host "Get-Coursemember: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
}

<#
.Synopsis
   Einen oder mehrere Schüler aus einer Klasse entfernen
.DESCRIPTION
   Löscht einen oder mehrere Schüler mit der id aus der Klasse mit der klassenid
.EXAMPLE
   Remove-Coursemember -id 1234 -klassenid 1234
.EXAMPLE
   Remove-Coursemember -id 1234 -klassenid 1234 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
  123,456,789| Remove-Coursemember -klassenid 1234 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
  Find-Pupil -VNAME % -NNAME % -GEBDAT 1968-04-12| Remove-Coursemember -klassenid 1234 
   Löscht die Schüler , die am 12.4.1968 geboren sind aus der Klasse mit der id 1234
.EXAMPLE
  Import-CSV schueler.csv | Find-Pupil | Remove-Coursemember -klassenid 1234 
   Löscht die Schüler , die in der CSV Datei enthalten sind aus der Klasse mit der ID 1234. Die CSV Datei hat dabei folgendes Aussehen
   "GEBDAT","NNAME","VNAME"
   "1968-04-11","Tuttas","Jörg"
.EXAMPLE
  Find-Coursemember FISI13A  | Remove-Coursemember -klassenid 1234 
   Löscht die Schüler aus der Klasse Fisi13A in der Klasse mit der ID 1234.
#>
function Remove-Coursemember
{
    Param
    (
        # Objekt des Schülers
        [Parameter(ValueFromPipeline=$true)]
        $schueler, 
        # Name der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [int]$id,

        # ID der klasse
        [Parameter(Mandatory=$true,Position=0)]
        [int]$klassenid,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server
    )

    Begin
    {
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
    }
    Process
    {
        try {
            $r=Invoke-RestMethod -Method Delete -Uri ($uri+"klasse/admin/"+$id+"/"+$klassenid) -Headers $headers 
            return $r;
         } catch {
            Write-Host "Remove-Coursemember: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }

    }
    End
    {
    }
}

