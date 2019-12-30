<# 
ACHTUNG im Produktivsystem zunächst erst einmal ein den gekennzeichneten Stellen
das -whatif Flag setzen
#>


Login-LDAP
Login-Moodle
Get-ADUser -Filter * -Server $global:ldapserver -Credential $global:ldapcredentials -Properties Pager,Mail | ForEach-Object {
    $u=Get-MoodleUser -property $_.Pager -PROPERTYTYPE IDNUMBER
    if (-not $u) {
        Write-Host "Der Benutzer $($_.Name) war noch nie bei Moodle angemeldet" -BackgroundColor DarkGray
    }
    else {
        if ($u.length -ge 2) {
            Write-Warning "Achtung den Benutzer mit der ID $($_.Pager) gibt es mehrmals, lösche die neueren Benutzer"
            for ($i=1;$i -lt $u.length ;$i++) {
                Write-Warning " +-- Lösche Benutzer $($u[$i].username)"
                # WHATIF
                Delete-MoodleUser -moodleid $u[$i].id -Verbose
            }
            $u=$u[0];
        }
        if ($_.Name -ne $u.username -or $_.Mail -ne $u.email -or $_.GivenName -ne $u.firstname -or $_.Surname -ne $u.lastname) {
            [String]$username=$_.NAME
            $username=$username.ToLower()
            Write-Warning "Die Attribute des Benutzers $($_.Name) mit MoodleID $($u.id) unterscheiden sich und werden angepasst! Benutzername=$username Email=$($_.Mail)"
            # WHATIF
            Set-MoodleUser -moodleid $u.id -username $username -email $_.Mail -firstname $_.GivenName -lastname $_.Surname  -Verbose 
        }
        else {
            Write-Host "Daten des Benutzers $($_.Name) identisch mit Moodle Daten" -BackgroundColor DarkGreen
        }
    }
}