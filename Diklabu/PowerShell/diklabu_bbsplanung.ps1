$out=[System.Data.OleDb.OleDbConnection]$global:connection

<#
.Synopsis
    Verbindung zu BBS PLanung Herstellen
.DESCRIPTION
    Verbindung zu BBS PLanung Herstellen
.EXAMPLE
    Connect-BbsPlan -location c:\Test
#>
function Connect-BbsPlan
{
    [CmdletBinding()]
    Param
    (
        # Hilfebeschreibung zu Param1
        [Parameter(Position=0)]
        [String]$location,

        [String]$user_id="SCHULE",

        [String]$passwort
    
    )
    
    Begin
    {
         if (-not $location) {
            if ($Global:logins["bbsplanung"]) {
                $location=$Global:logins["bbsplanung"].location;
            }
            else {
                Write-Error "Bitte location angeben!"
                break;
            }
        }
        $global:connection = new-object System.Data.OleDb.OleDbConnection
        try{
 
            $global:connection.ConnectionString="Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$location\schule_XP.mdb; Jet OLEDB:System Database=$location\System.mdw;User ID=$user_ID;Password=$user_password;"
            $global:connection.Open()
            Write-Verbose "Okay, db geöffnet"
            $global:connection 
        }
        catch {        
            Write-Error "Fehler beim Öffnen von BBS-Planung $($cn.InfoMessage)"
        }
        setKey "bbsplanung" $location $null
    }
}

<#
.Synopsis
    Abfrage BBSPlanung
.DESCRIPTION
    Abfrage BBSPlanung
.EXAMPLE
    Get-BbsPlan 
#>
function Get-BbsPlan
{
    [CmdletBinding()]
    Param
    (
    )
    
    Begin
    {
        $Global:logins["bbsplanung"]
    }
}

<#
.Synopsis
    Verbindung zu BBS PLanung beenden
.DESCRIPTION
    Verbindung zu BBS PLanung beenden
.EXAMPLE
    Disconnect-BbsPlan 
#>
function Disconnect-BbsPlan
{
    [CmdletBinding()]
    Param
    (
    )
    
    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -ne "Open") {
                Write-Warning "Verbindung ist nicht offen"
            }
            else {
                $global:connection.Close();
                Write-Verbose "Verbindung zu BBS Planung geschlossen"
            }
        }
        else {
            Write-Warning "Keine existierende Verbindung"
        }
    }
}


# Betrieb finden nach BBSPlanung ID
function findBetrieb($id) {
    foreach ($b in $betriebe) {
        if ($b.ID -eq $id) {
            return $b
        }
    }
}
# Ausbilder (Ansprechpartner) finden nach BBSPlanung Betriebs ID
function findAusbilder($id) {
    foreach ($a in $ausbilder) {
        if ($a.BETRIEB_NR -eq $id) {
            return $a
        }
    }
}


<#
.Synopsis
   Überprüft ob ein Schüler in einer BBSPlanung Klasse ist
.DESCRIPTION
   Überprüft ob ein Schüler in einer BBSPlanung Klasse ist
.EXAMPLE
   Test-BPCoursemember 
#>
function Test-BPCoursemember
{
    [CmdletBinding()]
    Param
    (
        # Name der Klasse
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]$KNAME,

        # BBS Planungs ID des Schülers
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [int]$BBSID

    )

    
    Process
    {
        $mem = Get-BPCoursemember -KL_NAME $KNAME
        foreach ($me in $mem) {
            if ($me.BBSID -eq $BBSID) {
                return $true
            }
        }
        return $false
    }
   
}

<#
.Synopsis
   Liest die Schüler aus BBS Planung aus
.DESCRIPTION
   Liest die Schüler aus BBS Planung aus
.EXAMPLE
   Get-BPPupils
