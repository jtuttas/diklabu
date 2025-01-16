
<#
.Synopsis
   Anmelden an Webuntis
.DESCRIPTION
   Anmelden an Webuntis
.EXAMPLE
   login-Untis -url https://borys.webuntis.com/WebUntis/jsonrpc.do?school=MMBbS%20Hannover -credential (Get-Credential Tuttas)

#>
function Login-Untis
{
    [CmdletBinding()]
   
    Param
    (
        # URL des Webuntis  Systems
        [Parameter(Position=0)]
        [String]$url,

        # Credentials f. das Moodle Systems
        [Parameter(Position=1)]
        [PSCredential]$credential

    )

    Begin
    {

        if (-not $url -or -not $credential) {
            if ($global:logins.webuntis) {
                $url=$Global:logins.webuntis.location;
                $password = $Global:logins.webuntis.password | ConvertTo-SecureString -Key $global:keys
                $credential = New-Object System.Management.Automation.PsCredential($Global:logins.webuntis.user,$password)
            }
            else {
                Write-Error "Bitte url und credentials angeben!"
                return;
            }
        }
        $base=$url
        $data=echo "" | Select-Object -Property "id","method","jsonrpc","params"
        $data.id=Get-Random
        $data.method="authenticate"
        $data.jsonrpc="2.0"
        $params = "" | Select-Object -Property "user","password","client"
        $params.client="ps"
        $params.user=$credential.UserName;
        $params.password=$credential.GetNetworkCredential().Password         
        $data.params=$params
        $headers=@{}
        $headers["content-Type"]="application/json"
        
        #$data | ConvertTo-Json
        $r=Invoke-RestMethod -Method POST -Uri $url -Body (ConvertTo-Json $data) -Headers $headers -SessionVariable session
        $global:session = $session
        if ($r.error) {
            Write-Verbose "Login fehlgeschlagen"
            Write-Error $r.error.message;
        }
        else {
            Write-Verbose "Login erfolgreich"
            $global:webuntis=$base
            $global:untistoken=$r.result.sessionId
            $r

        }  
        Set-Keystore -key "webuntis" -server $base -credential $credential       
    }
}


<#
.Synopsis
   Abfrage der Räume
.DESCRIPTION
   Abfrage der Räume
.EXAMPLE
   Get-UntisRooms 
   Abfrage der Räume
#>
function Get-UntisRooms
{
    [CmdletBinding()]
   
    Param
    (
    )

    Begin
    {
        if (-not $global:untistoken) {
            Write-Error "Sie sind nicht an WebUntis angemeldet, veruchen Sie es mit Login-Untis"
            return
        }
        $data=echo "" | Select-Object -Property "id","method","jsonrpc","params"
        $data.id=$Global:untistoken
        $data.method="getRooms"
        $params = @{}
        $data.params=$params
        $data.jsonrpc="2.0"

        #ConvertTo-Json $data

        $headers=@{}
        $headers["content-Type"]="application/json"
        $r=Invoke-RestMethod -Method POST -Uri $($Global:logins.webuntis.location) -Body (ConvertTo-Json $data) -Headers $headers -websession $global:session 
        #$r
        if ($r.error) {
            Write-Error $r.error.message
        }
        else {
            $r.result
        }
        
    }
}

<#
.Synopsis
   Abfrage der Klassen
.DESCRIPTION
   Abfrage der Klassen
.EXAMPLE
   Get-UntisCoures
   Abfrage der Klassen
#>
function Get-UntisCourses
{
    [CmdletBinding()]
   
    Param
    (
    )

    Begin
    {
        if (-not $global:untistoken) {
            Write-Error "Sie sind nicht an WebUntis angemeldet, veruchen Sie es mit Login-Untis"
            return
        }
        $data=echo "" | Select-Object -Property "id","method","jsonrpc","params"
        $data.id=$Global:untistoken
        $data.method="getKlassen"
        $params = @{}
        $data.params=$params
        $data.jsonrpc="2.0"

        #ConvertTo-Json $data

        $headers=@{}
        $headers["content-Type"]="application/json"
        $r=Invoke-RestMethod -Method POST -Uri $($Global:logins.webuntis.location) -Body (ConvertTo-Json $data) -Headers $headers -websession $global:session 
        #$r
        if ($r.error) {
            Write-Error $r.error.message
        }
        else {
            $r.result
        }
        
    }
}

