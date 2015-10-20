
package de.tuttas.restful.Data;

import de.tuttas.entities.Klasse;
import java.util.List;

/**
 * Das Ticket für die Kurswahl
 * @author Jörg
 */
public class Ticketing {

    /**
     * Anmeldeinformationen
     */
    private Credential credential;
    /**
     * Liste der Kurswünsche
     */
    private List<Klasse> courseList;
    /**
     * Buchung erfolgreich
     */
    private boolean success;
    /**
     * Nachricht der Buchung 
     */
    private String msg;

    /**
     * Nachricht für den Buchungsvorgang z.B. "Sie haben bereits gewählt"
     * @param msg Die Nachricht
     */
    public void setMsg(String msg) {
        this.msg = msg;
    }

    /**
     * Buchung erfolgreich
     * @param success success = true .. Buchung erfolgreich
     */
    public void setSuccess(boolean success) {
        this.success = success;
    }

    /**
     * Abfrage der Nachricht an den Benutzer
     * @return die Nachricht
     */
    public String getMsg() {
        return msg;
    }
    
    /**
     * Abfrage ob Buchung erfolgreich
     * @return true = Erfolgreich
     */
    public boolean getSuccess() {
        return success;
    }
    
    /**
     * Abfrage der Anmeldeinformationen des Benutzers
     * @return Anmeldeinformationen des Benutzers mit Name, Vorname und Geburtsdatum etc.
     */
    public Credential getCredential() {
        return credential;
    }

    /**
     * Setzen der Anmeldeinformatioen des Benutezrs
     * @param c Anmeldeinformationen des Benutzers mit Name, Vorname und Geburtsdatum etc.
     */
    public void setCredential(Credential c) {
        this.credential = c;
    }

    /**
     * Setzen der Kursliste (Wunschliste) der WPK's
     * @param courseList die Liste der gewählten Kurse
     */
    public void setCourseList(List<Klasse> courseList) {
        this.courseList = courseList;
    }

    /**
     * Abfrage der Kursliste (Wunschliste)
     * @return die Liste der gewählten Kurse
     */
    public List<Klasse> getCourseList() {
        return courseList;
    }

    /**
     * Ticket validieren (es dürfen nur drei Wünsche geäußert werden und diese Wünsche müssen
     * unterschiedlich sein.
     * @param t Das Ticket
     * @return  Das validierte Ticket (ergänzt um Statusmeldungen)
     */
    public Ticketing validate(Ticketing t) {                    
        if (t.getCourseList().size()!=3) {
            t.setSuccess(false);
            t.setMsg("Bitte drei Wünsche auswählen!");
            return t;
        }
        if (t.getCourseList().get(0).getId().intValue()== t.getCourseList().get(1).getId().intValue() ||
            t.getCourseList().get(0).getId().intValue()== t.getCourseList().get(2).getId().intValue() ||
            t.getCourseList().get(1).getId().intValue()== t.getCourseList().get(2).getId().intValue()) {
            t.setSuccess(false);
            t.setMsg("Bitte drei unterschiedliche Wünsche auswählen!");
        }
        t.setSuccess(true);
        return t;
    }

    @Override
    public String toString() {
        return "Ticketing: credentials="+this.getCredential().toString()+" CourseLIst="+this.getCourseList();
    }
    
    
    
    
    
}
