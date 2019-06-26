Write-Host "Die Verbindung zu BBS PLanung muss via Connect-BBSPlan hergestellt sein! Die Verbindung zum diklabu muss via Login-Diklabu hergestellt sein"
if(($dest = Read-Host "Pfad zum diklabu Bilderverzeichnis [$home]") -eq ''){$dest=$home}
if(($prefix = Read-Host "Prefix der Bilder (wie im Config.JSON angegeben) [bild]") -eq ''){$prefix="bild"}
$src=Get-BPPupilImages
$src | ForEach-Object {
    Write-Host "Lese Bild BBSID $($_.BBSID) Pfad $($_.BILDPFAD)"
    if (-not(Test-Path -Path $_.BILDPFAD)) {
        Write-Warning "SRC Bild $($_.BILDPFAD) nicht gefunden"
    }
    else {
        $p=Get-Pupil -bbsplanid $_.BBSID
        if (-not $p) {
            Write-Warning "Keinen Schüler mit BBSID=$($_.BBSID) im diklabu gefunden!"
        }
        else {
            $name=$prefix+$p.id+".jpg"
            Write-Host "Schreibe Bild $name in $dest"
            Copy-Item -Path $_.BILDPFAD -Destination "$dest/$name"
        }
    }
}