/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.restful.Data.SchuelerObject;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Schueler;
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
@Path("courseselect/getschueler")
@Stateless
public class SchuelerLogin {
     /**
     * Injection des EntityManagers
     */
        @PersistenceContext(unitName="DiklabuPU")
    EntityManager em;
        
        
     @POST   
    @Consumes(MediaType.APPLICATION_JSON)
    public List<Schueler> getSchueler(SchuelerObject so) {
        em.getEntityManagerFactory().getCache().evictAll();
        System.out.println ("Webservice courseselect/getSchueler POST:"+so.toString());
        
        Query  query = em.createNamedQuery("findSchuelerbyNameKlasse");
        query.setParameter("paramName", so.getName());
        query.setParameter("paramVorname", so.getVorname());
        query.setParameter("paramKlasse", so.getKlasse());
        List<Schueler> schueler = query.getResultList();
        System.out.println("Result List:"+schueler);
        return schueler;   
    }
    
}
