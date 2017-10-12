/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Verlauf;
import de.tuttas.util.Log;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.List;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.core.Context;

/**
 * Webservice zum Verwalten der Unterrichtsverlaufes
 * @author Jörg
 */
@Path("verlauf")
@Stateless
public class VerlaufManager {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;


    /**
     * Verlaufseintrag löschen
     * @param id ID des Verlauseintrages
     * @return gelöschtes Verlaufsobjekt oder NULL bei Fehlern
     */
    @DELETE
    @Path("/{id}")
    public Verlauf deleteVerlauf(@PathParam("id") int id) {
        Log.d("DELETE empfangen id=" + id);
        Verlauf v = em.find(Verlauf.class, id);
        if (v != null) {
            em.remove(v);
            v.setSuccess(true);
            v.setMsg("Eintrag gelöscht !");
            return v;
        }        
        return null;

    }

    /**
     * Verlauf Eintragen
     * @param v Verlaufs Objekt
     * @return Verlaufs Objekt mit vergebener ID
     */
    @POST
    public Verlauf addVerlauf(Verlauf v) {
        em.getEntityManagerFactory().getCache().evictAll();
        Log.d("POST Verlauf = " + v.toString());
        Query q = em.createNamedQuery("findVerlaufbyDatumStundeAndKlassenID");
        q.setParameter("paramDatum", v.getDATUM());
        q.setParameter("paramKlassenID", v.getID_KLASSE());
        q.setParameter("paramStunde", v.getSTUNDE());
        List<Verlauf> verlauf = q.getResultList();
        Log.d("Result List:" + verlauf);
        if (verlauf.size() != 0) {
            for (Verlauf ve : verlauf) {
                if (ve.getID_LEHRER()!=null && ve.getID_LEHRER().compareTo(v.getID_LEHRER()) == 0) {
                    Log.d("Es existier bereits ein Eintrag von " + ve.getID_LEHRER() + " also Update");
                    ve.setAUFGABE(v.getAUFGABE());
                    ve.setBEMERKUNG(v.getBEMERKUNG());
                    ve.setDATUM(ve.getDATUM());
                    ve.setID_KLASSE(v.getID_KLASSE());
                    ve.setID_LEHRER(v.getID_LEHRER());
                    ve.setID_LERNFELD(v.getID_LERNFELD());
                    ve.setINHALT(v.getINHALT());
                    ve.setSTUNDE(v.getSTUNDE());
                    em.merge(ve);
                    v.setSuccess(false);
                    v.setID(ve.getID());
                    v.setMsg("Eintrag aktualisiert!");
                    return v;
                }
            }
            v.setSuccess(false);
            v.setMsg("Es existieren bereits ein oder mehrere Einträge!");
            Log.d("Es existieren bereits ein oder mehrere Einträge! Als neuen Verlaufseintrag eintragen");
            em.persist(v);
        } else {
            Log.d("Neuen Verlaufseintrag erzeugen");
            em.persist(v);
            v.setSuccess(true);
        }
        return v;
    }

    /**
     * Unterrichtsverlauf für einer Klasse abfragen
     * @param kl Name der Klasse
     * @return Liste der Verlaufsobjekte
     */
    @GET
    @Path("/{klasse}")
    public List<Verlauf> getVerlauf(@PathParam("klasse") String kl) {

        em.getEntityManagerFactory().getCache().evictAll();
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Date d1 = new Date(cal.getTimeInMillis());
        Date d2 = new Date(cal.getTimeInMillis() + (1000 * 60 * 60 * 24));
        Log.d("Webservice Verlauf GET from Date=" + d1.toString() + " To " + d2.toString() + " klasse=" + kl);
        Query query = em.createNamedQuery("findVerlaufbyKlasse");
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", d1);
        query.setParameter("paramToDate", d2);
        List<Verlauf> verlauf = query.getResultList();
        Log.d("Result List:" + verlauf);
        return verlauf;
    }

    /**
     * Abfrage des Verlaufes für einer Klasse ab einem Datum
     * @param kl Name der Klasse
     * @param from Datum (ab)
     * @return Liste der Verlaufsobjekte
     */
    @GET
    @Path("/{klasse}/{from}")
    public List<Verlauf> getVerlauf(@PathParam("klasse") String kl, @PathParam("from") Date from) {
        em.getEntityManagerFactory().getCache().evictAll();
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Date d = new Date(from.getTime()+1000*60*60*24-1);
        Log.d("Webservice Verlauf GET klasse=" + kl + " from=" + from + " to=" + d);
        Query query = em.createNamedQuery("findVerlaufbyKlasse");
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", from);
        query.setParameter("paramToDate", d);
        List<Verlauf> verlauf = query.getResultList();
        Log.d("Result List:" + verlauf);
        return verlauf;
    }

    /**
     * Abfrage des Verlaufes einer Klasse von bis
     * @param kl Name der Klasse
     * @param from von Datum
     * @param to bis Datum
     * @return Liste der Verlaufsobjekte
     */
    @GET
    @Path("/{klasse}/{from}/{to}")
    public List<Verlauf> getVerlauf(@PathParam("klasse") String kl, @PathParam("from") Date from, @PathParam("to") Date to) {
        em.getEntityManagerFactory().getCache().evictAll();
        Log.d("Webservice Verlauf GET from=" + from + " to=" + to);
        Query query = em.createNamedQuery("findVerlaufbyKlasse");
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", from);
        query.setParameter("paramToDate", to);
        List<Verlauf> verlauf = query.getResultList();
        Log.d("Result List:" + verlauf);
        return verlauf;
    }
}