#>
function Get-BPPupils
{
    [CmdletBinding()]
    Param
    (
    )

    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -eq "Open") {
                $command = $global:connection.CreateCommand()
	            $command.CommandText = "Select * From SIL"
                Write-Verbose "Lese Datenbank SIL (Schülerdaten) ein!" 

                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)
                $schueler=@();
                foreach ($item in $dataset.Tables[0]) {
                    $sch="" | Select-Object -Property "BBSID","NNAME","VNAME","GEBDAT","GEBORT","STR","PLZ","ORT","TEL","TEL_HANDY","EMAIL","GESCHLECHT","KL_NAME","BETRIEB_NR","ID_AUSBILDER"
                    $sch.BBSID=$item.id;
                    $sch.NNAME=$item.NNAME;
                    $sch.VNAME=$item.VNAME;
                    if ((""+$item.GEBDAT).Length -gt 0) {
                        [datetime]$sch.GEBDAT=$item.GEBDAT
                    }
                    $sch.GEBORT=$item.GEBORT
                    $sch.STR=$item.STR
                    $sch.PLZ=$item.PLZ
                    $sch.ORT=$item.ORT
                    $sch.TEL=$item.TEL
                    $sch.TEL_HANDY=$item.TEL_HANDY
                    $sch.EMAIL=$item.EMAIL
                    $sch.GESCHLECHT=$item.GESCHLECHT
                    $sch.KL_NAME=$item.KL_NAME
                    $sch.BETRIEB_NR=$item.BETRIEB_NR                    
                    $schueler+=$sch;    
                } 
                Write-Verbose "Insgesammt $($schueler.Length) Schüler eingelesen!"
                return $schueler
            }
            else {
                Write-Error "Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            }
        }
        else {
            Write-Error "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
        }
    }
}

<#
.Synopsis
   Liest die Betriebe aus BBS Planung aus
.DESCRIPTION
   Liest die Betriebe aus BBS Planung aus
.EXAMPLE
   Get-BPCompanies
#>
function Get-BPCompanies
{
    [CmdletBinding()]
    Param
    (
    )

    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -eq "Open") {
                $command = $global:connection.CreateCommand()
	            $command.CommandText = "Select * From BETRIEBE"
                Write-Verbose "Lese Datenbank BETRIEBE (Betriebe/Ausbilder) ein!" 
                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)
                $betriebe=@();
                foreach ($item in $dataset.Tables[0]) {
                    $bet="" | Select-Object -Property "NAME","PLZ","ORT","STRASSE","NR","ID"

                    $bet.NAME=$item.BETRNAM1;
                    $bet.STRASSE=$item.BETRSTR;
                    $bet.PLZ=$item.BETRPLZ;
                    $bet.ORT=$item.BETRORT;
                    $bet.ID=$item.id;

                    $betriebe+=$bet;
                } 
                Write-Verbose "Insgesammt $($betriebe.Length) Betriebe eingelesen!"
                return $betriebe
            }
            else {
                Write-Error "Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            }
        }
        else {
            Write-Error "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
        }
    }
}

<#
.Synopsis
   Liest Betriebe aus BBS Planung aus
.DESCRIPTION
   Liest Betriebe aus BBS Planung aus
.EXAMPLE
   Get-BPCompany -BETRIEB_NR 123
   Gibt den Betrieb mit der ID 123 aus
.EXAMPLE
   566,991 Get-BPCompany 
   Gibt die Betriebe mit den IDs 566 und 991 aus
.EXAMPLE
   Get-BPCoursemember -KL_NAME BFHOLZ14 | ForEach-Object {$_.BETIEB_NR} | Get-Company
   Zeigt die Betriebe der Klasse BFHOLZ14 an

#>
function Get-BPCompany
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [int]$BETRIEB_NR
    )

    Process
    {
        if ($global:connection) {
            if ($global:connection.State -eq "Open") {
                $command = $global:connection.CreateCommand()
	            $command.CommandText = "Select * From BETRIEBE where id=$BETRIEB_NR"
                Write-Verbose "Lese Datenbank BETRIEBE (Betriebe/Ausbilder) ein!" 
                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)
                $betriebe=@();
                foreach ($item in $dataset.Tables[0]) {
                    $bet="" | Select-Object -Property "NAME","PLZ","ORT","STRASSE","NR","ID"

                    $bet.NAME=$item.BETRNAM1;
                    $bet.STRASSE=$item.BETRSTR;
                    $bet.PLZ=$item.BETRPLZ;
                    $bet.ORT=$item.BETRORT;
                    $bet.ID=$item.id;

                    $betriebe+=$bet;
                } 
                Write-Verbose "Insgesammt $($betriebe.Length) Betriebe eingelesen!"
                return $betriebe
            }
            else {
                Write-Error "Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            }
        }
        else {
            Write-Error "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
        }
    }
}

<#
.Synopsis
   Liest die Ausbilder aus BBS Planung aus
