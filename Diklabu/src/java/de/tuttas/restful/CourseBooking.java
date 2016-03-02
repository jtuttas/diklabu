
package de.tuttas.restful;

import de.tuttas.entities.Klasse;
import de.tuttas.entities.Konfig;
import de.tuttas.entities.Kurswunsch;
import de.tuttas.entities.LoginSchueler;
import de.tuttas.restful.Data.Ticketing;



import de.tuttas.entities.Schueler;
import de.tuttas.restful.Data.Credential;
import de.tuttas.util.Log;
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
@Path("kurswahl")
@Stateless
public class CourseBooking {
    
    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName="DiklabuPU")
    EntityManager em;
        
        /**
     * Abfrage eines beispielhaften Login Onjektes mit Daten
     * @return Das Anmeldeobjekt
     */
    @GET   
    @Path("/login")
    @Consumes(MediaType.APPLICATION_JSON)
    public Credential about() {
        Credential c = new Credential();
        c.setName("Nachname");
        c.setVorName("Vorname");
        c.setGebDatum(Date.valueOf("2014-12-31"));
        return c;
    }
    
    /**
     * Bnutzernamledung am System
     * @param c Credential Objekt mit Anmelde Daten
     * @return das Credential Objekt mit Anmelde Daten erweiter um Attribute id, success und msg
     */
    @POST   
    @Path("/login")
    @Consumes(MediaType.APPLICATION_JSON)
    public Credential login(Credential c) {
        em.getEntityManagerFactory().getCache().evictAll();
        Log.d ("Webservice courseselect/login"+c.toString());
        Query  query = em.createNamedQuery("findSchuelerbyCredentials");
        query.setParameter("paramName", c.getName());
        query.setParameter("paramVorname", c.getVorName());
        query.setParameter("paramGebDatum", c.getGebDatum());
        
        List<Schueler> pupils = query.getResultList();
        Log.d("Result List:"+pupils);
        if (pupils.size()>0) {
            c.setLogin(true);
            c.setMsg("Anmeldung erfolgreich!");
            c.setId(pupils.get(0).getId().intValue());
            // Abfrage der gewählten Kurse
            query = em.createNamedQuery("findKlasseByUserId");
            query.setParameter("paramId", c.getId());
            List<Klasse> courses = query.getResultList();
            Log.d("Liste der Wünsche:"+courses);
            c.setCourses(courses);
            Log.d("Liste des gewählten Kurses:"+courses);
            
            LoginSchueler ls= em.find(LoginSchueler.class, pupils.get(0).getId().intValue());
            c.setEduplazaMail(ls.getLOGIN()+"@mmbbs.eduplaza.de");
            
            // Abfrage des zugeteilten Kurses
            if (courses.size()!=0) {
                query = em.createNamedQuery("findKlassebyKurswunsch");
                query.setParameter("paramWunsch1ID", courses.get(0).getId());
                query.setParameter("paramWunsch2ID", courses.get(1).getId());
                query.setParameter("paramWunsch3ID", courses.get(2).getId());
                query.setParameter("paramIDSchueler", c.getId());
                List<Klasse> selectCourses = query.getResultList();
                Log.d("Liste der zugeteilten Kurses:"+selectCourses);
                if (selectCourses.size()!=0) c.setSelectedCourse(selectCourses.get(0));
            }
            
        }
        else {
            c.setLogin(false);
            c.setMsg("Kann Anmeldedaten nicht in der Datenbank finden!");
        }
        return c;
    }
    

    
    /**
         * Abfrage der Kuirsliste der Buchbaren Kurse
         * @return Die Liste mit Kursen (Klassen)
         */
     @GET  
     @Path("/getcourses")
    @Consumes(MediaType.APPLICATION_JSON)
    public List<Klasse> getCourses() {
        em.getEntityManagerFactory().getCache().evictAll();
        Log.d ("Webservice courseselect/booking GET:");
        
        Query  query = em.createNamedQuery("getSelectedKlassen");
        List<Klasse> courses = query.getResultList();
        Log.d("Result List:"+courses);
        return courses;                
    }   
    
    /**
     * Buchen eines Kurses
     * @param t Das Ticketing Objekt mit Credentials und Kurslist
     * @return Das Ticketing Objekt ergänzt im msg und success Attribute
     */
    @POST   
    @Path("/buchen")
    @Consumes(MediaType.APPLICATION_JSON)
    public Ticketing book(Ticketing t) {
        em.getEntityManagerFactory().getCache().evictAll();
        Log.d ("Webservice courseselect/booking POST:"+t.toString());
        Query  query = em.createNamedQuery("findSchuelerbyCredentials");
        query.setParameter("paramName", t.getCredential().getName());
        query.setParameter("paramVorname", t.getCredential().getVorName());
        query.setParameter("paramGebDatum", t.getCredential().getGebDatum());
        List<Schueler> pupils = query.getResultList();
        Log.d("Result List Pupil:"+pupils);
        
        // Schauen ob Kursbuchung aktiv
        
        Query qk = em.createNamedQuery("findTitel");        
        qk.setParameter("paramTitel", "kursbuchung");
        List<Konfig> konfig = qk.getResultList();
        Log.d ("Konfig="+konfig);
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
                    Log.d("Result List Courses:"+courses);
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
                        query = em.createNamedQuery("findKlassebyKurswunsch");
                        query.setParameter("paramWunsch1ID", courses.get(0).getId());
                        query.setParameter("paramWunsch2ID", courses.get(1).getId());
                        query.setParameter("paramWunsch3ID", courses.get(2).getId());
                        query.setParameter("paramIDSchueler", t.getCredential().getId());
                        List<Klasse> selectCourses = query.getResultList();
                        Log.d("Liste der zugeteilten Kurses:"+selectCourses);
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
