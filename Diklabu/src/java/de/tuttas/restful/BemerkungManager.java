/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Bemerkung;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Lehrer;
import de.tuttas.entities.Schueler;
import de.tuttas.restful.Data.SchuelerObject;
import java.util.List;
import javax.ejb.EJBTransactionRolledbackException;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.swing.text.AbstractDocument;
import javax.validation.ConstraintViolationException;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;

/**
 *
 * @author Jörg
 */
@Path("bemerkungen")
@Stateless
public class BemerkungManager {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    @GET
    @Path("/{klasse}")
    public List<Bemerkung> getBemerkung(@PathParam("klasse") String kl) {
        em.getEntityManagerFactory().getCache().evictAll();
        Query query = em.createNamedQuery("findBemerkungbyKlasse");
        query.setParameter("paramKName", kl);
        List<Bemerkung> bemerkungen = query.getResultList();
        System.out.println("Result List:" + bemerkungen);
        return bemerkungen;
    }

    @GET
    public Bemerkung getBemerkung() {
        Bemerkung bemerkung = new Bemerkung(1500, "TU", "eine Bemerkung");
        return bemerkung;
    }

    @POST
    public Bemerkung setBemerkung(Bemerkung b) {
        System.out.println("Setze Bemerkung" + b);

        Lehrer l = em.find(Lehrer.class, b.getID_LEHRER());
        Schueler s = em.find(Schueler.class, b.getID_SCHUELER());
        Bemerkung be = em.find(Bemerkung.class, b.getID_SCHUELER());
        if (l == null) {
            b.setSuccess(false);
            b.setMsg("Lehrer mit id=" + b.getID_LEHRER() + " unbekannt");
            return b;
        }
        if (s == null) {
            b.setSuccess(false);
            b.setMsg("Schueler mit id=" + b.getID_SCHUELER() + " unbekannt");
            return b;
        }
        if (be == null) {
            em.persist(b);
            b.setSuccess(true);
            b.setMsg("Bemerkung eingetragen");
        } else {
            em.merge(b);
            b.setSuccess(true);
            b.setMsg("Bemerkung von " + be.getID_LEHRER() + " überschrieben");
        }

        return b;
    }

}
