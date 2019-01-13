Get-ChildItem 'C:\Users\jtutt\Documents\NetBeansProjects\diklabu\Diklabu\PowerShell' | ForEach-Object {
    if ($_.Directory -and $_.Name.Contains("diklabu")) {
        Write-Host "Teste $($_.Name)" -BackgroundColor DarkGreen    
        try {
            & $_.FullName
        }
        catch {
            Write-Error "Fehler in Zeile $($_.Exception)"
        } 
    }
  
}