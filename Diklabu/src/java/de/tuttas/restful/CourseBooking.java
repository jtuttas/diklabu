/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.restful.Data.Ticketing;
import de.tuttas.entities.Courses;
import de.tuttas.entities.Pupil;
import de.tuttas.entities.Rel_Courses_Pupil;
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
 *
 * @author Jörg
 */
@Path("courseselect/booking")
@Stateless
public class CourseBooking {
    
        @PersistenceContext(unitName="DiklabuPU")
    EntityManager em;
        
     @GET   
    @Consumes(MediaType.APPLICATION_JSON)
    public List<Courses> getCourses() {
        System.out.println ("Webservice courseselect/booking GET:");
        Query  query = em.createNamedQuery("getAllCourses");
        List<Courses> courses = query.getResultList();
        System.out.println("Result List:"+courses);
        return courses;
    }   
    
    @POST   
    @Consumes(MediaType.APPLICATION_JSON)
    public Ticketing book(Ticketing t) {
        System.out.println ("Webservice courseselect/booking POST:"+t.toString());
        Query  query = em.createNamedQuery("findPupilbyCredentials");
        query.setParameter("paramName", t.getCredential().getName());
        query.setParameter("paramVorname", t.getCredential().getVorName());
        query.setParameter("paramGebDatum", t.getCredential().getGebDatum());
        List<Pupil> pupils = query.getResultList();
        System.out.println("Result List Pupil:"+pupils);
        // Validireung der empfangenen Daten
        if (pupils.size()!=0) {
            t.getCredential().setLogin(true);
            t.getCredential().setMsg("Anmeldung erfolgreich");
            t.getCredential().setId(pupils.get(0).getId());
            t = t.validate(t);
            if (t.getSuccess()) {
                //  Schauen ob der Pupil schon gewählt hat
                Query  q = em.createNamedQuery("findCoursesByUserId");
                q.setParameter("paramId", t.getCredential().getId());
                List<Courses> courses = q.getResultList();
                System.out.println("Result List Courses:"+courses);
                if (courses.size()==0) {                
                    // Die drei Wünsche
                    Rel_Courses_Pupil rel1 = new Rel_Courses_Pupil(
                            t.getCourseList().get(0).getId().intValue(),
                            t.getCredential().getId(), 1);
                    Rel_Courses_Pupil rel2 = new Rel_Courses_Pupil(
                            t.getCourseList().get(1).getId().intValue(),
                            t.getCredential().getId(), 2);
                    Rel_Courses_Pupil rel3 = new Rel_Courses_Pupil(
                            t.getCourseList().get(2).getId().intValue(),
                            t.getCredential().getId(), 3);
                    // Validierung erfolgreich, jetzt Daten in DB eintragen
                    em.persist(rel1); //em.merge(u); for updates
                    em.persist(rel2); //em.merge(u); for updates
                    em.persist(rel3); //em.merge(u); for updates
                    t.setMsg("Buchung erfolgreich!");
                }
                else {
                    t.setSuccess(false);
                    t.setMsg("Sie haben bereits gewählt!");
                }
                
            }
        }
        else {
            t.getCredential().setLogin(false);
            t.setSuccess(false);
            t.setMsg("Anmeldedaten ungültig");
        }
        return t;
    }
}
