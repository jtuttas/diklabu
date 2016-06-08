<#
    VERBEN:
        get .... 
        set .... 
        new .... 
        delete . 
        add....
        remove ...
        enable
        disable
        list...

    NOMEN:
        poll
        pollquestion
        pollanswer
        pollresults
#>
<#
.Synopsis
   Umfragen abfragen
.DESCRIPTION
   Listet die Umfragen auf
.EXAMPLE
   List-Poll
.EXAMPLE
   List-Poll -uri http://localhost:8080/Diklabu/api/v1/
#>
function List-Poll
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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"umfrage") -Headers $headers 
            return $r;
        } catch {
            Write-Host "List-Poll: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
}

<#
.Synopsis
   Fragen und Antwortsmöglichkeiten einer Umfrage abfragen
.DESCRIPTION
   Liefert die Fragen und die Antworten zu einer Umfrage zurück
.EXAMPLE
   Get-Poll -ID 1
.EXAMPLE
   Get-Poll -ID 2 -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   0,1 | Get-Poll
#>
function Get-Poll
{
    Param
    (
        # ID der umfrage
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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"sauth/umfrage/fragen/"+$ID) -Headers $headers  
            return $r;
        } catch {
            Write-Host "Get-Poll: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
   
}

<#
.Synopsis
   Auswertung einer Umfrage abfragenb
.DESCRIPTION
   Liefert die Anzahl der Antworten für die jeweilige Klasse und der entsprechenden Umfrage
.EXAMPLE
   Get-Pollresults -ID 1 -KNAME FISI14A
.EXAMPLE
   Get-Pollresults -ID 2 -KNAME FISI14A -uri http://localhost:8080/Diklabu/api/v1/
.EXAMPLE
   FISI14A,FISI14% | Get-Poll -ID 1
#>
function Get-Pollresults
{
    Param
    (
        # ID der umfrage
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [int]$ID,

        # Name der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        [string]$KNAME,

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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"umfrage/auswertung/"+$ID+"/"+$KNAME) -Headers $headers  
            foreach ($row in $r) {
                $out = echo "" | Select-Object -Property "frage"
                $out.frage=$row.frage;
                $n=1;
                foreach ($skala in $row.skalen) {
                    $out | Add-Member -NotePropertyName Item$n -NotePropertyValue $skala.name
                    $out | Add-Member -NotePropertyName Value$n -NotePropertyValue $skala.anzahl
                    $n++;
                }
                $out
            }
        } catch {
            Write-Host "Get-Pollresults: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
   
}
<#
.Synopsis
   Legt eine  oder mehrere neue(n) Fragen an
.DESCRIPTION
   Erzeugt eine oder mehrere neue(n) Fragen. Als Import kann z.B. eine CSV Datei genutzt werden mit folgenden Einträgen
    "FRAGE"
    
.EXAMPLE
   New-PollQuestion -FRAGE "Wie fandest Du den Unterricht?"
.EXAMPLE
   Import-Csv fragen.csv | New-PollQuestion
#>
function New-PollQuestion
{
    Param
    ( 
        # Frage
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$frage,
        
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
          $f=echo "" | Select-Object -Property "frage"
          $f.frage=$frage
          try {        
            $r=Invoke-RestMethod -Method Post -Uri ($uri+"umfrage/admin/frage") -Headers $headers -Body (ConvertTo-Json $f)
            return $r;
          } catch {
              Write-Host "New-PollQuestion: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
          }
    }
}

<#
.Synopsis
   Ändert eine  oder mehrere Fragen
.DESCRIPTION
   Ändert eine oder mehrere Fragen. 
    
.EXAMPLE
   Set-PollQuestion  -id 1 -FRAGE "Wie fandest Du den Unterricht?"
#>
function Set-PollQuestion
{
    Param
    ( 
        #ID der Frage
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $ID,
        # Frage
        [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$FRAGE,
        
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
          $f=echo "" | Select-Object -Property "id","frage"
          $f.frage=$FRAGE
          $f.id=$ID
          try {        
            $r=Invoke-RestMethod -Method Put -Uri ($uri+"umfrage/admin/frage") -Headers $headers -Body (ConvertTo-Json $f)
            return $r;
          } catch {
              Write-Host "Set-PollQuestion: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
          }
    }
}
<#
.Synopsis
   Löscht eine  oder mehrere Fragen
.DESCRIPTION
   Löscht eine oder mehrere Fragen. 
    
.EXAMPLE
   delete-PollQuestion  -id 1 
.EXAMPLE
   1,2,3| delete-PollQuestion 
   Löscht die Fragen mit der ID 1 und ID 2 und ID 3

#>
function Delete-PollQuestion
{
    Param
    ( 
        #ID der Frage
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $ID,
        
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
            $r=Invoke-RestMethod -Method Delete -Uri ($uri+"umfrage/admin/frage/"+$ID) -Headers $headers 
            return $r;
          } catch {
              Write-Host "Delete-PollQuestion: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
          }
    }
}
<#
.Synopsis
   Abfrage einer  oder mehrere Fragen
.DESCRIPTION
   Abfrage einer oder mehrere Fragen. 
    
.EXAMPLE
   Get-PollQuestion  -id 1 
.EXAMPLE
   1,2,3| Get-PollQuestion    

#>
function Get-PollQuestion
{
    Param
    ( 
        #ID der Frage
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $ID,
        
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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"umfrage/admin/frage/"+$ID) -Headers $headers 
            return $r;
          } catch {
              Write-Host "Get-PollQuestion: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
          }
    }
}
