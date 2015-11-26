# Abfrage des PS Resrfull Service
$auth = "" | Select-Object -Property benutzer,kennwort
$auth.benutzer="admin"
$auth.kennwort="geheim"
$pscaller = "" | Select-Object -Property script,auth
$pscaller.script="c:\Temp\getchilditem.ps1 c:\temp"
$pscaller.auth=$auth
ConvertTo-Json $pscaller

$s=Invoke-RestMethod -Method Post  -ContentType "application/json; charset=UTF-8" -Uri http://localhost:8080/Diklabu/api/v1/manager/pscaller  -Body (ConvertTo-Json $pscaller) 
$out=ConvertFrom-Json $s.result
$out

