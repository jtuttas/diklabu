<# Synchronisation der Schüler aller Klassen gegen die AD und Übernahme der EMail Adresse 
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
        if (-not $user.GivenName) {
            Write-Warning "Achtung der AD Nutzer "$user.SamAccountName" hat keinen GivenName" 
        }
        [String]$name=$user.SamAccountName+$user.GivenName;
        #Write-Host "Teste!! $name"
        $l=Measure-StringDistance  $name $tofind
        if ($l -lt $min) {
            $min=$l;
            $found=$user;
        }

    }
    if ($min -gt 0 -and $min -lt 3) {
        #Write-Host "   LEW=$min" -BackgroundColor DarkYellow
    }
    elseif ($min -ge 3) {
        Write-Warning "  Achtung Lewenshtein Distanz bei $tofind ist größer als 2! LEW=$min" 
    }
    
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
 [CmdletBinding()]
    Param
    (
        [switch]$whatif,
        [switch]$force
    )

    Begin
    {
        if (-not $Global:logins["ldap"]) {
            Write-Error "Keine LDAP Credentials gefunden, Bitte via Login-LDAP anmelden!"
            break;
        }

        $res="" | Select-Object "total","update","error","msg"
        $res.total=0;
        $res.update=0;
        $res.error=0;
        $res.msg="";
        #$u=get-aduser -Properties mail -Credential $credentials -Server 172.31.0.1 -LDAPFilter “(Cn=FIAE15H.*)" -SearchBase  "DC=mmbbs,DC=local"
        $password = $Global:logins["ldap"].password | ConvertTo-SecureString 
        $credential = New-Object System.Management.Automation.PsCredential($Global:logins["ldap"].user,$password)

        $course = get-courses -id_kategorie 0
        
        foreach ($c in $course) {
            Write-Verbose "-----------------------"
            Write-Verbose "Bearbeite Schüler der Klasse $($c.KNAME)" 
            $res.msg +="`n`rBearbeite Schüler der Klasse "+$c.KNAME+"`n`r"
            
            $cn=“(Cn="+$c.KNAME+".*)"
            #try {
                $member=get-aduser -Properties mail -Credential $credential -Server $Global:logins["ldap"].location -LDAPFilter $cn -SearchBase  "DC=mmbbs,DC=local"
   
                $p=Get-Coursemember -id $c.id
                foreach ($schueler in $p) {
                    if ($p.ABGANG -like "N") {
                        Write-Verbose "`n`rBearbeite $($schueler.VNAME) $($schueler.NNAME) ID=$($schueler.id)"
                        $res.msg +="Bearbeite "+$schueler.VNAME+" "+$schueler.NNAME+" (ID="+$schueler.id+")`n"
                        $res.total++;
                        [String]$s=$c.KNAME+"."+$schueler.NNAME
                        $s=$s.Replace(" ","")

                        if ($s.Length -gt 19) {
                            $s=$s.Substring(0,18)
                            #Write-Host "Kürzen"
                        }
                        $s=$s+$schueler.VNAME
                        Write-Verbose "Suche: $s"

                        $u=search-User $member $s 4
                        if ($u) {
                            #$u
                            Write-Verbose "+- gefunden wurde $($u.GivenName) $($u.Surname) ($($u.UserPrincipalName))"
                            $res.msg += "+- gefunden wurde "+$u.GivenName+" "+$u.Surname+"("+$u.UserPrincipalName+") Email ($($u.mail))`n"
                            [String]$mail=$u.mail
                            $mail=$mail.Trim()
                            $m=$mail.Split(" ");
                            $mail=$m[0]
                            #Write-Host $mail
                            if ($schueler.EMAIL -ne $mail) {
                                if (-not $whatif) {
                                    $np=Set-Pupil -id $schueler.id -EMAIL $mail
                                }
                                Write-Warning "+- EMail Adresse für "$schueler.VNAME$schueler.NNAME" geändert von $($schueler.EMAIL) auf "$mail 
                                $res.msg += "+- EMail Adresse für "+$schueler.VNAME+" "+$schueler.NNAME+" geändert von $($schueler.EMAIL) auf "+$mail+"`n"
                                $res.update++;
                            }
                            # Übernehmen der Vornamen und des Nachnahmens aus der AD
                            <#
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
                            #>            
                        }
                        else {
                            Write-Warning "#- Schüler $($schueler.VNAME) $($schueler.NNAME) nicht gefunden!" 
                            $res.msg +=  "#- Schüler "+$schueler.VNAME+" "+$schueler.NNAME+" nicht gefunden!`n" 
                            $res.error++;
                       }
                       
                    }
                }
            #}
            #catch {
            #    Write-Error "Kann keine Verbindung zum AD aufbauen!"
            #   break;
            #}
        }
        return $res
    }
}
