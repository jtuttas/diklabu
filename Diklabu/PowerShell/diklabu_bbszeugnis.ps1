<#
    ToDo:
    - Export-BZeugnis .. erzeugt eine Excel Datei
    - Import-BZeugnis .. liest eine Excel Datei
    - Send-BZeugnis .... versendet eine Zeúgnisliste via EMail an KLassenlehrer
#>

function Connect-BbsZeugnis
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
            if ($Global:logins["bbszeugnis"]) {
                $location=$Global:logins["bbszeugnis"].location;
            }
            else {
                Write-Error "Bitte location angeben!"
                break;
            }
        }
        $global:connection = new-object System.Data.OleDb.OleDbConnection
        try{
 
            $global:connection.ConnectionString="Provider=Microsoft.ACE.OLEDB.12.0;Data Source=$location\zeugnis_XP.mdb; Jet OLEDB:System Database=$location\System.mdw;User ID=$user_ID;Password=$user_password;"
            $global:connection.Open()
            Write-Verbose "Okay, db geöffnet"
            Write-Verbose "Lese Notenbezeichnungen"
            $global:grades = Get-BZGrades
            Write-Verbose "Lese AVSZ Bezeichnungen"
            $global:avsv = Get-BZAvSv
            Write-Verbose "Lese Vermerke"
            $global:annotations = Get-BZAnnotations
            Write-Verbose "Lese Bemerkungen"
            $global:remarks = Get-BZRemarks
            Write-Verbose "Lese Durchschnittsnoten"
            $global:dnote = Get-BZAverageGrades
            $global:connection 
        }
        catch {        
            Write-Error "Fehler beim Öffnen von BBS-Zeugnis $($_.ErrorDetails.Message)"
            $_
        }
        Set-Keystore -key "bbszeugnis" -server $location
    }
   
}

<#
.Synopsis
   Liest die Zeuignisdaten eines Schülers
.DESCRIPTION
   Liest die Zeuignisdaten eines Schülers
.EXAMPLE
   Get-BZGrade -NR_SCHÜLER 13
   Liest die Zeugnisdaten des Schülers mit der NR 13
.EXAMPLE
   Get-BZGrade -NR_SCHÜLER 12,13
   Liest die Zeugnisdaten des Schüler mit den NR 12 und 13
.EXAMPLE
   12,13 | Get-BZGrade 
   Liest die Zeugnisdaten des Schüler mit den NR 12 und 13
.EXAMPLE
   Get-BZGrade -KNAME FML2-
   Liest die Zeugnisdaten der Schüler der Klasse FML2-
.EXAMPLE
   Get-BZGrade -KNAME FML2-,FML1-
   Liest die Zeugnisdaten der Schüler der Klassen FML2- und FML1-
.EXAMPLE
   "FML2-","FML1-" | Get-BZGrade 
   Liest die Zeugnisdaten der Schüler der Klassen FML2- und FML1-
