
package de.tuttas.restful.Data;

import java.sql.Date;

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

    public void setId(int id) {
        this.id = id;
    }

    public int getId() {
        return id;
    }
       

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public String getMsg() {
        return msg;
    }

    
    public void setGebDatum(Date gebDatum) {
        this.gebDatum = gebDatum;
    }

    public void setLogin(boolean login) {
        this.login = login;
    }

    public boolean getLogin() {
        return login;
    }
    
    public void setName(String name) {
        this.name = name;
    }

    public void setVorName(String vorName) {
        this.vorName = vorName;
    }

    public Date getGebDatum() {
        return gebDatum;
    }

    public String getName() {
        return name;
    }

    public String getVorName() {
        return vorName;
    }
    
 @Override
    public String toString() {
        return "de.tuttas.model.Pupil[ Name="+name+" Vorname="+vorName+" GebDatum="+gebDatum  +"]";
    }
    
}
