/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Ausbilder;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Schueler;
import de.tuttas.entities.Verlauf;
import de.tuttas.restful.Data.AnwesenheitEintrag;
import de.tuttas.restful.Data.PsResultObject;
import de.tuttas.restful.Data.ResultObject;
import de.tuttas.util.Log;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.List;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;

/**
 *
 * @author Jörg
 */
@Path("admin/ausbilder")
@Stateless
public class AusbilderManager {
     /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;
    
    @GET
    @Produces({"application/json; charset=iso-8859-1"})
    @Path("find/{name}")
    public List<Ausbilder> getAusbilder(@PathParam("name") String n) {
        Query query = em.createNamedQuery("findAusbilderByName");
        query.setParameter("paramAusbildername", n);
        List<Ausbilder> ausbilder = query.getResultList();
        return ausbilder;
    }

    @GET
    @Produces({"application/json; charset=iso-8859-1"})
    @Path("{id}")
    public Ausbilder getAusbilder(@PathParam("id") int id) {
        Ausbilder a = em.find(Ausbilder.class, id);
        return a;
    }

    @POST
    @Produces({"application/json; charset=iso-8859-1"})
    @Path("{id}")
    public Ausbilder setAusbilder(@PathParam("id") int id,Ausbilder aus) {
        em.getEntityManagerFactory().getCache().evictAll();
        Ausbilder a = em.find(Ausbilder.class, id);
        if (a!=null) {
            if (aus.getANREDE()!=null) a.setANREDE(aus.getANREDE());
            if (aus.getEMAIL()!=null) a.setEMAIL(aus.getEMAIL());
            if (aus.getFAX()!=null) a.setFAX(aus.getFAX());
            if (aus.getID_BETRIEB()!=null) a.setID_BETRIEB(aus.getID_BETRIEB());
            if (aus.getNNAME()!=null) a.setNNAME(aus.getNNAME());
            if (aus.getTELEFON()!=null) a.setTELEFON(aus.getTELEFON());
            em.merge(a);
        }
        return a;
    }
    
    @DELETE
    @Produces({"application/json; charset=iso-8859-1"})
    @Path("{id}")
    public PsResultObject delAusbilder(@PathParam("id") int id) {
        em.getEntityManagerFactory().getCache().evictAll();
        PsResultObject ro = new PsResultObject();
        Ausbilder a = em.find(Ausbilder.class, id);
        if (a!=null) {
            Query query = em.createNamedQuery("findSchuelerByAusbilderId");
            query.setParameter("paramAusbilderId", id);
            List<Schueler> schueler = query.getResultList();
            if (schueler.size() != 0) {
                ro.setSuccess(false);
                ro.setMsg("Dem Ausbilder " + a.getNNAME()+ " sind noch Schüler zugewiesen!");
                Log.d("Dem Ausbilder sind noch "+schueler.size()+" zugewiesen");
                int[] ids = new int[schueler.size()];
                for (int i=0;i<schueler.size();i++) {
                    ids[i]=schueler.get(i).getId();   
                }
                ro.setIds(ids);                
                return ro;
            }
            else {
                em.remove(a);
                ro.setSuccess(true);
                ro.setMsg("Ausbilder "+a.getNNAME()+" gelöscht");
            }
        }
        else {
            ro.setSuccess(false);
            ro.setMsg("Kann Ausbilder mit ID="+id+" nicht finden!");
        }
        return ro;
    }
    
    @POST
    @Produces({"application/json; charset=iso-8859-1"})    
    public Ausbilder setAusbilder(Ausbilder aus) {
        em.getEntityManagerFactory().getCache().evictAll();
        em.persist(aus);
        em.flush();
        return aus;
    }
}