#>
function Get-BZGrade
{
    [CmdletBinding()]
    Param
    (
        # NR_SCHÜLER
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0,ParameterSetName='byID')]
        [int[]]$NR_SCHÜLER,
        # K_NAME
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0,ParameterSetName='byKNAME')]
        [String[]]$KNAME,

        [DateTime]$Zeugnisdatum,
        [String]$Zeugnisart

    )

    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -ne "Open") {
                Write-Error "Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
                return;
            }
        }
        else {
            Write-Error "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            return;
        }
    }
    Process {
        if ($NR_SCHÜLER) {
            $obj=$NR_SCHÜLER
        }
        else {
            $obj=$KNAME
        }
        $obj | ForEach-Object {
            $command = $global:connection.CreateCommand()
            if ($NR_SCHÜLER) {
    	        $command.CommandText = "Select * From SQL_NOTE where NR_SCHÜLER=$_"
            }
            else {
                $command.CommandText = "Select * From SQL_NOTE where KL_NAME='$_'"
            }
            $dataset = New-Object System.Data.DataSet
	        $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
            $out=$adapter.Fill($dataset)
            $schueler=@();
            foreach ($item in $dataset.Tables[0]) {
                #$item
                $sch="" | Select-Object -Property "NR_SCHÜLER","NNAME","VNAME","GEBDAT","KL_NAME","BILDUNGSGANG","Abschluss_Vorbildung"
                $sch.NR_SCHÜLER=$item.NR_SCHÜLER
                $sch.NNAME=$item.NNAME;
                $sch.VNAME=$item.VNAME;
                $sch.GEBDAT=$item.GEBDAT;
                $sch.KL_NAME=$item.KL_NAME;
                $sch.BILDUNGSGANG=$item.TAKLSTORG;
                $sch.Abschluss_Vorbildung=$item.ABSCHLUSS;
                foreach ($property in $item.PSObject.Properties) { 
                    #Write-Host "Teste $($property.Name) mit $($property.Value)"
                       
                    if ($property.Name -match "FACH" -and $([String]$property.Value).Length -ne 0 -and $property.Name -notmatch "FACHLANG") {      
                        $num=$property.Name.Substring(4);
                        $sch | Add-Member -MemberType NoteProperty -Name ($property.NAME) -Value $property.VALUE
                        $sch | Add-Member -MemberType NoteProperty -Name ("NSCHL"+$num) -Value $item["NSCHL"+$num]
                    }   
                    if ($property.Name -match "BEM" ) {   
                        $numb=$property.Name.Substring(3);   
                        $sch | Add-Member -MemberType NoteProperty -Name $property.NAME -Value $item["BSCHL"+$numb];
                    }  
                    if ($property.Name -match "VERM" ) { 
                        $numv=$property.Name.Substring(4);     
                        $sch | Add-Member -MemberType NoteProperty -Name $property.NAME -Value $item["VSCHL"+$numv];
                    }  
                }
                $sch | Add-Member -MemberType NoteProperty -Name "Arbeitsverhalten" -Value $item.ASV;
                $sch | Add-Member -MemberType NoteProperty -Name "Sozialverhalten" -Value $item.SZV;
                $sch | Add-Member -MemberType NoteProperty -Name "Fehltage_Gesamt" -Value $item.FTG;
                $sch | Add-Member -MemberType NoteProperty -Name "Fehltage_Entschuldigt" -Value $item.FTE;
                

                $sch | Add-Member -MemberType NoteProperty -Name "Abschluss" -Value $item.ENTLABSCHLUSS;
                $sch | Add-Member -MemberType NoteProperty -Name "Durchschnittnote" -Value $item.NOTE;
                if ($Zeugnisart) {
                    $sch | Add-Member -MemberType NoteProperty -Name "Zeugnisart" -Value $Zeugnisart;
                }
                else {
                    $sch | Add-Member -MemberType NoteProperty -Name "Zeugnisart" -Value $item.ZART;
                }
                if ($Zeugnisdatum) {
                    $sch | Add-Member -MemberType NoteProperty -Name "Zeugnisdatum" -Value $Zeugnisdatum
                }
                else {
                    $sch | Add-Member -MemberType NoteProperty -Name "Zeugnisdatum" -Value $item.DATUM;
                }
                     
                $schueler+=$sch;    
            } 
            $schueler;
        }
    }
}

<#
.Synopsis
   Liest die Notenbezeichnungen aus
.DESCRIPTION
   Liest die Notenbezeichnungen aus
.EXAMPLE
   Get-BZGrades 
#>
function Get-BZGrades
{
    [CmdletBinding()]
    Param
    (
    )

    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -ne "Open") {
                Write-Error "Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
                return;
            }
            else {
                $command = $global:connection.CreateCommand()
    	        $command.CommandText = "Select * From SQL_Z_SCHL"
                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)
                $obj=@{}
                foreach ($item in $dataset.Tables[0]) {
                    Write-Verbose "Schlüssel $($item.SCHL) ist $($item.TEXT)";
                    $obj[""+$item.SCHL]=$item.TEXT
                } 
                $obj
            }
        }
        else {
            Write-Error "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            return;
        }
    }
}

<#
.Synopsis
   Liest die AVSV aus
.DESCRIPTION
   Liest die AVSV aus
.EXAMPLE
   Get-BZAvSv
#>
function Get-BZAvSv
{
    [CmdletBinding()]
    Param
    (
    )

    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -ne "Open") {
                Write-Error "Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
                return;
            }
            else {
                $command = $global:connection.CreateCommand()
    	        $command.CommandText = "Select * From SQL_Z_SZV"
                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)
                $obj=@{}
                foreach ($item in $dataset.Tables[0]) {
                    #$item
                    $obj[""+[String]$item.SZV]=$item.TEXT
                } 
                $obj
            }
        }
        else {
            Write-Error "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            return;
        }
    }
}

<#
.Synopsis
   Liest die Vermerke aus
.DESCRIPTION
   Liest die Vermerke aus
