<#
.Synopsis
   Abfrage der Kurse aus einem Untis Export
.DESCRIPTION
   Abfrage der Kurse aus einem Untis Export, dieses muss folgende Spaltenbezeichnungen enthalten
   Unr .... Untis ID
   klasse . Klassenbezeichnung
   fach ... Fach oder Kursbezeichnung
   lol .... Kürzel des Lehrers
.EXAMPLE
   get-UntisCourses -csv="test.csv" -Delimiter=";"
#>
function Get-UntisCourses
{
    [CmdletBinding()]
    [OutputType([object[]])]
    Param
    (
        # CSV Datei
        [Parameter(Mandatory=$true,
                   Position=0)]
        $csv,

        [Parameter(Position=1)]
        [String]$Delimiter


    )

    Begin
    {
        $courses = @{}
        try {
            $csv = Get-Content $csv | ConvertFrom-Csv -Delimiter ";"
        }
        catch {
            Write-Error "Konnte die CSV Datei $csv nicht finden"
        }
        foreach ($line in $csv) {
            if (-not $courses[[String]$line.klasse]) {
                $courses[[String]$line.klasse]=$line.klasse
            }
        }
        $klassen = @();
        foreach ($co in $courses.Values) {
            $c="" | Select-Object -Property KNAME
            $c.KNAME = $co
            $c
            $klassen+=$c
        }
        return $klassen
    }
    End
    {
    }
}

<#
.Synopsis
   Abfrage der Mitgliedschaft in einer Klasse
.DESCRIPTION
   Abfrage der Mitgliedschaft in einer Klasse aus einem Untis Export, dieses muss folgende Spaltenbezeichnungen enthalten
   Unr .... Untis ID
   klasse . Klassenbezeichnung
   fach ... Fach oder Kursbezeichnung
   lol .... Kürzel des Lehrers
.EXAMPLE
   get-UntisCoursemember -csv="test.csv" -Delimiter=";" -KNAME "FISI14A"
   Liest die Lehrer aus, die in der Klasse FISI14A unterricht haben
.EXAMPLE
   "FISI14A"|FISI14B" | get-UntisCoursemember -csv="test.csv" -Delimiter=";" 
   Liest die Lehrer aus, die in der Klasse FISI14A und FISI14B unterricht haben
#>
function Get-UntisCoursemeber
{
    [CmdletBinding()]
    [OutputType([object[]])]
    Param
    (
        # CSV Datei
        [Parameter(Mandatory=$true,
                   Position=0)]
        $csv,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeLine=$true,
                   Position=1)]
        $KNAME,

        [Parameter(Position=2)]
        [String]$Delimiter


    )

    Begin
    {
        $courses = @{}
        try {
            $csv = Get-Content $csv | ConvertFrom-Csv -Delimiter ";"
        }
        catch {
            Write-Error "Konnte die CSV Datei $csv nicht finden"
        }
        foreach ($line in $csv) {
            if (-not $courses[[String]$line.klasse]) {
                $courses[[String]$line.klasse]=$line.klasse
            }
        }

    }
    Process
    {
        if ($KNAME.KNAME) {
            $KNAME=$KNAME.KNAME
        }
        Write-Verbose "Suche Mitgliedschaften in der Klasse $KNAME"
        foreach ($line in $csv) {
            if ($KNAME -eq $line.klasse) {
                $out = "" | Select-Object -Property KNAME,ID,Fach
                $out.KNAME = $line.klasse;
                $out.ID = $line.lol;
                $out.Fach = $line.fach
                $out
            }
        }        
    }
    End
    {
    }
}