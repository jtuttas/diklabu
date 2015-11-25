param ($dir)
$p=Get-ChildItem -Directory $dir | Select-Object -Property Name,Length
ConvertTo-Json $p