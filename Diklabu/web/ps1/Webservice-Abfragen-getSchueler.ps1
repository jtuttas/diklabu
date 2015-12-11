# Abfrage des Login Namnes
$pupil = "" | Select-Object -Property name,vorname,klasse,auth
$auth = "" | Select-Object -Property benutzer,kennwort
$auth.benutzer="mmbbs"
$auth.kennwort="geheim"
$pupil.auth=$auth
$pupil.name="Bückmann"
$pupil.vorname="Sascha"
$pupil.klasse="FISI13A"

$s=Invoke-RestMethod -Method Post  -ContentType "application/json; charset=UTF-8" -Uri http://localhost:8080/Diklabu/api/v1/manager/getschueler  -Body (ConvertTo-Json $pupil) 
$s.name=$pupil.name
$s.vorname=$pupil.vorname
$s
