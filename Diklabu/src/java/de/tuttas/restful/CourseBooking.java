
package de.tuttas.restful;

import de.tuttas.entities.Klasse;
import de.tuttas.entities.Konfig;
import de.tuttas.entities.Kurswunsch;
import de.tuttas.restful.Data.Ticketing;



import de.tuttas.entities.Schueler;
import de.tuttas.restful.Data.Credential;
import java.sql.Date;
import java.util.List;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.core.MediaType;

/**
 * Restful Webservice für die Kursbuchung (WPK Buchung)
 * @author Jörg
 */
@Path("courseselect/booking")
@Stateless
public class CourseBooking {
    
    /**
     * Injection des EntityManagers
     */
        @PersistenceContext(unitName="DiklabuPU")
    EntityManager em;
        
        /**
         * Abfrage der Kuirsliste der Buchbaren Kurse
         * @return Die Liste mit Kursen (Klassen)
         */
     @GET   
    @Consumes(MediaType.APPLICATION_JSON)
    public List<Klasse> getCourses() {
        em.getEntityManagerFactory().getCache().evictAll();
        System.out.println ("Webservice courseselect/booking GET:");
        
        Query  query = em.createNamedQuery("getSelectedKlassen");
        List<Klasse> courses = query.getResultList();
        System.out.println("Result List:"+courses);
        return courses;                
    }   
    
    /**
     * Buchen eines Kurses
     * @param t Das Ticketing Objekt mit Credentials und Kurslist
     * @return Das Ticketing Objekt ergänzt im msg und success Attribute
     */
    @POST   
    @Consumes(MediaType.APPLICATION_JSON)
    public Ticketing book(Ticketing t) {
        em.getEntityManagerFactory().getCache().evictAll();
        System.out.println ("Webservice courseselect/booking POST:"+t.toString());
        Query  query = em.createNamedQuery("findSchuelerbyCredentials");
        query.setParameter("paramName", t.getCredential().getName());
        query.setParameter("paramVorname", t.getCredential().getVorName());
        query.setParameter("paramGebDatum", t.getCredential().getGebDatum());
        List<Schueler> pupils = query.getResultList();
        System.out.println("Result List Pupil:"+pupils);
        
        // Schauen ob Kursbuchung aktiv
        
        Query qk = em.createNamedQuery("findTitel");        
        qk.setParameter("paramTitel", "kursbuchung");
        List<Konfig> konfig = qk.getResultList();
        System.out.println ("Konfig="+konfig);
        if (konfig.get(0).getSTATUS()==0) {
            t.setSuccess(false);
            t.setMsg("Wahl ist noch nicht freigeschaltet!");            
        }
        else {
            // Validireung der empfangenen Daten
            if (pupils.size()!=0) {
                t.getCredential().setLogin(true);
                t.getCredential().setMsg("Anmeldung erfolgreich");
                t.getCredential().setId(pupils.get(0).getId());
                t = t.validate(t);
                if (t.getSuccess()) {
                    //  Schauen ob der Pupil schon gewählt hat
                    Query  q = em.createNamedQuery("findKlasseByUserId");
                    q.setParameter("paramId", t.getCredential().getId());
                    List<Klasse> courses = q.getResultList();
                    System.out.println("Result List Courses:"+courses);
                    if (courses.size()==0) {                
                        // Die drei Wünsche
                        Kurswunsch rel1 = new Kurswunsch(t.getCredential().getId(),t.getCourseList().get(0).getId().intValue(), "1","0");
                        Kurswunsch rel2 = new Kurswunsch(t.getCredential().getId(),t.getCourseList().get(1).getId().intValue(), "2","0");
                        Kurswunsch rel3 = new Kurswunsch(t.getCredential().getId(),t.getCourseList().get(2).getId().intValue(), "3","0");
                        // Validierung erfolgreich, jetzt Daten in DB eintragen
                        em.persist(rel1); //em.merge(u); for updates
                        em.persist(rel2); //em.merge(u); for updates
                        em.persist(rel3); //em.merge(u); for updates
                        t.setMsg("Buchung erfolgreich!");
                    }
                    else {
                        // Abfrage des zugeteilten Kurses
                        query = em.createNamedQuery("findSelectKlasseByUserId");
                        query.setParameter("paramId", t.getCredential().getId());
                        List<Klasse> selectCourses = query.getResultList();
                        System.out.println("Liste des gewählten Kurses:"+courses);
                        if (selectCourses.size()!=0) t.getCredential().setSelectedCourse(selectCourses.get(0));
                        t.setSuccess(false);
                        t.getCredential().setCourses(courses);
                        t.setMsg("Sie haben bereits gewählt!");
                    }

                }
            }
            else {
                t.getCredential().setLogin(false);
                t.setSuccess(false);
                t.setMsg("Anmeldedaten ungültig");
            }
        }
        return t;
    }
}
