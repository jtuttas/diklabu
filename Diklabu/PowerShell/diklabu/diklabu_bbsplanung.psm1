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

        [String]$user_password=""
    
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
 
            $global:connection.ConnectionString="Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$location\s_daten.mdb; Jet OLEDB:System Database=$location\System.mdw;User ID=$user_ID;Password=$user_password;"
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
   Liest den Pfad zu den Schülerbilder aus BBS Planung aus
.DESCRIPTION
   Liest den Pfad zu den Schülerbilder aus BBS Planung aus
.EXAMPLE
   Get-BPPupilImages
#>
function Get-BPPupilImages
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
	            $command.CommandText = "Select * From PASSBILD_BILDER"
                Write-Verbose "Lese Datenbank PASSBILD_BILDER ein!" 

                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)
                $schueler=@();
                foreach ($item in $dataset.Tables[0]) {
                #$item
                    $sch="" | Select-Object -Property "BBSID","KL_NAME","BILDPFAD"
                    $sch.BBSID=$item.id;
                    $sch.KL_NAME=$item.KL_NAME;
                    $sch.BILDPFAD=$item.BILDPFAD;
                    $schueler+=$sch;    
                } 
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
                    $sch="" | Select-Object -Property "BBSID","NNAME","VNAME","GEBDAT","GEBORT","STR","PLZ","ORT","TEL","TEL_HANDY","EMAIL","GESCHLECHT","KL_NAME","BETRIEB_NR","ID_AUSBILDER","E_ANREDE","E_NNAME","E_VNAME","E_STR","E_PLZ","E_ORT","E_TEL","E_FAX","E_EMAIL"
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
                    $sch.E_ANREDE=$item.E_ANREDE
                    $sch.E_NNAME=$item.E_NNAME
                    $sch.E_VNAME=$item.E_VNAME
                    $sch.E_STR=$item.E_STR
                    $sch.E_PLZ=$item.E_PLZ
                    $sch.E_ORT=$item.E_ORT
                    $sch.E_TEL=$item.E_TEL
                    $sch.E_FAX=$item.E_FAX
                    $sch.E_EMAIL=$item.E_EMAIL
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
   Liest einen Schüler aus BBS Planung aus
.DESCRIPTION
   Liest einen Schüler aus BBS Planung aus
.EXAMPLE
   Get-BPPupil -id 16505
.EXAMPLE
   Get-BPPupil -NR_SCHÜLER 1
