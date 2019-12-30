Get-ChildItem 'C:\Users\jtutt\Documents\NetBeansProjects\diklabu\Diklabu\PowerShell' | ForEach-Object {
  if ($_.Directory -and $_.Name.Contains("diklabu")) {
        Write-Host "Teste $($_.Name)" -BackgroundColor DarkGreen    
        try {
            & $_.FullName
        }
        catch {
            if ($_.Exception -match "System.ata.OleDb.OleDbConnection") {
                Write-Error "Skipped Fehler: $($_.Exception.Message)"
            }
            else {
                Write-Error "Fehler: $($_.Exception.Message)"
                exit 1
            }
        } 
    }

  
}