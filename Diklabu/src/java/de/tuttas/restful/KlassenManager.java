/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Klasse;
import de.tuttas.entities.Schueler;
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
@Path("klasse")
@Stateless
public class KlassenManager {
    
    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName="DiklabuPU")
    EntityManager em;
        
    @GET   
    @Path("/{klasse}")
    public List<Schueler> getPupil(@PathParam("klasse") String kl) {
        System.out.println ("Webservice klasse GET: klasse="+kl);
        
        Query  query = em.createNamedQuery("findSchuelerEinerBenanntenKlasse");
        query.setParameter("paramNameKlasse", kl);
        List<Schueler> schueler = query.getResultList();
        System.out.println("Result List:"+schueler);
        return schueler;  
    }

   

}
