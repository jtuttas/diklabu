<#
Dieses Skript verucht alle Schülerinnen und Schülern in der AD zu finden (anhand vom Account Name), wenn es einen
Schüler gefunden hat, wird dessen Pager Nummer auf die Klassenbuch ID des Schülers gestezt!
#>

Get-Courses | Where-Object {$_.idKategorie -eq 0} | foreach-Object {[String]$KNAME=$_.KNAME;Get-Coursemember -ID $_.ID} | ForEach-Object {
    #[String]$acc = "$KNAME.$([String]$_.VNAME.SubString(0,1))$([String]$_.NNAME)*"
    [String]$acc = "$KNAME.$([String]$_.NNAME)"
    $acc=$acc.Substring(0,$acc.Length-1)+"*"
    $acc=$acc.ToLower();
    $acc=$acc.Trim();
    $acc=$acc.Replace(" ","");      
    $acc=$acc.Replace("-","");      
    $acc=$acc.Replace("ä","ae");
    $acc=$acc.Replace("ö","oe");
    $acc=$acc.Replace("ü","ue");
    $acc=$acc.Replace("ß","ss");
    if ($acc.Length -gt 16) {
        $acc=$acc.Substring(0,15);
        $acc=$acc+"*";
    }
    Write-Host "Suche: $($acc)" -BackgroundColor DarkGreen
    $u=Get-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Filter {SamAccountName -like $acc} -Properties EmailAddress,GivenName,Surname,Pager -SearchBase "OU=Schüler,DC=mmbbs,DC=local"
    if ($u) {
        if ($u.Count -gt 1) {
            Write-Host "Mehr als einen Schüler $acc in der AD gefunden" -ForegroundColor red
        }
        else {
            Write-Host "Setze für $acc die ID $($_.ID)" -ForegroundColor Green
            $u | Set-ADUser -Credential $global:ldapcredentials -Server $global:ldapserver -Replace @{Pager=$_.ID}
        }
    }
    else {
        Write-Host "Schüler $acc nicht in der AD gefunden" -ForegroundColor Yellow
    }
    break;
}