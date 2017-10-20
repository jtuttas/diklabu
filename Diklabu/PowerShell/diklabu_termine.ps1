
<#
.Synopsis
   Einen neuen Termin erzeugen
.DESCRIPTION
   Einen neuen Termin erzeugen
.EXAMPLE
   New-Date -ID 140 -sqldate "2017-10-10"
   Erzeugt eine neuen Termin f. die TerminCategorie 140
.EXAMPLE
   "2017-10-10","2017-10-11" | New-Date -ID 140
   Erzeugt die neuen Termin für die Termincategorie 140
.EXAMPLE
   New-Date -ID 140 -date (get-date)
   Erzeugt die neuen Termin des aktuellen für die Termincategorie 140

#>
function New-Date
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParametersetName='sql')]
        [String]$sqldate,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParametersetName='obj')]
        [DateTime]$date,

        [Parameter(Mandatory=$true,Position=1)]
        [int]$idTermin,

        # Adresse des Diklabu Servers
        [String]$uri=$global:server,

        [switch]$whatif=$false

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
        $termin=echo "" | Select-Object -Property "ID_TERMIN","DATUM"
        $termin.ID_TERMIN=$idTermin
        if ($date) {
            $termin.DATUM=(Get-Date $date -UFormat "%Y-%m-%d")+"T00:00:00"
        }
        else {
            $termin.DATUM=$sqldate+"T00:00:00" 
        }

        try {
          if (-not $whatif) {
            $r=Invoke-RestMethod -Method Post -Uri ($uri+"termin") -Headers $headers -Body (ConvertTo-Json $termin)
          }
          Write-Verbose "Trage den Termin $termin für die Kategorie $idTermin ein"
          return $r;
         } catch {
            Write-Error "New-Date: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
        }

    }
    End
    {
    }
}
