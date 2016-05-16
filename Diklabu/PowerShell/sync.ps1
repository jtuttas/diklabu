# DB Pfad zur Access Datenbak
$path = "C:\Users\jtutt_000\Documents\bbsplanung.mdb"
$adOpenStatic = 3
$adLockOptimistic = 3
 
$cn = new-object -comobject ADODB.Connection
$rs = new-object -comobject ADODB.Recordset 
$cn.Open("Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=$path")



Write-Host "Lese Datenbank SIL (Schülerdaten) ein!" -BackgroundColor Green
$rs.Open("Select * From SIL", $cn,$adOpenStatic,$adLockOptimistic) 
$rs.MoveFirst() 
$schueler=@();
do {
    $sch="" | Select-Object -Property "NNAME","VNAME","GEBDAT","GEBORT","STR","PLZ","ORT","TEL","TEL_HANDY","EMAIL","GESCHLECHT","KL_NAME","BETRIEB_NR"
    $sch.NNAME=$rs.Fields.Item("NNAME").Value;
    $sch.VNAME=$rs.Fields.Item("VNAME").Value;
    [datetime]$sch.GEBDAT=$rs.Fields.Item("GEBDAT").Value;
    $sch.GEBORT=$rs.Fields.Item("GEBORT").Value;
    $sch.STR=$rs.Fields.Item("STR").Value;
    $sch.PLZ=$rs.Fields.Item("PLZ").Value;
    $sch.ORT=$rs.Fields.Item("ORT").Value;
    $sch.TEL=$rs.Fields.Item("TEL").Value;
    $sch.TEL_HANDY=$rs.Fields.Item("TEL_HANDY").Value;
    $sch.EMAIL=$rs.Fields.Item("EMAIL").Value;
    $sch.GESCHLECHT=$rs.Fields.Item("GESCHLECHT").Value;
    $sch.KL_NAME=$rs.Fields.Item("KL_NAME").Value;
    $sch.BETRIEB_NR=$rs.Fields.Item("BETRIEB_NR").Value;
    $schueler+=$sch;
    $rs.MoveNext()
} 
until ($rs.EOF -eq $True)
$rs.close()
Write-Host "Insgesammt "$schueler.Length" Schüler eingelesen!"

Write-Host "Lese Datenbank BETRIEBE (Betriebe/Ausbilder) ein!" -BackgroundColor Green
$rs.Open("Select * From BETRIEBE", $cn,$adOpenStatic,$adLockOptimistic) 
$rs.MoveFirst() 
$betriebe=@();
$ausbilder=@();
do {
    $bet="" | Select-Object -Property "NAME","PLZ","ORT","STRASSE","NR","ID"
    $aus="" | Select-Object -Property "ID","ID_BETRIEB","NNAME","EMAIL","TELEFON","FAX"

    $bet.NAME=$rs.Fields.Item("BETRNAM1").Value;
    $bet.STRASSE=$rs.Fields.Item("BETRSTR").Value;
    $bet.PLZ=$rs.Fields.Item("BETRPLZ").Value;
    $bet.ORT=$rs.Fields.Item("BETRORT").Value;
    $bet.ID=$rs.Fields.Item("ID").Value;

    $aus.TELEFON=$rs.Fields.Item("BETRTEL").Value;
    $aus.NNAME=$rs.Fields.Item("BETRANSPR").Value;
    $aus.FAX=$rs.Fields.Item("BETRFAX").Value;
    $aus.EMAIL=$rs.Fields.Item("BETRONLINE").Value;
    $aus.ID_BETRIEB=$rs.Fields.Item("ID").Value;
    $betriebe+=$bet;
    $ausbilder+=$aus;
    $rs.MoveNext()
} 
until ($rs.EOF -eq $True)
$rs.close()
Write-Host "Insgesammt "$betriebe.Length" Betriebe eingelesen!"

