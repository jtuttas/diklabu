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
            return $r;
        } catch {
            Write-Host "Get-Pollresults: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription -ForegroundColor red
        }
    }
   
}
