/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.LoginSchueler;
import de.tuttas.restful.Data.SchuelerObject;
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
@Path("manager/getschueler")
@Stateless
public class SchuelerManager {
     /**
     * Injection des EntityManagers
     */
        @PersistenceContext(unitName="DiklabuPU")
    EntityManager em;
        
        
     @POST   
    @Consumes(MediaType.APPLICATION_JSON)
    public SchuelerObject getSchueler(SchuelerObject so) {
        em.getEntityManagerFactory().getCache().evictAll();
        System.out.println ("Webservice manager/getSchueler POST:"+so.toString());
        
        Query  query = em.createNamedQuery("findSchuelerbyNameKlasse");
        query.setParameter("paramName", so.getName());
        query.setParameter("paramVorname", so.getVorname());
        query.setParameter("paramKlasse", so.getKlasse());
        List<Schueler> schueler = query.getResultList();
        System.out.println("Result List:"+schueler);
        
        if (schueler.size()!=0) {
            so.setId(schueler.get(0).getId());
            so.setGebDatum(schueler.get(0).getGEBDAT());
            System.out.println("Find Schüler mit id="+schueler.get(0).getId());
            
            LoginSchueler ls=em.find(LoginSchueler.class, schueler.get(0).getId());
            System.out.println("found:"+ls);
            if (ls!=null) so.setLogin(ls.getLOGIN());
            
            
        }
        //return em.find(SchuelerLogin.class, schueler.get(0).getId());
         System.out.println("Sende zurück:"+so);
        return so;
    }
    
}
