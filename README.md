# Digitales Klassenbuch (diklabu)
RESTful Webservice inkl. Client für das digitale Klassenbuch.
## Installations
Zunächst muss eine leere Datenbank herunter geladen werden (https://github.com/jtuttas/diklabu/raw/master/Diklabu/doc/diklabu.GDB) und z.B. gespeichert werden nach **c:\Temp**

Es existiert eine Docker Installation des diklabu's.
```
docker pull tuttas/diklabu
docker run -v c:/Temp:/var/lib/firebird/2.5/data -i -t -p 8080:8080 tuttas/diklabu
```
Dann aufruf der Seite http://localhost:8080/Diklabu/dev2/

## Screenshots
### Anmeldung
![Screenshot](diklabu/Diklabu/doc/screen1.png)
### Unterrichtsverlauf
![Screenshot](Diklabu/doc/screen2.png)
### Anwesenheit
![Screenshot](Diklabu/doc/screen3.png)