Write-Host "Lese Datenbank LVUEL (Lehrerdaten) ein!" -BackgroundColor Green
$rs.Open("Select * From LVUEL", $cn,$adOpenStatic,$adLockOptimistic)
$rs.MoveFirst() 
$lehrer=@();
do {
  $leh="" | Select-Object -Property "NNAME","VNAME","KÜRZEL"
  $leh.NNAME=$rs.Fields.Item("NNAME").Value;
  $leh.VNAME=$rs.Fields.Item("VNAME").Value;
  $leh.Kürzel=$rs.Fields.Item("Kürzel").Value;
  $lehrer+=$leh;
  $rs.MoveNext()
} 
until ($rs.EOF -eq $True)
$rs.close()
$cn.close()
Write-Host "Insgesammt "$lehrer.Length" Lehrer eingelesen!"
Write-Host "Anmeldung am diklabu Server an" -BackgroundColor Green
$l=Login-Diklabu -user TU -password mmbbs

Write-Host "Synchonisiere Betriebe" -BackgroundColor Green
foreach ($b in $betriebe) {
  $c=Find-Company -NAME $b.NAME
  if (!$c) {
      Write-Host "  Neuen Betrieb gefunden "$b.NAME"! Lege Betrieb an!" -BackgroundColor DarkRed
      $nc= New-Company -ID $b.ID -NAME $b.NAME -PLZ $b.PLZ -ORT $b.ORT -STRASSE $b.STRASSE -NR $b.NR 
  }
  else {
      Write-Host "  Bekannten Betrieb gefunden "$b.NAME"! Aktualisiere Einträge!" -BackgroundColor DarkGreen
      $sc= Set-Company -ID $c.ID -NAME $b.NAME -PLZ $b.PLZ -ORT $b.ORT -STRASSE $b.STRASSE -NR $b.NR 
  }
}

Write-Host "Synchonisiere Ausbilder" -BackgroundColor Green
foreach ($a in $ausbilder) {
  $c=Find-Instructor -NNAME $a.NNAME 
  if ($c.length -gt 1) {
      Write-Host "Mehr als einen Ausbilder mit dem Namen "$a.NNAME" gefunden! Weitere Identifikation über EMAIL Adresse " -ForegroundColor Red
      $found=$false;
      foreach ($ausb in $c) {
        if ($ausb.EMAIL -eq $a.EMAIL) {
            $found=$true
            break;
        }
      }
      if ($found) {
        Write-Host "  Bekannten Ausbilder gefunden "$a.NNAME" mit EMAIL "$a.EMAIL" ! Aktualisiere Einträge!" -BackgroundColor DarkGreen
        $na= Set-Instructor -ID $ausb.ID -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON
      }
      else {
        Write-Host "  Neuen Ausbilder gefunden "$a.NNAME" mit EMAIL "$a.EMAIL"! Lege Ausbilder an!" -BackgroundColor DarkRed
        $na= New-Instructor -ID_BETRIEB $a.ID_BETRIEB -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON
      }
  }
  else {
    if (!$c) {
        Write-Host "  Neuen Ausbilder gefunden "$a.NNAME"! Lege Ausbilder an!" -BackgroundColor DarkRed
        $na= New-Instructor -ID_BETRIEB $a.ID_BETRIEB -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON
    }
    else {
        Write-Host "  Bekannten Ausbilder gefunden "$a.NNAME"! Aktualisiere Einträge!" -BackgroundColor DarkGreen
        $na= Set-Instructor -ID $c.ID -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON
    }
  }
}

Write-Host "Synchonisiere Schüler" -BackgroundColor Green
foreach ($s in $schueler) {
  $c=Find-Pupil -VNAME $s.VNAME -NNAME $s.NNAME -GEBDAT $s.GEBDAT
  if (!$c) {
      Write-Host "  Neuen Schüler gefunden "$s.VNAME" "$s.NNAME"! Lege Schüler an!" -BackgroundColor DarkRed
      
  }
  else {
      Write-Host "  Bekannten Schüler gefunden "$b.VAME" "$s.NNAME"! Aktualisiere Einträge!" -BackgroundColor DarkGreen
      
  }
}
