<#
    Schüler auf Abgang setzten, die CSV Datei enthält folgende Einträge
    "NNAME","VNAME","GEBDAT"
#>
Import-Csv C:\Users\jtutt_000\Temp\abgänger.csv | ForEach-Object {Search-Pupil -VNAMENNAMEGEBDAT $($_.VNAME+$_.NNAME+$_.GEBDAT) -LDist 3} | Set-Pupil -ABGANG "J"