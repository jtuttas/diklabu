# key
PARAM($key)
try {
    Publish-Module -NuGetApiKey $key -Path /builds/tuttas/diklabu/Diklabu/PowerShell/diklabu
    exit 0
}
catch {
    Write-Error "Failed:$($_.Exception.Message)"
    exit 1
}
