<# Synchronisation der Schüler aller Klassen gegen die AD und Übernahme der EMail Adresse und ggf. Ändern von
   Vor- und Nachnamen
#>

$global:min=999;

function search-User {
    param(
        $users,
        $tofind,
        $lew
    )
    
    if ($users.length -eq 0) {
        return $null
    }
    $global:min=999;
    $found=$users[0];
    foreach ($user in $users) {
        [String]$name=$user.SamAccountName+$user.GivenName;
        #Write-Host "Teste!! $name"
        $l=Measure-StringDistance  $name $tofind
        if ($l -lt $min) {
            $min=$l;
            $found=$user;
        }

    }
    Write-Host "LEW=$min"
    if ($min -le $lew) {
        return $found;
    }
    else {
        return $null;
    }
}


function Measure-StringDistance {
    <#
        .SYNOPSIS
            Compute the distance between two strings using the Levenshtein distance formula.
        
        .DESCRIPTION
            Compute the distance between two strings using the Levenshtein distance formula.
        .PARAMETER Source
            The source string.
        .PARAMETER Compare
            The comparison string.
        .EXAMPLE
            PS C:\> Measure-StringDistance -Source "Michael" -Compare "Micheal"
            2
            There are two characters that are different, "a" and "e".
        .EXAMPLE
            PS C:\> Measure-StringDistance -Source "Michael" -Compare "Michal"
            1
            There is one character that is different, "e".
        .NOTES
            Author:
            Michael West
    #>

    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([int])]
    param (
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$Source = "",
        [string]$Compare = ""
    )
    $n = $Source.Length;
    $m = $Compare.Length;
    $d = New-Object 'int[,]' $($n+1),$($m+1)
        
    if ($n -eq 0){
      return $m
	}
    if ($m -eq 0){
	    return $n
	}

	for ([int]$i = 0; $i -le $n; $i++){
        $d[$i, 0] = $i
    }
    for ([int]$j = 0; $j -le $m; $j++){
        $d[0, $j] = $j
    }

	for ([int]$i = 1; $i -le $n; $i++){
	    for ([int]$j = 1; $j -le $m; $j++){
            if ($Compare[$($j - 1)] -eq $Source[$($i - 1)]){
                $cost = 0
            }
            else{
                $cost = 1
            }
		    $d[$i, $j] = [Math]::Min([Math]::Min($($d[$($i-1), $j] + 1), $($d[$i, $($j-1)] + 1)),$($d[$($i-1), $($j-1)]+$cost))
	    }
	}
	    
    return $d[$n, $m]
}


<#
.Synopsis
   Synchronisiert die Email mit der AD
.DESCRIPTION
   Synchronisiert die Email mit der AD
.EXAMPLE
   set-emails
.EXAMPLE
   set-emails -forve
#>
function set-emails
{
    Param
    (
        [switch]$whatif,
        [switch]$force
    )

    Begin
    {
        
        $config=Get-Content "$PSScriptRoot/config.json" | ConvertFrom-json
        $password = $config.bindpassword | ConvertTo-SecureString -asPlainText -Force
        $credentials = New-Object System.Management.Automation.PSCredential -ArgumentList "ldap-user", $password
        #$u=get-aduser -Properties mail -Credential $credentials -Server 172.31.0.1 -LDAPFilter “(Cn=FIAE15H.*)" -SearchBase  "DC=mmbbs,DC=local"

        $course = get-courses -id_kategorie 0
        foreach ($c in $course) {
            Write-Host "Bearbeite Schüler der Klasse "$c.KNAME
            $cn=“(Cn="+$c.KNAME+".*)"
            try {
                $member=get-aduser -Properties mail -Credential $credentials -Server 172.31.0.1 -LDAPFilter $cn -SearchBase  "DC=mmbbs,DC=local"
   
                $p=Get-Coursemember -id $c.id
                foreach ($schueler in $p) {
                    if ($p.ABGANG -like "N") {
                        Write-Host "Bearbeite "$schueler.VNAME$schueler.NNAME
                        [String]$s=$c.KNAME+"."+$schueler.NNAME
                        $s=$s.Replace(" ","")

                        if ($s.Length -gt 19) {
                            $s=$s.Substring(0,18)
                            #Write-Host "Kürzen"
                        }
                        $s=$s+$schueler.VNAME
                        Write-Host "Suche: $s"

                        $u=search-User $member $s 4
                        if ($u) {
                            [String]$mail=$u.mail
                            $m=$mail.Split(" ");
                            $mail=$m[0]
                            #Write-Host $mail
                            if (-not $whatif) {
                                $np=Set-Pupil -id $schueler.id -EMAIL $mail
                            }
                            Write-Host "EMail Adresse für "$schueler.VNAME$schueler.NNAME" geändert auf "$mail -BackgroundColor DarkGreen

                            $l = Measure-StringDistance $u.GivenName $schueler.VNAME
                            if ($l -ne 0) {
                                if (-not $whatif) {
                                    $np=Set-Pupil -id $schueler.id -VNAME $u.GivenName
                                }
                                Write-Host "Vorname  ("$schueler.VNAME") geändert auf ("$u.GivenName")" -BackgroundColor DarkYellow
                            }
                            $l = Measure-StringDistance $u.Surname $schueler.NNAME
                            if ($l -ne 0) {
                                if (-not $whatif) {
                                    $np=Set-Pupil -id $schueler.id -NNAME $u.Surname
                                }
                                Write-Host "Nachname ("$schueler.NNAME") geändert auf ("$u.Surname")" -BackgroundColor DarkYellow
                            }             
                        }
                        else {
                            Write-Host "Schüler "$schueler.VNAME$schueler.NNAME "nicht gefunden!" -BackgroundColor DarkRed                 
                       }
                    }
                }
            }
            catch {
                Write-Host "Kann keine Verbindung zum AD aufbauen!" -BackgroundColor DarkRed                 
                break;
            }
        }
    }
}