.EXAMPLE
   Get-BZAvSv
#>
function Get-BZAnnotations
{
    [CmdletBinding()]
    Param
    (
    )

    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -ne "Open") {
                Write-Error "Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
                return;
            }
            else {
                $command = $global:connection.CreateCommand()
    	        $command.CommandText = "Select * From SQL_Z_VERM"
                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)
                $obj=@{}
                foreach ($item in $dataset.Tables[0]) {
                    $obj[""+[String]$item.VERM]=$item.TEXT
                } 
                $obj
            }
        }
        else {
            Write-Error "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            return;
        }
    }
}

<#
.Synopsis
   Liest die Durchschnittsnoten aus
.DESCRIPTION
   Liest die Durchschnittsnoten aus
.EXAMPLE
   Get-BZAverageGrades
#>
function Get-BZAverageGrades
{
    [CmdletBinding()]
    Param
    (
    )

    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -ne "Open") {
                Write-Error "Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
                return;
            }
            else {
                $command = $global:connection.CreateCommand()
    	        $command.CommandText = "Select * From SQL_Z_DN"
                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)
                $obj=@{}
                foreach ($item in $dataset.Tables[0]) {
                    $obj[""+[String]$item.DN]=$item.DNTEXT
                } 
                $obj
            }
        }
        else {
            Write-Error "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            return;
        }
    }
}
<#
.Synopsis
   Liest die Bemerkungen aus
.DESCRIPTION
   Liest die Bemerkungen aus
.EXAMPLE
   Get-BZAvSv
#>
function Get-BZRemarks
{
    [CmdletBinding()]
    Param
    (
    )

    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -ne "Open") {
                Write-Error "Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
                return;
            }
            else {
                $command = $global:connection.CreateCommand()
    	        $command.CommandText = "Select * From SQL_Z_BEM"
                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)
                $obj=@{}
                foreach ($item in $dataset.Tables[0]) {
                    $obj[""+[String]$item.BEM]=$item.TEXT
                } 
                $obj;
            }
        }
        else {
            Write-Error "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            return;
        }
    }
}