<#
.Synopsis
   Abfrage der Lehrer
.DESCRIPTION
   Abfrage der Lehrer
.EXAMPLE
   Get-UntisTeachers
   Abfrage der Lehrer
#>
function Get-UntisTeachers
{
    [CmdletBinding()]
   
    Param
    (
    )

    Begin
    {
        if (-not $global:untistoken) {
            Write-Error "Sie sind nicht an WebUntis angemeldet, veruchen Sie es mit Login-Untis"
            return
        }


        $headers=@{}
        $headers["content-Type"]="application/json"
        $url=$Global:logins.webuntis.location.Substring(0,$Global:logins.webuntis.location.LastIndexOf("/"))
        $url=$url+"/api/public/timetable/weekly/pageconfig?type=2";
        #Write-Host $url
        $r=Invoke-RestMethod -Method GET -Uri $url -Headers $headers -websession $global:session 
        #$r
        if ($r.error) {
            Write-Error $r.error.message
        }
        else {
            $r.data.elements
        }
        
    }
}


<#
.Synopsis
   Abfrage der Schüler
.DESCRIPTION
   Abfrage der Schüler
.EXAMPLE
   Get-UntisStudents
   Abfrage der Schüler
#>
function Get-UntisStudents
{
    [CmdletBinding()]
   
    Param
    (
    )

    Begin
    {
        if (-not $global:untistoken) {
            Write-Error "Sie sind nicht an WebUntis angemeldet, veruchen Sie es mit Login-Untis"
            return
        }
        $data=echo "" | Select-Object -Property "id","method","jsonrpc","params"
        $data.id=$Global:untistoken
        $data.method="getStudents"
        $params = @{}
        $data.params=$params
        $data.jsonrpc="2.0"

        #ConvertTo-Json $data

        $headers=@{}
        $headers["content-Type"]="application/json"
        $r=Invoke-RestMethod -Method POST -Uri $($Global:logins.webuntis.location) -Body (ConvertTo-Json $data) -Headers $headers -websession $global:session 
        #$r
        if ($r.error) {
            Write-Error $r.error.message
        }
        else {
            $r.result
        }
        
    }
}

<#
.Synopsis
   Abfrage der Fächer
.DESCRIPTION
   Abfrage der Fächer
.EXAMPLE
   Get-UntisSubjects
   Abfrage der Fächer
#>
function Get-UntisSubjects
{
    [CmdletBinding()]
   
    Param
    (
    )

    Begin
    {
        if (-not $global:untistoken) {
            Write-Error "Sie sind nicht an WebUntis angemeldet, veruchen Sie es mit Login-Untis"
            return
        }
        $data=echo "" | Select-Object -Property "id","method","jsonrpc","params"
        $data.id=$Global:untistoken
        $data.method="getSubjects"
        $params = @{}
        $data.params=$params
        $data.jsonrpc="2.0"

        #ConvertTo-Json $data

        $headers=@{}
        $headers["content-Type"]="application/json"
        $r=Invoke-RestMethod -Method POST -Uri $($Global:logins.webuntis.location) -Body (ConvertTo-Json $data) -Headers $headers -websession $global:session 
        #$r
        if ($r.error) {
            Write-Error $r.error.message
        }
        else {
            $r.result
        }
        
    }
}

<#
.Synopsis
   Abfrage der Abteilungen
.DESCRIPTION
   Abfrage der Abteilungen
.EXAMPLE
   Get-UntisDepartments
   Abfrage der Abteilungen
#>
function Get-UntisDepartments
{
    [CmdletBinding()]
   
    Param
    (
    )

    Begin
    {
        if (-not $global:untistoken) {
            Write-Error "Sie sind nicht an WebUntis angemeldet, veruchen Sie es mit Login-Untis"
            return
        }
        $data=echo "" | Select-Object -Property "id","method","jsonrpc","params"
        $data.id=$Global:untistoken
        $data.method="getDepartments"
        $params = @{}
        $data.params=$params
        $data.jsonrpc="2.0"

        #ConvertTo-Json $data

        $headers=@{}
        $headers["content-Type"]="application/json"
        $r=Invoke-RestMethod -Method POST -Uri $($Global:logins.webuntis.location) -Body (ConvertTo-Json $data) -Headers $headers -websession $global:session 
        #$r
        if ($r.error) {
            Write-Error $r.error.message
        }
        else {
            $r.result
        }
        
    }
}

