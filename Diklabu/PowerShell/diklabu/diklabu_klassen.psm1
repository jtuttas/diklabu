<#
    VERBEN:
        find ... findet einen oder mehrere Klassen nach Namen. '%' ist WildCard
        get .... findet eine Klasse durch angabe des PK
        set .... ändert Attribute einer Klasse durch angabe des PK
        new .... erzeugt eine neue Klasse
        delete . eine Klasse löschen
    NOMEN:
        course
#>
<#
.Synopsis
   Eine Klasse(n) abfragen. % ist Wildcard
.DESCRIPTION
   Fragt die Tabelle Klassen ab und gibt die Klasse zurück wenn diese existiert. 
.EXAMPLE
   Find-Course -kname "FISI13A"
.EXAMPLE
   Find-Course -kname "FISI13%" 
.EXAMPLE
   Find-Course -kname "FISI13A" -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   "FISI13%","FIAE13%" | Find-Course -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   Import-Csv klassen.csv | Find-Course 
   Findet die Klassen die in der CSV Datei mit dem Attribut/Spalte "KNAME" versehen sind
#>
function Find-Course
{
    Param
    (
        # Name der Klasse
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"klasse/info/"+$KNAME) -Headers $headers  
            return $r;
        } catch {
            Write-Host "Find-Course: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }    
}

<#
.Synopsis
   Attribute einer Klasse oder mehrere Klassen ändern
.DESCRIPTION
   Ändert die Attribute einer Klasse oder mehrerer Klassen
.EXAMPLE
   Set-Course -id 1245 -kname FISI13A 
.EXAMPLE
   Set-Course -id 1234 -kname FISI13A -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   Set-Course -id 1234 -kname FISI13A -uri http://localhost:8080/Diklabu/api/v1/ -titel "Eine Klasse"
.EXAMPLE
   Set-Course -id 1244 -uri http://localhost:8080/Diklabu/api/v1/ -idlehrer TU
.EXAMPLE
   Set-Course -id 2124 -uri http://localhost:8080/Diklabu/api/v1/ -idkategorie 17
.EXAMPLE
   Set-Course -id 3456 -uri http://localhost:8080/Diklabu/api/v1/ -termine Block_blau
.EXAMPLE
   1234,5678,9876| Set-Course -uri http://localhost:8080/Diklabu/api/v1/ -termine Block_blau
   Weist die Termine der Klassen den Block_blau zu !
.EXAMPLE
   Find-Course -KNAME "FISI13%" | Set-Course -ID_LEHRER TU
   Der Klassenlehrer aller Klassen die mit FISI13 beginnen ist TU

#>
function Set-Course
{
    Param
    (
        # ID der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [int]$id,
        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        # Name der Klasse
        [String]$KNAME,
        # Kürzel (fk) des Klassenlehrers        
        [String]$ID_LEHRER,
        # Titel der Klasse
        [String]$TITEL,
        # Notiz zur Klasse
        [String]$NOTIZ,
        # Termine
        [String]$TERMINE,
        # ID_Kategorie
        [int]$ID_KATEGORIE
    )

    Begin
    {
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;       
    }
    Process
    {
        $klasse=echo "" | Select-Object -Property "ID_LEHRER","KNAME","TITEL","NOTIZ","TERMINE","ID_KATEGORIE"
        if ($ID_LEHRER) {
            $klasse.ID_LEHRER=$ID_LEHRER
        }
        if ($KNAME) {
            $klasse.KNAME=$KNAME
        }
        if ($TITEL) {
            $klasse.TITEL=$TITEL
        }
        if ($NOTIZ) {
            $klasse.NOTIZ=$NOTIZ
        }
        if ($TERMINE) {
            $klasse.TERMINE=$TERMINE
        }
        if ($ID_KATEGORIE -ne 0) {
            $klasse.ID_KATEGORIE=$ID_KATEGORIE
        }
        try {
            $r=Invoke-RestMethod -Method Post -Uri ($uri+"klasse/admin/id/"+$id) -Headers $headers  -Body (ConvertTo-Json $klasse)
            return $r;
        } catch {
            Write-Host "Set-Course: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
}

<#
.Synopsis
   Eine oder mehrere Klasse(n) abfragen
.DESCRIPTION
   Attribute einer oder mehrere Klasse(n) abfragen. Dieses geht auch über eine CSV Datei, die die id's der Klassen beinhaltet
        "id"
        3606
        3603
.EXAMPLE
   Get-Course -id 1245 
.EXAMPLE
   Get-Course -id 1234 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   1234,5678,9876| Get-Course 
.EXAMPLE
   Import-Csv C:\Users\jtutt_000\kids.csv | Get-Course
#>
function Get-Course
{
    Param
    (
        # ID der Klasse
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Position=0)]
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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"klasse/id/"+$id) -Headers $headers 
            return $r;
        } catch {
            Write-Host "Get-Course: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
}

