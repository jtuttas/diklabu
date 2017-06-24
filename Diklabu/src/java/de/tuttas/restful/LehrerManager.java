/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Klasse;
import de.tuttas.entities.Lehrer;
import de.tuttas.entities.Verlauf;
import de.tuttas.restful.Data.PsResultObject;
import de.tuttas.util.Log;
import de.tuttas.util.PlanType;
import de.tuttas.util.StundenplanUtil;
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
 * Restful Webservice zum Verwalten der Lehrer
 * @author Jörg
 */
@Path("lehrer")
@Stateless
public class LehrerManager {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    /**
     * Liste aller Lehrer abfragen
     * @return List der Lehrer
     */
    @GET
    public List<Lehrer> getAllLehrer() {
        Log.d("Webservice Lehrer Get:");
        Query query = em.createNamedQuery("findAllTeachers");
        List<Lehrer> lehrer = query.getResultList();
        return lehrer;
    }

    /**
     * Details zu einem Lehrer abfragen
     * @param idLehrer ID des Lehrers
     * @return Lehrer Objekt
     */
    @GET
    @Path("/{idLehrer}")
    @Produces({"application/json; charset=iso-8859-1"})
    public Lehrer getLehrer(@PathParam("idLehrer") String idLehrer) {
        Log.d("Webservice Lehrer Get:" + idLehrer);
        Lehrer lehrer = em.find(Lehrer.class, idLehrer);
        if (lehrer != null) {
            lehrer.setStdPlan(StundenplanUtil.getInstance().getPlanObject(lehrer.getNNAME(), PlanType.STDPlanLehrer).getUrl());
        }
        if (lehrer != null) {
            lehrer.setvPlan(StundenplanUtil.getInstance().getPlanObject(lehrer.getNNAME(), PlanType.VERTRPlanLehrer).getUrl());
        }
        return lehrer;
    }

    /**
     * Einen neuen Lehrer anlegen
     * @param l Lehrerobjekt
     * @return Lehrerobjekt mit vergebener ID
     */
    @POST
    @Produces({"application/json; charset=iso-8859-1"})
    @Path("admin")
    public Lehrer createLehrer(Lehrer l) {
        Log.d("Neuen Lehrer anlegen " + l);
        em.persist(l);
        em.flush();
        return l;
    }

    /**
     * Attribute für einen Lehrer verändern
     * @param lid ID des Lehrers
     * @param l Lehrerobjekt
     * @return Lehrerobjekt oder null bei Fehlern
     */
    @POST
    @Produces({"application/json; charset=iso-8859-1"})
    @Path("admin/id/{idlehrer}")
    public Lehrer setLehrer(@PathParam("idlehrer") String lid, Lehrer l) {
        em.getEntityManagerFactory().getCache().evictAll();
        Lehrer le = em.find(Lehrer.class, lid);
        if (le != null) {
             le.setEMAIL(l.getEMAIL());
            
            if (l.getIdplain() != null) {
                le.setIdplain(l.getIdplain());
            }
            if (l.getNNAME() != null) {
                le.setNNAME(l.getNNAME());
            }
            if (l.getTELEFON() != null) {
                le.setTELEFON(l.getTELEFON());
            }
            if (l.getVNAME() != null) {
                le.setVNAME(l.getVNAME());
            }
            em.merge(le);
        }
        return le;
    }

    /**
     * Einen Lehrer löschen
     * @param lid ID des Lehrers
     * @return Ergebnisobjekt mit Meldungen
     */
    @DELETE
    @Path("admin/{idlehrer}")
    @Produces({"application/json; charset=iso-8859-1"})
    public PsResultObject deleteLehrer(@PathParam("idlehrer") String lid) {
        Lehrer l = em.find(Lehrer.class, lid);

        PsResultObject ro = new PsResultObject();
        if (l != null) {
            Query query = em.createNamedQuery("findKlasseByLehrerId");
            query.setParameter("paramLehrerId", lid);
            List<Klasse> klassen = query.getResultList();
            if (klassen.size() == 0) {
                query = em.createNamedQuery("findVerlaufByLehrerId");
                query.setParameter("paramLehrerId", lid);
                List<Verlauf> verlauf = query.getResultList();
                for (Verlauf v : verlauf) {
                    em.remove(v);
                }
                em.remove(l);
                ro.setSuccess(true);
                ro.setMsg("Lehrer " + l.getNNAME() + " gelöscht!");
            } else {
                ro.setSuccess(false);
                ro.setMsg("Lehrer " + l.getNNAME() + " sind noch Klassen zugeordnet!");
                int[] ids = new int[klassen.size()];
                for (int i = 0; i < klassen.size(); i++) {
                    ids[i] = klassen.get(i).getId();
                }
                ro.setIds(ids);
            }
        } else {
            ro.setSuccess(false);
            ro.setMsg("Kann Lehrer mit ID=" + lid + " nicht finden!");
        }
        return ro;
    }

}