<#
.Synopsis
   Abfrage der Belegung einzelnet Elemente
.DESCRIPTION
   Abfrage der Belegung einzelnet Elemente  (1 = class, 2 = teacher, 3 = subject, 4 = room, 5 = student)
.EXAMPLE
   Get-UntisTimetable -elementType room -id 424
   Abfrage der Belegung des Raumes mit der ID 424 für den heutigen Tag
.EXAMPLE
   Get-UntisTimetable -elementtype student -id 151 -startDate 20171101 -endDate 20171201
   Abfrage des Stundenplans des Schülers mit der id 151 für den gewählten Zeitbereich
.EXAMPLE
   151,152 | Get-UntisTimetable -elementtype student  -startDate 20171101 -endDate 20171201
   Abfrage des Stundenplans der Schülers mit den id's 151 und 152 für den gewählten Zeitbereich
#>
function Get-UntisTimetable
{
    [CmdletBinding()]
   
    Param
    (
        # Elementtype 
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateSet('class','teacher','subject','room','student')]
        [String]$elementtype,

        # ID
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=1)]
        [int]$id ,
        # Start Datum YYYYMMDD (wenn nicht gesetzt, dann wird das aktuelle Datum genommen)
        [String]$startDate,
        # Ende Datum YYYYMMDD (wenn nicht gesetzt, dann wird das aktuelle Datum genommen)
        [String]$endDate
    )

    Begin
    {
        if (-not $global:untistoken) {
            Write-Error "Sie sind nicht an WebUntis angemeldet, veruchen Sie es mit Login-Untis"
            return
        }
    }
    Process {
        $data=echo "" | Select-Object -Property "id","method","jsonrpc","params"
        $data.id=$Global:untistoken
        $data.method="getTimetable"
        $params = "" | Select-Object -Property "options"
        $options = "" | Select-Object -Property "element","showBooking","showInfo","showSubsText","showLsText","showLsNumber","showStudentgroup","klasseFields","roomFields","subjectFields","teacherFields"
        #$options = "" | Select-Object -Property "element","showBooking","showInfo","showSubsText","showLsText","showLsNumber","showStudentgroup"
        $element = "" | Select-Object -Property "id","type"
        if ($startDate) {
            $options | Add-Member -MemberType NoteProperty -Name "startDate" -Value $startDate
            $options | Add-Member -MemberType NoteProperty -Name "endDate" -Value $startDate
        }
        if ($endDate) {
            $options | Add-Member -MemberType NoteProperty -Name "endDate" -Value $endDate -force
        }
        $element.id=$id
        if ($elementtype -eq "class") {
            $element.type="1"
        }
        if ($elementtype -eq "teacher") {
            $element.type="2"
        }
        if ($elementtype -eq "subject") {
            $element.type="3"
        }
        if ($elementtype -eq "room") {
            $element.type="4"
        }
        if ($elementtype -eq "student") {
            $element.type="5"
        }
        $options.element=$element;
        
        $options.showBooking=$true
        $options.showInfo=$true
        $options.showSubsText=$true
        $options.showLsText=$true
        $options.showLsNumber=$true
        $options.showStudentgroup=$true
        $itemArray = @("id", "name", "longname", "externalkey")
        #$itemArray
        $options.klasseFields=$itemArray
        $options.roomFields=$itemArray
        $options.subjectFields=$itemArray
        $options.teacherFields=$itemArray


        $params.options=$options
        $data.params=$params
        $data.jsonrpc="2.0"

        #ConvertTo-Json $data -Depth 3
                
        $headers=@{}
        $headers["content-Type"]="application/json"
        $r=Invoke-RestMethod -Method POST -Uri $($Global:logins.webuntis.location) -Body (ConvertTo-Json $data -Depth 3) -Headers $headers -websession $global:session 
        #$r
        if ($r.error) {
            Write-Error $r.error.message
        }
        else {
            $r.result
        } 
        
    }
}

<#
.Synopsis
   Suchen eines Schülers oder Lehrers
.DESCRIPTION
   Suchen eines Schülers oder Lehrers 