.DESCRIPTION
   Liest die Ausbilder aus BBS Planung aus
.EXAMPLE
   Get-BPCompanies
#>
function Get-BPInstructors
{
    [CmdletBinding()]
    Param
    (
    )

    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -eq "Open") {
                $command = $global:connection.CreateCommand()
	            $command.CommandText = "Select * From BETRIEBE"
                Write-Verbose "Lese Datenbank BETRIEBE (Betriebe/Ausbilder) ein!" 
                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)

                $ausbilder=@();
                foreach ($item in $dataset.Tables[0]) {
                    $aus="" | Select-Object -Property "BETRIEB_NR","ID_BETRIEB","NNAME","EMAIL","TELEFON","FAX"

                    $aus.TELEFON=$item.BETRTEL;
                    $aus.NNAME=$item.BETRANSPR;
                    $aus.FAX=$item.BETRFAX;
                    $aus.EMAIL=$item.BETRONLINE
                    $aus.ID_BETRIEB=$item.id
                    $aus.BETRIEB_NR=$item.id
                    $ausbilder+=$aus;
                } 
                Write-Verbose "Insgesammt $($ausbilder.Length) Ausbilder eingelesen!"
                return $ausbilder
            }
            else {
                Write-Error "Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            }
        }
        else {
            Write-Error "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
        }
    }
}

<#
.Synopsis
   Liest die Lehrer aus BBS Planung aus
.DESCRIPTION
   Liest die Lehrer aus BBS Planung aus
.EXAMPLE
   Get-BPTeachers
#>
function Get-BPTeachers
{
    [CmdletBinding()]
    Param
    (
    )

    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -eq "Open") {
                $command = $global:connection.CreateCommand();
	            $command.CommandText = "Select * From LVUEL"
                Write-Verbose "Lese Datenbank LVUEL (Lehrerdaten) ein!" 
                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)
                $lehrer=@();
                foreach ($item in $dataset.Tables[0]) {
                    $leh="" | Select-Object -Property "NNAME","VNAME","KÜRZEL"
                    $leh.NNAME=$item.NNAME;
                    $leh.VNAME=$item.VNAME;
                    $leh.Kürzel=$item.NKURZ;
                    $lehrer+=$leh;
                }
                Write-Verbose "Insgesammt $($lehrer.Length) Lehrer eingelesen!"
                return $lehrer
            }
            else {
                Write-Error "Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            }
        }
        else {
            Write-Error "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
        }
    }
}

<#
.Synopsis
   Liest die Klassen aus BBS Planung aus
.DESCRIPTION
   Liest die Klassen aus BBS Planung aus
.EXAMPLE
   Get-BPCourses
#>
function Get-BPCourses
{
    [CmdletBinding()]
    Param
    (
    )

    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -eq "Open") {
                $command = $global:connection.CreateCommand()
	            $command.CommandText = "Select * From KUL"
                Write-Verbose "Lese Datenbank KUL (Klassen) ein!" 
                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)
                $klassen=@();
                foreach ($item in $dataset.Tables[0]) {
                    $kl="" | Select-Object -Property "KNAME","ID_LEHRER"
                    $kl.KNAME=$item.KL_NAME;
                    $kl.ID_LEHRER=$item.KL_LEHRER;
                    $klassen+=$kl;  
                } 
                Write-Verbose "Insgesammt $($klassen.Length) Klassen eingelesen!" 
                return $klassen
            }
            else {
                Write-Error "Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            }
        }
        else {
            Write-Error "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
        }
    }
}

<#
.Synopsis
   Liest die Klassenmitgliedschaft aus BBS Planung aus
.DESCRIPTION
   Liest die Klassenmitgliedschaft aus BBS Planung aus
.EXAMPLE
   Get-BPCoursemember 
