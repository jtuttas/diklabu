#####                                   DIKLABU_CWAPROCESS.PSM1
##### Dieses Modul enthält Funktionen, die für die Daten für die cwa Process benötigt werden
##### CWA Process ist das Flowmanagement-Tool für die Schule
#####
<#
.Synopsis
   Erzeugt eine Liste als csv, die eine Zuordnung der Klassen und ihrer Lehrkräfte enthält
.DESCRIPTION
   Liest alle Lehrkräfte aus BBS-Planung ein und ermittelt die Klassen, 
   die sie unterrichten. Dazu wird eine Abfrage an Webuntis gestellt und die beiden
   Datenquellen zusammengeführt. Das Ergebnis wird in einer csv-Datei gespeichert.
.PARAMETER BPBackupRootDir
   Pfad zum Backup-Verzeichnis von BBS-Planung, z.B. "C:\Users\Public\Documents\BBS-Planung\Backup"
.PARAMETER WUlocationClassTeachers
   Parameterdatei für alle Nextcloud VWN Dienste
.PARAMETER WUclassesTeachersDelimiter
   Trennzeichen für die Klassen der Lehrkräfte in Webuntis
.EXAMPLE
   get-NCparameters
.EXAMPLE
   get-NCparameters -file c:\Temp\keys
#>
function new-cwapClassesTeachers{
    [CmdletBinding()]
     Param
     (
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
                [String]$BPBackupRootDir,
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
                [String]$WUlocationClassTeachers,
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
                [String]$WUclassesTeachersDelimiter,
        [Parameter(Mandatory=$true,
                ValueFromPipelineByPropertyName=$true,
                Position=3)]
             [String]$pathCWAteachersClasses, 
        [Parameter(Mandatory=$true,
             ValueFromPipelineByPropertyName=$true,
             Position=4)]
          [String]$allgCsvDelimiter
     )
     Begin{
        $bpTeachers = get-BpTeachers -useDB $false -bpBackupRootDir $BPBackupRootDir
        # get credentials for Untis
        $WUcreds = get-LoginCreds -userKey "WUuser" -passKey "WUpass" -passFileKey "WUpassFile"
          
        $hashClassesTeachers=get-untisClassTeacherTeams -checkHashlistClassesTeachers $true -WUlocationClassTeachers $WUlocationClassTeachers -WUclassesTeachersDelimiter $WUclassesTeachersDelimiter -WUcreds $WUcreds 

        # zu $bpteachers eine Spalte mit dem Namen der Klassen hinzufügen
        $bpTeachers | ForEach-Object {
            $kurz = $_.Kürzel
            $ou=""
            foreach($item in $hashClassesTeachers.GetEnumerator()){
                # Lehrkräfte der aktuellen Klasse ermitteln
                $classTeachers = @()
                $classTeachers = ($item.value).split($WUclassesTeachersDelimiter)
                if ($classTeachers -contains $kurz) {
                    if ( $ou -ne "" ) {
                        $ou+=$WUclassesTeachersDelimiter + $($item.key)
                    } 
                    else {
                        $ou+="$($item.key)"
                    }
                }
            }
            $_ | Add-Member -MemberType NoteProperty -Name "Klassen" -Value $ou
        }
         $bpTeachers|Export-Csv -Path $pathCWAteachersClasses -NoTypeInformation -Delimiter $allgCsvDelimiter
    }
}