.EXAMPLE
   tisPerson -elementType stunden -sn Tuttas -fn Jörg
   Sucht die ID des Schülers Jörg Tuttas
#>
function Find-UntisPerson
{
    [CmdletBinding()]
   
    Param
    (
        # Elementtype 
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateSet('teacher','student')]
        [String]$elementtype,

        # Surname
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [String]$sn ,
        # Forename
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [String]$fn,
        # Geburtstag
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   Position=3)]
        [int]$dob=0
    )

    Begin
    {
        if (-not $global:untistoken) {
            Write-Error "Sie sind nicht an WebUntis angemeldet, veruchen Sie es mit Login-Untis"
            return
        }
    }
    Process {
        $data=echo "" | Select-Object -Property "id","method","jsonrpc","params"
        $data.id=$Global:untistoken
        $data.method="getPersonId"
        $params = "" | Select-Object -Property "type","sn","fn","dob"
        if ($elementtype -eq "teacher") {
            $params.type="2"
        }
        if ($elementtype -eq "student") {
            $params.type="5"
        }
        $params.sn= $sn
        $params.fn= $fn
        $params.dob=$dob
        $data.params=$params
        $data.jsonrpc="2.0"

        #ConvertTo-Json $data -Depth 3
                
        $headers=@{}
        $headers["content-Type"]="application/json;charset=UTF-8"
        $body = ConvertTo-Json $data -Depth 3
        $r=Invoke-RestMethod -Method POST -Uri $($Global:logins.webuntis.location) -Body $body -Headers $headers -websession $global:session -ContentType "application/json;charset=UTF-8"
        #$r
        if ($r.error) {
            Write-Error $r.error.message
        }
        else {
            $r.result
        } 
        
    }
}


<#
.Synopsis
   Mitglieder einer Klasse anzeigen
.DESCRIPTION
   Mitglieder einer Klasse anzeigen
.EXAMPLE
   Get-UntisCoursemember -id 171 -startDate "2018-10-22" -type class
   Sucht Schüler der Klasse mit der ID 171 am 22.10.2018
.EXAMPLE
   Get-UntisCoursemember -id 125 -startDate "2018-10-25" -type subject
   Sucht Schüler des Kurses mit der ID 171 am 25.10.2018
.EXAMPLE
   Get-UntisCoursemember -id 125 -startDate "2018-10-25","2018-10-18","2018-11-08" -type subject
   Sucht Schüler des Kurses mit der ID 171 am 25.10.2018 (Do. block rot), 18.10.2018 (Do. block gelb) und 8.11.2018 (Do. block blau)
.EXAMPLE
   Get-UntisCourses | Where-Object {$_ -match "FIAE18"} | Get-UntisCoursemember -startDate "2018-10-22","2018-10-15","2018-11-05" -type class 
   Listet alle Schüler des Jahrgangs FIAE18 auf
.EXAMPLE
   Get-UntisSubjects | Where-Object {$_.name -match "-TU"} | Get-UntisCoursemember  -startDate "2018-10-25","2018-10-18","2018-11-08" -type subject
   Listet alle Schüler aus dem WPK-TU auf 
