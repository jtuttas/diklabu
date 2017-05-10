<#
.Synopsis
   Setzen des DWO Servers
.DESCRIPTION
   Hier wird die URL für den DWO Server gesetzt und im KeyStore gespeichert!
.EXAMPLE
   Set-DWO -url http://service.joerg-tuttas.de:8082/dwoRest/webresources/
#>
function set-DWO
{
    [CmdletBinding()]
    Param
    (
        # URL des DWO Servers
        [Parameter(Mandatory=$true,                   
                   Position=0)]
        $url
    )

    Begin
    {
        Set-Keystore -key dwo -server $url 
    }
}

<#
.Synopsis
   Abteilungen abfragen
.DESCRIPTION
   Fragt die im DWO angelegten Abteilungen ab
.EXAMPLE
   Get-DWODepartments
#>
function Get-DWODepartments
{
    [CmdletBinding()]
    Param
    (
        # Adresse DWO Diklabu Servers
        [String]$uri=$Global:logins["dwo"].location
    )

    Begin
    {
        if (-not $Global:logins["dwo"].location) {
            Write-Error "Es ist kein DWO Server hinterlegt, probieren Sie Set-DWO"
            return;
        }
        try {
            $r=Invoke-RestMethod -Method Get -Uri ($uri+"abteilung")
            Write-Verbose "Abfrage aller Abteilungen"
            return $r;
        } catch {
            Write-Error "Get-DWODepartments: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }
    }
}

<#
.Synopsis
   Berufe einer Abteilung
.DESCRIPTION
   Abfrage der Berufe einer Abteilung
.EXAMPLE
   Get-DWOProfessions -departmentId 1
   Listet alle Berufe auf, die die Abteilung mit der ID 1 ausbildet
.EXAMPLE
   1,2 |Get-DWOProfessions 
   Listet alle Berufe auf, die die Abteilungen mit den IDs 1 und 2 ausbildet
.EXAMPLE
   Get-DWOProfessions -departmentID 1,2
   Listet alle Berufe auf, die die Abteilungen mit den IDs 1 und 2 ausbildet
#>
function Get-DWOProfessions
{
    [CmdletBinding()]
    Param
    (
        # ID der Abteilung
        [Parameter(Position=0,Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
        [Alias("id")]
        [int[]]$departmentID,

        # Adresse DWO Diklabu Servers
        [String]$uri=$Global:logins["dwo"].location
    )

    Begin
    {
        if (-not $Global:logins["dwo"].location) {
            Write-Error "Es ist kein DWO Server hinterlegt, probieren Sie Set-DWO"
            return;
        }
    }
    Process {
        $departmentID | ForEach-Object {
            try {
                $r=Invoke-RestMethod -Method Get -Uri ($uri+"abteilung/"+$_+"/beruf")
                Write-Verbose "Abfrage der Berufe der Abteilungen mit der ID $_"
                return $r;
            } catch {
                Write-Error "Get-DWODepartments: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
            }
        }
    }
}


<#
.Synopsis
   Abfrage der Lernsituationen für einen Beruf
.DESCRIPTION
   Abfrage der Lernsituationen für einen oder mehrere Berufe
.EXAMPLE
   Get-DWOLearningSituations -professionId 1
   Listet alle Lernsituationen auf des Berufes mit der ID 1
.EXAMPLE
   1,2 |Get-DWOLearningSituations 
   Listet alle Lernsituationen auf des Berufes mit den IDs 1 und 2
.EXAMPLE
   Get-DWOLearningSituations -professionId 1,2
   Listet alle Lernsituationen auf des Berufes mit den IDs 1 und 2
#>
function Get-DWOLearningSituations
{
    [CmdletBinding()]
    Param
    (
        # ID des Berufes (Profession)
        [Parameter(Position=0,Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
        [Alias("id")]
        [int[]]$professionID,

        # Adresse DWO Diklabu Servers
        [String]$uri=$Global:logins["dwo"].location
    )

    Begin
    {
        if (-not $Global:logins["dwo"].location) {
            Write-Error "Es ist kein DWO Server hinterlegt, probieren Sie Set-DWO"
            return;
        }
    }
    Process {
        $professionID | ForEach-Object {
            try {
                $r=Invoke-RestMethod -Method Get -Uri ($uri+"beruf/"+$_+"/lernsituation")
                Write-Verbose "Abfrage der Lernsituationen des Berufes mit der ID $_"
                return $r;
            } catch {
                Write-Error "Get-DWOLearningSituations: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
            }
        }
    }
}

<#
.Synopsis
   Abfrage einer Lernsituation
.DESCRIPTION
   Abfrage einer Lernsituation
.EXAMPLE
   Get-DWOLearningSituation -Id 1
   Abfrage der Lernsituationen  mit der ID 1
.EXAMPLE
   1,2 |Get-DWOLearningSituation 
   Listet alle Lernsituationen mit den IDs 1 und 2
.EXAMPLE
   Get-DWOLearningSituation -Id 1,2
   Listet alle Lernsituationen mit den IDs 1 und 2
#>
function Get-DWOLearningSituation
{
    [CmdletBinding()]
    Param
    (
        # ID des Berufes (Profession)
        [Parameter(Position=0,Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
        [int[]]$Id,

        # Adresse DWO Diklabu Servers
        [String]$uri=$Global:logins["dwo"].location
    )

    Begin
    {
        if (-not $Global:logins["dwo"].location) {
            Write-Error "Es ist kein DWO Server hinterlegt, probieren Sie Set-DWO"
            return;
        }
    }
    Process {
        $Id | ForEach-Object {
            try {
                $r=Invoke-RestMethod -Method Get -Uri ($uri+"lernsituation/"+$_)
                Write-Verbose "Abfrage der Lernsituatione mit der ID $_"
                return $r;
            } catch {
                Write-Error "Get-DWOLearningSituation: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
            }
        }
    }
}