<#
.Synopsis
   Klassen einer Kategorie abfragen
.DESCRIPTION
   Klassen einer Kategorie abfragen
.EXAMPLE
   Get-Courses -id 1 
.EXAMPLE
   Get-Courses -id 2 -uri http://localhost:8080/Diklabu/api/v1/
#>
function Get-Courses
{
    Param
    (
        # ID Kategorie der Klasse
        [Parameter(Position=0)]
        [int]$id_kategorie=-1,

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
            if ($id_kategorie -ne -1) {                
                $r=Invoke-RestMethod -Method Get -Uri ($uri+"klasse/klassen/"+$id_kategorie) -Headers $headers 
            }
            else {
                $r=Invoke-RestMethod -Method Get -Uri ($uri+"noauth/klassen") -Headers $headers 
            }
            return $r;
        } catch {
            Write-Host "Get-Courses: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
}

<#
.Synopsis
   Eine neue Klasse anlegen
.DESCRIPTION
   Legt eine Neue Klasse mit den Attributen an. Auch der Import aus einer CSV Datei
   wird unterstützt, diese CSV Datei kann folgende Einträge haben

   "ID_KATEGORIE","ID_LEHRER","KNAME","NOTIZ","TITEL"
   "0","TU","FISI13A","Tolle Klasse!!","Ein Titel!!"

.EXAMPLE
   New-Course -kname FISI13A 
.EXAMPLE
   New-Course -kname FISI13A -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   New-Course -kname FISI14A -uri http://localhost:8080/Diklabu/api/v1/ -idlehrer TU
.EXAMPLE
   "FISI17A","FISI17B","FISI17C" | New-Course -kname FISI14A -ID_LEHRER TU
.EXAMPLE
   Import-CSV klasse.csv | New-Course 


#>
function New-Course
{
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$KNAME,
        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        # Kürzel (fk) des Klassenlehrers        
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$ID_LEHRER,
        # Titel der Klasse
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$TITEL,
        # Notiz zur Klasse
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$NOTIZ,
        # Termine
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$TERMINE,
        # ID_Kategorie
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$ID_KATEGORIE=-1,
        # id
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$id
    )
     Begin
    {
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
    }  
    Process
    {
        $klasse=echo "" | Select-Object -Property "ID_LEHRER","KNAME","TITEL","NOTIZ","TERMINE","ID_KATEGORIE","id"
        if ($ID_LEHRER) {
          $klasse.ID_LEHRER=$ID_LEHRER
        }
        if ($KNAME) {
          $klasse.KNAME=$KNAME
        }
        if ($TITEL) {
          $klasse.TITEL=$TITEL
        }
        if ($NOTIZ) {
          $klasse.NOTIZ=$NOTIZ
        }
        if ($TERMINE) {
          $klasse.TERMINE=$TERMINE
        }
        if ($ID_KATEGORIE -ne -1) {
          $klasse.ID_KATEGORIE=$ID_KATEGORIE
        }
        if ($id -ne 0) {
          $klasse.id=$id
        }
        try {
            $r=Invoke-RestMethod -Method Post -Uri ($uri+"klasse/admin/") -Headers $headers  -Body (ConvertTo-Json $klasse)                         
            return $r;       
        } catch {
            Write-Host "New-Course: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }   
}

<#
.Synopsis
   Eine oder mehrere Klasse(n) löschen
.DESCRIPTION
   Löscht eine oder mehrere Klasse(n) in der Tabelle KLASSE.Dieses geht auch über eine CSV Datei, die die id's der Klassen beinhaltet
        "id"
        3606
        3603
.EXAMPLE
   Delete-Course -id 1234
.EXAMPLE
   Delete-Course -id 1234 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   1234,5678| Delete-Course 
.EXAMPLE
   Import-CSV datei.csv | Delete-Course 
.EXAMPLE
   Find-Course -KNAME "WPK%lila" | Delete-Course
   Löscht alle WPK Kurse, die mit "lila" enden
#>
function Delete-Course
{
    Param
    (
        # id der Klasse
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Position=0)]
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
            $r=Invoke-RestMethod -Method Delete -Uri ($uri+"klasse/admin/"+$id) -Headers $headers 
            return $r
        } catch {
            Write-Host "Delete-Course: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
    End
    {
    }
}

