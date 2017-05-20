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
   Liest die Teamzuordnung als CSV ein und Legt einsprechende Gruppen in der AD (unter Seachbase) an
.DESCRIPTION
   Liest die Teamzuordnung, entweder via Angabe des CSV Files oder Seafile URL, ein und synchronisietrt diese 
   mit den Gruppen in der AD. Die CSV Datei hat dabei folgendes Format:
   
   "Email","FIAE","FISI","SYE","SYKIFK","MBT"
   "tuttas@mmbbs.de",,,"x","x","x"

   Email ist ein Pflichtfeld, neue Spalten werden als globale Gruppen in der AD angelegt. Wird
   eine Spalte gelöscht, so bleibt die Gruppe erhalten. Wird eine Zeile (ein Lehrer) gelöscht,
   so wird auch seine Zuordnung in der Gruppe gelöscht.
.EXAMPLE
   sync-LDAPTeams -url https://seafile.mm-bbs.de/f/5f11890fe8/?raw=1 -searchbase "OU=mmbbs,DC=tuttas,DC=de" -force -Verbose 
   Die freigegebenen CSV Datei unter der o.g. Adresse wird als Quelle genutzt
.EXAMPLE
   Sync-LDAPTeams -csv C:\Temp\Moodle_Teamzuordnung.csv -searchbase "OU=mmbbs,DC=tuttas,DC=de" -force -Verbose 
   Die CSV Datei unter der o.g. Pfad wird als Quelle genutzt
#>
function Sync-LDAPTeams
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
        [String]$searchbase="OU=Schüler,DC=mmbbs,DC=local",
         [switch]$force
    )

    Begin
    {
        $to=Login-LDAP
        if ($csv) {
            if (Test-Path $csv) {
                $g = Import-Csv -Path $csv -Delimiter ","
            }
            else {
                Write-Error "File $csv not found";
                break;
            }
        }
        else {
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
        $tas = getTeamObject($g)
        foreach ($tm in $tas.GetEnumerator()) {
            Write-Host "Synchronisiere Gruppe "$tm.Name -BackgroundColor DarkGreen
            if (-not (Test-LDAPCourse $tm.Name -searchbase $searchbase)) {
                Write-Verbose "Gruppe $($tm.Name) wird angelegt!"
                $in=New-ADGroup -Credential $global:ldapcredentials -Server $global:ldapserver -GroupScope Global -Path $searchbase -Name $tm.Name
            }
            $member=@();
            foreach ($l in $tm.Value) {
                $t = Get-LDAPTeacher -email $l  -Verbose
                if ($t.EMAIL) {
                    $member+=$t
                }
                else {
                    Write-Warning "Kann Lehrer mit EMail $($l) nicht in der AD finden!"
                }
            }
            $member | Sync-LDAPCourseMember -KNAME $tm.Name -searchbase $searchbase -force
        }
    }
}

