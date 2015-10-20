
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

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMsg() {
        return msg;
    }
    
    public boolean getSuccess() {
        return success;
    }
    
    public Credential getCredential() {
        return credential;
    }

    public void setCredential(Credential c) {
        this.credential = c;
    }

    public void setCourseList(List<Klasse> courseList) {
        this.courseList = courseList;
    }

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
