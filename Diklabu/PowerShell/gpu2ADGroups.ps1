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

function get-classTeachersTeam {
    [CmdletBinding()]
    Param
    (    
        # Pfad- und Dateiname der aus GP Untis exportierten Datei
        [Parameter(Mandatory=$true,Position=0)]
        [String]$path,
        # Kurse die nicht berücksichtigt werden
        [String[]]$blacklist=("EN-","WPK-","ITKVR","FöKu_","SPK-","CCNA","LR","VOrgMe","VOrgIT","Seminar","Linux")

    )

    Process
    {
       $csvhead = "Unr;std1;std2;std3;klasse;lol;fach;raum;uebertragen;feld_j;wstd;halbj;statkuerzel;feld_n;datumstart;datumend;feld_q;SIst;LIst;raum2;uform;feld_v;feld_w;feld_x;feld_y;feld_z;feld_aa;feld_ab;feld_ac;feld_ad;feld_ae;feld_af;feld_ag;feld_ah;feld_ai;feld_aj;feld_ak;feld_al;feld_am;feld_an;feld_ao"
       $out_delimiter="," #Trennzeichen für die Lehrerliste einer Klasse
    
       try{
       if ((get-content $path -totalcount 1) -ne $csvhead) {
          #Kopfzeile einfügen falls noch nicht vorhanden
          $ftext = get-content $path -Encoding UTF8 #alten content merken  
          $csvhead|out-file -filepath $path -Encoding utf8
  
          $ftext|out-file -filepath $path -Append -Encoding utf8

          # msg "Kopfzeile in GPU Exportdatei eingefügt" $s
      }
      
      # Untis csv einlesen
      $gpu_unterrichte=Import-Csv -Delimiter ";" -Path $path -Encoding UTF8
      
      $out=@{}
      foreach ($gpu_unterricht in $gpu_unterrichte){
        #Wenn .fach bestimmte Bezeichnungen enthält, wird LoL nicht die Liste eingepflegt
        $eintragen = $true
        foreach($keinLFoderFach in $blacklist){
          if(($gpu_unterricht.fach).contains($keinLFoderFach)){$eintragen=$false}
        }

        if($eintragen){
            #falls Eintrag für diese Klasse noch leer, wird das jetzt einfach eingetragen
            if ((!$out["Klassenteam-$($gpu_unterricht.klasse)"]) -or ($out["Klassenteam-$($gpu_unterricht.klasse)"] -eq "")){
                $r=@();
                $r+=$gpu_unterricht.lol
                $out["Klassenteam-$($gpu_unterricht.klasse)"]=$r
            }
            elseif (!$out["Klassenteam-$($gpu_unterricht.klasse)"].contains($gpu_unterricht.lol)) {
             #LoL noch nicht eingetragen, hinten anhängen
             $r=$out["Klassenteam-$($gpu_unterricht.klasse)"]
             $r+=$gpu_unterricht.lol
             $out["Klassenteam-$($gpu_unterricht.klasse)"]=$r
            
            }
        }
        
      }#ende foreach
       $out
      

     }#ende try
     
     catch {
            Write-Error "Get-classTeachersTeam: Status-Code"$_.Exception.Response.StatusCode.value__ " "$_.Exception.Response.StatusDescription 
     }
    }

}#ende get-classTeachersTeam function

#cls
#get-classteachersteam "$PSSCRIPTROOT\gpu002.txt"
