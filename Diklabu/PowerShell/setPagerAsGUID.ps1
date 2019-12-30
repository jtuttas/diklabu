Login-LDAP
Get-ADUser -Filter * -Server $global:ldapserver -Credential $global:ldapcredentials | ForEach-Object {
    $p=$_.ObjectGUID;$_ |  Set-ADUser -Server $global:ldapserver -Credential $global:ldapcredentials -Replace @{pager=$p} -Verbose
}