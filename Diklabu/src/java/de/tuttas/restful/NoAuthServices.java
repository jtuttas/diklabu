/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Lehrer;
import de.tuttas.entities.Lernfeld;
import de.tuttas.restful.Data.KlasseShort;
import de.tuttas.util.Log;
import java.util.List;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.ws.rs.GET;
import javax.ws.rs.Path;


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
}
