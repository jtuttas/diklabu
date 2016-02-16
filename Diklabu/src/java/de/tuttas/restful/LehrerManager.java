/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Lehrer;
import de.tuttas.util.PlanType;
import de.tuttas.util.StundenplanUtil;
import java.util.List;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;

/**
 *
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
     
    @GET   
    public List<Lehrer> getAllLehrer() {
        System.out.println("Webservice Lehrer Get:");
        Query query = em.createNamedQuery("findAllTeachers");
        List<Lehrer> lehrer = query.getResultList();
        return lehrer;
    }
    
    @GET   
    @Path("/{idLehrer}")
    public Lehrer getLehrer(@PathParam("idLehrer") String idLehrer) {
        System.out.println("Webservice Lehrer Get:"+idLehrer);        
        Lehrer lehrer = em.find(Lehrer.class, idLehrer);
        lehrer.setStdPlan(StundenplanUtil.getInstance().getPlanObject(lehrer.getNNAME(), PlanType.STDPlanLehrer).getUrl());
        lehrer.setvPlan(StundenplanUtil.getInstance().getPlanObject(lehrer.getNNAME(), PlanType.VERTRPlanLehrer).getUrl());
        return lehrer;
    }
}
