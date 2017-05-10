function countZeilen($pfad) {
Get-ChildItem -Recurse -Path $pfad | Where-Object {$_.Extension -eq ".java" -or $_.Extension -eq ".js" -or $_.Extension -eq ".html" -or $_.Extension -eq ".ps1"} |
    ForEach-Object {
        $out="" | Select-Object -Property Verzeichnis,Name,Zeilen
        $out.Verzeichnis = $_.DirectoryName
        $out.Name=$_.Name
        $content = Get-Content $_.FullName
        $out.Zeilen=$content.Length
        $out
    }
}