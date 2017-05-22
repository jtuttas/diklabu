function getTeamObject($g) {
    $teams=@{}
    foreach ($e in $g) {
        $teacher=$e.Email
        $e.psobject.Properties | Where-Object {$_.name -ne "Email"} | ForEach-Object {           
            if ($teams.ContainsKey($_.name) -eq $false) {
                $teams[$_.name]=@();
            }
            if ($_.value -eq "x") {
                $teams[$_.name]+=$teacher;        
            }
        }
    }
    $teams
}

<#
.Synopsis
   Liest die Teamzuordnung als CSV ein und Synchronisiert diese mit globalen Gruppen in Moodle
.DESCRIPTION
   Liest die Teamzuordnung, entweder via Angabe des CSV Files oder Seafile URL, ein und synchronisietrt diese 
   mit den globalen Gruppen in Moodle. Die CSV Datei hat dabei folgendes Format:
   
   "Email","FIAE","FISI","SYE","SYKIFK","MBT"
   "tuttas@mmbbs.de",,,"x","x","x"

   Email ist ein Pflichtfeld, neue Spalten in den Teams werden als globale Gruppen in Moodle erzeugt. Wird
   eine Spalte gelöscht, so bleibt die gloable Gruppe erhalten. Wird eine Zeile (ein Lehrer) gelöscht,
   so wird auch seine Zuordnung in den Teams gelöscht.
.EXAMPLE
   sync-moodleTeams -url https://seafile.mm-bbs.de/f/5f11890fe8/?raw=1
   Die freigegebenen CSV Datei unter der o.g. Adresse wird als Quelle genutzt
.EXAMPLE
   sync-moodleTeams -csv $HOME/Teams.csv
   Die CSV Datei unter der o.g. Pfad wird als Quelle genutzt
#>
function Sync-MoodleTeams
{
    [CmdletBinding()]
    Param
    (
        # URL der CSV Datei
        [Parameter(Mandatory=$true,
                   Position=0,ParameterSetName=’seafile‘)]
        $url,

        [Parameter(Mandatory=$true,
                   Position=0,ParameterSetName=’csv‘)]
        $csv,
        [Parameter(Mandatory=$true,
                   Position=0,ParameterSetName=’obj‘)]
        $obj
    )

    Begin
    {
        $to=Login-Moodle
        if ($csv) {
            if (Test-Path $csv) {
                $g = Import-Csv -Path $csv
            }
            else {
                Write-Error "File $csv not found";
                break;
            }
        }
        elseif ($url) {
            try {
                $g=Invoke-WebRequest $url | ConvertFrom-Csv
                if (-not [bool]($g[0].PSobject.Properties.name  -match "Email")) {
                    Write-Error "Notwendiges Feld 'Email' fehlt unter $url";
                    break;
                }            
            }
            catch {
                Write-Error $_.Exception.Message;
                break;
            }
        }
        else {
            $g=$obj
        }
        $tas = getTeamObject($g)

        foreach ($tm in $tas.GetEnumerator()) {
            Write-Host "Synchronisiere Team "$tm.Name -BackgroundColor DarkGreen
            if ($PSBoundParameters['Verbose']) {
                $group= Get-MoodleCohorts -Verbose | Where-Object {$_.idnumber -eq $tm.Name}
            }
            else {
                $group= Get-MoodleCohorts | Where-Object {$_.idnumber -eq $tm.Name}
            }
            
            if (-not $group) {
                Write-Warning "Gruppe $($tm.Name) existiert nicht und wird angelegt"
                $group=New-MoodleCohort -name $tm.Name -idnumber $tm.Name -description "Teamgruppe $($tm.Name)" -force
            }
            if ($PSBoundParameters['Verbose']) {
                $tm.Value | Get-MoodleUser -PROPERTYTYPE EMAIL | ForEach-Object {$_.id} | Sync-MoodleCohortMember -cohortid $group.id -force -Verbose
            }
            else {
                $tm.Value | Get-MoodleUser -PROPERTYTYPE EMAIL | ForEach-Object {$_.id} | Sync-MoodleCohortMember -cohortid $group.id -force
            }
        }
    }
}