#>
function Get-UntisCoursemember
{
    [CmdletBinding()]
   
    Param
    (
        # ID
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [int]$id,
        # Date
        [Parameter(Mandatory=$true,
                   Position=1)]
        [String[]]$startDate,
        # Type
        [Parameter(Mandatory=$true,
                   Position=2)]
        [ValidateSet('class','subject')]
        [String]$type
    )

    Begin
    {
        if (-not $global:untistoken) {
            Write-Error "Sie sind nicht an WebUntis angemeldet, veruchen Sie es mit Login-Untis"
            return
        }

    }
    Process {
        #ConvertTo-Json $data -Depth 3
        Write-Verbose "---- Process ID($id) type($type) ----"
        $startDate | ForEach-Object {   
            $dateNumber=[int]$_.replace("-","")    
            Write-Verbose "Date = $_"
            $headers=@{}
            $headers["content-Type"]="application/json"
            $url=$Global:logins.webuntis.location.Substring(0,$Global:logins.webuntis.location.LastIndexOf("/"))
            if ($type -eq "class") {
                $reg1=$url+"/api/public/timetable/weekly/data?elementType=1&elementId=$id&date=$_&formatId=3"
            }
            if ($type -eq "subject") {
                $reg1=$url+"/api/public/timetable/weekly/data?elementType=3&elementId=$id&date=$_&formatId=3"

            }
            #$reg1
            try {
                $r=Invoke-WebRequest -Uri $reg1 -websession $global:session 
            }
            catch {
                Login-Untis
                $r=Invoke-WebRequest -Uri $reg1 -websession $global:session 
            }
            Write-Verbose "Status Code is $($r.StatusCode)"
            $obj=ConvertFrom-Json $r.content
            
            if ($obj.isSessionTimeout -eq $true) {
                Write-Error "Session timed out, please login again"
                break;
            }

            $array = $obj.data.result.data.elementPeriods."$id"    
            $matchingLessons=@{}
            foreach ($entry in $array) {
                Write-Verbose "Date is $($entry.date) Studen-Group $($entry.studenGroup)"
                
                if ($entry.date -eq $dateNumber -and $entry.studentGroup) {
                    
                    if ($type -eq "subject") {
                        
                        $matchingLessons[$($entry.studentGroup)]=$entry                        
                    }
                    if ($type -eq "class") {
                        if (-not $entry.studentGroup -and -not $entry.hasPeriodText) {
                            $matchingLessons["$id"]=$entry
                            break;
                        }
                        else {
                            if ($entry.hasPeriodText) {
                                Write-Warning "Klasse mit ID $id am $_ mit Kommentar $($entry.periodText)"
                            }
                            Write-Verbose "Found Stundent Group $($entry.studentGroup) -> skipped!";
                        }
                    }
                }
            }
            
            
            if ($matchingLessons.Count -eq 0) {
                Write-Warning "No matching lesson found!"
            }
            else {
                foreach ($lesson in $matchingLessons.GetEnumerator()) {
                    $lessonID=$lesson.Value.lessonId;
                    $periodID=$lesson.Value.id
                    Write-Verbose "Found LessonID $lessonID and PeriodID $periodID"
                    $url=$Global:logins.webuntis.location.Substring(0,$Global:logins.webuntis.location.LastIndexOf("/"))
                    $url=$url+"/lessonstudentlist.do?lsid="+$lessonID+"&periodId="+$periodID;
                    #$url

                    $r=Invoke-WebRequest $url -websession $global:session 
       
                    if ($r.error) {
                        Write-Error $r.error.message
                    }
                    else {
            
                        ## Extract the tables out of the web request
                        $tables = @($r.ParsedHtml.getElementById("lessonStudentListForm.assignedStudents"))   
                        if ($tables) {
                            $table = $tables[0]
                            $titles = @()
                            $rows = @($table.Rows)
                            $titles += "studentGroup"
                            ## Go through all of the rows in the table
                            foreach($row in $rows)
                            {
                                $cells = @($row.Cells)

                                ## If we've found a table header, remember its titles
                                if($cells[0].tagName -eq "TH")
                                {
                                    $titles = @($cells | % { ("" + $_.InnerText).Trim() })
                                    continue
                                }

                                ## If we haven't found any table headers, make up names "P1", "P2", etc.
                                if(-not $titles)
                                {
                                    $titles = @(1..($cells.Count + 2) | % { "P$_" })
                                }

                                ## Now go through the cells in the the row. For each, try to find the
                                ## title that represents that column and create a hashtable mapping those
                                ## titles to content

                                $resultObject = [Ordered] @{}

                                for($counter = 0; $counter -lt $cells.Count; $counter++)
                                {
                                    $title = $titles[$counter]
                                    if(-not $title) { continue }
                                    $resultObject[$title] = ("" + $cells[$counter].InnerText).Trim()
                                    $resultObject["stundentGroup"]=$lesson.Name
                                }

                                ## And finally cast that hashtable to a PSCustomObject
                                [PSCustomObject] $resultObject
                            }
                        }
                    }
                }
            }
        }        
    }       
}
###                           get-sjNds                               ###
##### JoKe 2025-01-11 ###################################################
<#
.Synopsis
   Gibt Anfangsdatum und Endedatum des im Parameter übergebenen Schuljahres im Format "yyyyMMdd" zurück