#>
function Get-BPPupil
{
    [CmdletBinding()]
    Param
    (
        # ID des Schülers
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParameterSetName = "Set 1")]
        [int]$id,

        # BBS-PLan ID des Schülers
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Position=0,ParameterSetName = "Set 2")]
         [alias("ID_MMBBS")]
        [int]$NR_SCHÜLER
    )

    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -eq "Open") {
                $command = $global:connection.CreateCommand()
                if ($id) {
	                $command.CommandText = "Select * From SIL where id=$id"
                }
                elseif ($NR_SCHÜLER) {
                   $command.CommandText = "Select * From SIL where NR_SCHÜLER=$NR_SCHÜLER"
                }
                Write-Verbose "Lese Datenbank SIL (Schülerdaten) ein!" 

                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)
                $schueler=@();
                foreach ($item in $dataset.Tables[0]) {
                #$item
                    $sch="" | Select-Object -Property "BBSID","NNAME","VNAME","GEBDAT","GEBORT","STR","PLZ","ORT","TEL","TEL_HANDY","EMAIL","GESCHLECHT","KL_NAME","BETRIEB_NR","ID_AUSBILDER","E_ANREDE","E_NNAME","E_VNAME","E_STR","E_PLZ","E_ORT","E_TEL","E_FAX","E_EMAIL"
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
                    $sch.E_ANREDE=$item.E_ANREDE
                    $sch.E_NNAME=$item.E_NNAME
                    $sch.E_VNAME=$item.E_VNAME
                    $sch.E_STR=$item.E_STR
                    $sch.E_PLZ=$item.E_PLZ
                    $sch.E_ORT=$item.E_ORT
                    $sch.E_TEL=$item.E_TEL
                    $sch.E_FAX=$item.E_FAX
                    $sch.E_EMAIL=$item.E_EMAIL
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
            Write-Verbose "-------------------------";
            $reorg=$false;
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
                        #Write-Verbose $cc
                        Write-Verbose "Nach Levenstein gefunden, es ist $($cc[0].vorname) $($cc[0].name)";
                        $p=Get-Pupil -id $cc[0].id
                        $c=find-Pupil -VNAME $p.vorname -NNAME $p.name -GEBDAT $p.gebDatum
                        if ($c) {
                            $oldPupil = Get-Pupil -bbsplanid $s.BBSID;
                            if ($oldPupil) {
                                [int]$neuId=[int]$oldPupil.ID_MMBBS+10000;
                                Set-Pupil -id $oldPupil.id -bbsplanid $neuId;
                                Write-Verbose "Setze für Schüler mit BBS Plan ID=$($oldPupil.ID_MMBBS) $($oldPupil.VNAME) $($oldPupil.NNAME) die ungültige BBSID $neuId";
                                if ($log) {"Setze für Schüler mit BBS Plan ID=$($oldPupil.ID_MMBBS) $($oldPupil.VNAME) $($oldPupil.NNAME) die ungültige BBSID $neuId"}
                            }
                            Write-Verbose "Schüler ID=$($cc[0].id) $($cc[0].VNAME) $($cc[0].NNAME) gefunden ändere (NR_SCHÜLER) auf $($s.BBSID)"
                            if ($log) {"Schüler ID=$($cc[0].id)  gefunden ändere ID (NR_SCHÜLER) auf $($s.BBSID)"}
                            $c=Set-Pupil -id $cc[0].id -bbsplanid $s.BBSID
                        } 
                    }
                    else {
                        $c=$null
                    }
                    $reorg=$true;
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
                Write-Verbose "  Bekannten Schüler gefunden $($c.VNAME) $($c.NNAME) diklabu ID $($c.id) BBS ID = $($c.ID_MMBBS)!" 
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
                            $oldPupil = Get-Pupil -bbsplanid $S.BBSID;
                            if ($oldPupil) {
                                $neuId=$oldPupil.ID_MMBBS+10000;
                                Set-Pupil -id $oldPupil.id -bbsplanid $neuId;
                                Write-Verbose "Setze für Schüler mit BBS Plan ID=$($oldPupil.ID_MMBBS) $($oldPupil.VNAME) $($oldPupil.NNAME) die ungültige BBSID $neuId";
                                if ($log) {"Setze für Schüler mit BBS Plan ID=$($oldPupil.ID_MMBBS) $($oldPupil.VNAME) $($oldPupil.NNAME) die ungültige BBSID $neuId"}
                            }
                            $p=Get-Pupil -id $cc.id
                            $c2=find-Pupil -VNAME $p.vorname -NNAME $p.name -GEBDAT $p.gebDatum
                            Write-Verbose "Schüler gefunden, aktualisiere BBS Plan ID für NNAME=$($c2.NNAME) VNAME=$($c2.VNAME) von $($c.ID_MMBBS) nach $($c2.ID_MMBBS)"
                            if ($log) {"Schüler gefunden, aktualisiere BBS Plan ID für NNAME=$($c2.NNAME) VNAME=$($c2.VNAME) von $($c.ID_MMBBS) nach $($c2.ID_MMBBS)"}
                            if (-not $whatif) {
                                Set-Pupil -id $c2.id -bbsplanid $c.ID_MMBBS                                
                            }
                            $reorg=$true;
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

                if (-not $reorg) {
                    $s.diklabuID=$c.id
                    $kl = Get-Coursemembership $c.id | Where-Object {$_.ID_Kategorie -eq 0 -or $_.ID_Kategorie -eq 17}
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

<#
.Synopsis
   Sucht einen Schüler nach Vorname Nachname und Geburtsdatum
.DESCRIPTION
   Sucht einen Schüler nach Vorname Nachname und Geburtsdatum
.EXAMPLE
   Find-BPPupil -Vorname Max -Nachname Mustermann -GebDat (get-Date("4.4.1980")) -Verbose
#>
function Find-BPPupil
{
    [CmdletBinding()]
    Param
    (
         [Parameter(Mandatory=$true,Position=0)]
         [String]$Vorname,    
         [Parameter(Mandatory=$true,Position=1)]
         [String]$Nachname,    
         [Parameter(Mandatory=$true,Position=2)]
         [DateTime]$GebDat    
    )
    Begin
    {
        
        if ($global:connection) {
            if ($global:connection.State -eq "Open") {
                $command = $global:connection.CreateCommand()

                $gd = get-date($GebDat) -Format "dd/MM/yyyy"
                $gd=$gd.Replace(".","/");
	            $command.CommandText = "Select * From SIL where NNAME='$Nachname' and VNAME='$Vorname' and GEBDAT=#"+$gd+"#"
                
                #Write-Host "Command is:"+ $command.CommandText

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
   Eine Liste aller Kurse in BBS-Planung liefern
.DESCRIPTION
   Liefert eine Liste aller Kurse in BBS Planung mit den Entitäten
   
   KNR,KNAME,KBEM,KLEHRER,KTHEMA
   
   KNR (Kursnummer, in BBS-Planung Tabelle "KURSE", Spalte "K_NR")
   KBEM (Bemerkungen, in BBS-Planung Tabelle "KURSE", Spalte "BEM", hier steht der Diklabukursname)
   KLEHRER (Kursleiter (wie Klassenlehrer), in BBS-Planung Tabelle "KURSE", Spalte "K_LEHRER")
   KTHEMA (Kursthema, in BBS-Planung Tabelle "KURSE", Spalte "KT1")
   KNAME (Kursname, in BBS-Planung Tabelle "KURSE", Spalte "K_NAME")
   

.EXAMPLE
   get-BPkurs
   Liefert alle Kurse in BBS Planung aus der Tabelle KURSE
.EXAMPLE
   get-BPkurs -knr "42"
   Gibt die Attribute zu Kursnummer 42 zurück
.EXAMPLE
   get-BPkurs -kname "BSFHR16DEr"
   Gibt die Attribute des Kurses BSFHR16DEr zurück
.EXAMPLE
   get-BPkurs -kbem "IT17_WPK_HN_gelb"
   Gibt die Attribute des Kurses mit der Bemerkung IT17_WPK_HN_gelb zurück
   (Besonderheit: das ist die Bezeichnung wie sie im diklabu geführt wird)


#>
function get-BPkurs {

    [CmdletBinding()]
    Param
    (
        # KNR (Kursnummer, in BBS-Planung Tabelle "KURSE", Spalte "K_NR")
        # Kursnummer darf noch nicht für anderen Kurs vergeben sein
        # Wenn keine Kursnummer vergeben wurde,  wird die nächst größere aus allen Kursen gewählt
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$KNR,

        # KNAME (Kursname, in BBS-Planung Tabelle "KURSE", Spalte "K_NAME")
        # Länge maximal 10 Zeichen!
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$KNAME,
        
        # KBEM (Bemerkungen, in BBS-Planung Tabelle "KURSE", Spalte "BEM")
        # Länge maximal 255 Zeichen!
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$KBEM

    )

    Begin {
      # Konfigdaten einlesen, wenn notwendig
      if (!$global:logins.bp) {
       $path=(get-childitem $MyInvocation.PSCommandPath|select directoryname).directoryname
       get-keystore -file "$path\bpconfig.json"
      }
      
      # Verbindung zur Datenbank aufbauen
      $isDBConnectionOpenFromParent=$true #am Ende die Verbindung nur schließen, wenn sie in dieser Funktion auch geöffnet wurde
      try {

          if (!$global:connection -or !($global:connection.State -eq "Open")) {
            connect-BbsPlan -location $global:logins.bp.bpdbpath
            $isDBConnectionOpenFromParent=$false
          }
      }
      catch {
      Write-Error "Verbindung zur Datenbank BBS-Planung konnte nicht geöffnet werden in CMDlet new-BPkurs"
      return
      }


    } #ende begin

    Process {
    # ********************************************* Functions **********************************


    # ********************************************* End Functions **********************************




       $error.Clear()

       try{

        # Query zusammenbauen
        if (!$knr -or $knr -eq "") {
         # Keine Kursnummer angegeben
         if (!$kname -or $kname -eq "") {
          # Auch kein Name angegeben
          if (!$kbem -or $kbem -eq "") {
           # Auch keine Bemerkung angegeben, also kein Parameter
           $q="SELECT K_NR AS KNR,K_NAME AS KNAME,BEM AS KBEM,K_LEHRER AS KLEHRER,KT1 AS KTHEMA FROM KURSE;"
          }
          else {
           # Suche über die Bemerkung/ Kursbezeichnung diklabu
           $q="SELECT K_NR AS KNR,K_NAME AS KNAME,BEM AS KBEM,K_LEHRER AS KLEHRER,KT1 AS KTHEMA FROM KURSE WHERE (BEM='$KBEM');"
          }
         } # ende kein Name angegeben
         else {
         # Name angegeben
         $q="SELECT K_NR AS KNR,K_NAME AS KNAME,BEM AS KBEM,K_LEHRER AS KLEHRER,KT1 AS KTHEMA FROM KURSE WHERE (K_NAME='$KNAME');"
         }
        } # keine Kursnummer angegeben
        else {
         # Hier war eine Kursnummer angegeben
         $q="SELECT K_NR AS KNR,K_NAME AS KNAME,BEM AS KBEM,K_LEHRER AS KLEHRER,KT1 AS KTHEMA FROM KURSE WHERE (K_NR=$KNR);"
        }
        $query=$global:connection.CreateCommand()
        $query.CommandText=$q
        $dataset = New-Object System.Data.DataSet
        $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $query
        $out=$adapter.Fill($dataset)
        return $dataset.Tables[0].rows
       } #ende try
       
       catch {
       write-host ($error|Select-Object FullyQualifiedErrorId).FullyQualifiedErrorId
       $error
       
       }
       
 
    } #Process

    end {

     if(!$isDBConnectionOpenFromParent){
      #nur schließen, wenn die Verbindung innerhalb dieser Funktion aufgebaut wurde
      Disconnect-BbsPlan
     }
    }
   
} #ende get-BPKurs

<#
.Synopsis
   Einen/ mehrere neue/n Kurs/e in BBS-Planung anlegen
.DESCRIPTION
   Legt einen neuen Kurs in BBS-Planung an, bzw. importiert Kurse aus einer CSV Datei
   Der gleiche Kursname darf nicht bereits vorhanden sein, Länge maximal 10 Zeichen!
   Das Lehrerkürzel muss gültig sein, heißt bei den Kürzeln in Tabelle LVUEL.NKURZ auffindbar sein
   Die Kursnummer darf nicht bereits vorhanden sein, sie ist optional, ist sie nicht in der Parameterliste, wird die 
    nächsthöhere aus allen Kursnummern ermittelt und zugewiesen. Als good Practise sollte die Nummer aus dem Diklabu
    verwendet werden
   Kursthema (max. 100 Zeichen), Kursbemerkung (max. 255 Zeichen) und Schulnummer sind optional
   Ist keine Schulnummer übergeben wird diese dem Eintrag in bpconfig.json entnommen

   Zu jedem Kurs in Tabelle KURSE können in Tabelle STD Stunden zugeteilt werden. Dieses CMDlet fügt dem aktuellen Kurs die Einträge
   gemäß aktuellem Funktionsaufruf hinzu.

   Der Header einer csv-Datei sollte also folgendermaßen aussehen (genaue Parameterbeschreibung siehe unten Param(), Kategorie wird nicht genutzt):
   KNR,KBEM,KLEHRER,Kategorie,KTHEMA,KNAME,SCHUL_NR,NRFACHBEZ,KSOLL,KIST,LSOLL,LIST,NKURZ
   
   Aufbau Tabelle STD: 
   id       wird automatisch erzeugt
   SNR      Schulnummer ($SCHuL_NR)
   KL_NAME  Kursname ($KNAME)
   LFD      Kursnummer ($KNR)
   ART      KU (Kurs) oder KL (Klasse), hier also immer auf "KU" setzen
   FACHNR   Laufende schultinerne Nummerierung der Fächer bei Klassen/Kurse-Stunden, fängt Normalerweise bei 1 an (Kursbezogen)
   NR       Referenz zur Tabelle ZUORDNUNG DER FACHBEZEICHNUNGEN... (s.u.), Spalte NR ($NRFACHBEZ)
    FACH     Schulinterne Kurzbezeichnung für das Fach, entspricht Tabelle ZUORDNUNG DER FACHBEZ..., Spalte SCHULBEZOGENES KÜRZEL, Lookup!
    FACHLANG Schulinterne Langbezeichnung für das Fach, entspricht Tabelle ZUORDNUNG DER FACHBEZ..., Spalte SCHULBEZOGENE FACHBEZEICHNUNG, Lookup!
    FACHKURZ Statistische Kurzbezeichnung für das Fach, entspricht Tabelle ZUORDNUNG DER FACHBEZ..., Spalte STATISTIKKÜRZEL, Lookup!
    FACHART  Zeigt Theorie- oder Praxisunterricht an, entspricht Tabelle ZUORDNUNG DER FACHBEZ..., Spalte TFP, Lookup!
    BES      Besonderheiten, z.B. WA für Wahlangebot oder FH für Fachhochschulreife, entspricht Tabelle ZUORDNUNG DER FACHBEZ..., Spalte BES, Lookup!
   KSOLL    Sollstunden für die Klasse (Bei Englisch WPK auf 0 lassen)
   KIST     Iststunden für die Klasse
   LSOLL    Lehrersollstunden (bei Englisch WPK auf 0 lassen)
   LIST     Lehreriststunden
   NKURZ    Lehrerkürzel für die erteilten Stunden im Kurs (muss in LVUEL.NKURZ auffindbar sein) (NICHT unbedingt $KLEHRER !!!)
   P_FAKTOR Auf 0 belassen (für Projektbetreuung ein Faktor für die Lehrerstunden)
   KO       Nicht beschreiben (???)
   FEHLER   Auf 0 setzen (???)

   Die Fachbezeichnungen können der Tabelle "ZUORDNUNG DER FACHBEZEICHNUNGEN (SCHULE-STATISTIK-STDTAFEL)" entnommen werden
   Das dort genannte Feld "Nr" (FBEZNR in diesem CMDlet) ist die Referenz aus den von Diklabu übernommenen Kursen, bzw. einer Zwischentabelle, 
   die zwischen Diklabu-Kursbezeichnungen und BBS-Planung Kursnamen übersetzt
.EXAMPLE
   New-BPkurs -kname "BSFHR16DEr" -klehrer "EK"
   Diese beiden Parameter sind obligatorisch
.EXAMPLE
   New-BPkurs -kname "BSFHR16DEr" -klehrer "EK" -knr "42" -kthema "Deutsch FH-Reife" -kbem "Wird nur in jedem 2. Jahr unterrichet" -schul_nr "75322"
   Alle Parameter benutzt
.EXAMPLE
   Import-Csv kurse.csv | New-BPkurs
   In der csv-Datei müssen mindestens die Parameter KNAME und KLEHRER definiert sein. Es können weitere, auch hier nicht
    ausgewertete Parameter (Spaltenüberschriften) in der csv verwendet werden

#>
function new-BPkurs {

    [CmdletBinding()]
    Param
    (
        # KNAME (Kursname, in BBS-Planung Tabelle "KURSE", Spalte "K_NAME")
        # Länge maximal 10 Zeichen!
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$KNAME,
        
        # KLEHRER (Kursleiter (wie Klassenlehrer), in BBS-Planung Tabelle "KURSE", Spalte "K_LEHRER")
        # Das Lehrerkürzel muss gültig sein, heißt bei den Kürzeln in Tabelle LVUEL.NKURZ auffindbar sein
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$KLEHRER,

        # KNR (Kursnummer, in BBS-Planung Tabelle "KURSE", Spalte "K_NR")
        # Kursnummer darf noch nicht für anderen Kurs vergeben sein
        # Wenn keine Kursnummer vergeben wurde,  wird die nächst größere aus allen Kursen gewählt
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$KNR,

        # KTHEMA (Kursthema, in BBS-Planung Tabelle "KURSE", Spalte "KT1")
        # Länge maximal 100 Zeichen!
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$KTHEMA,

        # KBEM (Bemerkungen, in BBS-Planung Tabelle "KURSE", Spalte "BEM")
        # Länge maximal 255 Zeichen!
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$KBEM,

        # SCHUL_NR (BBS-Planung Nr. der Schule. in BBS-Planung Tabelle "KURSE", Spalte "SNR")
        # Multi Media BbS 75322
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$SCHUL_NR,

        # NRFACHBEZ (Referenz zur Tabelle ZUORDNUNG DER FACHBEZEICHNUNGEN..., Spalte NR. In Tabelle STD, Spalte NR)
        # Multi Media BbS 75322
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$NRFACHBEZ,

        # KSOLL (Sollstunden für die Klasse (Bei Englisch WPK auf 0 lassen))
        # Multi Media BbS 75322
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$KSOLL,

        # KIST (Iststunden für die Klasse)
        # Multi Media BbS 75322
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$KIST,

        # LSOLL (Lehrersollstunden (bei Englisch WPK auf 0 lassen))
        # Multi Media BbS 75322
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$LSOLL,

        # LIST (Lehreriststunden)
        # Multi Media BbS 75322
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$LIST,

        # NKURZ (Lehrerkürzel für die erteilten Stunden im Kurs (muss in LVUEL.NKURZ auffindbar sein) (NICHT unbedingt $KLEHRER !!!))
        # Multi Media BbS 75322
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$NKURZ,


        # whatif true liest alle Werte ein und gibt Fehlermeldungen aus, wenn z.B. ein String zu lang ist
        # oder das Lehrerkürzel nicht auffindbar ist, legt aber den Kurs nicht in BBS-Planung an
        [switch]$whatif=$false

    )

    Begin {
      # Konfigdaten einlesen, wenn notwendig
      if (!$global:logins.bp) {
       $path=(get-childitem $MyInvocation.PSCommandPath|select directoryname).directoryname
       get-keystore -file "$path\bpconfig.json"
      }
      
      # Verbindung zur Datenbank aufbauen
      $isDBConnectionOpenFromParent=$true #am Ende die Verbindung nur schließen, wenn sie in dieser Funktion auch geöffnet wurde
      try {

          if (!$global:connection -or !($global:connection.State -eq "Open")) {
            connect-BbsPlan -location $global:logins.bp.bpdbpath
            $isDBConnectionOpenFromParent=$false
          }
      }
      catch {
      Write-Error "Verbindung zur Datenbank BBS-Planung konnte nicht geöffnet werden in CMDlet new-BPkurs"
      return
      }


    } #ende begin

    Process {
    # ********************************************* Functions **********************************
    function isLehrerInLVUEL{
      # Lehrerkürzel auf Vorhandensein in Tabelle LVUEL testen
      # DB Connection muss auf sein
      Param(
       [String]$kurz # Lehrerkürzel
       )
       $query=$global:connection.CreateCommand()
       $query.CommandText="SELECT NKURZ FROM LVUEL WHERE (NKURZ='$kurz');" #
       $dataset = New-Object System.Data.DataSet
       $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $query
       $out=$adapter.Fill($dataset)
       if ($dataset.Tables[0].rows.Count -eq 0) {
           # keine Zeilen --> Lehrer nicht gefunden
           return $false
       }
       else {
        return $true
       }

    } # Ende isLehrerInLVUEL

    # ********************************************* End Functions **********************************




       $error.Clear()

       try{
        # Prüfen, ob die Parameter nicht zu lang sind
        if($KNAME.Length -gt 10){
         throw $("new-BPkurs: Kurs "+$KNAME+ " konnte nicht angelegt werden, weil Kursname (KNAME=$KNAME) die Maximallänge von 10 Zeichen überschreitet!")
           
        }

        if($KTHEMA.Length -gt 100){
         throw $("new-BPkurs: Kurs "+$KNAME+ " konnte nicht angelegt werden, weil Kursthema (KTHEMA=$KTHEMA) die Maximallänge von 100 Zeichen überschreitet!")
           
        }

        if($KBEM.Length -gt 255){
         throw $("new-BPkurs: Kurs "+$KNAME+ " konnte nicht angelegt werden, weil Bemerkung (KBEM=$KBEM) die Maximallänge von 255 Zeichen überschreitet!")
           
        }

        # Kursleiterkürzel auf Vorhandensein in Tabelle LVUEL testen
        if ((isLehrerInLVUEL $KLEHRER) -eq $false) {
            # Kursleiter nicht gefunden
            throw $("new-BPkurs: Kurs "+$KNAME+ " konnte nicht angelegt werden, weil Lehrer "+$KLEHRER+" noch nicht in BBS Planung, Tabelle LVUEL angelegt ist!")
        }

        # Prüfen, ob dieser Kurs schon angelegt ist
        # Falls schon vorhanden, muss sowohl die Nummer als auch die Schulnummer des neu anzulegenden Kurses mit der bereits eingetragenen übereinstimmen
        # Ist das nicht der Fall, muss abgebrochen werden
        # Falls Kurs noch nicht vorhanden, dann anlegen
        $query=$global:connection.CreateCommand()
        $query.CommandText="SELECT K_NAME FROM KURSE WHERE (K_NAME='$KNAME');" #
        $dataset = New-Object System.Data.DataSet
        $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $query
        $out=$adapter.Fill($dataset)
        if ($dataset.Tables[0].rows.Count -ne 0) {
             # --> Kurs gefunden, prüfen, ob die Kursnummer mit der neu anzulegenden Nummer übereinstimmt
             $query=$global:connection.CreateCommand()
             $query.CommandText="SELECT K_NR FROM KURSE WHERE (K_NAME='$KNAME');" #
             $dataset = New-Object System.Data.DataSet
             $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $query
             $out=$adapter.Fill($dataset)
             if (($dataset.Tables[0].rows[0]).K_NR -ne $KNR) {
               # Daten aus neu anzulegendem Kurs und bereits vorhandenem stimmen nicht überein
               throw $("new-BPkurs: Kurs "+$KNAME+ " konnte nicht angelegt werden, weil Kurs "+$KNAME+" bereits vorher in BBS Planung, Tabelle KURSE angelegt wurde UND die Kursnummern nicht übereinstimmen!")
             }
             
             #Jetzt noch checken, ob auch die Schulnummern gleich sind
             $query=$global:connection.CreateCommand()
             $query.CommandText="SELECT SNR FROM KURSE WHERE (K_NAME='$KNAME');" #
             $dataset = New-Object System.Data.DataSet
             $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $query
             $out=$adapter.Fill($dataset)
             if (($dataset.Tables[0].rows[0]).SNR -ne $SCHUL_NR) {
               # Daten aus neu anzulegendem Kurs und bereits vorhandenem stimmen nicht überein
               throw $("new-BPkurs: Kurs "+$KNAME+ " konnte nicht angelegt werden, weil Kurs "+$KNAME+" bereits vorher in BBS Planung, Tabelle KURSE angelegt wurde UND die Schulnummern nicht übereinstimmen!")
             }

        } # ende Kurs gefunden, prüfen, ob die Kursnummer mit der neu anzulegenden Nummer übereinstimmt
        else {
         # Kursname wurde nicht gefunden, also neu anlegen
         # Falls keine Schulnummer angegeben ist, die Defaultnummer einsetzen
         if ($SCHUL_NR -eq "") {
           $SCHUL_NR = $global:logins.bp.bpschulnr
         }
         # Falls keine Kursnummer angegeben ist, Maximalwert aller Kurse herausfinden und um 1 inkrementieren als neue Kursnummer
         if ($KNR -eq ""){
          $query=$global:connection.CreateCommand()
          $query.CommandText="SELECT MAX (K_NR) AS KNRMAX FROM KURSE;" #
          $dataset = New-Object System.Data.DataSet
          $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $query
          $out=$adapter.Fill($dataset)
          $KNR = ($dataset.Tables[0].rows[0]).KNRMAX  + 1
          write-verbose ("new-BPkurs: Kursnummer (K_NR) für Kurs " +$KNAME + " auf " + $KNR +" gesetzt")
         }
         else {
          # Immer noch: Neuen Kurs anlegen, daher: Es wurde eine Kursnummer angegeben, daher testen, ob sie schon anderweitig verwendet wurde
          $query=$global:connection.CreateCommand()
          $query.CommandText="SELECT K_NR FROM KURSE WHERE (K_NR=$KNR);" #
          $dataset = New-Object System.Data.DataSet
          $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $query
          $out=$adapter.Fill($dataset)
          if ($dataset.Tables[0].rows.Count -ne 0) {
             # --> Kursnummer gefunden, bzw. ist schon vergeben
             throw $("new-BPkurs: Kurs "+$KNAME+ " konnte nicht angelegt werden, weil Kursnummer "+$KNR+" bereits vorher in BBS Planung, Tabelle KURSE verwendet wurde!")
          }
         }
         # alles okay bis hierher ---> Kurs anlegen
         if (!$whatif){
        
          $cmd=$global:connection.CreateCommand()
          $cmd.CommandText="INSERT INTO KURSE (K_NAME,K_LEHRER,K_NR,KT1,BEM,SNR,KO,FEHLER) VALUES('$KNAME','$KLEHRER','$KNR','$KTHEMA','$KBEM','$SCHUL_NR','00','1');"
          $cmd.ExecuteNonQuery()
         }
         else {
          write-verbose ("new-BPkurs: Kurs "+$KNAME+ " konnte nicht angelegt werden, weil Testmodus mit Schalter -whatif gesetzt wurde!")
         }

        } # Ende Kurs neu anlegen
        # An dieser Stelle gibt es auf jeden Fall einen neuen (oder alten) Kurs
        # Falls vorhanden, müssen nun alle Stunden und Lehrer in die Unterrichtstabelle STD eingetragen werden
        # Ist die Summe alle vier Stundenarten = 0, wird nichts in STD eingetragen
        #   Mit dieser Vereinbarung können Kurse ohne Stundeneinträge angelegt werden
        # Sind Stunden angegeben, so werden zunächst alle alten Einträge in STD bezüglich dieses Kurses gelöscht
        # Das Lehrerkürzel muss vorhanden sein in LVUEL

        # Erstmal Stundensumme überprüfen
        $stdsumme=[decimal]$KSOLL.replace(",",".")+[decimal]$KIST.replace(",",".")+[decimal]$LSOLL.replace(",",".")+[decimal]$LIST.replace(",",".")
        if($stdsumme -gt 0){
         # es soll ein Datensatz in STD eingetragen werden
         if ((isLehrerInLVUEL $NKURZ) -eq $false){
          # Lehrerkürzel nicht gefunden
          throw $("new-BPkurs: Kurs "+$KNAME+ " konnte nicht angelegt werden, weil Lehrer "+$NKURZ+" noch nicht in BBS Planung, Tabelle LVUEL angelegt ist!")
         }
         else{
          # Lehrer vorhanden, Datensatz anlegen
          if (!$whatif){
           # Erstmal bis jetzt höchste vergebene Unterrichtsnummer herausfinden
           
           $query=$global:connection.CreateCommand()
           $query.CommandText="SELECT MAX (FACHNR) AS FACHNRMAX FROM STD WHERE (ART='KU');" #WHERE (ART='KU' AND LFD=$KNR)
           $dataset = New-Object System.Data.DataSet
           $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $query
           $out=$adapter.Fill($dataset)
           if (([DBNull]::Value).Equals($dataset.Tables[0].rows[0].FACHNRMAX)) {
            # keine Einträge gefunden
            $FACHNR=1
           }
           else{
            $FACHNR = $dataset.Tables[0].rows[0].FACHNRMAX  + 1
           }

           write-verbose ("new-BPkurs: Laufende Nummer für Stunden eines Kurses (FACHNR) für Kurs " +$KNAME + " auf " + $FACHNR +" gesetzt")

           # In 'ZUORDNUNG DER FACHBEZEICHNUNGEN (SCHULE-STATISTIK-STDTAFEL)' abfragen: Fach, Fachlang, Fachkurz, Fachart, Bes
           $query=$global:connection.CreateCommand()
           $query.CommandText="SELECT [Schulbezogene Fachbezeichnung] AS FACHLANG,[Schulbezogenes Kürzel] AS FACH, Statistikkürzel AS FACHKURZ,TFP,BES FROM [ZUORDNUNG DER FACHBEZEICHNUNGEN (SCHULE-STATISTIK-STDTAFEL)] WHERE (NR=$NRFACHBEZ);" #
           $dataset = New-Object System.Data.DataSet
           $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $query
           $out=$adapter.Fill($dataset)
           $FACHBEZ = $dataset.Tables[0].rows[0]
           if ($dataset.Tables[0].rows.Count -eq 0) {
             # --> Nr nicht gefunden in ZUORDNUNG DER FACHBEZEICHNUNGEN (...
             throw $("new-BPkurs: Kurs "+$KNAME+ " konnte nicht angelegt werden, weil Fachbezeichnungsnummer "+$NRFACHBEZ+" nicht in Tabelle 'ZUORDNUNG DER FACHBEZEICHNUNGEN (SCHULE-STATISTIK-STDTAFEL)' gefunden wurde!")
           }
           
           
           $cmd=$global:connection.CreateCommand()
           $cmd.CommandText="INSERT INTO STD (SNR,KL_NAME,LFD,ART,Nr,FACHNR,FACH,FACHLANG,FACHKURZ,FACHART,KSOLL,KIST,LSOLL,LIST,NKURZ,"`
            +$(if(![dbnull]::value.Equals($fachbez.bes)){"BES,"})+"P_FAKTOR,FEHLER) "`
            +"VALUES($SCHUL_NR,'$KNAME',$KNR,'KU',$NRFACHBEZ,$FACHNR,'$($FACHBEZ.FACH)','$($FACHBEZ.FACHLANG)','$($FACHBEZ.FACHKURZ)','$($FACHBEZ.TFP)', "`
            +"$($KSOLL.Replace(",",".")),$($KIST.Replace(",",".")),$($LSOLL.Replace(",",".")),$($LIST.Replace(",",".")),'$NKURZ',"+$(if(![dbnull]::value.Equals($fachbez.bes)){"'$($FACHBEZ.BES)',"})+"0,1);"
           $cmd.ExecuteNonQuery()
          }
          else {
           write-verbose ("new-BPkurs: Stundeneintrag zu Kurs "+$KNAME+ " konnte nicht angelegt werden, weil Testmodus mit Schalter -whatif gesetzt wurde!")
          }
         }  # ende else, Lehrer vorhanden, Datensatz anlegen
        } # ende es soll ein Datensatz in STD eingetragen werden
       } #ende try
       
       catch {
       write-host ($error|Select-Object FullyQualifiedErrorId).FullyQualifiedErrorId
       $error
       
       }
       
 
    } #Process

    end {

     if(!$isDBConnectionOpenFromParent){
      #nur schließen, wenn die Verbindung innerhalb dieser Funktion aufgebaut wurde
      Disconnect-BbsPlan
     }
    }
   
} # ende new-BPKurs

<#
.Synopsis
   Einen/ mehrere neue/n Kurs/e in BBS-Planung löschen
.DESCRIPTION
   Löscht einen Kurs aus BBS-Planung. Dabei sind drei Tabellen betroffen. Die Schülerzugehörigkeit wird in der 
   Tabelle SIL, also direkt im Schülerdatensatz in den Feldern K1/ K_NR1 bis K15/ K_NR15 mit Kursname und Kursnummer
   eingetragen. Die Unterrichtsstunden werden in der Tabelle STD hinterlegt und die eigentlichen Kursdaten in der 
   Tabelle KURSE.

   An remove-BPKurs kann entweder die Kursnummer, der BBS Planung Kursname oder der Diklabu Kursname übergeben werden. 
   Ist mehreres übergeben, wird die Nummer als Suchkriterium gewählt, dann BBS-Planungname, dann diklabu. 
   Wenn unter Bemerkungen in Tabelle "KURSE", Spalte "BEM", der Diklabuname angegeben ist, kann auch so ein
   Kurs bei einem Schüler gelöscht werden. Der Diklabuname wird dann per lookup in der Tabelle KURSE in 
   eine Kursnummer konvertiert.
   Ist nichts angegeben, wird das CMDlet mit einer Fehlermeldung (throw) verlassen
   
   Die Löschung erfolgt in vier Schritten:
   1. Kursnummer ermitteln (eventuell über einen Lookup in KURSE, wenn nur der Kursname angegeben ist)
   2. remove-BPKursTN über alle Schülerdatensätze ausführen, um alle Teilnehmer zu löschen
   3. Alle Einträge zu Unterrichtsstunden in STD löschen
   4. Die Kursdaten aus KURSE löschen
  
   Der Header einer csv-Datei sollte also folgendermaßen aussehen (genaue Parameterbeschreibung siehe unten Param(), Kategorie wird nicht genutzt):
   KNR,KNAME,KNAMEDIKLABU (Kursnummer, Kursname, Kursname Diklabu)

.EXAMPLE
   remove-BPkurs -knr 1896
   Löscht den Kurs mit der Kursnummer 1896
   
.EXAMPLE
   remove-BPkurs -kname "BSFHR16DEr"
   Löscht den Kurs mit dem Namen BSFHR16DEr

.EXAMPLE
   Import-Csv kurse.csv | remove-BPkurs
   In der csv-Datei muss mindestens einer der Parameter KNR, KNAME oder KNMAEDIKLABU definiert sein. Es können weitere, auch hier nicht
    ausgewertete Parameter (Spaltenüberschriften) in der csv verwendet werden

#>
function remove-BPkurs {

    [CmdletBinding()]
    Param
    (
        # KNR (Kursnummer, in BBS-Planung Tabelle "KURSE", Spalte "K_NR")
        # Kursnummer darf noch nicht für anderen Kurs vergeben sein
        # Wenn keine Kursnummer vergeben wurde,  wird die nächst größere aus allen Kursen gewählt
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$KNR,

        # KNAME (Kursname, in BBS-Planung Tabelle "KURSE", Spalte "K_NAME")
        # Länge maximal 10 Zeichen!
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$KNAME,
        
        # KNAMEDIKLABU (Kursname, in BBS-Planung Tabelle "KURSE", Spalte "BEM", 
        # wird dann umgerechnet in K_NR in Tabelle SIL beim Schüler "K_NR{1..15}))
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$KNAMEDIKLABU,

        # whatif true liest alle Werte ein und gibt Fehlermeldungen aus, wenn z.B. ein String zu lang ist
        # oder das Lehrerkürzel nicht auffindbar ist, legt aber den Kurs nicht in BBS-Planung an
        [switch]$whatif=$false,

        # all = true löscht komplett alle Kurse und Stunden sowie alle Teilnehmer
        [switch]$all=$false


    )

    Begin {
      # Konfigdaten einlesen, wenn notwendig
      if (!$global:logins.bp) {
       $path=(get-childitem $MyInvocation.PSCommandPath|select directoryname).directoryname
       get-keystore -file "$path\bpconfig.json"
      }
      
      # Verbindung zur Datenbank aufbauen
      $isDBConnectionOpenFromParent=$true #am Ende die Verbindung nur schließen, wenn sie in dieser Funktion auch geöffnet wurde
      try {

          if (!$global:connection -or !($global:connection.State -eq "Open")) {
            connect-BbsPlan -location $global:logins.bp.bpdbpath
            $isDBConnectionOpenFromParent=$false
          }
      }
      catch {
      Write-Error "Verbindung zur Datenbank BBS-Planung konnte nicht geöffnet werden in CMDlet new-BPkurs"
      return
      }


    } #ende begin

    Process {
    # ********************************************* Functions **********************************
    function prot{
     # Ausgabe eines Kommentares in die Protokolldatei
     param(
      [String]$t
     )
     $t=(get-date -format "hh:mm:ss") +": "+ $t
     $t|out-file -filepath ($global:logins.bp.protpath+"\remove-BPKurs-Prot-"+$(Get-Date -Format 'yyyy-MM-dd-hh-mm-ss')+".TXT") -Append

    }

    function msg{
        # Ausgabe einer Bildschirmmeldung
        param(
            [String]$t,
            [datetime]$dt
        )

        if($dt){
            # Zeitdifferenz ausgeben, wenn eine Zeit übergeben wurde (für Dauer einer Befehlsausführung)
            [datetime]$end = get-date
            $t+=": "
            $t+=(new-timespan -start $dt -end $end).Seconds
            $t+=" Sekunden"
        }
        prot $t
        write-host $t
        # Zeit nur zurückgeben, wenn keine Zeit übergeben wurde
        if(!$dt) {return (get-date)}
    }
    # ********************************************* End Functions **********************************

       $error.Clear() > $null

       try{

        #*** 1. Kursnummer ermitteln (eventuell über einen Lookup in KURSE, wenn nur der Kursname angegeben ist) ***

        # Datenbank vorbereiten
        $query=$global:connection.CreateCommand()
        $dataset = New-Object System.Data.DataSet
        $adapter = New-Object System.Data.OleDb.OleDbDataAdapter

        # Switch -all überprüfen und evtl. alle Kurse löschen
        if($all){
         if(!$whatif) {
            $s=msg "$KNAME : 2. remove-BPKursTN über alle Schülerdatensätze ausführen, um alle Kursteilnehmer aus allen Kursen zu löschen"
            
            remove-BPKursTN  -silent -SOSVNAME "*" -SOSNNAME "*" -SOSKLASSE "*" 

            
            msg "$KNAME : Geschafft: 2. remove-BPKursTN über alle Schülerdatensätze ausführen, um alle Kursteilnehmer aus allen Kursen zu lösche"

            #***   3. Alle Einträge zu Unterrichtsstunden in STD löschen ***
            $cmd=$global:connection.CreateCommand()
            $cmd.CommandText="DELETE FROM STD WHERE (ART='KU');"
            $cmd.ExecuteNonQuery() > $null


            #***   4. Die Kursdaten aus KURSE löschen ***
            $cmd.CommandText="DELETE FROM KURSE;"
            $cmd.ExecuteNonQuery() > $null

         } # ende whatif
        else {
         write-verbose ("remove-BPkurs: Kurs "+$KNAME+ " konnte nicht gelöscht werden, weil Testmodus mit Schalter -whatif gesetzt wurde!")

         }
 

        } # ende mit if($all){

        else{
         # Prüfen, welcher der Kursparameter übergeben wurde
        if(!$KNR -or ($KNR -le 0)) {
            # keine Kursnummer angegeben

            if ($KNAME -and ($KNAME -ne "")) {
            # KNAME für Tabelle KURSE angegeben
            $query.CommandText="SELECT K_NR, K_NAME FROM KURSE WHERE (K_NAME='$KNAME');" #
            }
            elseif ($KNAMEDIKLABU -and ($KNAMEDIKLABU -ne "")) {
            $query.CommandText="SELECT K_NR, K_NAME FROM KURSE WHERE (BEM='$KNAMEDIKLABU');" #
            }
            else {
                # gar kein Übergabeparameter
                throw $("remove-BPKurs: Kann Kurs nicht löschen: weder Kursnummer, noch Kursname, noch Kursnamediklabu an remove-BPKurs übergeben!")
            }
        } # ende mit Kursnummern über die Namen suchen
        else {
            # einfachste Variante: KNR ist angegeben
            $query.CommandText="SELECT K_NR, K_NAME FROM KURSE WHERE (K_NR=$KNR);" #
        }

        # Hier ist das geeignete Querycommand zusammengesetzt und kann nun ausgeführt werden. Es liefert KNR und KNAME
        # Prüfen, ob diese Kursnummer schon angelegt ist

        $adapter.SelectCommand = $query
        $out=$adapter.Fill($dataset)
        if ($dataset.Tables[0].rows.Count -eq 0) {
            # keine Zeilen --> Kurs nicht gefunden
            throw $("remove-BPKurs: Kann Kurs mit Nr. $KNR nicht löschen: Kursnummer nicht gefunden in Tabelle KURSE!")
        }
        # Kursnamen merken für später
        $KNR=$dataset.Tables[0].rows[0].K_NR
        $KNAME=$dataset.Tables[0].rows[0].K_NAME

        # ab hier gibt es auf jeden Fall eine gültige Kursnummer und der BBS Planungname ist auch verfügbar
        # Der Kurs existiert auch tatsächlich

        #***   2. remove-BPKursTN über alle Schülerdatensätze ausführen, um alle Teilnehmer zu löschen ***

        # Alle Schülerdatensätze nach Name, Vorname und Klasse abfragen
 
        $s=msg "$KNAME : Alle Schülerdatensätze mit Eintrag $KNR nach Name, Vorname und Klasse abfragen"
        # Querystring zusammenstellen
        $q="SELECT VNAME,NNAME,KL_NAME FROM SIL WHERE("
        for ($i=1;$i -lt 15;$i++) {
          $q+=("K_NR"+$i+"="+$KNR+" OR ")
        }
        $q+="K_NR15="+$KNR+");"

        $query.CommandText = $q
        $dataset.Clear()
        $adapter.SelectCommand = $query
        $out=$adapter.Fill($dataset)
        $rowcount=$dataset.Tables[0].rows.Count
        msg "$KNAME : Geschafft: Alle Schülerdatensätze mit Eintrag $KNR nach Name, Vorname und Klasse abfragen"

        if(!$whatif) {
            $s=msg "$KNAME : 2. remove-BPKursTN über alle Schülerdatensätze ausführen, um alle Teilnehmer zu löschen"
            for($i=0;$i -lt $rowcount;$i++) {
             remove-BPKursTN  -silent -SOSVNAME $dataset.Tables[0].rows[$i].VNAME -SOSNNAME $dataset.Tables[0].rows[$i].NNAME -SOSKLASSE $dataset.Tables[0].rows[$i].KL_NAME -KNR $KNR 

            }
            msg "$KNAME : Geschafft: 2. remove-BPKursTN über alle Schülerdatensätze ausführen, um alle Teilnehmer zu löschen"

            #***   3. Alle Einträge zu Unterrichtsstunden in STD löschen ***
            $cmd=$global:connection.CreateCommand()
            $cmd.CommandText="DELETE FROM STD WHERE (ART='KU' AND LFD=$KNR);"
            $cmd.ExecuteNonQuery() > $null


            #***   4. Die Kursdaten aus KURSE löschen ***
            $cmd.CommandText="DELETE FROM KURSE WHERE (K_NR=$KNR);"
            $cmd.ExecuteNonQuery() > $null

        } # ende whatif
        else {
         write-verbose ("remove-BPkurs: Kurs "+$KNAME+ " konnte nicht gelöscht werden, weil Testmodus mit Schalter -whatif gesetzt wurde!")

        }
       }

       } #ende try
       
       catch {
       write-host ($error|Select-Object FullyQualifiedErrorId).FullyQualifiedErrorId
       # $error
       
       }
     
 
    } #Process

    end {

     if(!$isDBConnectionOpenFromParent){
      #nur schließen, wenn die Verbindung innerhalb dieser Funktion aufgebaut wurde
      Disconnect-BbsPlan
     }
    }
   
} #ende remove-BPKurs

<#
.Synopsis
   Ordnet einem Schüler in BBS Planung einen Kurs zu
.DESCRIPTION
   Ordnet einem Schüler in BBS Planung einen Kurs zu. Überprüft dabei anhand der Kursnummer (Geschwindigkeitsaspekt), 
   ob dieser Kurs in der Tabelle KURSE vorhanden ist und ob er dem SoS bereits zugeordnet ist. 
   Sollte das der Fall sein, wird dieser Kurs nicht noch einmal zugeordnet.
   Die ebenfalls in die Tabelle SIL einzutragende Kursbezeichnung wird anhand der Kursnummer aus der Tabelle KURSE abgefragt
   Die Eindeutigkeit der Schüleridentität wird bei gleichen Werten für Nachname (sosnname), Vorname (sosvname) und
   Klassenbezeichnung (sklasse) vorausgesetzt. Die Eindeutigkeit wird überprüft. Sollte es zwei SoS mit 
   gleichen Werten geben, wird die Eintragung des Kurses abgebrochen bei Ausgabe einer Fehlermeldung.
.EXAMPLE
   add-BPKursTN -sosnname "Meier" -sosvname "Fritzchen" -sosklasse "FISI16X" -knr "3"
.EXAMPLE
   Import-Csv kursTN.csv | add-BPKursTN
   In der csv-Datei müssen mindestens die Parameter SOSNNAME, SOSVNAME, SOSKLASSE und KNR definiert sein. Good
   Practise ist, wenn die Kursnummer der zugehörigen Kurs ID im Diklabu entspricht. Auch wenn das im Moment nicht
   ausgewertet wird, sollte die diklabu Schüler ID mit übermittelt werden (SOSID)  
   Es können weitere, auch hier nicht ausgewertete Parameter (Spaltenüberschriften) in der csv verwendet werden
   Zum Beispiel die Kursbezeichnung (Schreibweise Diklabu oder/ und BBS Planung)

#>
function add-BPKursTN {
    [CmdletBinding()]
   
    Param (
   
           # SOSNNAME (Schülernachname, in BBS-Planung Tabelle "SIL", Spalte NNAME")
           # 
           [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
           [String[]]$SOSNNAME,
   
           # SOSVNAME (Schülervorname, in BBS-Planung Tabelle "SIL", Spalte VNAME")
           # 
           [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
           [String[]]$SOSVNAME,
   
           # SOSKLASSE (Klassenname, in BBS-Planung Tabelle "SIL", Spalte KL_NAME")
           # 
           [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
           [String[]]$SOSKLASSE,
           
           # KNR (Kursnummer, in BBS-Planung Tabelle "KURSE", Spalte "K_NR", bzw. in Tabelle SIL beim Schüler "K_NR{1..15}))
           # Good Practise ist, wenn die Kursnummer der zugehörigen Kurs ID im Diklabu entspricht
           [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
           [String[]]$KNR,
   
           # SOSID (Eindeutige Schülernummer, in BBS-Planung Tabelle "SIL", Spalte "???", bzw. in Diklabu)
           # Wird im Moment noch nicht ausgewertet
           [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
           [String[]]$SOSID,
           
           # whatif true liest alle Werte ein und gibt Fehlermeldungen aus, wenn z.B. ein Kurs nicht gelistet ist
           # oder der Schüler nicht eindeutig ist, legt aber die Kurszuordnung nicht in BBS-Planung an
           [switch]$whatif=$false
   
    )
   
    Begin {
         # Konfigdaten einlesen, wenn notwendig
         if (!$global:logins.bp) {
          $path=(get-childitem $MyInvocation.PSCommandPath|select directoryname).directoryname
          get-keystore -file "$path\bpconfig.json"
         }
         
         # Verbindung zur Datenbank aufbauen
         $isDBConnectionOpenFromParent=$true #am Ende die Verbindung nur schließen, wenn sie in dieser Funktion auch geöffnet wurde
         try {
   
             if (!$global:connection -or !($global:connection.State -eq "Open")) {
               connect-BbsPlan -location $global:logins.bp.bpdbpath
               $isDBConnectionOpenFromParent=$false
             }
         }
         catch {
         Write-Error "Verbindung zur Datenbank BBS-Planung konnte nicht geöffnet werden in CMDlet new-BPkurs"
         return
         }
   
       } #ende begin
   
   
    Process {
      # ********************************************* Functions **********************************
      function prot{
       # Ausgabe eines Kommentares in die Protokolldatei
       param(
        [String]$t
       )
       $t=(get-date -format "hh:mm:ss") +": "+ $t
       $t|out-file -filepath ($global:logins.bp.protpath+"\add-BPKursTN-Prot-"+$(Get-Date -Format 'yyyy-MM-dd')+".TXT") -Append
   
      }
   
      function msg{
          # Ausgabe einer Bildschirmmeldung
          param(
              [String]$t,
              [datetime]$dt
          )
   
          if($dt){
              # Zeitdifferenz ausgeben, wenn eine Zeit übergeben wurde (für Dauer einer Befehlsausführung)
              [datetime]$end = get-date
              $t+=": "
              $t+=(new-timespan -start $dt -end $end).Seconds
              $t+=" Sekunden"
          }
          prot $t
          write-host $t
          # Zeit nur zurückgeben, wenn keine Zeit übergeben wurde
          if(!$dt) {return (get-date)}
      }
      # ********************************************* End Functions **********************************
   
   
    $error.Clear() > $null
    try{
   
     # Prüfen, ob dieser Kurs schon angelegt ist
     $query=$global:connection.CreateCommand()
     $query.CommandText="SELECT K_NR, K_NAME FROM KURSE WHERE (K_NR=$KNR);" #
     $dataset = New-Object System.Data.DataSet
     $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $query
     $out=$adapter.Fill($dataset)
     if ($dataset.Tables[0].rows.Count -eq 0) {
          # keine Zeilen --> Kurs nicht gefunden
          throw $("Kursnummer "+$knr+" noch nicht in BBS Planung angelegt!")
     }
     else{
      # Kursnamen merken für später
      $KNAME=$dataset.Tables[0].rows[0].K_NAME
     }
     
   
     # Prüfen, ob SoS schon für diesen Kurs registriert ist
     $query.CommandText="SELECT * FROM SIL WHERE (NNAME='$sosnname' AND VNAME='$sosvname' AND KL_NAME='$sosklasse');" #
     $dataset.Clear() > $null
     $adapter.SelectCommand = $query
     $out=$adapter.Fill($dataset)
     if ($dataset.Tables[0].rows.Count -ne 1) {
          # es darf nur ein SoS ermittelt worden sein!
          throw $(";"+$sosklasse+";"+$sosnname+";"+$sosvname+"; nicht eindeutig, es wurden " + $dataset.Tables[0].rows.Count +" Einträge gefunden!;"+$kname+";"+$knr)
     }
     $i=1
     $isSoSeingebuchtInKurs=$false
     while (($i -le 15) -and !$isSoSeingebuchtInKurs){
      # alle 15 Kursfelder in SIL Schülerdatensatz untersuchen, ob Kurs bereits eingetragen ist
      if ($dataset.Tables[0][0].@("K_NR"+$i) -eq $knr){
       write-verbose ("Kursnummer "+$knr+" bereits registriert bei "+$sosvname+" "+$sosnname+", Klasse "+$sosklasse+", in K_NR"+$i)
       $isSoSeingebuchtInKurs=$true
      }
      $i++
     }
   
     if (!$isSoSeingebuchtInKurs){
        
         # Nächstes freies Feld (K1 bis K15) in BBS-Planung, Tabelle SIL, ermitteln und Kurs beim SoS eintragen 
         $found=$false
         $i=1
         while (!$found -and ($i -le 15)){
          if (([DBNull]::Value).Equals($dataset.Tables[0].rows[0].@("K_NR"+$i))) {
             $cmd=$global:connection.CreateCommand()
             $cmd.CommandText="UPDATE SIL SET K$i='$kname',K_NR$i=$KNR WHERE (KL_NAME='$sosklasse' AND NNAME='$sosnname' AND VNAME='$sosvname');"
             $cmd.ExecuteNonQuery() > $null
             $found=$true
          }
          else{
             $i++
          }
          if ($i -gt 15){
            ## schlecht gelaufen, zu viele Kurse beim SoS registriert
            throw $("Kein freies Feld zum Eintragen des Kurses bei Schüler/-in "+$sosvname+" "+$sosnname+" in Klasse "+$sosklasse+" gefunden!")
          }
         } #ende while(!$found...
      } # ende if (!$isSoSeingebuchtInKurs)
     
    } #ende try
    catch{
     # prot ($error|Select-Object FullyQualifiedErrorId).FullyQualifiedErrorId
     msg ($error|Select-Object FullyQualifiedErrorId).FullyQualifiedErrorId
     # $error
   
    }
   } # ende Process
   
   end {
   
        if(!$isDBConnectionOpenFromParent){
         #nur schließen, wenn die Verbindung innerhalb dieser Funktion aufgebaut wurde
         Disconnect-BbsPlan
        }
        
       }
      
   } # ende add-BPKursTN
   

<#
.Synopsis
   Liefert alle Schüler eines Kurses in BBS Planung
.DESCRIPTION
   Liefert alle Schüler eines Kurses in BBS Planung
.EXAMPLE
   get-BPKursTN -KNAME "EN-WN34b"
   Liefert eine Liste mit Teilnehmern, die den Kurs "EN-WN34b" besuchen
.EXAMPLE
   get-BPKurs|where-object {$_.KNAME -like "EN*"}|get-BPKursTN
   Liefert alle Schüler aus Kursen, deren Name mit "EN" anfängt

#>
function get-BPKursTN {
    [CmdletBinding()]
   
    Param (
   
           # KNAME (wie er bei BBS Planung im Feld Gruppe/Kurs steht)
           # 
           [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
           [String]$KNAME        
   
    )
   
    Begin {
         # Konfigdaten einlesen, wenn notwendig
         if (!$global:logins.bp) {
          $path=(get-childitem $MyInvocation.PSCommandPath|select directoryname).directoryname
          get-keystore -file "$path\bpconfig.json"
         }
         
         # Verbindung zur Datenbank aufbauen
         $isDBConnectionOpenFromParent=$true #am Ende die Verbindung nur schließen, wenn sie in dieser Funktion auch geöffnet wurde
         try {
   
             if (!$global:connection -or !($global:connection.State -eq "Open")) {
               connect-BbsPlan -location $global:logins.bp.bpdbpath
               $isDBConnectionOpenFromParent=$false
             }
         }
         catch {
         Write-Error "Verbindung zur Datenbank BBS-Planung konnte nicht geöffnet werden in CMDlet new-BPkurs"
         return
         }
   
       } #ende begin
   
   
    Process {
      # ********************************************* Functions **********************************
      function prot{
       # Ausgabe eines Kommentares in die Protokolldatei
       param(
        [String]$t
       )
       $t=(get-date -format "hh:mm:ss") +": "+ $t
       $t|out-file -filepath ($global:logins.bp.protpath+"\add-BPKursTN-Prot-"+$(Get-Date -Format 'yyyy-MM-dd')+".TXT") -Append
   
      }
   
      function msg{
          # Ausgabe einer Bildschirmmeldung
          param(
              [String]$t,
              [datetime]$dt
          )
   
          if($dt){
              # Zeitdifferenz ausgeben, wenn eine Zeit übergeben wurde (für Dauer einer Befehlsausführung)
              [datetime]$end = get-date
              $t+=": "
              $t+=(new-timespan -start $dt -end $end).Seconds
              $t+=" Sekunden"
          }
          prot $t
          write-host $t
          # Zeit nur zurückgeben, wenn keine Zeit übergeben wurde
          if(!$dt) {return (get-date)}
      }
      # ********************************************* End Functions **********************************
   
   
    $error.Clear() > $null
    try{
   
     # Prüfen, ob dieser Kurs schon angelegt ist
     $query=$global:connection.CreateCommand()
     $query.CommandText="SELECT K_NR AS KNR, K_NAME AS KNAME FROM KURSE WHERE (K_NAME='$kname');" #
     $dataset = New-Object System.Data.DataSet
     $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $query
     $out=$adapter.Fill($dataset)
     if ($dataset.Tables[0].rows.Count -eq 0) {
          # keine Zeilen --> Kurs nicht gefunden
          throw $("Kurs "+$kname+" noch nicht in BBS Planung angelegt!")
     }
     else{
      # Kursnummer merken für später
      $KNR=$dataset.Tables[0].rows[0].KNR
     }
     
   
     # Alle SuS und KENNUNG1 (Englischniveau) aus diesem Kurs ermitteln. KENNUNG1 ist eigtl. nur für EN Kurse interessant
     $query.CommandText="SELECT NNAME,VNAME,KL_NAME,KENNUNG1 FROM SIL WHERE (K_NR1=$knr OR K_NR2=$knr OR K_NR2=$knr OR K_NR4=$knr OR K_NR5=$knr OR K_NR6=$knr OR K_NR7=$knr OR K_NR8=$knr OR K_NR9=$knr OR K_NR10=$knr OR K_NR11=$knr OR K_NR12=$knr OR K_NR13=$knr OR K_NR14=$knr OR K_NR15=$knr);" #
     $dataset.Clear() > $null
     $adapter.SelectCommand = $query
     $out=$adapter.Fill($dataset)
     
     if ($dataset.Tables[0].rows.Count -eq 0) {
          # Kein TN im Kurs!
          throw $("Keine Einträge gefunden für Kurs: "+$kname+"; Kursnummer: "+$knr)
     }
     else{
         # Kurs enthält TN
         # And finally cast that table to a PSCustomObject
         
         $psco=[PSCustomObject] $dataset.Tables[0]
         $len=$dataset.Tables[0].rows.count
         # Nun noch die Kursnummer und -Namen eintragen, die beiden Felder KNR und KNAME sind im Dataset schon vom Kursquery vorhanden
         For($i=0;$i -lt $len;$i++){
             $psco.rows[$i].KNR=$KNR
             $psco.rows[$i].KNAME=$KNAME
         }
         
         return $psco
         
     }
     
     
     
    } #ende try
    catch{
     # prot ($error|Select-Object FullyQualifiedErrorId).FullyQualifiedErrorId
     msg ($error|Select-Object FullyQualifiedErrorId).FullyQualifiedErrorId
     # $error
   
    }
   } # ende Process
   
   end {
   
        if(!$isDBConnectionOpenFromParent){
         #nur schließen, wenn die Verbindung innerhalb dieser Funktion aufgebaut wurde
         Disconnect-BbsPlan
        }
        
       }
      
   } # ende get-BPKursTN

<#
.Synopsis
   Eine/n SoS aus einem Kurs in BBS-Planung l�schen
.DESCRIPTION
   In BBS Planung werden die Kurse, in denen ein SoS registriert ist in der Sch�lertabelle SIL gespeichert. Maximal k�nnen
   15 Kurse belegt werden, die in den Feldern K1, K_NR1 bis K15, K_NR15 abgespeichert werden. In K wird der Kursname, in K_NR 
   die Kursnummer abgespeichert. Kursname und Kursnummer m�ssen mit den Entit�ten in der Tabelle KURSE �bereinstimmen.

   remove-BPKursTN durchsucht die 15 Felder des ausgew�hlten Sch�lerdatensatzes nach dem �bergebenen Kurs
   und l�scht diesen im Sch�lerdatensatz.

   Es kann entweder die Kursnummer, der BBS Planung Kursname oder der Diklabu Kursname �bergeben werden. 
   Ist mehreres �bergeben, wird die Nummer als Suchkriterium gew�hlt, dann BBS-Planungname, dann diklabu. 
   Wenn unter Bemerkungen in Tabelle "KURSE", Spalte "BEM", der Diklabuname angegeben ist, kann auch so ein
   Kurs bei einem Sch�ler gel�scht werden. Der Diklabuname wird dann per lookup in der Tabelle KURSE in 
   eine Kursnummer konvertiert.
   Ist nichts angegeben, wird das CMDlet mit einer Fehlermeldung (throw) verlassen
   
   Die Eindeutigkeit der Sch�leridentit�t wird bei gleichen Werten f�r Nachname (sosnname), Vorname (sosvname) und
   Klassenbezeichnung (sklasse) vorausgesetzt. Die Eindeutigkeit wird �berpr�ft. Sollte es zwei SoS mit 
   gleichen Werten geben, wird die L�schung des Kurses abgebrochen bei Ausgabe einer Fehlermeldung.

   Das CMDlet ist pipeline f�hig, kann also beispielsweise von einer csv bespeist werden. Diese sollte folgende Parameter mitliefern
   SOSNNAME; SOSVNAME; SOSKLASSE;sosid;KNR;KNAME;KNAMEDIKLABU
   
.EXAMPLE
   remove-BPKursTN -sosnname "Meier" -sosvname "Fritzchen" -sosklasse "FISI16X" -knr "1841"

.EXAMPLE
   remove-BPKursTN -sosnname "Meier" -sosvname "Fritzchen" -sosklasse "FISI16X" -kname "WPKXYb"

   Hier muss der Kursname aus BBS-Planung angegeben werden, nicht der aus dem Diklabu

.EXAMPLE
   remove-BPKursTN -sosnname "Meier" -sosvname "Fritzchen" -sosklasse "FISI16X" -knamediklabu "IT17_WPK_XY_blau"

   Wenn unter Bemerkungen in Tabelle "KURSE", Spalte "BEM", der Diklabuname angegeben ist kann auch so ein Kurs bei einem
   Sch�ler gel�scht werden

.EXAMPLE
   Import-Csv kursTN.csv | remove-BPKursTN

   In der csv-Datei m�ssen mindestens die Parameter SOSNNAME, SOSVNAME, SOSKLASSE und KNR oder KNAME oder KNAMEDIKLABU
   definiert sein. Good Practise ist, wenn die Kursnummer der zugeh�rigen Kurs ID im Diklabu entspricht. 
   Auch wenn das im Moment nicht ausgewertet wird, sollte die diklabu Sch�ler ID mit �bermittelt werden (SOSID)  
   Es k�nnen weitere, auch hier nicht ausgewertete Parameter (Spalten�berschriften) in der csv verwendet werden. Hier der
   beispielhafte Aufbau des Kopfes einer csv:
   SOSNNAME;SOSVNAME;SOSKLASSE;SOSID;KNR;KNAME;KNAMEDIKLABU

.EXAMPLE
   remove-BPKursTN -sosnname "*" -sosvname "*" -sosklasse "*"

   L�scht komplett alle Kurszuordnungen aller SoS
   
#>
function remove-BPKursTN {

    [CmdletBinding()]
  
   Param (
  
          # SOSNNAME (Sch�lernachname, in BBS-Planung Tabelle "SIL", Spalte NNAME")
          # 
          [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
          [String[]]$SOSNNAME,
  
          # SOSVNAME (Sch�lervorname, in BBS-Planung Tabelle "SIL", Spalte VNAME")
          # 
          [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
          [String[]]$SOSVNAME,
  
          # SOSKLASSE (Klassenname, in BBS-Planung Tabelle "SIL", Spalte KL_NAME")
          # 
          [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
          [String[]]$SOSKLASSE,
          
          # SOSID (Eindeutige Sch�lernummer, in BBS-Planung Tabelle "SIL", Spalte "???", bzw. in Diklabu)
          # Wird im Moment noch nicht ausgewertet
          [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
          [String[]]$SOSID,
          
          # KNR (Kursnummer, in BBS-Planung Tabelle "KURSE", Spalte "K_NR", bzw. in Tabelle SIL beim Sch�ler "K_NR{1..15}))
          # Good Practise ist, wenn die Kursnummer der zugeh�rigen Kurs ID im Diklabu entspricht
          [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
          [String[]]$KNR,
  
          # KNAME (Kursname, in BBS-Planung Tabelle "KURSE", Spalte "K_NAME", bzw. in Tabelle SIL beim Sch�ler "K{1..15}))
          [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
          [String[]]$KNAME,
  
          # KNAMEDIKLABU (Kursname, in BBS-Planung Tabelle "KURSE", Spalte "BEM", 
          # wird dann umgerechnet in K_NR in Tabelle SIL beim Sch�ler "K_NR{1..15}))
          [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
          [String[]]$KNAMEDIKLABU,
  
          # silent true gibt keine Error logs aus, eignet sich f�r Massenl�schungen vieler Kurse, um Verarbeitunszeit zu sparen
          [switch]$silent=$false,
  
          # whatif true liest alle Werte ein und gibt Fehlermeldungen aus, wenn z.B. ein Kurs nicht gelistet ist
          # oder der Sch�ler nicht eindeutig ist, l�scht aber nicht die Kurszuordnung in BBS-Planung
          [switch]$whatif=$false
  
   )
  
   Begin {
        # Konfigdaten einlesen, wenn notwendig
        if (!$global:logins.bp) {
         $path=(get-childitem $MyInvocation.PSCommandPath|select directoryname).directoryname
         get-keystore -file "$path\bpconfig.json"
        }
        
        # Verbindung zur Datenbank aufbauen
        $isDBConnectionOpenFromParent=$true #am Ende die Verbindung nur schlie�en, wenn sie in dieser Funktion auch ge�ffnet wurde
        try {
  
            if (!$global:connection -or !($global:connection.State -eq "Open")) {
              connect-BbsPlan -location $global:logins.bp.bpdbpath
              $isDBConnectionOpenFromParent=$false
            }
        }
        catch {
        Write-Error "Verbindung zur Datenbank BBS-Planung konnte nicht ge�ffnet werden in CMDlet new-BPkurs"
        return
        }
  
      } #ende begin
  
  
   Process {
  
   $error.Clear()
   try{
  
    $query=$global:connection.CreateCommand() # auf jeden Fall muss eine Abfrage in KURSE hinein erfolgen
    $dataset = New-Object System.Data.DataSet
    $adapter = New-Object System.Data.OleDb.OleDbDataAdapter
      
    # Wenn ALLE Kurszuordnungen bei ALLEN SuS gel�scht werden sollen, wurden "*" als Parameter �bergeben
    if ($SOSNNAME -eq "*" -and $SOSVNAME -eq "*" -and $SOSKLASSE -eq "*"){
     if(!$whatif){
      $cmd=$global:connection.CreateCommand()
      for ($i=1;$i -le 15;$i++){
       
          $cmd.CommandText="UPDATE SIL SET K$i=NULL,K_NR$i=NULL;"
          $cmd.ExecuteNonQuery()
      }
     }
     else {
      write-verbose ("remove-BPkursTN: Das L�schen aller Kursteilnehmer konnte nicht durchgef�hrt werden, weil Testmodus mit Schalter -whatif gesetzt wurde!")
     }
    }
    else{
    # "Normalfall", Daten f�r einen Sch�ler angegeben
    # Pr�fen, welcher der Kursparameter �bergeben wurde
    if(!$KNR -or ($KNR -le 0)) {
     # keine Kursnummer angegeben
  
     if ($KNAME -and ($KNAME -ne "")) {
      # KNAME f�r Tabelle KURSE angegeben
      $query.CommandText="SELECT K_NR, K_NAME FROM KURSE WHERE (K_NAME='$KNAME');" #
     }
     elseif ($KNAMEDIKLABU -and ($KNAMEDIKLABU -ne "")) {
      $query.CommandText="SELECT K_NR, K_NAME FROM KURSE WHERE (BEM='$KNAMEDIKLABU');" #
      }
      else {
       # gar kein �bergabeparameter
       throw $("Weder Kursnummer, noch Kursname, noch Kursnamediklabu f�r SoS "+$SOSVNAME+"  "+$SOSNNAME+", Klasse "+$SOSKLASSE+" an remove-BPKursTN �bergeben!")
      }
     # Hier ist das geeignete Querycommand zusammengesetzt und kann nun ausgef�hrt werden. Es liefert KNR und KNAME
     $adapter.SelectCommand = $query
     $out=$adapter.Fill($dataset)
     if ($dataset.Tables[0].rows.Count -eq 0) {
         # keine Zeilen --> Kurs nicht gefunden
         throw $("Keinen Kurs f�r SoS "+$SOSVNAME+"  "+$SOSNNAME+", Klasse "+$SOSKLASSE+" in Tabelle KURSE gefunden!")
     }
     else{
      # Kursnamen merken f�r sp�ter
      $KNR=$dataset.Tables[0].rows[0].K_NR
      $KNAME=$dataset.Tables[0].rows[0].K_NAME
     }
    } # ende mit Kursnummern �ber die Namen suchen
  
    else{  
     # einfachste Variante: KNR ist angegeben
     # Pr�fen, ob diese Kursnummer schon angelegt ist
     $query.CommandText="SELECT K_NR, K_NAME FROM KURSE WHERE (K_NR=$KNR);" #
     $adapter.SelectCommand = $query
     $out=$adapter.Fill($dataset)
     if ($dataset.Tables[0].rows.Count -eq 0) {
         # keine Zeilen --> Kurs nicht gefunden
         throw $("Keinen Kurs mit Nr. "+$KNR+" f�r SoS "+$SOSVNAME+"  "+$SOSNNAME+", Klasse "+$SOSKLASSE+" in Tabelle KURSE gefunden!")
     }
     else{
      # Kursnamen merken f�r sp�ter
      $KNR=$dataset.Tables[0].rows[0].K_NR
      $KNAME=$dataset.Tables[0].rows[0].K_NAME
     }
    }
    # ab hier gibt es auf jeden Fall eine g�ltige Kursnummer und der BBS Planungname ist auch verf�gbar
  
    # zun�chst mal den Sch�lerdatensatz finden
    $query.CommandText="SELECT * FROM SIL WHERE (NNAME='$sosnname' AND VNAME='$sosvname' AND KL_NAME='$sosklasse');" #
    $dataset.Clear()
    $adapter.SelectCommand = $query
    $out=$adapter.Fill($dataset)
    if ($dataset.Tables[0].rows.Count -ne 1) {
         # es darf nur ein SoS ermittelt worden sein!
         throw $($sosvname+"-"+$sosnname+"-"+$sosklasse+" nicht eindeutig oder nicht vorhanden. Es wurden " + $dataset.Tables[0].rows.Count +" Eintr�ge gefunden!")
    }
  
    # jetzt Kursnummer suchen bei dem angegebenen SoS
    $found=$false
    $i=1
    while (!$found -and ($i -le 15)){
     if ((([DBNull]::Value).Equals($dataset.Tables[0].rows[0].@("K_NR"+$i))) -or ($dataset.Tables[0].rows[0].@("K_NR"+$i) -ne $KNR)) {
      $i++
     }
     else{
      $found=$true
      if(!$whatif){
        $cmd=$global:connection.CreateCommand()
        $cmd.CommandText="UPDATE SIL SET K$i=NULL,K_NR$i=NULL WHERE (KL_NAME='$sosklasse' AND NNAME='$sosnname' AND VNAME='$sosvname');"
        $cmd.ExecuteNonQuery()
      }
      else {
       write-verbose ("remove-BPkursTN: Kurseintrag zu Kurs "+$KNAME+ " bei "+$sosvname+" "+$sosnname+", Klasse "+$sosklasse+", konnte nicht gel�scht werden, weil Testmodus mit Schalter -whatif gesetzt wurde!")
      }
  
     }
     if ($i -gt 15){
       ## schlecht gelaufen, Kurs in keinem Feld gefunden
       throw $("remove-BPKursTN: Kurs "+$KNAME+" nicht gefunden bei Sch�ler/-in "+$sosvname+" "+$sosnname+" in Klasse "+$sosklasse+"!")
     }
    } #ende while(!$found...
   
   } #ende else Wenn alle Kurszuordnungen bei allen SuS gel�scht werden sollen, wurden "*" als Parameter �bergeben
  
   } #ende try
   catch{
    
    if (!$silent){
       write-host ($error|Select-Object FullyQualifiedErrorId).FullyQualifiedErrorId
       $error
    }
  
   }
  } # ende Process
  
  end {
  
       if(!$isDBConnectionOpenFromParent){
        #nur schlie�en, wenn die Verbindung innerhalb dieser Funktion aufgebaut wurde
        Disconnect-BbsPlan
       }
       
      }
     
  } # ende remove-BPKursTN
  
  

  
   <#
   .Synopsis
      Englisch Niveau in BBS-Planung einfügen, muss mit powershell (x86) gestartet werden
   .DESCRIPTION
      Englisch Niveau in BBS-Planung einfügen
      Attribute zum Auffinden des Schülerdatensatzes
      NNAME    Nachname SoS
      VNAME    Vorname SoS
      KLASSE   Klassenbezeichnung
      Attribute, die eingpflegt werden
      ENNIV    Englischniveau, A1 (340), A2 (344), B1 (343), B2 (342), C1 (341) bis C2 (345) 
   
   .EXAMPLE
      Set-BPEngNiveau -NNAME "Imum" -VNAME "Max" -KLASSE "FISI18B" -ENNIV "A1"
   .EXAMPLE
      Get-EngNiveauAusZusatz -pathZusatzdaten "C:\\Muell" | set-BPEngniveau
      Holt alle Englischniveaus aus den verschlüsselten oder auch unverschlüsselten 
      Zeugniszusatzlisten in C:\Muell (und Unterverzeichnissen) und schreibt sie in 
      die aktuelle BBS-Planungsconnection
   .EXAMPLE
      $engsus=get-EngNiveauAusZusatz -pathZusatzdaten "C:\SchuleSync\MM-BBS\SL\Zeugnis\Listenpool\"
      $engsus | set-BPEngNiveau -location "C:\access\plan"
      oder $engsus |export-csv -path "C:\SchuleSync\MM-BBS\SL\Zeugnis\Listenpool\engsus.csv" -Encoding utf8 -NoTypeInformation
    
   #>
   function set-BPEngNiveau {
   
       [CmdletBinding()]
       Param
       (
           # Nachname
           [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
           [String[]]$NNAME,
   
           # Vorname
           [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
           [String[]]$VNAME,
   
           # Klasse
           [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
           [String[]]$KLASSE,
   
           # Englischniveau
           [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
           [String[]]$ENNIV="",
   
           # Optional Pfad zur schule_xp.mdb
           [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
           [String]$location="",
   
           # whatif true liest alle Werte ein und gibt Fehlermeldungen aus, wenn z.B. ein String zu lang ist
           # oder der Schüler nicht auffindbar ist, legt aber die Bemerkungen nicht in BBS-Planung an
           [switch]$whatif=$false
       )
   
       begin{
           # Konfigdaten einlesen, wenn notwendig,  also logindaten vorhanden und keine location angegeben
           if ($location -eq "" -and !$global:logins.bp) {
               $path=(get-childitem $MyInvocation.PSCommandPath|select directoryname).directoryname
               get-keystore -file "$path\bpconfig.json"
               $location = $global:logins.bp.bpdbpath
           }
   
           # Verbindung zur Datenbank aufbauen
           $isDBConnectionOpenFromParent=$true #am Ende die Verbindung nur schließen, wenn sie in dieser Funktion auch geöffnet wurde
           try {
   
               if (!$global:connection -or !($global:connection.State -eq "Open")) {
                   connect-BbsPlan -location $location
                   $isDBConnectionOpenFromParent=$false
               }
           }
           catch {
               Write-Error "Verbindung zur Datenbank BBS-Planung konnte nicht geöffnet werden in CMDlet set-BPEngniveau"
               return
           }
   
       } #ende begin
   
       Process {
           # ********************************************* Functions **********************************
           function prot{
               # Ausgabe eines Kommentares in die Protokolldatei
               param(
               [String]$t
               )
               $t=(get-date -format "hh:mm:ss") +": "+ $t
               # $t|out-file -filepath ($global:logins.bp.protpath+"\remove-BPKurs-Prot-"+$(Get-Date -Format 'yyyy-MM-dd-hh-mm-ss')+".TXT") -Append
               $t|out-file -filepath ($psscriptroot+"\set-BPEngniveau-"+$(Get-Date -Format 'yyyy-MM-dd')+".TXT") -Append
   
           }
   
           function msg{
               # Ausgabe einer Bildschirmmeldung
               param(
                   [String]$t,
                   [datetime]$dt
               )
   
               if($dt){
                   # Zeitdifferenz ausgeben, wenn eine Zeit übergeben wurde (für Dauer einer Befehlsausführung)
                   [datetime]$end = get-date
                   $t+=": "
                   $t+=(new-timespan -start $dt -end $end).Seconds
                   $t+=" Sekunden"
               }
               prot $t
               write-host $t
               # Zeit nur zurückgeben, wenn keine Zeit übergeben wurde
               if(!$dt) {return (get-date)}
           }
           # ********************************************* End Functions **********************************
   
           $error.Clear()
   
           try{
               
               # Datenbank vorbereiten
               $query=$global:connection.CreateCommand()
               $dataset = New-Object System.Data.DataSet
               $adapter = New-Object System.Data.OleDb.OleDbDataAdapter
   
               #*** 1. Prüfen, ob es den SoS gibt (nur für qualifizierte Fehlermeldung) ***
               $query.CommandText="SELECT NNAME FROM SIL WHERE (NNAME='$nname' AND VNAME='$vname' AND KL_NAME='$klasse');"
               $adapter.SelectCommand = $query
               $out=$adapter.Fill($dataset)
               if ($dataset.Tables[0].rows.Count -eq 0) {
                   # keine Zeilen --> Schüler nicht gefunden
                   msg "set-BPEngNiveau: Kann Schüler $nname,$vname, $klasse nicht finden in Tabelle SIL!"
                   # throw $("set-BPEngNiveau: Kann Schüler $nname,$vname, $klasse nicht finden in Tabelle SIL!")
                   return
               }
               if ($dataset.Tables[0].rows.Count -gt 1) {
                   # zu viele Zeilen --> mehr als ein Schüler gefunden
                   msg "set-BPEngNiveau: Mehrere Schüler $nname,$vname, $klasse gefunden in Tabelle SIL!"
                   # throw $("set-BPEngNiveau: Mehrere Schüler $nname,$vname, $klasse gefunden in Tabelle SIL!")
                   return
               }
   
               # hier ist genau der SoS gefunden worden, also Englischniveau eintragen
               if (-not $whatif){
                   $cmd=$global:connection.CreateCommand()
                   $cmd.CommandText="UPDATE SIL SET KENNUNG1 = '$enniv' WHERE (NNAME='$nname' AND VNAME='$vname' AND KL_NAME='$klasse');"
                   $cmd.ExecuteNonQuery()
               }
               else {
                   write-verbose ("set-BPEngNiveau: Das Einschreiben des Englischniveaus für $nname, $vname, $klasse konnte nicht durchgeführt werden, weil Testmodus mit Schalter -whatif gesetzt wurde!")
               }
           } 
           catch {
               write-host ($error|Select-Object FullyQualifiedErrorId).FullyQualifiedErrorId
               # $error
   
           }
       } #ende process
   } # ende set-BPEngNiveau
   
   function get-BPEngNiveau {

    [CmdletBinding()]
    Param
    (
        # Nachname
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$NNAME,

        # Vorname
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$VNAME,

        # Klasse
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String[]]$KLASSE,

        # Optional Pfad zur schule_xp.mdb
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [String]$location=""
    )

    begin{
        # Konfigdaten einlesen, wenn notwendig,  also logindaten vorhanden und keine location angegeben
        if ($location -eq "" -and !$global:logins.bp) {
            $path=(get-childitem $MyInvocation.PSCommandPath|select directoryname).directoryname
            get-keystore -file "$path\bpconfig.json"
            $location = $global:logins.bp.bpdbpath
        }

        # Verbindung zur Datenbank aufbauen
        $isDBConnectionOpenFromParent=$true #am Ende die Verbindung nur schließen, wenn sie in dieser Funktion auch geöffnet wurde
        try {

            if (!$global:connection -or !($global:connection.State -eq "Open")) {
                connect-BbsPlan -location $location
                $isDBConnectionOpenFromParent=$false
            }
        }
        catch {
            Write-Error "Verbindung zur Datenbank BBS-Planung konnte nicht geöffnet werden in CMDlet set-BPEngniveau"
            return
        }

    } #ende begin

    Process {
        # ********************************************* Functions **********************************
        function prot{
            # Ausgabe eines Kommentares in die Protokolldatei
            param(
            [String]$t
            )
            $t=(get-date -format "hh:mm:ss") +": "+ $t
            # $t|out-file -filepath ($global:logins.bp.protpath+"\remove-BPKurs-Prot-"+$(Get-Date -Format 'yyyy-MM-dd-hh-mm-ss')+".TXT") -Append
            $t|out-file -filepath ($psscriptroot+"\set-BPEngniveau-"+$(Get-Date -Format 'yyyy-MM-dd')+".TXT") -Append

        }

        function msg{
            # Ausgabe einer Bildschirmmeldung
            param(
                [String]$t,
                [datetime]$dt
            )

            if($dt){
                # Zeitdifferenz ausgeben, wenn eine Zeit übergeben wurde (für Dauer einer Befehlsausführung)
                [datetime]$end = get-date
                $t+=": "
                $t+=(new-timespan -start $dt -end $end).Seconds
                $t+=" Sekunden"
            }
            prot $t
            write-host $t
            # Zeit nur zurückgeben, wenn keine Zeit übergeben wurde
            if(!$dt) {return (get-date)}
        }
        # ********************************************* End Functions **********************************

        $error.Clear()

        try{
            
            # Datenbank vorbereiten
            $query=$global:connection.CreateCommand()
            $dataset = New-Object System.Data.DataSet
            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter

            #*** KENNUNG1 ist Attribut für Eng-Niveau ***
            $query.CommandText="SELECT KENNUNG1 FROM SIL WHERE (NNAME = '$nname' AND VNAME = '$vname' AND KL_NAME = '$klasse');"
            $adapter.SelectCommand = $query
            $out=$adapter.Fill($dataset)
            if ($dataset.Tables[0].rows.Count -eq 0) {
                # keine Zeilen --> Schüler nicht gefunden
                msg "get-BPEngNiveau: Kann Schüler $nname,$vname, $klasse nicht finden in Tabelle SIL!"
                # throw $("set-BPEngNiveau: Kann Schüler $nname,$vname, $klasse nicht finden in Tabelle SIL!")
                return
            }
            if ($dataset.Tables[0].rows.Count -gt 1) {
                # zu viele Zeilen --> mehr als ein Schüler gefunden
                msg "get-BPEngNiveau: Mehrere Schüler $nname,$vname, $klasse gefunden in Tabelle SIL!"
                # throw $("set-BPEngNiveau: Mehrere Schüler $nname,$vname, $klasse gefunden in Tabelle SIL!")
                return
            }

            # hier ist genau ein/e SoS gefunden worden, also Englischniveau zurückgeben
            return $dataset.Tables[0].rows[0].KENNUNG1
           
        } 
        catch {
            write-host ($error|Select-Object FullyQualifiedErrorId).FullyQualifiedErrorId
            # $error

        }
    } #ende process
    End {
        # Verbindung nur schließen, wenn sie offen ist und innerhalb dieses Skriptes geöffnet wurde
        if(($isDBConnectionOpenFromParent -eq $false) -and ($global:connection.State -eq "Open")){
            $global:connection.close()
        }
    }
} # ende get-BPEngNiveau

   
