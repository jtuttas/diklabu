<#
    VERBEN:
        get .... findet einen Lehrer durch angabe des PK (Kürzel)
        set .... ändert Attribute eines Lehrers durch Angabe des PK (Kürzel)
        new .... erzeugt ein neuen Lehrer
        delete . einen Lehrer löschen

    NOMEN:
        teacher
#>


<#
.Synopsis
   Attribute eines oder mehrerer Lehrer ändern
.DESCRIPTION
   Ändert die Attribute eines oder mehrerer Lehrer
.EXAMPLE
   Set-Teacher -ID TU -EMAIL "jtuttas@gmx.net"
.EXAMPLE
   Set-Teacher -ID TU -NName "Dr. Tuttas" -VNAME "Jörg"
.EXAMPLE
   "TU","BK"| Set-Teacher -VNAME "NN"

#>
function Set-Teacher
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$ID,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server,

        #Nachname des Lehrers
        [String]$NNAME,
        #Vorname des Lehrers
        [String]$VNAME,
        #EMAIL Adresse des Lehrers
        [String]$EMAIL,
        #TELEFON des Lehrers
        [String]$TELEFON,
        [switch]$whatif
    )

    Begin
    {
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
        if (-not $global:auth_token) {
            Write-Error "Sie sind nicht am diklabu angemeldet, versuchen Sie login-diklabu"
            return;
        }
    }
    Process
    {
        $lehrer=echo "" | Select-Object -Property "NNAME","VNAME","TELEFON","EMAIL"
        $lehrer.EMAIL=$null
        $lehrer.TELEFON=$null
        $lehrer.NNAME=$null
        $lehrer.VNAME=$null

        if ($NNAME -and $NNAME.Length -ne 0) {
            $lehrer.NNAME=$NNAME
        }
        if ($VNAME -and $VNAME.Length -ne 0) {
            $lehrer.VNAME=$VNAME
        }
        if ($EMAIL -and $EMAIL.Length -ne 0) {
            $lehrer.EMAIL=$EMAIL
        }        
        if ($TELEFON -and $TELEFON.Length -ne 0) {
            $lehrer.TELEFON=$TELEFON
        }
        try {
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Post -Uri ($uri+"lehrer/admin/id/"+$ID) -Headers $headers -Body (ConvertTo-Json $lehrer)
            }
            Write-Verbose "Ändere die Daten des Lehrer mit der ID $id auf $lehrer"
          return $r;
         } catch {
            Write-Error "Set-Teacher: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }

    }
    End
    {
    }
}


<#
.Synopsis
   Einen odere mehrere Lehrer abfragen
.DESCRIPTION
   Fragt einen oder mehrere Lehrer über ID (Kürzel) ab
.EXAMPLE
   Get-Teacher -ID "TU"
.EXAMPLE
   Get-Teacher -ID "TU" -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   "TU","BK" | Get-Teacher

#>
function Get-Teacher
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [alias("ID_LEHRER")]
        [String]$ID,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server
    )

    Begin
    {
          $headers=@{}
          $headers["content-Type"]="application/json;charset=iso-8859-1"
          $headers["auth_token"]=$global:auth_token;
        if (-not $global:auth_token) {
            Write-Error "Sie sind nicht am diklabu angemeldet, versuchen Sie login-diklabu"
            return;
        }
    }
    Process
    {
        try {
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"lehrer/"+$ID) -Headers $headers 
            Write-Verbose "Abfrage der Daten des Lehrer mit der ID $ID"
            return $r;
        } catch {
            Write-Warning "Get-Teacher: Fehler"
            $log=Login-Diklabu
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"lehrer/"+$ID) -Headers $headers 
            Write-Verbose "Abfrage der Daten des Lehrer mit der ID $ID"
            return $r;
        }
    }
}

<#
.Synopsis
   Alle Lehrer abfragen
.DESCRIPTION
   Fragt alle Lehrer ab
.EXAMPLE
   Get-Teachers 
