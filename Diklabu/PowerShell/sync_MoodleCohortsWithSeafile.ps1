function getTeamObject() {
    $g=Invoke-WebRequest https://seafile.mm-bbs.de/f/5f11890fe8/?raw=1 | ConvertFrom-Csv
    $teams=@{}
    foreach ($e in $g) {
        $teacher=$e.Email
        $e.psobject.Properties | Where-Object {$_.name -ne "Email"} | ForEach-Object {           
            if ($teams.ContainsKey($_.name) -eq $false) {
                $teams[$_.name]=@();
            }
            if ($_.value -eq "x") {
                $teams[$_.name]+=$teacher;        
            }
        }
    }
    $teams
}
$to=Login-Moodle
$tas = getTeamObject
foreach ($tm in $tas.GetEnumerator()) {
    Write-Host "Synchronisiere Team "$tm.Name -BackgroundColor DarkGreen
    $group= Get-MoodleCohorts | Where-Object {$_.idnumber -eq $tm.Name}
    if (-not $group) {
        Write-Warning "Gruppe $($tm.Name) existiert nicht und wird angelegt"
        $group=New-MoodleCohort -name $tm.Name -idnumber $tm.Name -force
    }
    $tm.Value | Get-MoodleUser -PROPERTYTYPE EMAIL | ForEach-Object {$_.id} | Sync-MoodleCohortMember -cohortid $group.id -force
}