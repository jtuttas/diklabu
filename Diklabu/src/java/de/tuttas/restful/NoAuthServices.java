/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Klasse;
import de.tuttas.entities.Lehrer;
import de.tuttas.entities.Lernfeld;
import de.tuttas.entities.Schueler;
import de.tuttas.restful.Data.AnwesenheitObjekt;
import java.util.ArrayList;
import java.util.List;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.ws.rs.GET;
import static javax.ws.rs.HttpMethod.PUT;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;


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
        System.out.println("Webservice Lehrer Get:");
        Query query = em.createNamedQuery("findAllTeachers");
        List<Lehrer> lehrer = query.getResultList();
        return lehrer;
    }

    @GET
    @Path("klassen")
    public List<Klasse> getClasses() {
        System.out.println("Webservice klasse GET");
        Query query = em.createNamedQuery("findAllKlassen");
        List<Klasse> klassen = query.getResultList();
        System.out.println("Result List:" + klassen);
        return klassen;
    }

    @GET
    @Path("lernfelder")
    public List<Lernfeld> getLernfeld() {
        System.out.println("Webservice Lernfeld GET:");
        Query query = em.createNamedQuery("findAllLernfelder");
        List<Lernfeld> lernfeld = query.getResultList();
        return lernfeld;
    }
}