.EXAMPLE
   Get-Teachers uri http://localhost:8080/Diklabu/api/v1/
#>
function Get-Teachers
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
        try {
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"noauth/lehrer/") -Headers $headers 
            Write-Verbose "Abfrage aller Lehrer"
            return $r;
        } catch {
            Write-Error "Get-Teachers: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }
}


<#
.Synopsis
   Einen neuen oder mehrere neu Lehrer anlegen
.DESCRIPTION
   Erzeugt einen Neuen Lehrer. Bzw. importiert die Betriebe aus einer CSV Datei mit folgenden Einträgen
   "NNAME","VNAME","TELEFON","EMAIL","ID"
.EXAMPLE
   New-Teacher -ID "NM"
.EXAMPLE
   New-Teacher -ID ""NM" -NNAME "Neumann"
.EXAMPLE
   Import-Csv lehrer.csv | New-Teacher

#>
function New-Teacher
{
    [CmdletBinding()]
    Param
    (
        # ID (Kürzel des Lehrers)
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String]$ID,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server,

        #Nachname des Lehrers
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$NNAME,
        #Vorname des Lehrers
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$VNAME,
        # Telefon des Lehrers
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$TELEFON,
        #Email Adresse des Lehrers
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$EMAIL,
        [switch]$whatif

    )

    Begin
    {
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
        if (-not $global:auth_token) {
            Write-Error "Sie sind nicht am diklabu angemeldet, versuchen Sie login-diklabu"
            return;
        }
    }
    Process
    {
        $lehrer=echo "" | Select-Object -Property "id","NNAME","VNAME","TELEFON","EMAIL"
        $lehrer.NNAME=$NNAME
        $lehrer.VNAME=$VNAME
        $lehrer.TELEFON=$TELEFON
        $lehrer.EMAIL=$EMAIL
        $lehrer.id=$ID
        try {
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Post -Uri ($uri+"lehrer/admin/") -Headers $headers -Body (ConvertTo-Json $lehrer)
            }
            Write-Verbose "Lege neuen Lehrer an mit den Daten $lehrer"
          return $r;
        } catch {
            Write-Error "New-Lehrer: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }
   
}
<#
.Synopsis
   Einen oder mehrere Lehrer(e) löschen
.DESCRIPTION
   Löscht einen oder mehrere Lehrer in der Tabelle LEHRER
.EXAMPLE
   Delete-Teacher -ID "NM"
.EXAMPLE
   Delete-Teacher -ID "NM" -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   "NN","NM" | Delete-Teacher

#>
function Delete-Teacher
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$ID,

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
                $r=Invoke-RestMethod -Method Delete -Uri ($uri+"lehrer/admin/"+$ID) -Headers $headers 
            }
            Write-Verbose "Lösche Lehrer mit der ID $ID"
          return $r;
          } catch {
            Write-Error "Delete-Teacher: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }
}

<#
.Synopsis
   Die Lehrer eine Klasse abfragen
.DESCRIPTION
   Fragt die Lehrer einer odere mehrerer KLassen ab
.EXAMPLE
   Get-CourseTeacher -ID 1660
.EXAMPLE
   Get-CourseTeacher -ID 1660 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   1660,1659 | Get-CourseTeacher

#>
function Get-CourseTeacher
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [alias("ID_COURSE")]
        [String]$ID,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server
    )

    Begin
    {
          $headers=@{}
          $headers["content-Type"]="application/json;charset=iso-8859-1"
          $headers["auth_token"]=$global:auth_token;
        if (-not $global:auth_token) {
            Write-Error "Sie sind nicht am diklabu angemeldet, versuchen Sie login-diklabu"
            return;
        }
    }
    Process
    {
        try {
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"klasse/lehrer/"+$ID) -Headers $headers 
            Write-Verbose "Abfrage der Lehrer der Klasse mit der ID $ID"
            return $r;
        } catch {
            Write-Error "Get-CourseTeacher: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }
}

<#
.Synopsis
   Einen Lehrer einer Klasse zuweisen
