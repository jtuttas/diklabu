<#
.Synopsis
   Importieren der Termindaten in das Klassenbuch
.DESCRIPTION
   Importieren der Termindaten in das Klassenbuch
.EXAMPLE
   Import-Dates -xlsx c:\Temp\Mappe1.xlsx
#>
function Import-Dates
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   Position=0)]
        [String]$xlsx,

        [switch]$whatif=$false,
        [switch]$force=$false
    )

    Begin
    {
        $diklabuDates=Get-Dates

        if (Test-Path $xlsx) {
            $excel = Import-Excel -Path $xlsx
            foreach ($row in $excel) {
                Write-Verbose "Bearbeite Zeile $row"
                switch ($row.Wochentag)
                {
                    'Montag' {
                        $d=New-Date -date (Get-Date ($row.Datum)) -idTermin ($diklabuDates | Where-Object {$_.Name -eq "Montag"}).id 
                        Write-Verbose "Trage ein Montag $($row.Datum) ID=$(($diklabuDates | Where-Object {$_.Name -eq "Montag"}).id)"
                        }
                    'Dienstag' {
                        $d=New-Date -date (Get-Date ($row.Datum)) -idTermin ($diklabuDates | Where-Object {$_.Name -eq "Dienstag"}).id 
                        Write-Verbose "Trage ein Dienstag $($row.Datum) ID=$(($diklabuDates | Where-Object {$_.Name -eq "Dienstag"}).id)"
                        }
                    'Mittwoch' {
                        $d=New-Date -date (Get-Date ($row.Datum)) -idTermin ($diklabuDates | Where-Object {$_.Name -eq "Mittwoch"}).id 
                        Write-Verbose "Trage ein Mittwoch $($row.Datum) ID=$(($diklabuDates | Where-Object {$_.Name -eq "Mittwoch"}).id)"
                        }
                    'Donnerstag' {
                        $d=New-Date -date (Get-Date ($row.Datum)) -idTermin ($diklabuDates | Where-Object {$_.Name -eq "Donnerstag"}).id 
                        Write-Verbose "Trage ein Donnerstag $($row.Datum) ID=$(($diklabuDates | Where-Object {$_.Name -eq "Donnerstag"}).id)"
                        }
                    'Freitag' {
                        $d=New-Date -date (Get-Date ($row.Datum)) -idTermin ($diklabuDates | Where-Object {$_.Name -eq "Freitag"}).id 
                        Write-Verbose "Trage ein Freitag $($row.Datum) ID=$(($diklabuDates | Where-Object {$_.Name -eq "Freitag"}).id)"
                        }
                    'Samstag' {
                        $d=New-Date -date (Get-Date ($row.Datum)) -idTermin ($diklabuDates | Where-Object {$_.Name -eq "Samstag"}).id 
                        Write-Verbose "Trage ein Samstag $($row.Datum) ID=$(($diklabuDates | Where-Object {$_.Name -eq "Samstag"}).id)"
                        }
                    Default {}
                }
                switch ($row.Farbe)
                {
                    'R' {
                        $d=New-Date -date (Get-Date ($row.Datum)) -idTermin ($diklabuDates | Where-Object {$_.Name -eq "Block_rot"}).id 
                        Write-Verbose "Trage ein Block_rot  $($row.Datum) ID=$(($diklabuDates | Where-Object {$_.Name -eq "Block_rot"}).id)"
                        }
                    'G' {
                        $d=New-Date -date (Get-Date ($row.Datum)) -idTermin ($diklabuDates | Where-Object {$_.Name -eq "Block_gelb"}).id 
                        Write-Verbose "Trage ein Block_gelb $($row.Datum) ID=$(($diklabuDates | Where-Object {$_.Name -eq "Block_gelb"}).id)"
                        }
                    'B' {
                        $d=New-Date -date (Get-Date ($row.Datum)) -idTermin ($diklabuDates | Where-Object {$_.Name -eq "Block_blau"}).id 
                        Write-Verbose "Trage ein Block_blau $($row.Datum) ID=$(($diklabuDates | Where-Object {$_.Name -eq "Block_blau"}).id)"
                        }
                    Default {}
                }
            }
        }
        else {
            Write-Error "Kann Excel File $xlsx nicht finden!";
        }
    }
}