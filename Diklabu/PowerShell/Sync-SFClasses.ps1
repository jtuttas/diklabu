<#
.Synopsis
   In Seafile Gruppen anlegen und Schüler und Lehrer dort eintragen 
.DESCRIPTION
   SF Gruppen anlegen und Benutzer (Schüler und Lehrer eintragen)
.EXAMPLE
   Sync-SFClasses -untisexport c:\Temp\untis.csv 
   Anhand des Untis Exporrtes werden die Lehrer zu den Klassen Gruppen hinzugefügt. Die Schüler werden aus den Moodle Cohorts 
   (globale Gruppen) den Klassen Kursen hinzugefügt

   Sync-SFCourses -untisexport C:\Temp\GPU-mmbbs-sj17-18_05082017.csv -force -Verbose -createUsers -searchbase "OU=Schüler,DC=mmbbs,DC=local" -nodelete
#>
function Sync-SFCourses
{
    [CmdletBinding()]
    Param
    (
        # Pfad zur UNTIS CSV Datei
        [Parameter(Position=0)]
        [String]$untisexport,
        [switch]$force,
        [switch]$whatif,
        # Gruppen die nicht in der AD enthalten sind, werden in SF auch nicht gelöscht 
        [switch]$nodelete=$true,
        [string]$searchbase="OU=mmbbs,DC=tuttas,DC=de",
        # Benutzer die in Seafile nicht zu finden sind, werden dort angelegt
        [switch]$createUsers=$false,
        # Wenn createUsers gesetz ist, so ist das hier das default kennwort
        [string]$password="mmbbs"
    )
    Begin
    {
        if ($untisexport) {
            if (Test-Path $untisexport) {
                ."$PSScriptRoot/gpu2AdGroups.ps1"
                $untis = Import-Untis -path $untisexport -prefix ""
            }
            else {
                Write-Error "Konnte die Datei $untisexport nicht finden!"
                return;
            }
        }

        Write-Host "Synchronisiere Gruppen in LDAP mit Gruppen aus SF" -BackgroundColor DarkGreen
        # Synchronisieren der Gruppen aus der AD mit den Gruppen in SF
        #Get-LDAPCourses -searchbase $searchbase | Select-Object -Property KName | Sync-SFGroups -force -nodelete:$nodelete
        
        Write-Host "Synchronisiere Gruppenmitgleider in LDAP mit Gruppenmitgliedern aus SF" -BackgroundColor DarkGreen
        # Synchronieren der Gruppenmitglieder
        #Get-LDAPCourses -searchbase $searchbase| ForEach-Object {Write-Host $_.KName;$kname=$_.KName; Get-LDAPCourseMember -KNAME $_.KName | Sync-SFGroupMember -KName $kname -Verbose -force -createUsers:$createUsers -password:$password}
        
        if ($untis) {
            Write-Host "Synchronisiere Lehrer mit Klassenkursen" -BackgroundColor DarkGreen
            $untis.Keys | % { 
                Write-Verbose "Synchronisiere Lehrer für die Klasse $_"
                #$untis
                # bisherige Mitgieder
                $c=Get-LDAPCourse -KNAME $_ -searchbase $searchbase
                if ($c) {
                    $membermail = Get-SFGroupmember -KName $_ | Where-Object {$_.is_admin -eq $false} | Select-Object -Property email
                    $untis.Item($_) | ForEach-Object {
                        $l=Get-LDAPTeacher -id $_
                        if ($l) {
                            $membermail+=$l.EMAIL;
                        }
                        else {
                            Write-Warning "Kann Lehrer mit ID $_ nicht im LDAP finden!"
                        }
                    }
                    $kname = $_;
                    $membermail | Sync-SFGroupMember -KName $kname -Verbose -force -createUsers:$createUsers -password:$password
                }
                else {
                    Write-Warning "Kann die Klasse $_ nich in der LDAP finden!"
                }               
            }
        }
        
    }
}
Write-Host "Anmeldung an Seafile"
Login-Seafile
Write-Host "Anmeldung am ldap"
Login-LDAP
