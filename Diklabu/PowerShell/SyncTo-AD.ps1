<#
.Synopsis
   Syncronisiert eine (oder mehrere) Klassen mit der AD
.DESCRIPTION
   Erzeugt in der AD OUs und Gruppen für Klassen und fügt die Schülerinnen und Schüler ein.
.EXAMPLE
   Syncto-AD -course FISI15A -credetials (Get-Credential Administrator) -path "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -server 192.168.178.53

   Legt die Schüler der Klasse FISI15A in der AD an und gibt ihnen das default Kennwort "MMBBS1!" Ferner wird eine OU FISI15A angelegt und in dieser eine Gruppe FISI15A. In der die Schüler als Mitglieder aufgenommen werden.
.EXAMPLE
   "FIAE16H","FIAE16H","FIAE16I"|SyncTo-AD -credentials (Get-Credential Administrator)  -server 192.168.178.53 -path "OU=Schüler,OU=mmbbs,DC=tuttas,DC=de" -Verbose

    Legt die Schüler der Klassen "FIAE16H","FIAE16H","FIAE16I" in der AD an und gibt ihnen das default Kennwort "MMBBS1!" Ferner werden OUs "FIAE16H","FIAE16H","FIAE16I" angelegt und entsprechende Gruppen in der die Schüler Mitgleid sind.
#>
function SyncTo-AD
{
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        [String]$course,

        # Pfad
        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        $path,


        # Credentials
        [Parameter(Position=2)]
        [PSCredential]$credentials,

        # Server
        [Parameter(Position=3)]
        $server="localhost",

        # Passwort
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        $password="Mm#bbS1!test!",

        # Home Laufwerk
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        $homeDrive="c:\\Test",

        [switch]$whatif



    )

    Begin
    {
       
    }
    Process
    {
        # Schauen ob Gruppe (Klasse) schon existiert
        #$course=$course.ToUpper();
        $courseObject = Find-Course -KNAME $course 
        if (-not $courseObject) {
            Write-Error "Kann Klasse $course nicht finden !" 
            break;
        }
        if ($courseObject.ID_KATEGORIE -ne 0) {
            Write-Warning "Achtung die Klasse $course ist ein Kurs, es werden keine Schüler angelegt!"
        }
        Write-Verbose "Bearbeite Klasse $course"
        $ou=Get-ADOrganizationalUnit -Credential $c -Server $server -Filter {Name -like $course}
        if ($ou) {
            Write-Verbose "+- OU $course existiert bereits" 
        }
        else {
            Write-Verbose "+- OU $course existiert nicht, wird angelegt" 
            if (-not $whatif) {
                $ou=New-ADOrganizationalUnit -Credential $c -Server $server -DisplayName $course -Name $course -Path $path -ProtectedFromAccidentalDeletion $False
            }
        }

        $gr=Get-ADGroup -Credential $c -Server $server -Filter {name -like $course}
        if (-not $gr) {
            Write-Verbose "+- Gruppe $course wird in OU $course angelegt !" 
            $other = @{'mail'=$course+"@mm-bbs.de"};
            if (-not $whatif) {
                New-ADGroup -Server $server -Credential $credentials -Name $course -SamAccountName $course -Path "OU=$course,$path" -GroupScope Global -OtherAttributes $other
                $gr=Get-ADGroup -Credential $c -Server $server -Filter {name -like $course}
            }
        }
        else {
            Write-Verbose "+- Gruppe $course existiert!" 
        }
        $member=$courseObject | Get-Coursemember | Get-Pupil
        foreach ($schueler in $member) {
            Write-Verbose "Bearbeite Schüler $($schueler.vorname) $($schueler.name) ID=$($schueler.ID)"
            if ($courseObject.ID_KATEGORIE -eq 0) {
                $courseName=$course
            }
            else {
                $courseName = $schueler.klassen | ForEach-Object {if ($_.ID_KATEGORIE -eq 0) {$_.KNAME}}                
            }
            $sname=$schueler.name
            # Anpassen an die Namenskonventionen in der AD
            $sname=$sname.Replace(" ","")            
            $sname=$sname.Replace("-","")            
            $sname=$sname.replace("ö","oe");
            $sname=$sname.replace("ä","ae");
            $sname=$sname.replace("ü","ue");
            $sname=$sname.replace("ß","ss");
            $l=$sname.Length
            if ($l -gt 12) {
                $l=12
            }
            $sname=$sname.Substring(0,$l);
            $sname=$courseName+"."+$sname;
            $cn=“(Cn="+$sname+")"
            Write-Verbose "+- LDAP Filter is $cn"
            try {
                $admember=get-aduser -Properties mail -Credential $credentials -Server $server -LDAPFilter $cn -SearchBase  "OU=$courseName,$path" -ErrorAction SilentlyContinue 
                #$admember
                if ($admember) {
                    Write-Verbose "+- Schüler gefunden!" 
                    $strUser = Get-ADPrincipalGroupMembership -Credential $credentials -Server $server -Identity $admember.distinguishedName | ForEach-Object {if ($_.name -like $course) {$_}}
                    if ($strUser) {
                        Write-Verbose "+- Der Schüler $($schueler.vorname) $($schueler.name) ist bereits in der Gruppe $course" 
                    }
                    else {
                        if (-not $whatif) {
                            Add-ADGroupMember -Credential $credentials -Server $server -Identity $gr -Members $sname
                        }
                        Write-Verbose "+- Der Schüler $($schueler.vorname) $($schueler.name) wurde zur Gruppe $course hinzugefügt"
                    }
                }
                else {
                    if ($courseObject.ID_KATEGORIE -eq 0) {
                        Write-Verbose "+- Schüler nicht gefunden, wird angelegt!" 
                        $mail = $sname                        
                        $mail+="@mm-bbs.de";
               
                        $other = @{'mail'=$mail;"streetAddress"=$schueler.betrieb.STRASSE;"postalCode"=$schueler.betrieb.PLZ;"l"=$schueler.betrieb.ORT};
                        $pass = $password | ConvertTo-SecureString -AsPlainText -Force
                        $company = $schueler.betrieb.NAME
                        $l=$company.Length
                        if ($l -ge 64) {
                            $company=$company.subString(0,63);
                        }                       
                        if (-not $whatif) {
                            #$cn
                            New-ADUser -Credential $credentials -Enabled $true  -Company "$company"  -Surname $schueler.name -AccountPassword $pass -SamAccountName $sname -UserPrincipalName $mail -Server $server -Name $sname -DisplayName  $sname  -GivenName $schueler.vorname -OfficePhone $schueler.id -Path "OU=$course,$path" -OtherAttributes $other              
                            Add-ADGroupMember -Credential $credentials  -Server $server -Identity $gr -Members $sname
                        }

                        Write-Verbose "+- Der Schüler $($schueler.vorname) $($schueler.name) wurde zur Gruppe $course hinzugefügt"
                    }
                    else {
                        Write-Warning "+- Der Schüler $($schueler.vorname) $($schueler.name) konnte nicht in der AD gefunden werden!"
                    }
                }
            }
            catch {
                $_
                Write-Warning "+-- LDAP Filter $cn nicht gefunden!"
            }
        }
    }
    End
    {
    }
}