function getTeamObject($g) {
    $teams=@{}
    foreach ($e in $g) {
        [String]$teacher=$e.Email
        $teacher=$teacher.Replace(" ","");
        $e.psobject.Properties | Where-Object {$_.name -ne "Email"} | ForEach-Object {   
            [String]$name=$_.name
            $name=$name.Replace(" ","");
            if ($teams.ContainsKey($name) -eq $false) {
                $teams[$name]=@();
            }
            if ($_.value -match "x") {
                $teams[$name]+=$teacher;        
            }
        }
    }
    $teams
}

<#
.Synopsis
   Liest die Teamzuordnung als CSV oder Objektmodell ein und Legt einsprechende Gruppen in der AD (unter Seachbase) an
.DESCRIPTION
   Liest die Teamzuordnung, entweder via Angabe des CSV Files oder Seafile URL, ein und synchronisietrt diese 
   mit den Gruppen in der AD. Die CSV Datei hat dabei folgendes Format:
   
   Email;FIAE;FISI;SYE;SYKIFK;MBT
   tuttas@mmbbs.de;;;x,x,x

   Email ist ein Pflichtfeld, neue Spalten werden als globale Gruppen in der AD angelegt. Wird
   eine Spalte gelöscht, so bleibt die Gruppe erhalten. Wird eine Zeile (ein Lehrer) gelöscht,
   so wird auch seine Zuordnung in der Gruppe gelöscht.

.EXAMPLE
  sync-LDAPTeams -url "https://multimediabbshannover-my.sharepoint.com/personal/tuttas_mmbbs_de/_layouts/15/download.aspx?docid=123&authkey=456" -searchbase "OU=lehrerg,OU=mmbbs,DC=tuttas,DC=de" -Verbose -force  
  Die freigegebenen CSV Datei unter der o.g. Adresse wird als Quelle genutzt
.EXAMPLE
   Sync-LDAPTeams -csv C:\Temp\Moodle_Teamzuordnung.csv -searchbase "OU=mmbbs,DC=tuttas,DC=de" -force -Verbose 
   Die CSV Datei unter der o.g. Pfad wird als Quelle genutzt
.EXAMPLE
    Sync-LDAPTeams -obj $obj -Verbose -force -searchbase "OU=lehrerg,OU=mmbbs,DC=tuttas,DC=de"
    $obj ist eine Objekt wie aus einem CSV entstanden, so können auch andere Formate wie xlsx gelesen werden und
    dem CMDlet zugeführt werden:

    Invoke-WebRequest -Uri "https://multimediabbshannover-my.sharepoint.com/personal/tuttas_mmbbs_de/_layouts/15/download.aspx?docid=123&authkey=789" -OutFile "$env:TMP\teams.xlsx"
    $obj=Import-Excel "$env:TMP\teams.xlsx"
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
        [Parameter(Mandatory=$true,
                   Position=0,ParameterSetName=’obj‘)]
        $obj,
        [Parameter(Mandatory=$true,
                   Position=0,ParameterSetName=’map‘)]
        [System.Collections.Hashtable]$map,
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
        elseif ($url) {
            try {
                $g=Invoke-WebRequest $url | ConvertFrom-Csv -Delimiter ";" 
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
        elseif ($obj) {
            $g=$obj;
        }
        if ($map) {
            $tas=$map

        }
        else {
            $tas = getTeamObject($g)
        }
        foreach ($tm in $tas.GetEnumerator()) {
            Write-Host "Synchronisiere Gruppe ($($tm.Name))" -BackgroundColor DarkGreen
            if (-not (Test-LDAPCourse $tm.Name -searchbase $searchbase)) {
                Write-Verbose "Gruppe $($tm.Name) wird angelegt!"
                [String]$gname=$tm.Name
                $in=New-ADGroup -Credential $global:ldapcredentials -Server $global:ldapserver -GroupScope Global -Path $searchbase -Name $gname -OtherAttributes @{'Mail'="$gname@mm-bbs.de"} `
            }
            $member=@();
            foreach ($l in $tm.Value) {
                if ($map) {
                    if ($l -ne "") {
                        $t = Get-LDAPTeacher -id $l  -Verbose 
                        if ($t.EMAIL) {
                            $member+=$t
                        }
                        else {
                            Write-Warning "Kann Lehrer mit ID $($l) nicht in der AD finden!"
                        }
                    }
                }
                else {
                    $t = Get-LDAPTeacher -email $l  -Verbose 
                    if ($t.EMAIL) {
                        $member+=$t
                    }
                    else {
                        Write-Warning "Kann Lehrer mit EMail $($l) nicht in der AD finden!"
                    }
                }
            }
            if ($member) {
                $member | Sync-LDAPCourseMember -KNAME $tm.Name -searchbase $searchbase -force  
            }
        }
        Write-Host "Lösche Gruppen die nicht verwendet werden unter $searchbase" -BackgroundColor DarkGreen
        $in = Get-LDAPCourses -searchbase $searchbase 

        $ist=@{}
        foreach ($i in $in) {
            $ist[$i.KName]=$i
        }
        foreach ($tm in $tas.GetEnumerator()) {
            $ist.Remove($tm.Name);
        }
        $ist.Values | ForEach-Object {
            if ($_.DistinguishedName -ne $null) {
                if (-not $force) {
                    $q = Read-Host "Soll die Gruppe $($_.KName) gelöscht werden? (J/N)"
                    if ($q -eq "J") {
                        Write-Verbose "Lösche die Gruppe ($($_.KName))"
                        $d=Remove-ADGroup -Server $global:ldapserver -Credential $global:ldapcredentials -Identity $_.DistinguishedName -Confirm:$false
                    }
                }
                else {
                    Write-Verbose "Lösche die Gruppe ($($_.KName))"
                    $d=Remove-ADGroup -Server $global:ldapserver -Credential $global:ldapcredentials -Identity $_.DistinguishedName -Confirm:$false
                }
            }
        }
    }
}
