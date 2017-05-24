
function ElementinArray ($element,$array) {
    foreach ($a in $array) {
        if ($element -like $a) {
            return $true
        }
    }
    return $false;
}

<#
.Synopsis
   Ein Array mit allen Klassen und den in Untis verplanten Lehrern der Klasse ermitteln
.DESCRIPTION
   Aus einer von Untis exportierten Textdatei werden aus allen Klassen die Lehrer aufgelistet
   Erzeugen der Untis-Datei:
    Datei-Import/Export-Export TXT Datei (CSV, DIF)-Schnittstellen-Unterricht
    Im Fenster "Export DIF-Datei Unterricht" als Trennzeichen ";" angeben und UTF-8 Checkbox aktivieren
    Autor: Joachim Kemmries
    Schule: Multi Media BbS Hannover
    Datum: 21.05.2017

    Letzte Änderung: 
    Grund: ???
    Letzte Änderung: 
    Grund:
####################################################################################################################


.EXAMPLE
   get-classTeachersTeam <Pfad GP Untis Datei>

#>

function Import-Untis {
    [CmdletBinding()]
    Param
    (    
        # Pfad- und Dateiname der aus GP Untis exportierten Datei
        [Parameter(Mandatory=$true,Position=0)]
        [String]$path,
        # Kurse die nicht berücksichtigt werden
        [String[]]$blacklist=("EN-*","WPK-*","ITKVR*","FöKu_*","SPK-*","CCNA*","LR*","VOrgMe*","VOrgIT","Seminar*","Linux*"),
        # Prefix des Klassennamnes
        [String]$prefix="Klassenteam-",
        # Wenn KuK -> Klassenzuordnungen muss dieser Schalter gesetzt werden, sonst K-> KuK zuordnung
        [switch]$kukk
    )

    Process
    {
       $csvhead = "Unr;std1;std2;std3;klasse;lol;fach;raum;uebertragen;feld_j;wstd;halbj;statkuerzel;feld_n;datumstart;datumend;feld_q;SIst;LIst;raum2;uform;feld_v;feld_w;feld_x;feld_y;feld_z;feld_aa;feld_ab;feld_ac;feld_ad;feld_ae;feld_af;feld_ag;feld_ah;feld_ai;feld_aj;feld_ak;feld_al;feld_am;feld_an;feld_ao"
       $out_delimiter="," #Trennzeichen für die Lehrerliste einer Klasse
    
       if ((get-content $path -totalcount 1) -ne $csvhead) {
          #Kopfzeile einfügen falls noch nicht vorhanden
          $ftext = get-content $path -Encoding UTF8 #alten content merken  
          $csvhead|out-file -filepath $path -Encoding utf8
  
          $ftext|out-file -filepath $path -Append -Encoding utf8

          # msg "Kopfzeile in GPU Exportdatei eingefügt" $s
      }
      
            
      $out=@{}
      import-csv $path -Delimiter ";" | Where-Object {-not (ElementInArray $_.fach $blacklist)} | ForEach-Object {
          if ($kukk) {
            $key=$_.lol;
            $value=$_.klasse
          }
          else {
            [String]$key=$prefix+$_.klasse
            $key=$key.Replace(" ","");
            [String]$value=$_.lol
            $value=$value.Replace(" ","");
          }



        if ($out[$key] -eq $null) {
            $data=@();
            $data+=$value;
            $out[$key]=$data
        }
        elseif (($out[$key] -notcontains $value)) {
            $data=$out[$key];
            $data+=$value;
            $out[$key]=$data
        }
      }
      $out
      
    }

}#ende get-classTeachersTeam function

#cls
#get-classteachersteam "$PSSCRIPTROOT\gpu002.txt"
