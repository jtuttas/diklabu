
package de.tuttas.restful.Data;

import de.tuttas.entities.Klasse;
import java.sql.Date;
import java.util.List;

/**
 * Anmelde Objekt, welches vom Restful Service verwendet wird
 * @author Jörg
 */
public class Credential {
    /**
     * Name des Benutzers
     */
    private String name;
    /**
     * Vorname des Benutzers
     */
    private String vorName;
    /**
     * Geburtsdatum des Benutzers in der Form yyyy-mm-dd
     */
    private Date gebDatum;
    /**
     * Anmeldung erfolgreich
     */
    private boolean login=false;
    /**
     * Nachricht / Fehlermeldung bei der Anmeldung
     */
    private String msg;
    /**
     * Primärschlässel des Benutzers aus der SCHUELR Tabelle
     */
    private int id;

    /**
     * Primärschlüssel des Benutzers aus das SCHUELER Entität
     * @param id Der Primärschlüssel
     */
    private List<Klasse> courses;

    /**
     * Der zugeiteilte Kurs
     */
    private Klasse selectedCourse;

    /**
     * Setzen des gewählten Kurses
     * @param selectedCourse  der gewählte Kurs
     */
    public void setSelectedCourse(Klasse selectedCourse) {
        this.selectedCourse = selectedCourse;
    }

    /**
     * Abfrage des gewählten Kurses
     * @return der gewählte Kurs
     */
    public Klasse getSelectedCourse() {
        return selectedCourse;
    }
    
    
    
    
    /**
     * Setze Liste der gebuchten Kurse
     * @param courses die Liste der gebuchten Kurse
     */
    public void setCourses(List<Klasse> courses) {
        this.courses = courses;
    }

    /**
     * Abfrage der Liste der gebuchten Kurse
     * @return die Liste der gebuchten Kurse
     */
    public List<Klasse> getCourses() {
        return courses;
    }
    
    
    
    
    public void setId(int id) {
        this.id = id;
    }

    /**
     * Primärschlüssel des Benutzers aus das SCHUELER Entität
     * @return Der Primärschlüssel
     */
    public int getId() {
        return id;
    }
       

    /**
     * Anmeldeinformationen an den Benutzer z.B. "Anmeldung Erfolgreich"
     * @param msg Die Nachricht
     */
    public void setMsg(String msg) {
        this.msg = msg;
    }

    /**
     * Anmeldeinformationen an den Benutzer z.B. "Anmeldung Erfolgreich"
     * @return Die Nachricht
     */
    public String getMsg() {
        return msg;
    }

    /**
     * Geburtsdatum des Benutzers in der Form yyyy-mm-dd als Date Objekt
     * @param gebDatum Das Geburtsdatum
     */
    public void setGebDatum(Date gebDatum) {
        this.gebDatum = gebDatum;
    }

    /**
     * Login erfolgreich?
     * @param login Login erfolgreich = true
     */
    public void setLogin(boolean login) {
        this.login = login;
    }

    /**
     * Abfrage ob Login erfolgreich
     * @return Login erfolgreich = true
     */
    public boolean getLogin() {
        return login;
    }
    
    /**
     * Nachname des Benutzers
     * @param name Der Nachname
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * Vorname des Benutzers
     * @param vorName der Vorname
     */
    public void setVorName(String vorName) {
        this.vorName = vorName;
    }

    /**
     * Abfrage des Geburtstages
     * @return der Geburtstag
     */
    public Date getGebDatum() {
        return gebDatum;
    }

    /**
     * Abfrage des Nachnamens
     * @return der Nachname
     */
    public String getName() {
        return name;
    }

    /**
     * Abfrage des Vornamens
     * @return der Vorname
     */
    public String getVorName() {
        return vorName;
    }
    
 @Override
    public String toString() {
        return "de.tuttas.model.Pupil[ Name="+name+" Vorname="+vorName+" GebDatum="+gebDatum  +"]";
    }
    
}
