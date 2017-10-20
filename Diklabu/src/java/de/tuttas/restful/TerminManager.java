/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Termindaten;
import de.tuttas.entities.Termine;
import de.tuttas.util.Log;
import java.util.List;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;

/**
 *
 * @author jtutt
 */
@Path("termin")
@Stateless
public class TerminManager {
    
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    @POST
    public Termindaten setTermine(Termindaten t) {
        Log.d("Webservice Set Termin:");
        Termine te = em.find(Termine.class, t.getID_TERMIN());
        // Für die ID gibt es keinen Termin
        if (te==null) return null;
        try {
            em.persist(t);
            return t;
        }
        catch (Exception e) {
            return null;
        }
    }
    
}