.DESCRIPTION
   Gibt Anfangsdatum und Endedatum des im Parameter übergebenen Schuljahres im Format "yyyyMMdd" zurück
   Parameter ist irgendein Datum innerhalb des gesuchten Schuljahres, Parameter hat ebenfalls das Format "yyyyMMdd"
   Falls kein Parameter angegeben wurde, wird das aktuelle Tagesdatum benutzt
   Basisdaten stammen vom 21.8.2023 von https://www.schulferien.org/deutschland/ferien/niedersachsen/
.EXAMPLE
   get-sjNds
.EXAMPLE
   get-sjNds "20250407"
#>
function get-sjNds {
    Param(
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String]$sj = (get-date -Format "yyyyMMdd") # Format "yyyyMMdd"
    )
    Begin{
        # start and end school day of the term
        $sjs = @{
            SJ2324 = @{
                startdate="20230817"
                enddate="20240621"
            }
            SJ2425 = @{
                startdate="20240805"
                enddate="20250702"
            }
            SJ2526 = @{
                startdate="20250814"
                enddate="20260701"
            }
            SJ2627 = @{
                startdate="20260813"
                enddate="20270707"
            }
            SJ2728 = @{
                startdate="20270819"
                enddate="20280719"
            }        
        } # end of schoolterm list
    }
    Process{
        $start ="00000000"
        $end = "00000000"
        foreach ($entry in $sjs.GetEnumerator()){
            if ($sj -in $entry.value['startdate']..$entry.value['enddate']){
                $start = $entry.value['startdate']
                $end = $entry.value['enddate']
            }
        }
        $dates=@{}
        $dates.startdate=$start
        $dates.enddate=$end
        return $dates
    }
}
###                           add-untisDay                               ###
##### JoKe 2025-01-11 ######################################################
<#
.Synopsis
   Addiert einen Tag zum Datum im Übergabeformat yyyyMMdd
.DESCRIPTION
   Addiert einen Tag zum Datum im Übergabeformat yyyyMMdd
   Beispielsweise wird aus "20233112" --> "20240101"
.EXAMPLE
   add-untisDay "20233112"
#>
function add-untisDay {
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]        
        [String]$datestring # Date in diklabu datestring format yyyyMMdd
    )
    $d=[DateTime]::ParseExact($datestring,"yyyyMMdd",$Null)
    $d=$d.AddDays(1)
    return $d.tostring("yyyyMMdd")
} # end function add-untisDay 
####################################### ende add-untisDay ##############################################

#####                                    get-untisClassTeacherTeams                                #####
##### JoKe 2025-01-11 ##################################################################################
<#
.Synopsis
   Baut eine Hashliste mit der Zuordnung Klasse zu Lehrkräfteteam
.DESCRIPTION
   Baut eine Hashliste mit der Zuordnung Klasse zu Lehrkräfteteam mit Daten aus dem aktuellen Webuntis
   Key: Klassenname, Value: Komma separierte Liste mit Lehrkräftekürzeln, z.B. FISI24D: "KE,LE,WE"
   Wenn $checkHashlistClassesTeachers $true gesetzt wird (default ist $false), 
   wird nach einer vorher abgespeicherten Version der Hashliste geschaut und, falls diese vorhanden UND TAGESAKTUELL ist, 
   diese verwendet anstelle der Webuntisdaten. Dieses Verfahren bietet Geschwindigkeitsvorteile 
   gegenüber der Abfrage in Webuntis, nutzt aber evtl. nicht die aktuellen Daten
.EXAMPLE
   get-untisClassTeacherTeams
.EXAMPLE
   get-untisClassTeacherTeams $true
