/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Klasse;
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
import javax.ws.rs.PathParam;
import javax.ws.rs.core.MediaType;

/**
 *
 * @author Jörg
 */
@Path("schueler")
@Stateless
public class SchuelerManager {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    @GET   
    @Path("/{idschueler}")
    public SchuelerObject getPupil(@PathParam("idschueler") int idschueler) {
        System.out.println("Abfrage Schueler mit der ID "+idschueler);
        SchuelerObject so = new SchuelerObject();
        Schueler s = em.find(Schueler.class, idschueler);
        if (s!=null) {
            so.setId(idschueler);
            so.setGebDatum(s.getGEBDAT());
            so.setName(s.getNNAME());
            so.setVorname(s.getVNAME());
            Query query = em.createNamedQuery("findKlassenbySchuelerID");
                    query.setParameter("paramIDSchueler", so.getId());
                    List<Klasse> klassen = query.getResultList();
                    System.out.println("Result List:" + klassen);
                    so.setKlassen(klassen);
        }
        
        return so;
    }

}
