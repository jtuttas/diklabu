Write-Host "Die Verbindung zu BBS Planung muss via Connect-BBSPlan hergestellt sein! Die Verbindung zum diklabu muss via Login-Diklabu hergestellt sein!"
#Write-Host "Ferner muss das Powershell Module Resize-Image installiert sein (via Powershell Galery über Install-Module -Name ResizeImageModule"
if(($dest = Read-Host "Pfad zum diklabu Bilderverzeichnis [$home]") -eq ''){$dest=$home}
if(($prefix = Read-Host "Prefix der Bilder (wie im Config.JSON angegeben) [bild]") -eq ''){$prefix="bild"}
$src=Get-BPPupilImages
$src | ForEach-Object {
    $bp=Get-BPPupil -id $_.BBSID
    Write-Host "Lese Bild ID=$($_.BBSID) SCHÜLER_NR=$($bp.BBSID) Pfad=$($_.BILDPFAD)"
    if (-not(Test-Path -Path $_.BILDPFAD)) {
        Write-Warning "SRC Bild $($_.BILDPFAD) nicht gefunden"
    }
    else {
        $i=Get-Item $_.BILDPFAD
        if ($i.Length -eq 0) {
            Write-Warning "Skipped, file size is 0"
        }
        else {
            $p=Get-Pupil -bbsplanid $bp.BBSID
            if (-not $p) {
                Write-Warning "Keinen Schüler mit BBSID=$($_.BBSID) im diklabu gefunden!"
            }
            else {
                $name=$prefix+$p.id+".jpg"
                Write-Host "Schreibe Bild $name in $dest"
                Copy-Item -Path $_.BILDPFAD -Destination "$dest/$name"
                #Resize-Image -InputFile $_.BILDPFAD -OutputFile "$dest/$name" -Width 200 -Height 200 -ProportionalResize $true
            }
        }
    }
}