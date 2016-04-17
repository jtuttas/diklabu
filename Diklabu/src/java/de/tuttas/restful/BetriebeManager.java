/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Betrieb;
import de.tuttas.entities.Schueler;
import de.tuttas.entities.Schueler_Klasse;
import de.tuttas.restful.Data.ResultObject;
import de.tuttas.util.Log;
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
@Path("betriebe")
@Stateless
public class BetriebeManager {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    @GET
    @Produces({"application/json; charset=iso-8859-1"})
    public List<Betrieb> getCompanies() {
        Log.d("Webservice klasse Betriebe");

        Query query = em.createNamedQuery("findBetriebe");
        List<Betrieb> betriebe = query.getResultList();
        return betriebe;
    }

    @GET
    @Path("/{betrieb}")
    @Produces({"application/json; charset=iso-8859-1"})
    public List<Betrieb> getCompanies(@PathParam("betrieb") String b) {
        Log.d("Webservice Betrieb:" + b);

        Query query = em.createNamedQuery("findBetriebByName");
        query.setParameter("paramNameBetrieb", b);
        List<Betrieb> betriebe = query.getResultList();
        Log.d("Results=" + betriebe);
        return betriebe;
    }
    
    @DELETE
    @Path("/{idbetrieb}")
    @Produces({"application/json; charset=iso-8859-1"})
    public ResultObject deleteCompanies(@PathParam("idbetrieb") int bid) {
        Log.d("Webservice delete Betrieb:" + bid);
        ResultObject ro = new ResultObject();
        Betrieb b = em.find(Betrieb.class, bid);
        if (b!=null) {
            em.remove(b);
            ro.setMsg("Betrieb gelöscht");
            ro.setSuccess(true);
        }
        else {
            ro.setMsg("Kann Betrieb mit id="+bid+" nicht finden");
            ro.setSuccess(false);
        }
        return ro;
    }

    @POST
    @Produces({"application/json; charset=iso-8859-1"})
    public List<Betrieb> addCompany(Betrieb b) {
        Log.d("Webservice add Betrieb:" + b);
        em.getEntityManagerFactory().getCache().evictAll();
        Query query = em.createNamedQuery("findBetriebByName");
        query.setParameter("paramNameBetrieb", b.getNAME());
        List<Betrieb> betriebe = query.getResultList();
        Log.d("Results=" + betriebe);
        if (betriebe.size() == 0) {
            em.persist(b);
            query = em.createNamedQuery("findBetriebByName");
            query.setParameter("paramNameBetrieb", b.getNAME());
            betriebe = query.getResultList();
            return betriebe;
        } else {
            Betrieb be = betriebe.get(0);
            be.setNR(b.getNR());
            be.setORT(b.getORT());
            be.setPLZ(b.getPLZ());
            be.setSTRASSE(b.getSTRASSE());
            em.merge(be);
            betriebe.set(0, be);

        }
        return betriebe;
    }
}
