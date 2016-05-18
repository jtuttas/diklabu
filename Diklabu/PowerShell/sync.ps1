# DB Pfad zur Access Datenbak
$path = "C:\Users\jtutt_000\Documents\bbsplanung.mdb"
$adOpenStatic = 3
$adLockOptimistic = 3
 
$cn = new-object -comobject ADODB.Connection
$rs = new-object -comobject ADODB.Recordset 
$cn.Open("Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=$path")

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


Write-Host "Lese Datenbank SIL (Schülerdaten) ein!" -BackgroundColor Green
$rs.Open("Select * From SIL", $cn,$adOpenStatic,$adLockOptimistic) 
$rs.MoveFirst() 
$schueler=@();
do {
    $sch="" | Select-Object -Property "NNAME","VNAME","GEBDAT","GEBORT","STR","PLZ","ORT","TEL","TEL_HANDY","EMAIL","GESCHLECHT","KL_NAME","BETRIEB_NR","ID_AUSBILDER","diklabuID"
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
    $bet="" | Select-Object -Property "NAME","PLZ","ORT","STRASSE","NR","ID","diklabuID"
    $aus="" | Select-Object -Property "BETRIEB_NR","ID_BETRIEB","NNAME","EMAIL","TELEFON","FAX","diklabuID"

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
    $aus.BETRIEB_NR=$rs.Fields.Item("ID").Value;
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
  $leh.Kürzel=$rs.Fields.Item("NKURZ").Value;
  $lehrer+=$leh;
  $rs.MoveNext()
} 
until ($rs.EOF -eq $True)
$rs.close()
Write-Host "Insgesammt "$lehrer.Length" Lehrer eingelesen!"

Write-Host "Lese Datenbank KUL (Klassen) ein!" -BackgroundColor Green
$rs.Open("Select * From KUL", $cn,$adOpenStatic,$adLockOptimistic)
$rs.MoveFirst() 
$klassen=@();
do {
  $kl="" | Select-Object -Property "KNAME","ID_LEHRER","diklabuID"
  $kl.KNAME=$rs.Fields.Item("KL_NAME").Value;
  $kl.ID_LEHRER=$rs.Fields.Item("KL_LEHRER").Value;
  $klassen+=$kl;
  $rs.MoveNext()
} 
until ($rs.EOF -eq $True)
$rs.close()
$cn.close()
Write-Host "Insgesammt "$klassen.Length" Klassen eingelesen!"



Write-Host "Anmeldung am diklabu Server an" -BackgroundColor Green
$l=Login-Diklabu -user TU -password mmbbs

Write-Host "Synchonisiere Betriebe" -BackgroundColor Green
foreach ($b in $betriebe) {
  $c=Find-Company -NAME $b.NAME
  if (!$c) {
      Write-Host "  Neuen Betrieb gefunden "$b.NAME"! Lege Betrieb an!" -BackgroundColor DarkRed
      $nc= New-Company  -NAME $b.NAME -PLZ $b.PLZ -ORT $b.ORT -STRASSE $b.STRASSE -NR $b.NR 
      $b.diklabuID=$nc.ID    
  }
  else {
      Write-Host "  Bekannten Betrieb gefunden "$b.NAME"! Aktualisiere Einträge!" -BackgroundColor DarkGreen
      $sc= Set-Company -ID $c.ID -NAME $b.NAME -PLZ $b.PLZ -ORT $b.ORT -STRASSE $b.STRASSE -NR $b.NR 
      $b.diklabuID=$c.ID    
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
        $betr = findBetrieb $a.ID_BETRIEB
        $na= Set-Instructor -ID $ausb.ID -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON $betr.diklabuID
        $a.diklabuID=$c.ID
        $a.ID_BETRIEB=$c.ID_BETRIEB
        
      }
      else {
        Write-Host "  Neuen Ausbilder gefunden "$a.NNAME" mit EMAIL "$a.EMAIL"! Lege Ausbilder an!" -BackgroundColor DarkRed
        $betr = findBetrieb $a.ID_BETRIEB
        $na= New-Instructor -ID_BETRIEB $betr.diklabuID -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON
        $a.diklabuID=$na.id
        $a.ID_BETRIEB=$betr.diklabuID
      }
  }
  else {
    if (!$c) {
        Write-Host "  Neuen Ausbilder gefunden "$a.NNAME"! Lege Ausbilder an!" -BackgroundColor DarkRed
        $betr = findBetrieb $a.ID_BETRIEB
        $na= New-Instructor -ID_BETRIEB $betr.diklabuID -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON
        $a.diklabuID=$na.ID
        $a.ID_BETRIEB=$betr.diklabuID
    }
    else {
        Write-Host "  Bekannten Ausbilder gefunden "$a.NNAME"! Aktualisiere Einträge!" -BackgroundColor DarkGreen
        $betr = findBetrieb $a.ID_BETRIEB
        $na= Set-Instructor -ID $c.ID -NNAME $a.NNAME -EMAIL $a.EMAIL -FAX $a.FAX -TELEFON $a.TELEFON -ID_BETRIEB $betr.diklabuID
        $a.diklabuID=$c.ID
        $a.ID_BETRIEB=$c.ID_BETRIEB
    }
  }
}