#>
function get-untisClassTeacherTeams{
    Param(
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
            [Boolean]$checkHashlistClassesTeachers = $false, # $true: use stored CSV-file if available and from today
        [Parameter(Mandatory=$true)]
            [string]$WUlocationClassTeachers, 
        [Parameter(Mandatory=$true)]
            [string]$WUclassesTeachersDelimiter,
        [Parameter(Mandatory=$true)]
            [System.Management.Automation.PSCredential]$WUcreds

    )
    Begin{
        $funcName = $MyInvocation.InvocationName # wer bin ich?
     }  
    Process {
        if ($checkHashlistClassesTeachers -and (Test-Path ($WUlocationClassTeachers)) -and ((Get-Item ($WUlocationClassTeachers)).LastWriteTime.Date -eq (Get-Date).Date)) {
            # Hashlist classes-teachers must be used and they are already created and from today
            $hashClassesTeachers = @{}
            $f=Import-Csv $WUlocationClassTeachers
            foreach ($row in $f){$hashClassesTeachers[$row.name]=$row.value}
        }
        else{
            # No check if lists are stored or CSV-file not found --> Login Untis
            $feedbacklogin=login-untis -url https://borys.webuntis.com/WebUntis/jsonrpc.do?school=MMBbS%20Hannover -credential $WUcreds
            write-verbose $feedbacklogin.toString() # damit keine Logininformationen im Klartext in der Konsole erscheinen
            # Alle Lehrkräfte aus dem aktuellen Stundenplan ermitteln
            $alleLuL = Get-UntisTeachers
            # Speicher für Timetable schulweit und über ein Jahr
            $classesTeachersRaw=@()
            
            foreach ($LoL in $alleLuL){
                # Ask Untis to start today

                $year = (get-date).year
                $monthString = ((get-date).Month).tostring()
                if ([int]$monthString -lt 8) {$year-=1} # second half of the school term
                $dateString = $year.toString() + "1231" # we need a valid date within the school term
                $startEndTerm=get-sjNds -sj $dateString
                write-host "$funcName : --$($LoL.name)-- hole Stundenplaneinträge von Webuntis ..."
                $classesTeacherRaw=(Get-UntisTimetable -elementtype teacher -id $LoL.id -startDate $startEndTerm.startDate -endDate $startEndTerm.enddate)  
                $classesTeachersRaw+=$classesTeacherRaw
                Start-Sleep -Milliseconds 100                    
            } # Ende foreach ($LoL in $alleLuL)

            # sort and bind teachers to classes
            Write-Host "$funcName : Sortiere und lösche Duplikate in Hashtabelle Klassen/ Lehrkräfte..."
            $classesTeachers =@{}
            foreach ($entry in $classesTeachersRaw){
                foreach ($class in $entry.kl){

                    # Klasse schon eingetragen?
                    if ($classesTeachers.($class.name) -ne $null){
                        # class already exists
                        foreach ($teacher in $entry.te){
                            # multiple teachers possible (teamteaching)
                            # Lehrkräfte in Array speichern, weil in einer Liste mit Trennzeichen sich 
                            # Suchprobleme ergeben (NO ist in KNO enthalten z.B.)
                            $listContainsTeacher = $false
                            $arrayClassTeachers = @()
                            $arrayClassTeachers = ($classesTeachers.($class.name)).split(",")
                            foreach ($elementOfClassTeachers in $arrayClassTeachers){
                                if ($elementOfClassTeachers -eq $teacher.name){
                                    $listContainsTeacher = $true
                                }
                            }
                            if (!$listContainsTeacher){
                                # teacher not yet associated
                                $classesTeachers.($class.name) += $teacher.name
                            }
                        }
                    }
                    else {
                        # class not in list right now --> create and fill in 1st teacher
                        $classesTeachers.($class.name)=[Array]$entry.te.name
                    }                
                }
            }
            Write-Host "$funcName : Alles sortiert und Duplikate entfernt!"
            Write-Host "$funcName : Baue die Hashtabelle mit Klassen (keys) und Komma separierte Liste mit Lehrkräftekürzeln ..."
            # das oben für die Suche nach bereits eingetragenen Lehrkräften angelegte Array für die Lehrkraftkürzel
            # (Grund z.B.: NO ist Element von KNO und wird dann nicht gefunden) wieder auflösen und als Liste mit
            # Trennzeichen erstellen
            $hashClassesTeachers= @{}
            foreach ($key in $classesTeachers.Keys){
                $hashClassesTeachers[$key] = @($classesTeachers[$key] | where-object {$_ -like '*'}) -join $WUclassesTeachersDelimiter
                
            }

            $hashClassesTeachers.GetEnumerator()| export-csv -noTypeInformation -path $WUlocationClassTeachers -encoding UTF8
        } # end else

        write-host "$funcName : Hashtabelle mit Klassen und Lehrkräften fertig erstellt!"
        return $hashClassesTeachers        
    }  # end Process
} # end function get-untisClassTeacherTeams
