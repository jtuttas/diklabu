<#
    VERBEN:
        find ... findet einen oder mehrere Objekte nach Namen. '%' ist WildCard
        get .... findet ein Objekt durch angabe des PK
        set .... ändert Attribute eines Objektes durch angabe des PK
        new .... erzeugt ein neuen Eintrag
        delete . ein Objekt löschen
#>
<#
.Synopsis
   Einen Ausbilder suchen
.DESCRIPTION
   Liefert eine Liste von passenden Ausbilder Objekten zurück
.EXAMPLE
   Find-Instructor -NNAME "%Meyer"
.EXAMPLE
   Find-Instructor -NNAME "%Meyer" -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   "%Schmidt","%Meyer" | Find-Instructor

#>
function Find-Instructor
{
    Param
    (
       
        # Name des Ausbilders
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [String]$NNAME,

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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"ausbilder/find/"+$NNAME) -Headers $headers  
            return $r;
         } catch {
            Write-Host "Find-Instructor: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }

    }
    End
    {
    }
}

<#
.Synopsis
   Einen Ausbilder abfragen
.DESCRIPTION
   Liefert den Ausbilder zur id zurück
.EXAMPLE
   Get-Instructor -ID 1234
.EXAMPLE
   Get-Instructor -ID 1234 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   1234,5678 | Get-Instructor
#>
function Get-Instructor
{
    Param
    (
        # ID des Ausbilders
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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"ausbilder/"+$ID) -Headers $headers  
            return $r;
        } catch {
            Write-Host "Get-Instructor: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
   
}


<#
.Synopsis
   Attribute eines Ausbilders oder mehrerer Ausbilder ändern
.DESCRIPTION
   Ändert diverse Attribute eines Ausbilders. Der Asubilder wird dabei über seine ID ausgewählt
.EXAMPLE
   Set-Instructor -ID 123 -NNAME "Herr Schmidt"
.EXAMPLE
   Set-Instructor -ID 123 -FAX 110 -TELEFON 112
.EXAMPLE
  1234,4567|Set-Instructor -TELEFON 110 -FAX 112
.EXAMPLE
  Find-Instructor -NNAME "Herr Schmidt" |Set-Instructor -TELEFON 110 -FAX 112
.DESCRIPTION
  Weist allen Ausbildern "Herr Schmidt" die angegebene Televon und FAX Nummer zu

#>
function Set-Instructor
{
    Param
    (
       # ID des Ausbilders
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [int]$ID,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        #Name
        [String]$NNAME,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        #Anrede des Ausbilders
        [String]$ANREDE,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        # EMAIL des Ausbilders
        [String]$EMAIL,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        #FAX Nummer des Asubilders
        [String]$FAX,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        #Tel Nummer des Asubilders
        [String]$TELEFON,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        #ID_Betrieb des Ausbilders
        [int]$ID_BETRIEB

    )

    Begin
    {
        $headers=@{}
        $headers["content-Type"]="application/json;charset=iso-8859-1"
        $headers["auth_token"]=$global:auth_token;        
    }
    Process
    {
        $ausbilder=echo "" | Select-Object -Property "NNAME","ANREDE","EMAIL","FAX","ID_BETRIEB","TELEFON"
        $ausbilder.ANREDE=$ANREDE
        $ausbilder.EMAIL=$EMAIL
        $ausbilder.FAX=$FAX
        $ausbilder.ID_BETRIEB=$ID_BETRIEB
        $ausbilder.TELEFON=$TELEFON
        $ausbilder.NNAME=$NNAME       
        try {         
            $r=Invoke-RestMethod -Method Post -Uri ($uri+"ausbilder/admin/"+$ID) -Headers $headers -Body (ConvertTo-Json $ausbilder)
            return $r;
        } catch {
            Write-Host "Set-Instructor: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
}

<#
.Synopsis
   Legt einen oder mehrere neue(n) Ausbilder an
.DESCRIPTION
   Erzeugt einen oder mehrere neue(n) Ausbilder. Als Import kann z.B. eine CSV Datei genutzt werden mit folgenden Einträgen
    "ANREDE","EMAIL","FAX","ID_BETRIEB","NNAME","TELEFON"
    "Herr","tuttas@mmbbs.de","05161/ 98 20 20","4084","Herr Tuttas","05161/ 98 20 12"
    "Herr","tuttas@mmbbs.de","05161/ 98 20 20","4084","Herr Dr. Tuttas","05161/ 98 20 12"
.EXAMPLE
   New-Instructor -NNAME "Herr Schmidt"
.EXAMPLE
   New-Instructor -NNAME "Herr Meyer" -TELEFON 110 -FAX 112 -EMAIL test@test.de
.EXAMPLE
   Import-Csv ausbilder.csv | New-Instructor
#>
function New-Instructor
{
    Param
    ( 
        # Objekt des Ausbilders
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $ausbilder,
        # Name des Ausbilders
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String]$NNAME,
        
        # Adresse des Diklabu Servers
        [String]$uri=$global:server,

        #Anrede des Ausbilders
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$ANREDE,
        # EMAIL des Ausbilders
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$EMAIL,
        #FAX Nummer des Asubilders
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$FAX,
        #Tel Nummer des Asubilders
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$TELEFON,
        #ID_Betrieb des Ausbilders
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$ID_BETRIEB

    )

    Begin
    {
          $headers=@{}
          $headers["content-Type"]="application/json;charset=iso-8859-1"
          $headers["auth_token"]=$global:auth_token;
        
    }
    Process
    {
          $ausbilder=echo "" | Select-Object -Property "NNAME","ANREDE","EMAIL","FAX","ID_BETRIEB","TELEFON"
          $ausbilder.ANREDE=$ANREDE
          $ausbilder.EMAIL=$EMAIL
          $ausbilder.FAX=$FAX
          $ausbilder.ID_BETRIEB=$ID_BETRIEB
          $ausbilder.TELEFON=$TEL
          $ausbilder.NNAME=$NNAME      
          try {        
            $r=Invoke-RestMethod -Method Post -Uri ($uri+"ausbilder/admin/") -Headers $headers -Body (ConvertTo-Json $ausbilder)
            return $r;
          } catch {
              Write-Host "New-Instructor: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
          }
    }
}

<#
.Synopsis
   Einen oder mehrere Ausbilder löschen
.DESCRIPTION
   Löscht einen oder mehrere Ausbilder
.EXAMPLE
   Delete-Instructor -ID 123 
.EXAMPLE
   Delete-Instructor -ID 123 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
  1234,4567|Delete-Instructor 
.EXAMPLE
  Find-Instruktor -NNAME "%Tuttas"|Delete-Instructor 
.DESCRIPTION
   Löscht alle Ausbilder die Tuttas im Namen haben

#>
function Delete-Instructor
{
    Param
    (
        # ID des Ausbilders
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Position=0)]
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
              $r=Invoke-RestMethod -Method Delete -Uri ($uri+"ausbilder/admin/"+$ID) -Headers $headers 
              return $r;
          } catch {
              Write-Host "Delete-Instructor: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
          }
    }
}

