function getTeamObject() {
    $g=Invoke-RestMethod https://spreadsheets.google.com/feeds/list/188sB_q19eaRHv8EDNjqKj14qVOwQb-PfTGHqC9OBfgY/od6/public/basic?alt=json
    $teams=@{}
    foreach ($e in $g.feed.entry) {
        $teacher=$e.title.'$t'
        $t = $e.content.'$t'.Split(",");
        foreach ($te in $t) {
            $te = $te.Trim()
            $te = $te.ToUpper()
            $te = $te.Substring(0,$te.IndexOf(":"));
            if ($teams.ContainsKey($te) -eq $false) {
                $teams[$te]=@();
            }
            $teams[$te]+=$teacher;
        
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
        Write-Warning "Gruppe exitsiert nicht und wird angelegt"
        $group=New-MoodleCohort -name $tm.Name -idnumber $tm.Name -force
    }
    $tm.Value | Get-MoodleUser -PROPERTYTYPE EMAIL | ForEach-Object {$_.id} | Sync-MoodleCohortMember -cohortid $group.id -force
}