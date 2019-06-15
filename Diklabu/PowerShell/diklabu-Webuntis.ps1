
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
            $options | Add-Member -MemberType NoteProperty -Name "endDate" -Value $endDate
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
            $r=Invoke-WebRequest -Uri $reg1 -websession $global:session 
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
