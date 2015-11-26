param ($d="c:\")
$p=Get-ChildItem $d| Select-Object -Property Name,Length
ConvertTo-Json $p -Compress 