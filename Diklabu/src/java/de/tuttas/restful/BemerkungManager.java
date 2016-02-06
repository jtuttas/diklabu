/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.BemerkungId;
import de.tuttas.entities.Bemerkung;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Lehrer;
import de.tuttas.entities.Schueler;
import de.tuttas.entities.Verlauf;
import de.tuttas.restful.Data.SchuelerObject;
import java.sql.Date;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.GregorianCalendar;
import java.util.List;
import javax.ejb.EJBTransactionRolledbackException;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.IdClass;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.swing.text.AbstractDocument;
import javax.validation.ConstraintViolationException;
import javax.ws.rs.DELETE;
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
    @Path("/{id}")
    public List<Bemerkung> getBemerkung(@PathParam("id") int id) {
        em.getEntityManagerFactory().getCache().evictAll();
        Query query = em.createNamedQuery("findBemerkungbySchuelerId");
        query.setParameter("paramSchuelerId", id);
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
    @Path("/{time}")
    public Bemerkung setBemerkung(@PathParam("time") String time, Bemerkung b) {
        em.getEntityManagerFactory().getCache().evictAll();
        System.out.println("time=" + time);
        time=time.replace("T", " ");
        java.util.Date date;
        try {
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yy-MM-dd hh:mm:ss");
            date = simpleDateFormat.parse(time);
            System.out.println("Date parsed =" + date.toString());
            b.setDATUM(new Timestamp(date.getTime()));
            System.out.println("Setze Bemerkung" + b);
            Lehrer l = em.find(Lehrer.class, b.getID_LEHRER());
            Schueler s = em.find(Schueler.class, b.getID_SCHUELER());
            BemerkungId bemId = new BemerkungId(b.getID_SCHUELER(), b.getID_LEHRER(), b.getDATUM());

            Bemerkung be = em.find(Bemerkung.class, bemId);
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
                System.out.println("Neue Bemerkung eingetragen");
                em.persist(b);
                b.setSuccess(true);
                b.setMsg("Neue Bemerkung eingetragen");
            } else {
                System.out.println("Bemerkung aktualisiert");
                be.setBEMERKUNG(b.getBEMERKUNG());
                be.setDATUM(b.getDATUM());
                b.setMsg("Bemerkung aktualisiert");
                em.merge(be);
                b.setSuccess(true);
            }
            return b;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    @DELETE
    @Path("/{ID_LEHRER}/{ID_SCHUELER}/{time}")
    public Bemerkung deleteVerlauf(@PathParam("ID_LEHRER") String idl, @PathParam("ID_SCHUELER") int ids, @PathParam("time") String time) {
        System.out.println("Time = " + time);

        java.util.Date date;
        try {
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yy-MM-dd hh:mm:ss");

            date = simpleDateFormat.parse(time);
            System.out.println("Date parsed =" + date.toString());
            System.out.println("DELETE empfangen id_Schueler=" + ids + " ID_LEHRER=" + idl + "Time=" + date);
            BemerkungId bemId = new BemerkungId(ids, idl, new Timestamp(date.getTime()));
            Bemerkung be = em.find(Bemerkung.class, bemId);

            if (be != null) {
                em.remove(be);
                be.setSuccess(true);
                be.setMsg("Eintrag gelöscht !");
            } else {
                be = new Bemerkung(ids, idl);
                be.setSuccess(false);
                be.setMsg("Eintrag kann nicht gelöscht werden");
            }
            return be;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
