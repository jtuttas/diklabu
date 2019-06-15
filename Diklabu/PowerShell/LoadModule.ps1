[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
Write-Host $PSScriptRoot
Import-Module -Name "$PSScriptRoot/diklabu" -Scope Global