<#
    VERBEN:
        find ... findet einen oder mehrere Betriebe nach Namen. '%' ist WildCard
        get .... findet einen Betrieb durch angabe des PK
        set .... ändert Attribute eines Betriebes durch Angabe des PK
        new .... erzeugt ein neuen Betrieb
        delete . einen Betrieb löschen

    NOMEN:
        company
#>

<#
.Synopsis
   Sucht einen Betrieb nach Namen
.DESCRIPTION
   Sucht einen Betrieb nach dessen Namen. % ist Wildcard
.EXAMPLE
   Find-Company -NAME "xy gmbh"
.EXAMPLE
   "Tel%","Comp%" | Find-Company 
.EXAMPLE
   Import-Csv betriebe.csv | Find-Company 

#>
function Find-Company
{
    Param
    (
        # Name des Betriebes
        
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$NAME,

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
          $tofind=[uri]::EscapeDataString($NAME)
          $r=Invoke-RestMethod -Method Get -Uri ($uri+"betriebe/"+$tofind) -Headers $headers  
          return $r;
         } catch {
            Write-Host "Find-Company: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }   
}


<#
.Synopsis
   Attribute eines oder mehrerer Betriebe ändern
.DESCRIPTION
   Ändert die Attribute eines oder mehrerer Betriebe
.EXAMPLE
   Set-Company -ID 1234 -Name "xy gmbh"
.EXAMPLE
   Set-Company -ID 1234 -Name "xy gmbh" -PLZ 16122 -ORT Hannover
.EXAMPLE
   1234,5678| Set-Company -ORT Hannover
.EXAMPLE
   Find-Company -NAME "Tel%"| Set-Company -ORT Hannover
   Alle Betriebe die mit "Tel" anfangen wird der Ort auf Hannover gesetzt

#>
function Set-Company
{
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [int]$ID,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server,

        #Name des Betriebes
        [String]$NAME,
        #PLZ des Betriebes
        [String]$PLZ,
        #Ort des Betriebes
        [String]$ORT,
        #Straße des Betriebes
        [String]$STRASSE,
        #Hausnummer des Betriebes
        [String]$NR
    )

    Begin
    {
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
    }
    Process
    {
        $betrieb=echo "" | Select-Object -Property "NAME","PLZ","ORT","STRASSE","NR"
        if ($NAME) {
            $betrieb.NAME=$NAME
        }
        if ($PLZ) {
            $betrieb.PLZ=$PLZ
        }
        if ($ORT) {
            $betrieb.ORT=$ORT
        }
        if ($STRASSE) {
            $betrieb.STRASSE=$STRASSE
        }
        if ($NR) {
            $betrieb.NR=$NR
        }
        try {
          $r=Invoke-RestMethod -Method Post -Uri ($uri+"betriebe/admin/id/"+$ID) -Headers $headers -Body (ConvertTo-Json $betrieb)
          return $r;
         } catch {
            Write-Host "Set-Company: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }

    }
    End
    {
    }
}


<#
.Synopsis
   Einen odere mehrere Betriebe abfragen
.DESCRIPTION
   Fragt einen oder mehrere Betriebe über ID ab
.EXAMPLE
   Get-Company -ID 1234
.EXAMPLE
   Get-Company -ID 1234 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   1234,5678 | Get-Company 

#>
function Get-Company
{
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [int]$ID,

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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"betriebe/id/"+$ID) -Headers $headers 
            return $r;
        } catch {
            Write-Host "Get-Company: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
}

<#
.Synopsis
   Alle Betriebe abfragen
.DESCRIPTION
   Fragt alle Betriebe ab
.EXAMPLE
   Get-Companies
.EXAMPLE
   Get-Companies -uri http://localhost:8080/Diklabu/api/v1/

#>
function Get-Companies
{
    Param
    (
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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"betriebe/") -Headers $headers 
            return $r;
        } catch {
            Write-Host "Get-Companies: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
}

<#
.Synopsis
   Einen neuen oder mehrere neu Betrieb(e) anlegen
.DESCRIPTION
   Erzeugt einen Neuen Betrieb. Bzw. importiert die Betriebe aus einer CSV Datei mit folgenden Einträgen
   "NAME","ORT","PLZ","STRASSE"
   "MMBBS GmbH","Hannover","30539","Exoplaza 3"
   "MMBBS AG","Hannover","30539","Exoplaza 4"
.EXAMPLE
   New-Company -NAME "xy gmbh"
.EXAMPLE
   New-Company -NAME "xy gmbh" -plz 16122 -ort Hannover
.EXAMPLE
   Import-Csv betriebe.csv | New-Company 

#>
function New-Company
{
    Param
    (
        # Name des Betriebes
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String]$NAME,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server,

        #PLZ des Betriebes
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$PLZ,
        #Ort des Betriebes
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$ORT,
        #Straße des Betriebes
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$STRASSE,
        #Hausnummer des Betriebes
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$NR,

        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [int]$ID

    )

    Begin
    {
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;
    }
    Process
    {
        $betrieb=echo "" | Select-Object -Property "NAME","PLZ","ORT","STRASSE","NR","ID"
        if ($NAME) {
          $betrieb.NAME=$NAME
          }
        if ($PLZ) {
          $betrieb.PLZ=$PLZ
          }
        if ($ORT) {
          $betrieb.ORT=$ORT
          }
        if ($STRASSE) {
          $betrieb.STRASSE=$STRASSE
          }
        if ($NR) {
          $betrieb.NR=$NR
        }
        if ($ID) {
          $betrieb.ID=$ID
          }
        try {
          $r=Invoke-RestMethod -Method Post -Uri ($uri+"betriebe/admin/") -Headers $headers -Body (ConvertTo-Json $betrieb)
          return $r;
        } catch {
            Write-Host "New-Company: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
   
}
<#
.Synopsis
   Einen oder mehrere Betrieb(e) löschen
.DESCRIPTION
   Löscht einen oder mehrere Betriebe in der Tabelle BETRIEBE 
.EXAMPLE
   Delete-Company -ID 1234
.EXAMPLE
   Delete-Company -ID 1234 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   1234,5678 | Delete-Company 
.EXAMPLE
   find-company -NAME "Tel%" | Delete-Company 
   Löscht alle Betriebe die mit "Tel" anfangen

#>
function Delete-Company
{
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [int]$ID,

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
          $r=Invoke-RestMethod -Method Delete -Uri ($uri+"betriebe/admin/"+$ID) -Headers $headers 
          return $r;
          } catch {
            Write-Host "Delete-Company: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
}