#>
function Get-BPCoursemember
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String]$KL_NAME
    )

    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -eq "Open") {
                $command = $global:connection.CreateCommand()
	            $command.CommandText = "Select * From SIL where KL_NAME like '$KL_NAME'"
                Write-Verbose "Lese Datenbank SIL (Schülerdaten) ein!" 

                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)
                $schueler=@();
                foreach ($item in $dataset.Tables[0]) {
                    $sch="" | Select-Object -Property "BBSID","NNAME","VNAME","GEBDAT","GEBORT","STR","PLZ","ORT","TEL","TEL_HANDY","EMAIL","GESCHLECHT","KL_NAME","BETRIEB_NR","ID_AUSBILDER"
                    $sch.BBSID=$item.id;
                    $sch.NNAME=$item.NNAME;
                    $sch.VNAME=$item.VNAME;
                    if ((""+$item.GEBDAT).Length -gt 0) {
                        [datetime]$sch.GEBDAT=$item.GEBDAT
                    }
                    $sch.GEBORT=$item.GEBORT
                    $sch.STR=$item.STR
                    $sch.PLZ=$item.PLZ
                    $sch.ORT=$item.ORT
                    $sch.TEL=$item.TEL
                    $sch.TEL_HANDY=$item.TEL_HANDY
                    $sch.EMAIL=$item.EMAIL
                    $sch.GESCHLECHT=$item.GESCHLECHT
                    $sch.KL_NAME=$item.KL_NAME
                    $sch.BETRIEB_NR=$item.BETRIEB_NR
                    $schueler+=$sch;    
                } 
                Write-Verbose "Insgesammt $($schueler.Length) Schüler eingelesen!"
                return $schueler
            }
            else {
                Write-Error "Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            }
        }
        else {
            Write-Error "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
        }
    }
}


 <#
 .Synopsis
    Exportiert die Daten in das Diklabu
 .DESCRIPTION
    Exportiert die Daten in das Diklabu. Dabei werden die Schüler anhand von Vorname, Nachname und Geburtsdatum identifiziuert.
    Wird ein Schüler gefunden, dann werden die Daten aktualisiert, ansonsten werden die Daten neu angelegt
 .EXAMPLE
    Export-Diklabu -mode SYNC
    Schülerinnen und Schüler werden anhand der BBS PLanung ID gesucht.
 .EXAMPLE
    Export-Diklabu -mode SYNC -newyear 
    Schülerinnen und Schüler werden anhand des Vornamens, Nachnamens und Geb. Datum gesucht. Klassen die in
    BBS PLanung nicht enthalten sind werden gelöscht. Schüler die in BBS PLanung nicht enthalten sind werden gelöscht.
    
 #>
 function Export-BBSPlanung
 {
    [CmdletBinding()]
     Param
     (
         #Syncronisation Mode mit BBS Blanung ONEWAY = im Diklabu werden keine Einträge gelöscht. SYNC = Klassen u. Schüler die in BBS PLanung nicht enthalten sind werden gelöscht
         [Parameter(Mandatory=$true,Position=0)]
         [ValidateSet('ONEWAY','SYNC')]
         [String]$mode,
         #true = es werden keine Schreibvorgänge am Klassenbuch durchgeführt
         [switch]$whatif=$false,
         # Schülerinnen und Schüler werden anhand des Vornamens, Nachnamens und Geb. Datum gesucht
         [switch]$newyear=$false,
         # Schülerinnen und Schüler werden gelöscht, die nicht in BBS PLanung enthalten sind
         [switch]$deletepupil=$false
         
         
     ) 
     Begin
     {
       
        if ($PSBoundParameters['Verbose']) {
            $VerbosePreference="continue"
        }
        else {
           $VerbosePreference="silentlycontinue"
        }
        if (-not $global:connection) {
            Write-Warning "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            return
        }
        if ($global:connection.State -ne "Open") {
            Write-Error "Die Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            return
        }

        Write-Verbose "Synchonisiere Betriebe" 
        $betriebe = Get-BPCompanies
        foreach ($b in $betriebe) {
            Write-Verbose "Suche Betrieb '$($b.NAME)' ID = $($b.ID)."
            $b |Add-Member -MemberType NoteProperty -Name diklabuID -Value -1
            if ((""+$b.NAME).Length -eq 0 ) {
                Write-Warning "Achtung der Betrieb mit der ID $($b.id) hat einen leeren Namen"
            }
            else {            
                $c=Find-Company -NAME $b.NAME
                if (!$c) {
                    Write-Verbose " +Neuen Betrieb gefunden $($b.NAME)! Lege Betrieb an!" 
                    if (-not $whatif) {
                        $nc= New-Company  -NAME $b.NAME -PLZ $b.PLZ -ORT $b.ORT -STRASSE $b.STRASSE -NR $b.NR 
                        $b.diklabuID=$nc.ID    
                    }
                }
                else {
                    Write-Verbose " -Bekannten Betrieb gefunden $($b.NAME)! Aktualisiere Einträge!" 
                    if (-not $whatif) {
                        $sc= Set-Company -ID $c.ID -NAME $b.NAME -PLZ $b.PLZ -ORT $b.ORT -STRASSE $b.STRASSE -NR $b.NR 
                        $b.diklabuID=$c.ID    
                    }
                }
            }
        }     
        
        Write-Verbose "Synchonisiere Ausbilder" 
        $ausbilder = Get-BPInstructors
        foreach ($a in $ausbilder) {
            Write-Verbose "Suche Ausbilder '$($a.NNAME)' EMail ist $($a.EMAIL)."
            $a |Add-Member -MemberType NoteProperty -Name diklabuID -Value -1
            if ((""+$a.NNAME).Length -eq 0 ) {
                $betr = findBetrieb $a.ID_BETRIEB
                Write-Warning "Achtung der Ausbilder einen leeren Namen, wähle Betriebsnamen $($betr.NAME)"
                $a.NNAME=$betr.NAME
                Write-Verbose "Suche Ausbilder '$($a.NNAME)' EMail ist $($a.EMAIL)."
            }
            
            $c=Find-Instructor -NNAME $a.NNAME 
            if ($c.length -gt 1) {
                Write-Warning "Mehr als einen Ausbilder mit dem Namen $($a.NNAME) gefunden! Weitere Identifikation über EMAIL Adresse " 
                $found=$false;
                foreach ($ausb in $c) {
                    if ($ausb.EMAIL -eq $a.EMAIL) {
                        $found=$true
                        break;
                    }
                }
                if ($found) {
                    Write-Verbose "  Bekannten Ausbilder gefunden $($a.NNAME) mit EMAIL $($a.EMAIL) ! Aktualisiere Einträge!" 
                    $betr = findBetrieb $ausb.ID_BETRIEB
                    if (-not $whatif) {
                        $na= Set-Instructor -ID $ausb.ID -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON -ID_BETRIEB $betr.diklabuID
                    }
                    $a.diklabuID=$ausb.ID
                    $a.ID_BETRIEB=$ausb.ID_BETRIEB
                }
                else {
                    Write-Warning "  Neuen Ausbilder gefunden $($a.NNAME) mit EMAIL $($a.EMAIL)! Lege Ausbilder an!"
                    $betr = findBetrieb $a.ID_BETRIEB
                    if (-not $whatif) {
                        $na= New-Instructor -ID_BETRIEB $betr.diklabuID -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON
                        $a.diklabuID=$na.id
                    }
                    $a.ID_BETRIEB=$betr.diklabuID
                }
            }
            else {
                if (!$c) {
                    Write-Warning "  Neuen Ausbilder gefunden $($a.NNAME)! Lege Ausbilder an!" 
                    $betr = findBetrieb $a.ID_BETRIEB
                    if (-not $whatif) {
                        $na= New-Instructor -ID_BETRIEB $betr.diklabuID -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON
                        $a.diklabuID=$na.ID
                    }
                    $a.ID_BETRIEB=$betr.diklabuID
                }
                else {
                    if ($a.EMAIL -eq $c.EMAIL) {
                        Write-Verbose "  Bekannten Ausbilder gefunden $($a.NNAME) mit EMAIL $($c.EMAIL)! Aktualisiere Einträge!" 
                        $betr = findBetrieb $a.ID_BETRIEB
                        if (-not $whatif) {
                            $na= Set-Instructor -ID $c.ID -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON -ID_BETRIEB $betr.diklabuID
                        }
                        $a.diklabuID=$c.ID
                        $a.ID_BETRIEB=$c.ID_BETRIEB
                    }
                    else {
                        Write-Verbose "  Ausbilder gefunden $($a.NNAME) hat andere EMail Adresse $($c.EMAIL)! Als neuen Ausbilder angesehen!" 
                        $betr = findBetrieb $a.ID_BETRIEB
                        if (-not $whatif) {
                            $na= New-Instructor -ID_BETRIEB $betr.diklabuID -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON
                            $a.diklabuID=$na.ID
                        }
                        $a.ID_BETRIEB=$betr.diklabuID
                    }
                }
            }
         }

        Write-Verbose "Synchonisiere Lehrer" 
        $lehrer = Get-BPTeachers
        foreach ($l in $lehrer) {
            Write-Verbose "Suche Lehrer mit Kürzel $($l.KÜRZEL)"
            $le=Get-Teacher -ID $l.KÜRZEL
            if (!$le) {
                Write-Warning "  Neuen Lehrer gefunden $($l.VNAME) $($l.NNAME)! Lege Lehrer an mit Kürzel $($l.KÜRZEL)!"
                if (-not $whatif) {
                    $nl=New-Teacher -ID $l.KÜRZEL -NNAME $l.NNAME -VNAME $l.VNAME -TELEFON $l.TELEFON -EMAIL $l.EMAIL 
                }
            }
            else {
                Write-Verbose "  Bekannten Lehrer gefunden $($l.VNAME) $($l.NNAME)! Aktualisiere Einträge!" 
                if (-not $whatif) {
                   $nl=Set-Teacher -ID $l.KÜRZEL -NNAME $l.NNAME -VNAME $l.VNAME -TELEFON $l.TELEFON -EMAIL $l.EMAIL       
                }
            }
        }

        Write-Verbose "Synchonisiere Klassen" 
        $klassen = Get-BPCourses
        foreach ($k in $klassen) {
            Write-Verbose "Suche Klasse $($k.KNAME)"
            $kl=Find-Course -KNAME $k.KNAME
            $k |Add-Member -MemberType NoteProperty -Name diklabuID -Value -1
            if (!$kl) {
                Write-Warning "  Neue Klasse $($k.KNAME)! Lege Klasse an!" 
                if (-not $whatif) {
                    $nl=New-Course -KNAME $k.KNAME -ID_LEHRER $k.ID_LEHRER -ID_KATEGORIE 0
                    $k.diklabuID=$nl.id
                }
            }
            else {
                Write-Verbose "  Bekannte Klasse $($kl.KNAME)! Aktualisiere Einträge!" 
                if (-not $whatif) {
                    $nl=Set-Course -id $kl.id -ID_LEHRER $k.ID_LEHRER
                    $k.diklabuID=$nl.id
                }
            }
        }

        Write-Verbose "Synchonisiere Schüler" 
        $schueler = Get-BPPupils
        foreach ($s in $schueler) {
            if ($s.GEBDAT) {
                $gdate = get-date $s.GEBDAT -Format "yyyy-MM-dd"
            }
            else {
                $gdate=$null
            }
            Write-Verbose "Suche Schüler $($s.VNAME) $($s.NNAME)  GEBDat $gdate"
            $s |Add-Member -MemberType NoteProperty -Name diklabuID -Value -1
            if ($newyear) {
                $cc=Search-Pupil -VNAMENNAMEGEBDAT ($s.VNAME+$s.NNAME+$gdate) -LDist 3
                if ($cc) {
                    $p=Get-Pupil -id $cc.id
                    $c=find-Pupil -VNAME $p.vorname -NNAME $p.name -GEBDAT $p.gebDatum
                }
                else {
                    $c=$null
                }
            }
            else {
                $c=Get-Pupil -bbsplanid $s.BBSID
            }
            if (!$c) {
                Write-Warning "  Neuen Schüler gefunden $($s.VNAME) $($s.NNAME)! Lege Schüler an!" 
                $ausb = findAusbilder $s.BETRIEB_NR
                if (-not $whatif) {
                    if ($gdate) {
                        $np=New-Pupil -VNAME $s.VNAME -NNAME $s.NNAME -GEBDAT $gdate -EMAIL $s.EMAIL -ABGANG "N" -ID_AUSBILDER $ausb.diklabuID -bbsplanid $s.BBSID
                    }
                    else {
                       $np=New-Pupil -VNAME $s.VNAME -NNAME $s.NNAME  -EMAIL $s.EMAIL -ABGANG "N" -ID_AUSBILDER $ausb.diklabuID -bbsplanid $s.BBSID
                    }
                    $s.diklabuID=$np.ID
                }
                $s.ID_AUSBILDER=$ausb.diklabuID
                Write-Warning "  Trage neuen Schüler $($s.VNAME) $($s.NNAME) in die Klasse $($s.KL_NAME) ein." 
                $kl=Find-Course -KNAME $s.KL_NAME
                if (-not $whatif) {
                    $res=Add-Coursemember -id $np.id -klassenid $kl.id
                    if ($res.success -ne $True) {
                        Write-Warning "Fehler beim Zuweisen des Schülers $($s.VNAME) $($s.NNAME) zur Klasse $($s.KL_NAME):  $($res.msg)"
                    }
                    else {
                        Write-Verbose $res.msg 
                    }
                }
            }
            else {
                
                Write-Verbose "  Bekannten Schüler gefunden $($s.VNAME) $($s.NNAME) diklabu ID $($c.id)! Aktualisiere Einträge!" 
                if (-not $whatif) {
                    $out=Set-Pupil -id $c.id -VNAME $s.VNAME -NNAME $s.NNAME -EMAIL $s.EMAIL -bbsplanid $s.bbspl -GEBDAT $gdate
                }
                $s.diklabuID=$c.id
                $kl = Get-Coursemembership $c.id
                foreach ($k in $kl) {
                    if ($k.ID_Kategorie -eq 0) {
                        if ($s.KL_NAME -ne $k.KNAME) {
                            Write-Warning "Der Schüler $($s.VNAME) $($s.NNAME) hat die Klasse gewechselt! Aus der Klasse $($k.KNAME) in die Klasse $($s.KL_NAME)"
                            if (-not $whatif) {
                                $out=Remove-Coursemember -id $s.diklabuID -klassenid $k.ID
                            }
                            $newKlasse = Find-Course -KNAME $s.KL_NAME
                            if (-not $whatif) {
                                $out=Add-Coursemember -id $s.diklabuID -klassenid $newKlasse.ID
                            }
                        }
                    }
                }

                $ausb=Get-Instructor -ID $c.ID_AUSBILDER
                $ausb2=findAusbilder $s.BETRIEB_NR
                
                if ($ausb.ID -ne $ausb2.diklabuID) {
                    Write-Warning "Der Schüler $($s.VNAME) $($s.NNAME) hat einen neuen Ausbildungsbetrieb / Ausbilder" 
                    if (-not $whatif) {
                        $out=Set-Pupil -id $s.diklabuID -ID_AUSBILDER $ausb2.diklabuID
                    }
                }            
            }
        }

        if ($mode -eq "SYNC") {
            Write-Verbose "Lösche Klassen die nicht in BBS PLanung enthalten sind"
            $courses = Get-Courses -id_kategorie 0
            foreach ($c in $courses) {
                $found=$false;
                foreach ($k in $klassen) {
                    if ($c.KNAME -eq $k.KNAME) {
                        $found=$true;
                        break;
                    }
                }                
                if (-not $found) {
                    Write-Warning "Lösche Klasse $($c.KNAME) ID=$($c.id)"
                    if (-not $whatif) {
                        # Schüler aus der Klasse entfernen
                        $out=Get-Coursemember -id $c.id | Remove-Coursemember -klassenid $c.id
                        $out=Delete-Course -id $c.id
                    }
                }
            }

            Write-Verbose "Entferne Schüler aus Klassen, die nicht in den Klassen von BBS Planung enthalten sind"
            
            $courses = Get-Courses
            foreach ($c in $courses) {
                $member = Get-Coursemember -id $c.id
                foreach ($m in $member) {
                    $tst = Test-BPCoursemember -KNAME $c.KNAME -BBSID $m.ID_MMBBS
                    if (-not $tst) {
                        Write-Warning "Entferne Schüler $($m.VNAME) $($m.NNAME) aus Klasse $($c.KNAME)"
                        if (-not $whatif) {
                            $out=Remove-Coursemember -id $m.id -klassenid $c.id
                        }
                    }
                }

            }
            
            if ($deletepupil) {
                Write-Verbose "Lösche Schüler die in BBS Planung nicht enthalten sind"
                $pupil = Get-Pupils
                foreach ($p in $pupil) {
                    if (-not $p.ID_MMBBS) {
                        Write-Warning "Lösche Schüler $($p.VNAME) $($p.NNAME), da keine ID aus BBSPLANUNG"
                        if (-not $whatif) {
                            $out=Delete-Pupil  -id $p.id 
                        }
                    }
                    else {
                        $found=$false
                        foreach ($s in $schueler) {
                            if ($s.BBSID -eq $p.ID_MMBBS) {
                                $found=$true
                            }
                        }
                        if (-not $found) {
                            Write-Warning "Lösche Schüler $($p.VNAME) $($p.NNAME)"
                            if (-not $whatif) {
                                $out=Delete-Pupil  -id $p.id 
                            }
                        }
                    }
                }
            }
        }
     }
 }
