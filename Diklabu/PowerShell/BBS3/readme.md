# Installation vom diklabu für die BBS3
## Voraussetzungen
Das Ausführen von Powershell Skripten muss erlaubt werden (als Administrator)
```
Set-Executionpolicy RemoteSigned
```
Das diklabu Powershell Modul muss installiert sein, entweder über die Powershell Galery als Admin über:
```
Install-Module -Name diklabu
```
oder aber durch ausführen des Scriptes **loadModule.ps1** aus dem Repository.

## Verbindung zum Diklabu
Die Verbindung zum Diklabu wird über den Befehl:
```
Login-Diklabu -uri http://192.168.9.51:8080/Diklabu/api/v1/ -credential (get-credential "KirkJa")
```

## Verbindung zu BBS Planung
Die Verbindung zu BBS Planung wird aufgebaut über:
```
Connect-BbsPlan {Pfad zu BBS PLanung}
```
Sollte es hier zu einem Fehler kommen muss zunächst die *Microsoft Access database engine 2010* in der Version für das Betriebssystem installiert werden.

## Synchronisation mit BBS Planung
### Voraussetzungen
Wie oben beschrieben, muss eine Verbindung zu BBSPlanung und eine Verbindung zum diklabu möglich sein. Anschließend ist das Script *Sync-BBSPlan.ps1" zu starten.
## Aufrufen der Webseiten
Die Desktop Webseite wird aufgerufen über:
```
http://{Server IP}:8080/Diklabu/abbs3/
```
Der mobile Client wird aufgerufen über:
```
http://{Server IP}:8080/Diklabu/diklabu/mobile.html
```



