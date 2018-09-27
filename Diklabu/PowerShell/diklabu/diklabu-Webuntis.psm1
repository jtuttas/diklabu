
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
   Find-UntisPerson -elementType stunden -sn Tuttas -fn Jörg
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
        $params.sn=$sn
        $params.fn=$fn
        $params.dob=$dob
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
   Mitglieder einer Klasse anzeigen
.DESCRIPTION
   Mitglieder einer Klasse anzeigen
.EXAMPLE
   Get-UntisCoursemember -id 34
   Sucht Schüler der Klasse mit der ID34
#>
function Get-UntisCoursemember
{
    [CmdletBinding()]
   
    Param
    (
        # Elementtype 
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]$id
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
                
        $headers=@{}
        $headers["content-Type"]="application/json"
        $url=$Global:logins.webuntis.location.Substring(0,$Global:logins.webuntis.location.LastIndexOf("/"))
        $url=$url+"/api/public/timetable/weekly/pageconfig?type=5&filter.klasseOrStudentgroupId=KL$id";
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
