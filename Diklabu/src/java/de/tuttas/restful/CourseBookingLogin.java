package de.tuttas.restful;


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
 * Restful Service für die Benutzeraneldung am WPK Buchungssystem System
 * @author Jörg
 */
@Path("courseselect/login")
@Stateless
public class CourseBookingLogin {
    @PersistenceContext(unitName="DiklabuPU")
    EntityManager em;
    
    /**
     * Abfrage eines beispielhaften Login Onjektes mit Daten
     * @return Das Anmeldeobjekt
     */
    @GET   
    @Consumes(MediaType.APPLICATION_JSON)
    public Credential about() {
        Credential c = new Credential();
        c.setName("Nachname");
        c.setVorName("Vorname");
        c.setLogin(false);
        c.setGebDatum(Date.valueOf("2014-12-31"));
        return c;
    }
    
    /**
     * Bnutzernamledung am System
     * @param c Credential Objekt mit Anmelde Daten
     * @return das Credential Objekt mit Anmelde Daten erweiter um Attribute id, success und msg
     */
    @POST   
    @Consumes(MediaType.APPLICATION_JSON)
    public Credential login(Credential c) {
        System.out.println ("Webservice courseselect/login"+c.toString());
        Query  query = em.createNamedQuery("findSchuelerbyCredentials");
        query.setParameter("paramName", c.getName());
        query.setParameter("paramVorname", c.getVorName());
        query.setParameter("paramGebDatum", c.getGebDatum());
        
        List<Schueler> pupils = query.getResultList();
        System.out.println("Result List:"+pupils);
        if (pupils.size()>0) {
            c.setLogin(true);
            c.setMsg("Anmeldung erfolgreich!");
            c.setId(pupils.get(0).getId().intValue());
        }
        else {
            c.setLogin(false);
            c.setMsg("Kann Anmeldedaten nicht in der Datenbank finden!");
        }
        return c;
    }
}