.DESCRIPTION
   Weist einen Lehrer eine Klasse zu
.EXAMPLE
   Add-CourseTeacher -ID "NM" -ID_COURSE 1660
.EXAMPLE
   Import-Csv lehrer.csv | Add-CourseTeacher

#>
function Add-CourseTeacher
{
    [CmdletBinding()]
    Param
    (
        # ID (Kürzel des Lehrers)
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String]$ID,

        # ID der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [String]$ID_COURSE,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server,

        [switch]$whatif

    )

    Begin
    {
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
        if (-not $global:auth_token) {
            Write-Error "Sie sind nicht am diklabu angemeldet, versuchen Sie login-diklabu"
            return;
        }
    }
    Process
    {
        $lehrer_klasse=echo "" | Select-Object -Property "ID_LEHRER","ID_KLASSE"
        $lehrer_klasse.ID_LEHRER=$ID;
        $lehrer_klasse.ID_KLASSE=$ID_COURSE;
        try {
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Post -Uri ($uri+"klasse/verwaltung/lehrer/add/") -Headers $headers -Body (ConvertTo-Json $lehrer_klasse)
                if ($r.success -eq $false) {
                    Write-Warning $r.msg;
                }
            }
            Write-Verbose "Trage Lehrer mit ID=$ID in die Klasse mit der ID=$ID_COURSE ein!"
          return $r;
        } catch {
            Write-Error "Add-CourseLehrer: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }   
}

<#
.Synopsis
   Einen Lehrer aus einer Klasse entfernen
.DESCRIPTION
   Entfernt einen oder mehrere Lehrer aus einer Klasse
.EXAMPLE
   Remove-CourseTeacher -ID "NM" -ID_COURSE=1660
#>
function Remove-CourseTeacher
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [String]$ID,

        [Parameter(Mandatory=$true,Position=1)]
        [int]$ID_COURSE,

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
                $r=Invoke-RestMethod -Method Delete -Uri ($uri+"klasse/verwaltung/lehrer/"+$ID+"/"+$ID_COURSE) -Headers $headers 
                if ($r.success -eq $false) {
                    Write-Warning $r.msg;
                }

            }
            Write-Verbose "Entferne Lehrer mit der ID $ID aus der Klasse mit der ID=$ID_COURSE"
          return $r;
          } catch {
            Write-Error "Remove-CourseTeacher: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }
}

<#
.Synopsis
   Synchronisert die Lehrer einer Klasse
.DESCRIPTION
   Synchronisiert die Lehrer einer Klasse
.EXAMPLE
   Sync-CourseTeacher -ID "NM","BK" -ID_COURSE=1660
.EXAMPLE
  "NM","BK" | Sync-CourseTeacher -ID_COURSE=1660
#>
function Sync-CourseTeacher
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [String[]]$ID,

        [Parameter(Mandatory=$true,Position=1)]
        [int]$ID_COURSE,

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
        Write-Verbose "Abfrage der Lehrer der KLasse $ID_COURSE"
        $in = Get-CourseTeacher -ID $ID_COURSE
        $ist=@{};
        foreach ($teacher in $in) {
            $ist[$teacher.id]=$teacher;
        }
    }
    Process
    {
        $ID | ForEach-Object {
            if ($ist[$_]) {
                Write-Verbose "Der Lehrer $_ befindet sich bereits im Kurs $ID_COURSE";
                $ist.Remove($_);
            }
            else {
                if (-not $whatif) {
                    $r=Add-CourseTeacher -ID $_ -ID_COURSE $ID_COURSE
                }
            }
        }
    }
    End
    {
        #Write-Verbose "Entferne Lehrer aus der Klasse $ID_COURSE"
        $ist.Keys | % { 
            #"key = $_ , value = " + $ist.Item($_) 
            Write-Verbose "Entferne Lehrer $_ aus der Klasse $ID_COURSE";
            if (-not $whatif) {
                $r=Remove-CourseTeacher -ID $_ -ID_COURSE $ID_COURSE
            }
        }
    }

}