Write-Host "Synchonisiere Lehrer" -BackgroundColor Green
foreach ($l in $lehrer) {
  $le=Get-Teacher -ID $l.KÜRZEL
  if (!$le) {
      Write-Host "  Neuen Lehrer gefunden "$l.VNAME" "$l.NNAME"! Lege Lehrer an mit Kürzel "$l.KÜRZEL"!" -BackgroundColor DarkRed
      $nl=New-Teacher -ID $l.KÜRZEL -NNAME $l.NNAME -VNAME $l.VNAME -TELEFON $l.TELEFON -EMAIL $l.EMAIL 
  }
  else {
      Write-Host "  Bekannten Lehrer gefunden "$l.VNAME" "$l.NNAME"! Aktualisiere Einträge!" -BackgroundColor DarkGreen
      $nl=Set-Teacher -ID $l.KÜRZEL -NNAME $l.NNAME -VNAME $l.VNAME -TELEFON $l.TELEFON -EMAIL $l.EMAIL       
  }
}

Write-Host "Synchonisiere Klassen" -BackgroundColor Green
foreach ($k in $klassen) {
  $kl=Find-Course -KNAME $k.KNAME
  if (!$kl) {
      Write-Host "  Neue Klasse gefunden "$k.KNAME"! Lege Klasse an!" -BackgroundColor DarkRed
      $nl=New-Course -KNAME $k.KNAME -ID_LEHRER $k.ID_LEHRER -ID_KATEGORIE 0
      $k.diklabuID=$nl.id
  }
  else {
      Write-Host "  Bekannte Klasse gefunden "$kl.KNAME"! Aktualisiere Einträge!" -BackgroundColor DarkGreen
      $nl=Set-Course -id $kl.id -ID_LEHRER $k.ID_LEHRER
      $k.diklabuID=$nl.id
  }
}


Write-Host "Synchonisiere Schüler" -BackgroundColor Green
foreach ($s in $schueler) {
  $gdate = get-date $s.GEBDAT -Format "yyyy-MM-dd"
  $c=Find-Pupil -VNAME $s.VNAME -NNAME $s.NNAME -GEBDAT $gdate
  if (!$c) {
      Write-Host "  Neuen Schüler gefunden "$s.VNAME" "$s.NNAME"! Lege Schüler an!" -BackgroundColor DarkRed
      $ausb = findAusbilder $s.BETRIEB_NR
      $np=New-Pupil -VNAME $s.VNAME -NNAME $s.NNAME -GEBDAT $gdate -EMAIL $s.EMAIL -ABGANG "N" -ID_AUSBILDER $ausb.diklabuID
      $s.diklabuID=$np.ID
      $s.ID_AUSBILDER=$ausb.diklabuID
      Write-Host "  Trage neuen Schüler "$s.VNAME" "$s.NNAME" in die Klasse "$s.KL_NAME" ein." -BackgroundColor DarkRed
      $kl=Find-Course -KNAME $s.KL_NAME
      $res=Add-Coursemember -id $np.id -klassenid $kl.id
      if ($res.success -ne $True) {
        Write-Host "Fehler beim Zuweisen des Schülers zur Klasse "$res.msg -ForegroundColor Red
      }
      else {
       Write-Host $res.msg -ForegroundColor Green
      }
  }
  else {
      Write-Host "  Bekannten Schüler gefunden "$s.VNAME" "$s.NNAME"! Aktualisiere Einträge!" -BackgroundColor DarkGreen
      $s.diklabuID=$c.id
      $kl = Find-Course -KNAME $s.KL_NAME
      $res=Add-Coursemember -id $c.id -klassenid $kl.id
      if ($res.success -eq $True) {
        Write-Host "Der Schüler hat die Klasse gewechselt!" -ForegroundColor DarkYellow
      }
      $ausb=Get-Instructor -ID $c.ID_AUSBILDER
      $ausb2=findAusbilder $s.BETRIEB_NR
      if ($ausb.ID -ne $ausb2.diklabuID) {
        Write-Host "Der Schüler hat einen neuen Ausbildungsbetrieb / Ausbilder" -ForegroundColor DarkYellow
      
      }
      
      
  }
}
