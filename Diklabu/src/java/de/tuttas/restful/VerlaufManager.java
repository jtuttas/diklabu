/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Anwesenheit;
import de.tuttas.entities.Schueler;
import de.tuttas.entities.Verlauf;
import de.tuttas.restful.Data.AnwesenheitEintrag;
import de.tuttas.restful.Data.AnwesenheitObjekt;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.List;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;

/**
 *
 * @author Jörg
 */
@Path("verlauf")
@Stateless
public class VerlaufManager {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;
    
    @GET   
    public Verlauf getVerlauf() {
          em.getEntityManagerFactory().getCache().evictAll();
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Timestamp d1 = new Timestamp(cal.getTimeInMillis());
        Verlauf v = new Verlauf(0, d1, "01", "TU", "LF6", "nix", "keine", "keine");
        return v;        
    }
    
    @DELETE
     @Path("/{id}")
    public Verlauf deleteVerlauf(@PathParam("id") int id) {
        System.out.println("DELETE empfangen id="+id);
        Verlauf v = em.find(Verlauf.class, id);
        if (v!=null)  em.remove(v);
        return v;
        
    }
    
    @POST
    public Verlauf setVerlauf(Verlauf v) {
          em.getEntityManagerFactory().getCache().evictAll();
        System.out.println("POST Verlauf = "+v.toString());
        Query  q = em.createNamedQuery("findVerlaufbyDatumStundeAndKlassenID");
        q.setParameter("paramDatum", v.getDATUM());
        q.setParameter("paramKlassenID", v.getID_KLASSE());        
        q.setParameter("paramStunde",v.getSTUNDE());
        List<Verlauf> verlauf = q.getResultList();
        System.out.println("Result List:" + verlauf);
        if (verlauf.size()!=0) {
            System.out.println("Es gibt schon einen Eintrag, also updaten");
            Verlauf ve = verlauf.get(0);
            ve.setAUFGABE(v.getAUFGABE());
            ve.setBEMERKUNG(v.getBEMERKUNG());
            ve.setDATUM(ve.getDATUM());
            ve.setID_KLASSE(v.getID_KLASSE());
            ve.setID_LEHRER(v.getID_LEHRER());
            ve.setID_LERNFELD(v.getID_LERNFELD());
            ve.setINHALT(v.getINHALT());
            ve.setSTUNDE(v.getSTUNDE());
            em.merge(ve);
        }
        else {
            System.out.println("Neuen Verlaufseintrag erzeugen");
            em.persist(v);
        }
        return v;
    }

    @GET
    @Path("/{klasse}")
    public List<Verlauf> getVerlauf(@PathParam("klasse") String kl) {
          
        em.getEntityManagerFactory().getCache().evictAll();
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Date d1 = new Date(cal.getTimeInMillis());
        Date d2 = new Date(cal.getTimeInMillis() + (1000 * 60 * 60 * 24));
        System.out.println("Webservice Verlauf GET from Date=" + d1.toString() + " To " + d2.toString() + " klasse=" + kl);
        Query query = em.createNamedQuery("findVerlaufbyKlasse");
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", d1);
        query.setParameter("paramToDate", d2);
        List<Verlauf> verlauf = query.getResultList();
        System.out.println("Result List:" + verlauf);
        return verlauf;
    }
    
    @GET   
    @Path("/{klasse}/{from}")
    public List<Verlauf> getAnwesenheitFrom(@PathParam("klasse") String kl,@PathParam("from") Date  from ) {
          em.getEntityManagerFactory().getCache().evictAll();
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Date d = new Date(cal.getTimeInMillis());      
        System.out.println ("Webservice Verlauf GET klasse="+kl+" from="+from+" to="+d);        
        Query query = em.createNamedQuery("findVerlaufbyKlasse");        
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", from);
        query.setParameter("paramToDate", d);
        List<Verlauf> verlauf = query.getResultList();
        System.out.println("Result List:" + verlauf);
        return verlauf;  
    }
    
    @GET   
    @Path("/{klasse}/{from}/{to}")
    public List<Verlauf> getAnwesenheitFrom(@PathParam("klasse") String kl,@PathParam("from") Date from,@PathParam("to") Date to ) {
          em.getEntityManagerFactory().getCache().evictAll();
        System.out.println ("Webservice Verlauf GET from="+from+" to="+to);        
        Query query = em.createNamedQuery("findVerlaufbyKlasse");        
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", from);
        query.setParameter("paramToDate", to);
        List<Verlauf> verlauf = query.getResultList();
        System.out.println("Result List:" + verlauf);
        return verlauf;  
    }
}