function examine
{
    [CmdletBinding()]
    Param
    (
        # NR_SCHÜLER
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [String]$table
    )

    Begin
    {
        if ($global:connection) {
            if ($global:connection.State -eq "Open") {
                $command = $global:connection.CreateCommand()
	            $command.CommandText = "Select * From $table"

                $dataset = New-Object System.Data.DataSet
	            $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
                $out=$adapter.Fill($dataset)
                foreach ($item in $dataset.Tables[0]) {
                 $item
                } 
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
   Setzt die Zeugnisdaten eines Schülers
.DESCRIPTION
   Setzt die Zeugnisdaten eines Schülers
.EXAMPLE
   Set-BZGrade -NR_SCHÜLER 13 -FACH1 2 -FACH2 3 -BEM1 700 -VERM1 3.2.1
   Setzt die Zeugnisdaten des Schülers mit der NR 13
.EXAMPLE
   import-Excel FIAE15G.xls | Set-BZGrade
   Setzt die Zeugnisdaten aus der XLSX Datei 
#>
function Set-BZGrade
{
    [CmdletBinding()]
    Param
    (
        # NR_SCHÜLER
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        $zeugnisObj,
        [String]$Zeugnisart,
        [DateTime]$Zeugnisdatum
    )

    Begin
    {
        
        if ($global:connection) {
            if ($global:connection.State -ne "Open") {
                Write-Error "Verbindung zu BBS Planung ist nicht geöffnet, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
                return;
            }
        }
        else {
            Write-Error "Es existiert noch keine Verbindung zu BBS Planung, evtl. zunächst mit Connect-BBSPlan eine Verbindung aufbauen"
            return;
        }
        $outObj = "" | Select-Object -Property "NR_SCHÜLER","success","msg","warnings","Warning_msg"
    }
    Process {
        Write-Verbose "SET Schüler Nr=$($zeugnisObj.NR_SCHÜLER) ";

        #Write-Host "vermerk=$VERM1"
        $command = $global:connection.CreateCommand()
        $outObj.NR_SCHÜLER=$zeugnisObj.NR_SCHÜLER;
        $outObj.success=$true
        $outObj.msg="Daten des Schülers $($zeugnisObj.VNAME) $($zeugnisObj.NNAME) Klasse $($zeugnisObj.KNAME) erfolgreich importiert!"
        $outObj.warnings=$false;
        $outObj.Warning_msg="";
        $tst = Get-BZGrade -NR_SCHÜLER $zeugnisObj.NR_SCHÜLER;
        if (-not $tst) {
            $outObj.success=$false
            $outObj.msg="Kann NR_SCHÜLER=$($zeugnisObj.NR_SCHÜLER) nicht finden"            
            $outObj
            return;
        }
        $sql = "Update SQL_NOTE SET "
        $attributes = @()
        $num=1;
        for ($num=1;$num -le 30;$num++) {
            if(Get-Member -inputobject $zeugnisObj -name ("NSCHL$num") -Membertype Properties ){
                if ([String]$zeugnisObj."NSCHL$num" -ne "") {
                    if ($($Global:grades[[String]$zeugnisObj."NSCHL$num"])) {
                        $attributes+="NSCHL$num = $($zeugnisObj."NSCHL$num"), NOTE$num = '$($Global:grades[[String]$zeugnisObj."NSCHL$num"])' "
                    }
                    else {
                        $attributes+="NSCHL$num = $($zeugnisObj."NSCHL$num")"
                        Write-Warning "NR_SCHÜLER=$($zeugnisObj.NR_SCHÜLER)  $($zeugnisObj.VNAME) $($zeugnisObj.NNAME): Keine Text für Note $($zeugnisObj."FACH$num") = $($zeugnisObj."NSCHL$num") gefunden!"
                        $outObj.warnings=$true;
                        $outObj.Warning_msg += ":Keine Text für $($zeugnisObj."FACH$num") = Note $($zeugnisObj."NSCHL$num") gefunden!"
                    }
                }
            }
        }
        for ($num=1;$num -le 5;$num++) {
            if(Get-Member -inputobject $zeugnisObj -name ("BEM$num") -Membertype Properties ){
                if ([String]$zeugnisObj."BEM$num" -ne "") {
                    if ($($Global:remarks[[String]$zeugnisObj."BEM$num"])) {
                        $attributes+="BSCHL$num = '$($zeugnisObj."BEM$num")', BEM$num = '$($Global:remarks[[String]$zeugnisObj."BEM$num"])' "
                    }
                    else {
                        $attributes+="BSCHL$num = '$($zeugnisObj."BEM$num")'"
                        Write-Warning "NR_SCHÜLER=$($zeugnisObj.NR_SCHÜLER)  $($zeugnisObj.VNAME) $($zeugnisObj.NNAME): Keine Text für Bemerkung BEM$num = $($zeugnisObj."BEM$num") gefunden!"
                        $outObj.warnings=$true;
                        $outObj.Warning_msg += ": Keine Text für Bemerkung BEM$num = $($zeugnisObj."BEM$num") gefunden!"
                    }
                }
            }
        }
        for ($num=1;$num -le 4;$num++) {
            if(Get-Member -inputobject $zeugnisObj -name ("VERM$num") -Membertype Properties ){
                if ([String]$zeugnisObj."VERM$num" -ne "") {
                    if ($($Global:annotations[[String]$zeugnisObj."VERM$num"])) {
                        $attributes+="VSCHL$num = '$($zeugnisObj."VERM$num")', VERM$num = '$($Global:annotations[[String]$zeugnisObj."VERM$num"])' "
                    }
                    else {
                        $attributes+="VSCHL$num = '$($zeugnisObj."VERM$num")'"
                        Write-Warning "NR_SCHÜLER=$($zeugnisObj.NR_SCHÜLER)  $($zeugnisObj.VNAME) $($zeugnisObj.NNAME): Keine Text für VERM$num = $($zeugnisObj."VERM$num") gefunden!"
                        $outObj.warnings=$true;
                        $outObj.Warning_msg += ": Keine Text für VERM$num = $($zeugnisObj."VERM$num") gefunden!"
                    }
                }
            }
        }
        if ([String]$zeugnisObj.Arbeitsverhalten -ne "") {
            if ($($Global:avsv[[String]$zeugnisObj.Arbeitsverhalten])) {
                $attributes+="ASV = '$($zeugnisObj.Arbeitsverhalten)', ASV_TEXT = '$($Global:avsv[[String]$zeugnisObj.Arbeitsverhalten])' "
            }
            else {
                $attributes+="ASV = '$($zeugnisObj.Arbeitsverhalten)'"
                Write-Warning "NR_SCHÜLER=$($zeugnisObj.NR_SCHÜLER)  $($zeugnisObj.VNAME) $($zeugnisObj.NNAME): Keine Text für Arbeitsverhalten $($zeugnisObj.Arbeitsverhalten) gefunden!"
                $outObj.warnings=$true;
                $outObj.Warning_msg +=": Keine Text für Arbeitsverhalten $($zeugnisObj.Arbeitsverhalten) gefunden!"
            }
        }
        if ([String]$zeugnisObj.Sozialverhalten -ne "") {
            if ($($Global:avsv[[String]$zeugnisObj.Sozialverhalten])) {
                $attributes+="SZV = '$($zeugnisObj.Sozialverhalten)', SZV_TEXT = '$($Global:avsv[[String]$zeugnisObj.Sozialverhalten])' "
            }
            else {
                $attributes+="SZV = '$($zeugnisObj.Sozialverhalten)'"
                Write-Warning "NR_SCHÜLER=$($zeugnisObj.NR_SCHÜLER)  $($zeugnisObj.VNAME) $($zeugnisObj.NNAME): Keine Text für Sozialverhalten $($zeugnisObj.Sozialverhalten) gefunden!"
                $outObj.warnings=$true;
                $outObj.Warning_msg +=": : Keine Text für Sozialverhalten $($zeugnisObj.Sozialverhalten) gefunden!"
            }
        }
        if ([String]$zeugnisObj.Fehltage_Gesamt -ne "") {
            $attributes+="FTG = $($zeugnisObj.Fehltage_Gesamt) "
        }
        if ([String]$zeugnisObj.Fehltage_Entschuldigt -ne "") {
            $attributes+="FTE = $($zeugnisObj.Fehltage_Entschuldigt) "
        }
        if ($zeugnisObj.Fehltage_Entschuldigt -gt $zeugnisObj.Fehltage_Gesamt) {
            Write-Warning "NR_SCHÜLER=$($zeugnisObj.NR_SCHÜLER) $($zeugnisObj.VNAME) $($zeugnisObj.NNAME): Fehltage entschuldigt > Fehltage gesamt"
            $outObj.warnings=$true;
            $outObj.Warning_msg +=": Fehltage entschuldigt $($zeugnisObj.Fehltage_Entschuldigt) > Fehltage gesamt $($zeugnisObj.Fehltage_Gesamt) "
         }
        if ([String]$zeugnisObj.Abschluss -ne "") {
            $attributes+="ENTLABSCHLUSS = '$($zeugnisObj.Abschluss)' "
        }
        if ($Zeugnisart) {
            $attributes+="ZART = '$Zeugnisart' "
        }
        else {
            $attributes+="ZART = '$($zeugnisObj.Zeugnisart)' "
        }
        if ($Zeugnisdatum) {
            $attributes+="DATUM = '$Zeugnisdatum' "
        }
        else {
            $attributes+="DATUM = '$($zeugnisObj.Zeugnisdatum)' "
        }
        if ([String]$zeugnisObj.Durchschnittnote -ne "") {
            if ($($Global:dnote[[String]$zeugnisObj.Durchschnittnote])) {
            
                $attributes+="[NOTE]=$($zeugnisObj.Durchschnittnote), NOTETEXT = '$($Global:dnote[[String]$zeugnisObj.Durchschnittnote])' "
            }
            else {
                $attributes+="[NOTE] = '$($zeugnisObj.Durchschnittnote)' "
                Write-Warning "NR_SCHÜLER=$($zeugnisObj.NR_SCHÜLER)  $($zeugnisObj.VNAME) $($zeugnisObj.NNAME): Keine Text für Durchschnitsnote $($zeugnisObj.Durchschnittnote) gefunden!"
                $outObj.warnings=$true;
                $outObj.Warning_msg +=": Keine Text für Durchschnitsnote $($zeugnisObj.Durchschnittnote) gefunden!"
            }
        }
       

        for ($i=0;$i -lt $attributes.Length;$i++) {
            if ($i -eq 0) {
                $sql+=$attributes[$i];
            }
            else {
                $sql+=","+$attributes[$i];
            }
        }

        $sql+="where NR_SCHÜLER=$($zeugnisObj.NR_SCHÜLER)";
    	
        $command.CommandText = $sql
        Write-Verbose "$($command.CommandText)"
        try {
            $dataset = New-Object System.Data.DataSet
	        $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $command
            $out=$adapter.Fill($dataset)    
        }
        catch {
            $outObj.success=$false;
            $outObj.msg=$_.Exception.Message
        }
        $outObj    
    }
}
