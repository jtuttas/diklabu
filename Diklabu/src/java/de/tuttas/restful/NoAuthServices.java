/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Lehrer;
import de.tuttas.entities.Lernfeld;
import de.tuttas.entities.Termindaten;
import de.tuttas.entities.Termine;
import de.tuttas.restful.Data.AnwesenheitEintrag;
import de.tuttas.restful.Data.KlasseShort;
import de.tuttas.restful.Data.Termin;
import de.tuttas.util.Log;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;


/**
 * Diese Webservices sind ohne eine Authentifizierung aufrufbar
 *
 * @author Jörg
 */
@Path("noauth")
@Stateless
public class NoAuthServices {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    @GET
    @Path("lehrer")
    public List<Lehrer> getAnwesenheit() {
        Log.d("Webservice Lehrer Get:");
        Query query = em.createNamedQuery("findAllTeachers");
        List<Lehrer> lehrer = query.getResultList();
        return lehrer;
    }

    @GET
    @Path("klassen")
    public List<KlasseShort> getClasses() {
        Log.d("Webservice klasse GET");
        TypedQuery<KlasseShort> query = em.createNamedQuery("findAllKlassen", KlasseShort.class);
        List<KlasseShort> klassen = query.getResultList();
        Log.d("Result List:" + klassen);
        return klassen;
    }

    @GET
    @Path("lernfelder")
    public List<Lernfeld> getLernfeld() {
        Log.d("Webservice Lernfeld GET:");
        Query query = em.createNamedQuery("findAllLernfelder");
        List<Lernfeld> lernfeld = query.getResultList();
        return lernfeld;
    }
    
    @GET
    @Path("termine/{from}/{to}/{filter1}/{filter2}")
    public List<Termin> getTermine(@PathParam("from") Date from, @PathParam("to") Date to,@PathParam("filter1") int f1_id,@PathParam("filter2") int f2_id) {
        Log.d("Webservice Termine GET: from:"+from+" to:"+to+" filter1="+f1_id+" filter2="+f2_id);
        
        Termine t1 = em.find(Termine.class, f1_id);
        Termine t2 = em.find(Termine.class, f2_id);
        if (t1!=null) {
            System.out.println("t1="+t1.getNAME());
            if (t2!=null) {
                System.out.println("t2="+t2.getNAME());                
            }
        }
        else {
            if (t2!=null) {
                System.out.println("t2="+t2.getNAME());                
                t1=t2;
            }
        }
        TypedQuery<Termin> query = null;
        if (t1!=null && t2!=null) {
            query = em.createNamedQuery("findAllTermineTwoFilters",Termin.class);
            query.setParameter("filter1", t1.getId());
            query.setParameter("filter2", t2.getId());
        }
        else if (t1!=null) {
            query = em.createNamedQuery("findAllTermineOneFilter",Termin.class);
            query.setParameter("filter1", t1.getId());
        }
        else {
            query = em.createNamedQuery("findAllTermine",Termin.class);
        }
        query.setParameter("fromDate", from);            
        query.setParameter("toDate", to);            
        
        List<Termin> termine = query.getResultList();
        System.out.println("result set="+termine+" type="+termine.getClass());
        return termine;
    }
}
