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
   Get-Polls
.EXAMPLE
   Get-Polls -uri http://localhost:8080/Diklabu/api/v1/
#>
function Get-Polls
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
            Write-Verbose "Abfragen aller Umfragen"
            return $r;
        } catch {
            Write-Error "Get-Polls: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"umfrage/fragen/"+$ID) -Headers $headers  
            Write-Verbose "Fragen und Antwortskalen der Umfrage mit der ID $ID"
            return $r;
        } catch {
            Write-Error "Get-Poll: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
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
   "FISI15A","FISI14%" | Get-Pollresults -ID 1
.EXAMPLE
   Get-Pollresults -ID 1 -KNAME 'FISI14A;FISI14B'
   Ermittelt die Ergebnisse der Klassen FISI14A und FISI14B
.EXAMPLE
   Get-Pollresults -ID 1 -KNAME 'FISI14%
   Ermittelt die Ergebnisse aller FISI14 Klassen
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
            $Encode = [System.Web.HttpUtility]::UrlEncode($KNAME) 
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"umfrage/auswertung/"+$ID+"/"+$Encode) -Headers $headers  
            Write-Verbose "Auswertung der Umfrage mit der ID $ID für die Klasse $KNAME"
            foreach ($row in $r) {
                $out = echo "" | Select-Object -Property "frage"
                $out.frage=$row.frage;
                $n=1;
                $row.skalen=$row.skalen | Sort-Object -Property id
                foreach ($skala in $row.skalen) {
                    $out | Add-Member -NotePropertyName $skala.name -NotePropertyValue $skala.anzahl
                    #$out | Add-Member -NotePropertyName Value$n -NotePropertyValue $skala.anzahl
                    $n++;
                }
                $out
            }
        } catch {
            Write-Error "Get-Pollresults: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
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
        [String]$uri=$global:server,
        [switch]$whatif

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
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Post -Uri ($uri+"umfrage/admin/frage") -Headers $headers -Body (ConvertTo-Json $f)
            }
            Write-Verbose "Erzeuge neue Frage ($frage)"
            return $r;
          } catch {
              Write-Error "New-PollQuestion: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
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
        [String]$uri=$global:server,
        [switch]$whatif

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
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Put -Uri ($uri+"umfrage/admin/frage") -Headers $headers -Body (ConvertTo-Json $f)
            }
            Write-Verbose "Ändere die Frage mit der ID $ID auf ($FRAGE)"
            return $r;
          } catch {
              Write-Error "Set-PollQuestion: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
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
        [String]$uri=$global:server,
        [switch]$whatif

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
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Delete -Uri ($uri+"umfrage/admin/frage/"+$ID) -Headers $headers 
            }
            Write-Verbose "Lösche die Frage mit der ID $ID"
            return $r;
          } catch {
              Write-Error "Delete-PollQuestion: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
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
            Write-Verbose "Abfrage der Frage mit der ID $ID"
            return $r;
          } catch {
              Write-Error "Get-PollQuestion: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}

<#
.Synopsis
   Abfrage aller Fragen
.DESCRIPTION
   Abfrage aller Fragen
.EXAMPLE
   Get-PollQuestions
#>
function Get-PollQuestions
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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"umfrage/admin/frage") -Headers $headers 
            Write-Verbose "Abfage aller Fragen"
            return $r;
          } catch {
              Write-Error "Get-PollQuestions: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}


<#
.Synopsis
   Legt eine  oder mehrere neue(n) Antworten an
.DESCRIPTION
   Erzeugt eine oder mehrere neue(n) Antworten. Als Import kann z.B. eine CSV Datei genutzt werden mit folgenden Einträgen
    "ANTWORT"
    
.EXAMPLE
   New-PollAnswer -ANTWORT "sehr gut!"
.EXAMPLE
   Import-Csv antworten.csv | New-PollAnswer
#>
function New-PollAnswer
{
    Param
    ( 
        # Antwort
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$ANTWORT,
        
        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [switch]$whatif

    )

    Begin
    {
          $headers=@{}
          $headers["content-Type"]="application/json;charset=iso-8859-1"
          $headers["auth_token"]=$global:auth_token;
        
    }
    Process
    {
          $a=echo "" | Select-Object -Property "name"
          $a.name=$ANTWORT
          try {        
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Post -Uri ($uri+"umfrage/admin/antwort") -Headers $headers -Body (ConvertTo-Json $a)
            }
            Write-Verbose "Erzeuge neue Antwortskale ($ANTWORT)"
            return $r;
          } catch {
              Write-Error "New-PollAnswer: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}

<#
.Synopsis
   Ändert eine  oder mehrere Antworten
.DESCRIPTION
   Ändert eine oder mehrere Antworten. 
    
.EXAMPLE
   Set-PollAnswer  -id 1 -ANTWORT "Sehr gut!"
#>
function Set-PollAnswer
{
    Param
    ( 
        #ID der Antwort
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $ID,
        # Antowrt
        [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$ANTWORT,
        
        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [switch]$whatif

    )

    Begin
    {
          $headers=@{}
          $headers["content-Type"]="application/json;charset=iso-8859-1"
          $headers["auth_token"]=$global:auth_token;
        
    }
    Process
    {
          $a=echo "" | Select-Object -Property "id","name"
          $a.name=$ANTWORT
          $a.id=$ID
          try {        
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Put -Uri ($uri+"umfrage/admin/antwort") -Headers $headers -Body (ConvertTo-Json $a)
            }
            Write-Verbose "Ändere die Antwort mit der ID $ID auf ($ANTWORT)"
            return $r;
          } catch {
              Write-Error "Set-PollAnswer: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}
<#
.Synopsis
   Löscht eine  oder mehrere Antworten
.DESCRIPTION
   Löscht eine oder mehrere Antworten. 
    
.EXAMPLE
   delete-PollAnswer  -id 1 
.EXAMPLE
   1,2,3| delete-PollAnswer
   Löscht die Antworten mit der ID 1 und ID 2 und ID 3

#>
function Delete-PollAnswer
{
    Param
    ( 
        #ID der Antwort
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $ID,
        
        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [switch]$whatif

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
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Delete -Uri ($uri+"umfrage/admin/antwort/"+$ID) -Headers $headers 
            }
            Write-Verbose "Lösche die Antwortskale mit der ID $ID"
            return $r;
          } catch {
              Write-Error "Delete-PollAnswer: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}
<#
.Synopsis
   Abfrage einer  oder mehrere Antworten
.DESCRIPTION
   Abfrage einer oder mehrere Antworten. 
    
.EXAMPLE
   Get-PollAnswer  -id 1 
.EXAMPLE
   1,2,3| Get-PollAnswer

#>
function Get-PollAnswer
{
    Param
    ( 
        #ID der Antwort
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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"umfrage/admin/antwort/"+$ID) -Headers $headers 
            Write-Verbose "Abfrage der Antwortskale mit der ID $ID : Ergebnis: $r"
            return $r;
          } catch {
              Write-Error "Get-PollAnswer: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}

<#
.Synopsis
   Abfrage aller Antworten
.DESCRIPTION
   Abfrage aller Antworten    
.EXAMPLE
   Get-PollAnswers  
#>
function Get-PollAnswers
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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"umfrage/admin/antwort") -Headers $headers 
            Write-Verbose "Abfrage aller Antwortskalen"
            return $r;
          } catch {
              Write-Error "Get-PollAnswers: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}

<#
.Synopsis
   Fügt eine Antwort einer Frage hinzu
.DESCRIPTION
   Fügt eine Antwort einer Frage hinzu    
.EXAMPLE
   Add-PollAnswer -IDFRage 1  -IDAntwort 1
.EXAMPLE
   1,2,3| Add-PollAnswer -IDAntwort 2
   Fügt den Fagen mit der ID 1,2 und 3 die Antwort mit der ID 2 hinzu

#>
function Add-PollAnswer
{
    Param
    ( 
        #IDFrage
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $IDFrage,

        #IDAntwort
        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        $IDAntwort,
        
        
        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [switch]$whatif

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
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Post -Uri ($uri+"umfrage/admin/add/"+$IDFrage+"/"+$IDAntwort) -Headers $headers 
            }
            Write-Verbose "Füge der Frage mit der ID $IDFrage die Antwortskale mit der ID $IDAntwort hinzu!"
            return $r;
          } catch {
              Write-Error "Add-PollAnswer: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}

<#
.Synopsis
   Entfernt eine Antwort aus einer Frage
.DESCRIPTION
   Entfernt eine Antwort aus einer Frage
.EXAMPLE
   Remove-PollAnswer -IDFRage 1  -IDAntwort 1
.EXAMPLE
   1,2,3| Remove-PollAnswer -IDAntwort 2
   Entfernt aus den Fagen mit der ID 1,2 und 3 die Antwort mit der ID 2 

#>
function Remove-PollAnswer
{
    Param
    ( 
        #IDFrage
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $IDFrage,

        #IDAntwort
        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        $IDAntwort,
        
        
        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [switch]$whatif

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
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Post -Uri ($uri+"umfrage/admin/remove/"+$IDFrage+"/"+$IDAntwort) -Headers $headers 
            }
            Write-Verbose "Entferne die Antwortskale $IDAntwort aus der Frage mit der ID $IDFrage"
            return $r;
          } catch {
              Write-Error "Remove-PollAnswer: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}

<#
.Synopsis
   Legt eine neue Umfrage an
.DESCRIPTION
   Erzeugt eine neue Umfrage    
.EXAMPLE
   New-Poll -TITEL "Schülerbefragung 2018"
#>
function New-Poll
{
    Param
    ( 
        # Titel
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$TITEL,
        
        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [switch]$whatif

    )

    Begin
    {
          $headers=@{}
          $headers["content-Type"]="application/json;charset=iso-8859-1"
          $headers["auth_token"]=$global:auth_token;
        
    }
    Process
    {
          $p=echo "" | Select-Object -Property "titel"
          $p.titel=$TITEL
          try {        
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Post -Uri ($uri+"umfrage/admin") -Headers $headers -Body (ConvertTo-Json $p)
            }
            Write-Verbose "Erzeuge einer neue Umfrage mit dem Titel ($TITEL)"
            return $r;
          } catch {
              Write-Error "New-Poll: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}

<#
.Synopsis
   Ändert eine Umfrage
.DESCRIPTION
   Ändert eine Umfrage
    
.EXAMPLE
   Set-Poll  -id 1 -TITEL "Schülerbefragung 2018/19"
#>
function Set-Poll
{
    Param
    ( 
        #ID der Umfrage
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $ID,
        # Titel der Umfage
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$TITEL,
        
        # Aktive Umfage (1=ja)
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$ACTIVE,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [switch]$whatif
    )

    Begin
    {
          $headers=@{}
          $headers["content-Type"]="application/json;charset=iso-8859-1"
          $headers["auth_token"]=$global:auth_token;
        
    }
    Process
    {
          $p=echo "" | Select-Object -Property "id"
          if ($TITEL) {
            $p | Add-Member -NotePropertyName "titel" -NotePropertyValue $TITEL
          }
          $p.id=$ID
          if ($ACTIVE) {
            $p | Add-Member -NotePropertyName "active" -NotePropertyValue $ACTIVE
          }
          try {        
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Put -Uri ($uri+"umfrage/admin") -Headers $headers -Body (ConvertTo-Json $p)
            }
            Write-Verbose "Ändere die Umfrage mit der ID $ID : auf $p"
            return $r;
          } catch {
              Write-Error "Set-Poll: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription
          }
    }
}
<#
.Synopsis
   Löscht eine Umfrage
.DESCRIPTION
   Löscht eine Umfrage
    
.EXAMPLE
   Delete-Poll -id 1 
#>
function Delete-Poll
{
    Param
    ( 
        #ID der Antwort
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $ID,

        [switch]$force=$false,
        
        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [switch]$whatif

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
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Delete -Uri ($uri+"umfrage/admin/"+$ID+"/"+$force) -Headers $headers 
            }
            Write-Verbose "Lösche die Umfrage mit der ID $ID"
            return $r;
          } catch {
              Write-Error "Delete-Poll: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}

<#
.Synopsis
   Fügt eine Frage eine Umfrage hinzu
.DESCRIPTION
   Fügt eine Frage eine Umfrage hinzu
.EXAMPLE
   Add-PollQuestion -IDUmfrage 1  -IDFrage 1
.EXAMPLE
   1,2,3| Add-PollAnswer -IDUmfrage 2
   Fügt den Fagen mit der ID 1,2 und 3 die Umfrage mit der ID 2 hinzu

#>
function Add-PollQuestion
{
    Param
    ( 
        #IDFrage
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $IDFrage,

        #IDAntwort
        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        $IDUmfrage,
        
        
        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [switch]$whatif

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
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Post -Uri ($uri+"umfrage/admin/addUmfrage/"+$IDFrage+"/"+$IDUmfrage) -Headers $headers 
            }
            Write-Verbose "Für die Frage mit der ID $IDFrage der Umfrage mit der ID $IDUmfrage hinzu!"

            return $r;
          } catch {
              Write-Error "Add-PollQuestion: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription
          }
    }
}

<#
.Synopsis
   Entfernt eine Frage aus einer Umfrage
.DESCRIPTION
   Entfernt eine Frage aus einer Umfrage
.EXAMPLE
   Remove-PollQuestion -IDFrage 1  -IDUmfrage 1
.EXAMPLE
   1,2,3| Remove-PollQuestion -IDUmfrage 2
   Entfernt die Fagen mit der ID 1,2 und 3 aus der Umfrage mit der ID 2 

#>
function Remove-PollQuestion
{
    Param
    ( 
        #IDFrage
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $IDFrage,

        #IDUmfrage
        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        $IDUmfrage,
        
        
        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [switch]$whatif

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
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Post -Uri ($uri+"umfrage/admin/removeUmfrage/"+$IDFrage+"/"+$IDUmfrage) -Headers $headers 
            }
            Write-Verbose "Entferne die Frage mit der ID $IDFrage aus der Umfrage mit der ID $IDUmfrage"
            return $r;
          } catch {
              Write-Error "Remove-PollQuestion: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}

<#
.Synopsis
   Legt eine  oder mehrere neue(n) Teilnehmer für einer Umfrage an
.DESCRIPTION
   Erzeugt eine oder mehrere neue(n) Teilnehmer für eine Umfrage
    
.EXAMPLE
   New-PollSubscriber -ID_UMFRAGE 1 -ID 2 -TYPE SCHUELER
.EXAMPLE
  find-Course -KNAME "FISI14A" | Get-Coursemember | ForEach-Object {$_.id} | New-PollSubscriber -ID_UMFRAGE 1 -TYPE SCHÜLER
   Alle Schüler der FISI14A werden zur Umfrage 1 hinzugefügt
#>
function New-PollSubscriber
{
    Param
    ( 
        # Umfrage
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [int]$ID_UMFRAGE,

        # ID-Subscriber
        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        $id,

        # TYPE
        [Parameter(Mandatory=$true,Position=2,ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('SCHÜLER','BETRIEB','LEHRER')]
        [String]$TYPE,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [switch]$whatif
    )

    Begin
    {
          $headers=@{}
          $headers["content-Type"]="application/json;charset=iso-8859-1"
          $headers["auth_token"]=$global:auth_token;
        
    }
    Process
    {
          if ($TYPE -eq "SCHÜLER") {
            $t=echo "" | Select-Object -Property "idUmfrage","idSchueler"            
            $t.idUmfrage=$ID_UMFRAGE
            $t.idSchueler=$id
            Write-Verbose "Erzeuge neuen Schüler Teilnehmer mit ID $id an der Umfrage mit der ID $ID_UMFRAGE ($t)"
          }
          elseif ($TYPE -eq "BETRIEB") {
            $t=echo "" | Select-Object -Property "idUmfrage","idBetrieb"
            $t.idUmfrage=$ID_UMFRAGE
            $t.idBetrieb=$id
            Write-Verbose "Erzeuge neuen Betrieb Teilnehmer mit ID $id an der Umfrage mit der ID $ID_UMFRAGE ($t)"
          }
          elseif ($TYPE -eq "LEHRER") {
            $t=echo "" | Select-Object -Property "idUmfrage","idLehrer"
            $t.idUmfrage=$ID_UMFRAGE
            $t.idLehrer=$id
            Write-Verbose "Erzeuge neuen Lehrer Teilnehmer mit ID $id an der Umfrage mit der ID $ID_UMFRAGE ($t)"
          }
          
          
          try {        
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Post -Uri ($uri+"umfrage/admin/subscriber") -Headers $headers -Body (ConvertTo-Json $t)
            }
            
            return $r;
          } catch {
              Write-Error "New-PollSubscriber: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}

<#
.Synopsis
   Fragt die Teilnehmer an einer Umfrage ab
.DESCRIPTION
   Fragt die Teilnehmer an einer Umfrage ab
    
.EXAMPLE
   Get-PollSubscribers -ID_UMFRAGE 1 
#>
function Get-PollSubscribers
{
    Param
    ( 
        # Umfrage
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String]$ID_UMFRAGE,

        
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
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"umfrage/admin/subscriber/"+$ID_UMFRAGE) -Headers $headers 
            Write-Verbose "Abfrage der Teilnehmer an der Umfrage mit der ID $ID_UMFRAGE"
            return $r;
          } catch {
              Write-Error "Get-PollSubscribers: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription
          }
    }
}

<#
.Synopsis
   Löscht einen Teilnehmer einer Umfrage ab
.DESCRIPTION
   Löscht einen Teilnehmer einer Umfrage ab
    
.EXAMPLE
   Delete-PollSubscriber -KEY abcd
.EXAMPLE
   Get-PollSubscribers -ID_UMFRAGE 1 | ForEach-Object {$_.key} | Delete-PollSubscriber
   Löscht alle Teilnehmer aus der Umfrage 1, die noch keine Antworten abgegeben haben
#>
function Delete-PollSubscriber
{
    Param
    ( 
        # key
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$KEY,

        [switch]$force=$false,
        
        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [switch]$whatif
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
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Delete -Uri ($uri+"umfrage/admin/subscriber/"+$Key+"/"+$force) -Headers $headers 
            }
            Write-Verbose "Lösche Teilnehmer mit KEY ($Key)"
            return $r;
          } catch {
              Write-Error "Delete-PollSubscriber: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}

<#
.Synopsis
   Schickt eine EMail an einen  Teilnehmer der Umfrage
.DESCRIPTION
   Schickt eine EMail an einen Teilnehmer der Umfrage
    
.EXAMPLE
   Invite-PollSubscriber -KEY abcd
.EXAMPLE
   "abcd","cdef" | Invite-PollSubscriber 
.EXAMPLE
   Import-Csv keys.csv | Invite-PollSubscriber 

#>
function Invite-PollSubscriber
{
    Param
    ( 
        # KEY
        
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$KEY,

        
        # Adresse des Diklabu Servers
        [String]$uri=$global:server,
        [switch]$whatif
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
            if (-not $whatif) {
                $r=Invoke-RestMethod -Method Get -Uri ($uri+"umfrage/admin/invite/"+$KEY) -Headers $headers 
            }
            Write-Verbose "Lade Teilnehmer mit Key ($KEY) ein!"
            return $r;
          } catch {
              Write-Error "Invite-PollSubscriber: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
          }
    }
}
