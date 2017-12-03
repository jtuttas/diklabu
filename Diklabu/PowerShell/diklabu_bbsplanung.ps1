$out=[System.Data.OleDb.OleDbConnection]$global:connection

function FormatTel([String]$in) {
    $in=$in.Trim()
    $in=$in.Replace("-","");
    $in=$in.Replace(" ","");
    $in=$in.Replace("/","");
    return $in
}

function TelEqTel([String]$tel1,[String]$tel2) {
    $tel1=FormatTel $tel1
    $tel2=FormatTel $tel2
    return $tel1 -eq $tel2
}

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

        [String]$passwort=""
    
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
            Write-Error "Fehler beim Öffnen von BBS-Planung $($_.ErrorDetails.Message)"
            $_
        }
        Set-Keystore -key "bbsplanung" -server $location
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
                #$item
                    $sch="" | Select-Object -Property "BBSID","NNAME","VNAME","GEBDAT","GEBORT","STR","PLZ","ORT","TEL","TEL_HANDY","EMAIL","GESCHLECHT","KL_NAME","BETRIEB_NR","ID_AUSBILDER"
                    $sch.BBSID=$item.NR_SCHÜLER;
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
                    $bet="" | Select-Object -Property "NAME","PLZ","ORT","STRASSE","NR","ID","BETRIEB_NR"

                    $bet.NAME=$item.BETRNAM1;
                    $bet.STRASSE=$item.BETRSTR;
                    $bet.PLZ=$item.BETRPLZ;
                    $bet.ORT=$item.BETRORT;
                    $bet.ID=$item.ID;
                    $bet.BETRIEB_NR=$item.BETRIEB_NR;

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
                    $aus.BETRIEB_NR=$item.BETRIEB_NR
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
                    $leh="" | Select-Object -Property "NNAME","VNAME","KÜRZEL","TELEFON","FAX","EMAIL"
                    $leh.NNAME=$item.NNAME;
                    $leh.VNAME=$item.VNAME;
                    $leh.Kürzel=$item.NKURZ;
                    $leh.TELEFON=$item.TEL1;
                    $leh.FAX=$item.FAX;
                    $leh.EMAIL=$item.ONLINE;
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
                    $sch.BBSID=$item.NR_SCHÜLER;
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
         [switch]$deletepupil=$false,
         # Es wird ein LOG Protokoll erzeugt
         [switch]$log=$false
         
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
        if ($log) {"== Synchonisiere Betriebe == "};
        $betriebe = Get-BPCompanies
        foreach ($b in $betriebe) {
            if ($b.BETRIEB_NR -like $null) {
                Write-Warning "ACHTIUNG Betrieb '$($b.NAME)' hat keine BetriebNr (skipped)" 
                if ($log) {"ACHTIUNG Betrieb '$($b.NAME)' hat keine BetriebNr (skipped)"}
            }
            else {
                Write-Verbose "Suche Betrieb '$($b.NAME)' ID = $($b.BETRIEB_NR)."
                if ($b.BETRIEB_NR -eq 0) {
                    $b.BETRIEB_NR=99999;
                    $b.NAME=" ";
                    $b.PLZ=" ";
                    $b.STRASSE=" ";
                    $b.NR=" ";
                    $b.ORT=" ";
                }
                $c=Get-Company -ID $b.BETRIEB_NR
                if (!$c) {
                    Write-warning " +Neuen Betrieb gefunden $($b.NAME)! Lege Betrieb an!" 
                    if ($log) {"Neuen Betrieb gefunden $($b.NAME)! Lege Betrieb an!"}
                    
                    if (-not $whatif) {
                        $nc= New-Company  -ID $b.BETRIEB_NR -NAME $b.NAME -PLZ $b.PLZ -ORT $b.ORT -STRASSE $b.STRASSE -NR $b.NR 
                    }
                }
                else {
                    Write-Verbose " -Bekannten Betrieb gefunden $($b.NAME)!" 
                    #Write-Verbose $c
                    #Write-Verbose $b
                    #Write-Verbose $($c.Name -notlike $null -and $c.NAME -ne $b.NAME)
                    if (($c.NAME -notlike $null -and $c.NAME -ne $b.NAME) -or 
                        ($c.PLZ -notlike $null -and $c.PLZ -ne $b.PLZ) -or
                        ($c.ORT -notlike $null -and $c.ORT -ne $b.ORT) -or
                        ($c.Strasse -notlike $null -and $c.STRASSE -ne $b.STRASSE) ) {
                        
                        #Write-Verbose "  Daten unterscheiden sich, aktualisiere Betriebsdaten: Aktualisiere Daten von Name=$($c.NAME) PLZ= $($c.PLZ) ORT=$($c.ORT) STRASSE=$($c.STRASSE) NR=$($c.NR) auf Name=$($b.NAME) PLZ= $($b.PLZ) ORT=$($b.ORT) STRASSE=$($b.STRASSE) NR=$($b.NR)Aktualisiere Daten von Name=$($c.NAME) PLZ= $($c.PLZ) ORT=$($c.ORT) STRASSE=$($c.STRASSE) NR=$($c.NR) auf Name=$($b.NAME) PLZ= $($b.PLZ) ORT=$($b.ORT) STRASSE=$($b.STRASSE) NR=$($b.NR)";
                        Write-Warning "  Daten unterscheiden sich, aktualisiere Betriebsdaten: Aktualisiere Daten von Name=$($c.NAME) PLZ= $($c.PLZ) ORT=$($c.ORT) STRASSE=$($c.STRASSE) NR=$($c.NR) auf Name=$($b.NAME) PLZ= $($b.PLZ) ORT=$($b.ORT) STRASSE=$($b.STRASSE) NR=$($b.NR)Aktualisiere Daten von Name=$($c.NAME) PLZ= $($c.PLZ) ORT=$($c.ORT) STRASSE=$($c.STRASSE) NR=$($c.NR) auf Name=$($b.NAME) PLZ= $($b.PLZ) ORT=$($b.ORT) STRASSE=$($b.STRASSE) NR=$($b.NR)";
                        if ($log) {" Aktualisiere Daten von Name=$($c.NAME) PLZ= $($c.PLZ) ORT=$($c.ORT) STRASSE=$($c.STRASSE) NR=$($c.NR) auf Name=$($b.NAME) PLZ= $($b.PLZ) ORT=$($b.ORT) STRASSE=$($b.STRASSE) NR=$($b.NR)"}
                        if (-not $whatif) {
                            $sc= Set-Company -ID $c.ID -NAME $b.NAME -PLZ $b.PLZ -ORT $b.ORT -STRASSE $b.STRASSE -NR $b.NR                              
                        }
                    }
                }
            }
        }     
        
        Write-Verbose "Synchonisiere Ausbilder" 
        if ($log) {"== Synchonisiere Ausbilder == "};
        $ausbilder = Get-BPInstructors
        foreach ($a in $ausbilder) {
            if ($a.BETRIEB_NR -like $null) {
                Write-Warning "  Achtung Ausbilder $($a.NNAME) hat keine BetriebNr!" 
                if ($log) {"  Achtung Ausbilder $($a.NNAME) hat keine BetriebNr!"  }
            }
            else {
                Write-Verbose "Suche Ausbilder '$($a.NNAME)' EMail ist $($a.EMAIL) ID $($a.BETRIEB_NR)"
                if ($a.BETRIEB_NR -eq 0) {
                    $a.BETRIEB_NR=99999
                    $a.NNAME=" ";
                    $a.EMAIL=" ";
                    $a.FAX=" ";
                    $a.TELEFON=" ";
                }
                $c=Get-Instructor -ID $a.BETRIEB_NR
                if (!$c) {
                    Write-Warning "  Neuen Ausbilder gefunden ($($a.NNAME))! Lege Ausbilder an!" 
                    if ($log) {"  Neuen Ausbilder gefunden $($a.NNAME)! Lege Ausbilder an!" }
                    if (-not $whatif) {
                        if ($a.NNAME -eq "" -or $a.NNAME -like $null) {
                            $a.NNAME=" ";
                        }
                        $na= New-Instructor -ID $a.BETRIEB_NR -ID_BETRIEB $a.BETRIEB_NR -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON
                    }
                }
                else {
                    Write-Verbose "  Bekannten Ausbilder gefunden $($a.NNAME) mit EMAIL $($c.EMAIL)!" 
                    #Write-Host "$a und $c"
                    $str1 = ""+$a.NNAME+$a.EMAIL+$(FormatTel $a.TELEFON)+$(FormatTel $a.FAX)
                    $str2 = ""+$c.NNAME+$c.EMAIL+$(FormatTel $c.TELEFON)+$(FormatTel $c.FAX)
                    $str1=$str1.Replace(" ","");
                    $str2=$str2.Replace(" ","");
                    if ($str1 -ne $str2) {
                        Write-Host ("str1=($str1) str2=($str2)") -BackgroundColor DarkRed
                        Write-warning "  Daten unterscheiden sich, aktualisiere Einträge von NNAME=$($c.NNAME) EMAIL=$($c.EMAIL) FAX=$($c.FAX) TELEFON=$($c.TELEFON) auf  NNAME=$($a.NNAME) EMAIL=$($a.EMAIL) FAX=$($a.FAX) TELEFON=$($a.TELEFON)";
                        if ($log) {"  Daten unterscheiden sich ändere von NNAME=$($c.NNAME) EMAIL=$($c.EMAIL) FAX=$($c.FAX) TELEFON=$($c.TELEFON) auf  NNAME=$($a.NNAME) EMAIL=$($a.EMAIL) FAX=$($a.FAX) TELEFON=$($a.TELEFON)"}

                        if (-not $whatif) {
                            $na= Set-Instructor -ID $c.ID -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON -ID_BETRIEB $a.BETRIEB_NR
                        }
                    }
                }
            }
         }
         
        Write-Verbose "Synchonisiere Lehrer" 
        if ($log) {"== Synchronisiere Lehrer =="}
        $lehrer = Get-BPTeachers
        foreach ($l in $lehrer) {
            Write-Verbose "Suche Lehrer mit Kürzel $($l.KÜRZEL)"
            $le=Get-Teacher -ID $l.KÜRZEL
            if (!$le) {
                Write-Warning "  Neuen Lehrer gefunden $($l.VNAME) $($l.NNAME)! Lege Lehrer an mit Kürzel $($l.KÜRZEL)!"
                if ($log) {"  Neuen Lehrer gefunden $($l.VNAME) $($l.NNAME)! Lege Lehrer an mit Kürzel $($l.KÜRZEL)!"}
                if (-not $whatif) {
                    $nl=New-Teacher -ID $l.KÜRZEL -NNAME $l.NNAME -VNAME $l.VNAME -TELEFON $l.TELEFON -EMAIL $l.EMAIL 
                }
            }
            else {
                Write-Verbose "  Bekannten Lehrer gefunden $($l.VNAME) $($l.NNAME)!" 
                #if ($l.EMAIL -like $null) {$l.EMAIL=""}    
                $str1=$l.NNAME+$l.VNAME+(FormatTel $l.TELEFON)+$l.EMAIL;
                $str2=$le.NNAME+$le.VNAME+(FormatTel $le.TELEFON)+$le.EMAIL;

                if ($str1 -ne $str2) {
                    Write-Verbose "  Daten unterscheiden sich, aktualisiere Einträge";
                    if ($log) {"Daten unterscheiden sich aktualisiere Lehrer $($l.KÜRZEL) von NNAME=$($le.NNAME) VNAME=$($le.VNAME) TELEFON=$($le.TELEFON) EMAIL=$($le.EMAIL) auf NNAME=$($l.NNAME) VNAME=$($l.VNAME) TELEFON=$($l.TELEFON) EMAIL=$($l.EMAIL)"}
                    if (-not $whatif) {
                       $nl=Set-Teacher -ID $l.KÜRZEL -NNAME $l.NNAME -VNAME $l.VNAME -TELEFON $l.TELEFON -EMAIL $l.EMAIL       
                    }
                }
            }
        }
        
        Write-Verbose "Synchonisiere Klassen" 
        if ($log) {"== Synchonisiere Klassen == "}
        $klassen = Get-BPCourses
        foreach ($k in $klassen) {
            Write-Verbose "Suche Klasse $($k.KNAME)"
            $kl=Find-Course -KNAME $([String]$k.KNAME).ToUpper()
            $k |Add-Member -MemberType NoteProperty -Name diklabuID -Value -1
            if (!$kl) {
                Write-Warning "  Neue Klasse $($k.KNAME)! Lege Klasse an!" 
                if ($log) {"WARNUNG: Neue Klasse $($k.KNAME)! Lege Klasse an!" };
                if (-not $whatif) {
                    $nl=New-Course -KNAME $([String]$k.KNAME).ToUpper() -ID_LEHRER $k.ID_LEHRER -ID_KATEGORIE 0
                    $k.diklabuID=$nl.id
                }
            }
            else {
                Write-Verbose "  Bekannte Klasse $($kl.KNAME)!" 
                $str1=""+$kl.ID_LEHRER;
                $str2=""+$k.ID_LEHRER;
                if ($str1 -ne $str2) {
                    Write-Verbose "  Daten unterscheiden sich, aktualisiere Einträge für $($k.KNAME) von ID_LEHRER=$($kl.ID_LEHRER) nach ID_LEHRER=$($k.ID_LEHRER)";
                    if ($log) {"  Daten unterscheiden sich, aktualisiere Einträge für $($k.KNAME) von ID_LEHRER=$($kl.ID_LEHRER) nach ID_LEHRER=$($k.ID_LEHRER)"};
                    if (-not $whatif) {
                        $nl=Set-Course -id $kl.id -ID_LEHRER $k.ID_LEHRER
                        $k.diklabuID=$nl.id
                    }
                }
            }
        }
       
        
        Write-Verbose "Synchonisiere Schüler" 
        if ($log) {"== Synchonisiere Schüler =="}
        $schueler = Get-BPPupils
        foreach ($s in $schueler) {
            if ($s.BETRIEB_NR -eq 0) {$s.BETRIEB_NR = 99999}
            if ($s.GEBDAT) {
                $gdate = get-date $s.GEBDAT -Format "yyyy-MM-dd"
            }
            else {
                $gdate=$null
            }
            
            $s | Add-Member -MemberType NoteProperty -Name diklabuID -Value -1
            if ($newyear) {
                Write-Verbose "Suche Schüler $($s.VNAME) $($s.NNAME)  GEBDat $gdate nach Levenstheindistanz"
                # Schüler werden gesucht anhand von Vorname, Nachname und Geburtsdatum und Levensthein Distanz
                $cc=Search-Pupil -VNAMENNAMEGEBDAT ($s.VNAME+$s.NNAME+$gdate) -LDist 3
                if ($cc) {
                    $p=Get-Pupil -id $cc[0].id
                    $c=find-Pupil -VNAME $p.vorname -NNAME $p.name -GEBDAT $p.gebDatum
                    if ($c) {
                        Write-Verbose "Schüler ID=$($cc[0].id) gefunden ändere (NR_SCHÜLER) auf $($s.BBSID)"
                        if ($log) {"Schüler gefunden, Schüler $($s.VNAME) $($S.NNAME) Gebdat=$gdate ist (vermutlich) $($cc[0].vorname) $($cc[0].name) $($c.GEBDAT) mit ID=$($cc[0].id), ändere ID (NR_SCHÜLER) auf $($s.BBSID)"}
                        $c=Set-Pupil -id $cc[0].id -bbsplanid $s.BBSID
                    } 
                }
                else {
                    $c=$null
                }
            }
            else {
                # Schüler werden anahand der BBS Planungs ID gesucht
                Write-Verbose "Suche Schüler $($s.VNAME) $($s.NNAME)  GEBDat $gdate nach BBSid=$($s.BBSID)"
                $c=Get-Pupil -bbsplanid $s.BBSID

                if (!$c) {
                    Write-Verbose "Schüler nicht gefunden, probiere suche nach Levensthein Distanz!"
                    $cc=Search-Pupil -VNAMENNAMEGEBDAT ($s.VNAME+$s.NNAME+$gdate) -LDist 3
               
                    if ($cc) {
                        $p=Get-Pupil -id $cc[0].id
                        $c=find-Pupil -VNAME $p.vorname -NNAME $p.name -GEBDAT $p.gebDatum
                        if ($c) {
                            Write-Verbose "Schüler ID=$($cc[0].id) gefunden ändere (NR_SCHÜLER) auf $($s.BBSID)"
                            if ($log) {"Schüler ID=$($cc[0].id)  gefunden ändere ID (NR_SCHÜLER) auf $($s.BBSID)"}
                            $c=Set-Pupil -id $cc[0].id -bbsplanid $s.BBSID
                        } 
                    }
                    else {
                        $c=$null
                    }
                }
            }
            # Schüler nicht gefunden
            if (!$c) {
                Write-Warning "  Neuer Schüler $($s.VNAME) $($s.NNAME)! Lege Schüler an!" 
                if ($log) {"WARNUNG: Neuen Schüler $($s.VNAME) $($s.NNAME)! Lege Schüler an!" }
                
                if (-not $whatif) {
                    if ($gdate) {
                        if ($s.BETRIEB_NR.getType().Name -eq "DBNull") {
                            $np=New-Pupil -VNAME $s.VNAME -NNAME $s.NNAME -GEBDAT $gdate -EMAIL $s.EMAIL -ABGANG "N"  -bbsplanid $s.BBSID -ID_AUSBILDER 99999
                        }
                        else {
                            $np=New-Pupil -VNAME $s.VNAME -NNAME $s.NNAME -GEBDAT $gdate -EMAIL $s.EMAIL -ABGANG "N"  -bbsplanid $s.BBSID -ID_AUSBILDER $s.BETRIEB_NR
                        }
                    }
                    else {
                        if ($s.BETRIEB_NR.getType().Name -eq "DBNull") {
                            $np=New-Pupil -VNAME $s.VNAME -NNAME $s.NNAME  -EMAIL $s.EMAIL -ABGANG "N" -bbsplanid $s.BBSID -ID_AUSBILDER 99999
                        }
                        else {
                            $np=New-Pupil -VNAME $s.VNAME -NNAME $s.NNAME  -EMAIL $s.EMAIL -ABGANG "N" -bbsplanid $s.BBSID -ID_AUSBILDER $s.BETRIEB_NR
                        }
                       
                    }
                    $s.diklabuID=$np.ID
                }
                Write-Warning "  Trage neuen Schüler $($s.VNAME) $($s.NNAME) in die Klasse $($s.KL_NAME) ein." 
                if ($log) {"WARNUNG:  Trage neuen Schüler $($s.VNAME) $($s.NNAME) in die Klasse $($s.KL_NAME) ein."}
                $kl=Find-Course -KNAME $([String]$s.KL_NAME).ToUpper()
                if (-not $whatif) {
                    $res=Add-Coursemember -id $np.id -klassenid $kl.id
                    if ($res.success -ne $True) {
                        Write-Warning "Fehler beim Zuweisen des Schülers $($s.VNAME) $($s.NNAME) zur Klasse $($s.KL_NAME):  $($res.msg)"
                        if ($log) {"FEHLER: Fehler beim Zuweisen des Schülers $($s.VNAME) $($s.NNAME) zur Klasse $($s.KL_NAME):  $($res.msg)"}
                    }
                    else {
                        Write-Verbose $res.msg 
                    }
                }
            }
            else {        
                #$c   
                #$s     
                Write-Verbose "  Bekannten Schüler gefunden $($s.VNAME) $($s.NNAME) diklabu ID $($c.id)!" 
                if ($c.VNAME -ne $s.VNAME -or 
                    $c.NNAME -ne $s.NNAME -or
                    $c.GEBDAT -ne $gdate ) {
                    Write-Verbose "  Die Daten haben sich geändert, aktualisiere Daten (ID=$($c.ID) BBSID=$($c.ID_MMBBS)) von NNAME=$($c.NNAME) VNAME=$($c.VNAME) GEBDAT=$($c.GEBDAT) nach NNAME=$($s.NNAME) VNAME=$($s.VNAME) GEBDAT=$gdate"
                    if ($log) {"  Die Daten haben sich geändert, aktualisiere Daten (ID=$($c.ID) BBSID=$($c.ID_MMBBS)) von NNAME=$($c.NNAME) VNAME=$($c.VNAME) GEBDAT=$($c.GEBDAT) nach NNAME=$($s.NNAME) VNAME=$($s.VNAME) GEBDAT=$gdate"}
                    if (($c.VNAME -ne $s.VNAME) -and ($c.NNAME -ne $s.NNAME) -and ($c.GEBDAT -ne $gdate)) {
                        Write-Warning "Alle drei Daten haben sich geändert, suche Schüler NNAME=$($s.NNAME) VNAME=$($s.VNAME) GEBDAT=$gdate mit Levensthein Distanz"
                        if ($log) {"Alle drei Daten haben sich geändert, suche Schüler NNAME=$($s.NNAME) VNAME=$($s.VNAME) GEBDAT=$gdate mit Levensthein Distanz"}
                        $cc=Search-Pupil -VNAMENNAMEGEBDAT ($s.VNAME+$s.NNAME+$gdate) -LDist 3
                        if ($cc) {
                            $p=Get-Pupil -id $cc.id
                            $c2=find-Pupil -VNAME $p.vorname -NNAME $p.name -GEBDAT $p.gebDatum
                            Write-Verbose "Schüler gefunden, aktualisiere BBS Plan ID für NNAME=$($c2.NNAME) VNAME=$($c2.VNAME)"
                            if ($log) {"Schüler gefunden, aktualisiere BBS Plan ID für NNAME=$($c2.NNAME) VNAME=$($c2.VNAME)"}
                            if (-not $whatif) {
                                Set-Pupil -id $c2.id -VNAME $s.VNAME -NNAME $s.NNAME -GEBDAT $gdate -bbsplanid $c.BBSID                                
                            }
                            $s.diklabuID=$c2.ID
                        }
                        else {
                            Write-Verbose "Schüler NICHT gefunden, trage neuen Schüler  NNAME=$($s.NNAME) VNAME=$($s.VNAME) ein"
                            if ($log) {"Schüler NICHT gefunden, trage neuen Schüler  NNAME=$($s.NNAME) VNAME=$($s.VNAME) ein"}
                            if (-not $whatif) {
                                if ($gdate) {
                                    $np=New-Pupil -VNAME $s.VNAME -NNAME $s.NNAME -GEBDAT $gdate -EMAIL $s.EMAIL -ABGANG "N" -ID_AUSBILDER $s.BETRIEB_NR -bbsplanid $s.BBSID
                                }
                                else {
                                   $np=New-Pupil -VNAME $s.VNAME -NNAME $s.NNAME  -EMAIL $s.EMAIL -ABGANG "N" -ID_AUSBILDER $s.BETRIEB_NR -bbsplanid $s.BBSID
                                }
                                $s.diklabuID=$np.ID
                            }

                        }                               
                    } 
                    else {
                        if (-not $whatif) {
                            $out=Set-Pupil -id $c.id -VNAME $s.VNAME -NNAME $s.NNAME -EMAIL $s.EMAIL -bbsplanid $s.BBSID -GEBDAT $gdate 
                        }
                    }
                }
                $s.diklabuID=$c.id

                $kl = Get-Coursemembership $c.id | Where-Object {$_.ID_Kategorie -eq 0}
                if (-not $kl) {
                    Write-Warning "Der Schüler $($s.VNAME) $($s.NNAME) ist in keiner Klasse, trage ein in $($s.KL_NAME)!"
                    if ($log) {"Der Schüler $($s.VNAME) $($s.NNAME) ist in keiner Klasse, trage ein in $($s.KL_NAME)!"}
                    if (-not $whatif) {
                        $klasse = Find-Course $([String]$s.KL_NAME).ToUpper()
                        $out=Add-Coursemember -id $c.id -klassenid $klasse.id
                    }
                }
                else {
                    foreach ($k in $kl) {
                        if ($k.ID_Kategorie -eq 0) {
                            if ($s.KL_NAME -ne $k.KNAME) {
                                Write-Warning "Der Schüler $($s.VNAME) $($s.NNAME) hat die Klasse gewechselt! Aus der Klasse $($k.KNAME) in die Klasse $($s.KL_NAME)"
                                if ($log) {"Der Schüler $($s.VNAME) $($s.NNAME) hat die Klasse gewechselt! Aus der Klasse $($k.KNAME) in die Klasse $($s.KL_NAME)"}
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
                }

                # $s Schüler aus BBS Planung und $c Schüler aus diklabu
                <#
                    $s BBS Planung
                    BBSID        : 8
                    NNAME        : Musterfrau
                    VNAME        : Erina
                    GEBDAT       : 07.04.1990 00:00:00
                    GEBORT       : 
                    STR          : 
                    PLZ          : 
                    ORT          : 
                    TEL          : 
                    TEL_HANDY    : 
                    EMAIL        : 
                    GESCHLECHT   : 
                    KL_NAME      : FIAE17B
                    BETRIEB_NR   : 5
                    ID_AUSBILDER : 


                    $c DIKLABU
                    ABGANG       : N
                    GEBDAT       : 1990-04-07
                    ID_AUSBILDER : 99999
                    ID_MMBBS     : 8
                    NNAME        : Musterfrau
                    VNAME        : Erina
                    id           : 15482
                #>
                # Der Schüler im Diklabu hat kein Attribut ID_AUSBILDER in BBS PLanung ist aber ein Ausbilder eingetragen
                if ((-not [bool]($c.PSobject.Properties.name  -match "ID_AUSBILDER") -and $s.BETRIEB_NR) -or  
                    # Schüler hatte keinen Betrieb und hat jetzt einen Bekommen
                    (($c.ID_AUSBILDER -eq 99999) -and  $s.BETRIEB_NR.getType().Name -ne "DBNull") -and $s.BETRIEB_NR -ne 99999 -or
                    # Schüler hatte einen Betrieb und hat jetzt keinen mehr
                    (($c.ID_AUSBILDER -ne 99999) -and $s.BETRIEB_NR.getType().Name -eq "DBNull") -or
                    # Schüler hatte einen Betrieb und hat jetzt einen neuen
                    (($c.ID_AUSBILDER -ne 99999) -and  $s.BETRIEB_NR.getType().Name -ne "DBNull" -and ($c.ID_AUSBILDER -ne $s.BETRIEB_NR)) 
                    ) {
                    Write-Warning "Der Schüler $($s.VNAME) $($s.NNAME) hat einen neuen Ausbildungsbetrieb / Ausbilder ID Ausbilder=($($s.BETRIEB_NR))" 
                    if ($log) {"Der Schüler $($s.VNAME) $($s.NNAME) hat einen neuen Ausbildungsbetrieb / Ausbilder ID Ausbilder=($($s.BETRIEB_NR))" }
                    #Write-Host "C:$c"
                    #Write-Host "S:$s"
                    if (-not $whatif) {
                        try {
                            $out=Set-Pupil -id $s.diklabuID -ID_AUSBILDER $s.BETRIEB_NR
                        }
                        catch {
                            $out=Set-Pupil -id $s.diklabuID -ID_AUSBILDER 99999
                        }
                    }
                }            
            }
        }

        if ($mode -eq "SYNC") {
            Write-Verbose "Lösche Klassen die nicht in BBS PLanung enthalten sind"
            if ($log) {"== Lösche Klassen die nicht in BBS PLanung enthalten sind =="}
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
                    if ($log) {"Lösche Klasse $($c.KNAME) ID=$($c.id)"}
                    if (-not $whatif) {
                        # Schüler aus der Klasse entfernen
                        $out=Get-Coursemember -id $c.id | Remove-Coursemember -klassenid $c.id
                        $out=Delete-Course -id $c.id
                    }
                }
            }

            Write-Verbose "Entferne Schüler aus Klassen, die nicht in den Klassen von BBS Planung enthalten sind"
            if ($log) {"== Entferne Schüler aus Klassen, die nicht in den Klassen von BBS Planung enthalten sind =="}
            $courses = Get-Courses | Where-Object {$_.idkategorie -eq 0}
            foreach ($c in $courses) {
                $member = Get-Coursemember -id $c.id
                foreach ($m in $member) {
                    $tst = Test-BPCoursemember -KNAME $c.KNAME -BBSID $m.ID_MMBBS
                    if (-not $tst) {
                        Write-Warning "Entferne Schüler $($m.VNAME) $($m.NNAME) aus Klasse $($c.KNAME)"
                        if ($log) {"Entferne Schüler $($m.VNAME) $($m.NNAME) aus Klasse $($c.KNAME)"}
                        if (-not $whatif) {
                            $out=Remove-Coursemember -id $m.id -klassenid $c.id
                        }
                    }
                }

            }
            
            if ($deletepupil) {
                Write-Verbose "Lösche Schüler die in BBS Planung nicht enthalten sind"
                if ($log) {"==  Lösche Schüler die in BBS Planung nicht enthalten sind  =="}
                $pupil = Get-Pupils
                foreach ($p in $pupil) {
                    if (-not $p.ID_MMBBS) {
                        Write-Warning "Lösche Schüler $($p.VNAME) $($p.NNAME), da keine ID aus BBSPLANUNG"
                        if ($log) {"Lösche Schüler $($p.VNAME) $($p.NNAME), da keine ID aus BBSPLANUNG"}
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
                            if ($log) {"Lösche Schüler $($p.VNAME) $($p.NNAME)"}
                            if (-not $whatif) {
                                $out=Delete-Pupil  -id $p.id 
                            }
                        }
                    }
                }
            }
        }
        elseif ($mode -eq "ONEWAY") {
            Write-Verbose "Setze Schüler auf Abgang, die im Diklabu eine BBS Planungs ID haben, aber nicht mehr in BBS Planung enthalten sind"
            if ($log) {"== Setze Schüler auf Abgang, die im Diklabu eine BBS Planungs ID haben, aber nicht mehr in BBS Planung enthalten sind =="}
            $diklabu_pupils = get-pupils | Where-Object {$_.ABGANG -ne "J" -and $_.ID_MMBBS -ne $null};
            $dp=@{};
            $n=1;
            foreach ($p in $diklabu_pupils) {
                if ($p.ID_MMBBS -eq 99999) {
                    $dp[($p.ID_MMBBS+$n)]=$p
                    $n++;
                }
                else {
                    $dp[$p.ID_MMBBS]=$p
                }
            }
            $bbsp = Get-BPPupils;
            foreach ($p in $bbsp) {
                $dp.Remove($p.BBSID);
            }
            Write-Verbose "Insgesamt werden $($dp.Count) Schüler auf abgang gesetzt!"
            foreach ($p in $dp.GetEnumerator()) {
                Write-Verbose "Setze Schüler ID=$($p.Value.ID) ($($p.Value.VNAME) $($p.Value.NNAME)) auf Abgang"
                if ($log) {"Setze Schüler ID=$($p.Value.ID)  ($($p.Value.VNAME) $($p.Value.NNAME)) auf Abgang"}
                if (-not $whatif) {
                    set-pupil -id $p.Value.id -ABGANG "J"
                }
            }
        }
     }
 }
