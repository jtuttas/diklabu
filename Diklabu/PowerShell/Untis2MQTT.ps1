if (Test-Path "$PSScriptRoot/untis.json") {
    $cfg = Get-Content "$PSScriptRoot/untis.json" | ConvertFrom-Json
    if ($cfg.dayOfYear -eq (get-date).DayOfYear) {
        $rooms = Get-Content "$PSScriptRoot/untisRooms.json" | ConvertFrom-Json
        if (Test-Path "$PSScriptRoot/untisData.json") {
            $data = Get-Content "$PSScriptRoot/untisData.json" | ConvertFrom-Json 
        }
        else {
            $data=@()
        }
    }
    else {
        Write-Host "Neuer Tag! Verbindungsaufbau zu Untis" -BackgroundColor DarkGreen
        Login-Untis
        rm "$PSScriptRoot/untisData.json" -ErrorAction SilentlyContinue        
        $rooms = get-UntisRooms
        $rooms | ConvertTo-Json | Set-Content "$PSScriptRoot/untisRooms.json"        
        $data = $rooms | get-UntisTimeTable -elementtype room
        $data | ConvertTo-Json -Depth 6 | Set-Content "$PSScriptRoot/untisData.json"        
        $cfg = "" | Select-Object -Property "dayOfYear"
        $cfg.dayOfYear = (get-Date).DayOfYear
        $cfg | ConvertTo-Json | set-Content "$PSScriptRoot/untis.json"
    }
}
else {
    Write-Host "Keine Konfig! Verbindungsaufbau zu Untis" -BackgroundColor DarkGreen
    Login-Untis
    rm "$PSScriptRoot/untisData.json" -ErrorAction SilentlyContinue            
    $rooms = get-UntisRooms
    $rooms | ConvertTo-Json | Set-Content "$PSScriptRoot/untisRooms.json"        
    $data = $rooms | get-UntisTimeTable -elementtype room
    $data | ConvertTo-Json -Depth 6 | Set-Content "$PSScriptRoot/untisData.json"        
    $cfg = "" | Select-Object -Property "dayOfYear"
    $cfg.dayOfYear = (get-Date).DayOfYear
    $cfg | ConvertTo-Json | set-Content "$PSScriptRoot/untis.json"
}

Write-Host "Verbindungsaufbau zu MQTT Server" -BackgroundColor DarkGreen
Add-Type -Path 'C:\Users\jtutt\OneDrive\bin\NuGet\M2Mqtt.4.3.0.0\lib\net45\M2Mqtt.Net.dll'
$MqttClient = [uPLibrary.Networking.M2Mqtt.MqttClient]("service.joerg-tuttas.de")
#
# Verbinden
$c=$mqttclient.Connect([guid]::NewGuid())

$startTime = ""+(get-Date).Hour
$m=(get-Date).Minute
if ($m -lt 10) {
    $startTime=$startTime+"0"+$m
}
else {
    $startTime=$startTime+$m
}
$startTime=[int]$startTime

Write-Host "Untis StartTime is $startTime" -BackgroundColor DarkGreen
foreach ($room in $rooms) {
    $timetable = $data
    $obj = "" | Select-Object -Property "KNAME","Raum","Fach","TEACHER_ID"
    $obj.KNAME="frei"
    $obj.Raum=$room.name
    $obj.Fach=" ";
    $obj.TEACHER_ID= " ";

    $belegt=$false
    foreach ($time in $data) {
    #$time
     #Write-Host "Teste Raum $($room.id) m. TimeTable $($time.ro[0].id)"
        if ($room.id -eq $time.ro[0].id -and $startTime -ge $time.startTime -and $time.endTime -ge $startTime ) {       
            if ($time.code -ne "cancelled") {
                Write-Host "Von $($time.startTime) bis $($time.endTime): Raum $($room.name) Klasse $($time.kl[0].name) Unterricht $($time.su[0].Name) bei $($time.te[0].name)" -BackgroundColor DarkGray
                $obj.KNAME=$time.kl[0].name
                $obj.Raum=$room.name
                $obj.Fach=$time.su[0].Name
                $obj.TEACHER_ID=$time.te[0].name
                $belegt=$true;
             }
        }
    }
    
    if ($obj.Raum.IndexOf(".") -ne -1) {
        $topic="mmbbs/"+$obj.Raum.Substring(0,$obj.Raum.IndexOf("."))+"/"+$obj.Raum.Substring($obj.Raum.IndexOf(".")+1);
    }
    else {
        $topic="mmbbs/"+$obj.Raum;
    }
    #$topic
    Write-Host "Publish topic ($topic) -> $(ConvertTo-Json $obj -Compress)"
    $payload = ConvertTo-Json $obj
    $r=$MqttClient.Publish("$topic", [System.Text.Encoding]::UTF8.GetBytes($payload),1,$true);    
    
}
$MqttClient.Disconnect()
