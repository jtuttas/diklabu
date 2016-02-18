/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Anwesenheit;
import de.tuttas.entities.Bemerkung;
import de.tuttas.entities.BemerkungId;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Schueler;
import de.tuttas.restful.Data.AnwesenheitEintrag;

import de.tuttas.restful.Data.AnwesenheitObjekt;
import de.tuttas.util.VerspaetungsUtil;
import java.sql.Date;
import java.sql.Timestamp;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;

import java.util.GregorianCalendar;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;

/**
 *
 * @author Jörg
 */
@Path("anwesenheit")
@Stateless
public class AnwesenheitsManager {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    @GET
    public AnwesenheitEintrag getAnwesenheit() {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Timestamp d1 = new Timestamp(cal.getTimeInMillis());
        AnwesenheitEintrag ae = new AnwesenheitEintrag(d1, "TU", 0, "a");
        return ae;
    }

    @POST
    public AnwesenheitEintrag setAnwesenheit(AnwesenheitEintrag ae) {
        System.out.println("POST Anwesenheitseintrag = " + ae.toString());
        Anwesenheit a = new Anwesenheit(ae.getID_SCHUELER(), ae.getDATUM(), ae.getID_LEHRER(), ae.getVERMERK());
        Query q = em.createNamedQuery("findAnwesenheitbyDatumAndSchuelerID");
        q.setParameter("paramDatum", ae.getDATUM());
        q.setParameter("paramSchuelerID", ae.getID_SCHUELER());
        List<Anwesenheit> anw = q.getResultList();
        if (anw.size() != 0) {
            System.out.println("Es gibt schon einen Eintrag, also updaten");
            em.merge(a);
        } else {
            System.out.println("Ein neuer Eintrag");
            em.persist(a);
        }
        if (ae.getBEMERKUNG()!=null) {
            System.out.println("Es gibt eine Bemerkung");
            BemerkungId bemId = new BemerkungId(ae.getDATUM(),ae.getID_SCHUELER());
            
            Bemerkung fb=em.find(Bemerkung.class, bemId);
            if (fb==null) {
                System.out.println("eine neue Bemerkung");
                Bemerkung b = new Bemerkung(ae.getDATUM(), ae.getID_SCHUELER());
                b.setID_LEHRER(ae.getID_LEHRER());
                b.setBEMERKUNG(ae.getBEMERKUNG());
                em.persist(b);
            }
            else {
                System.out.println("eine alte Bemerkung also update");
                fb.setID_LEHRER(ae.getID_LEHRER());
                fb.setBEMERKUNG(ae.getBEMERKUNG());
                em.merge(fb);
            }
        }
        else {
            System.out.println("Es gibt KEINE Bemerkung,schauen ob es eine alte Bemerkung gibt");
            BemerkungId bemId = new BemerkungId(ae.getDATUM(),ae.getID_SCHUELER());
            Bemerkung fb=em.find(Bemerkung.class, bemId);
            if (fb!=null) {
                System.out.println("ja es gab eine alte Bemerkung, diese löschen!");
                em.remove(fb);
            }
        }
        ae.setParseError(!VerspaetungsUtil.isValid(ae));
        return ae;
    }

    @GET
    @Path("/{klasse}")
    public List<AnwesenheitObjekt> getAnwesenheit(@PathParam("klasse") String kl) {
        em.getEntityManagerFactory().getCache().evictAll();

        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Date d1 = new Date(cal.getTimeInMillis());
        Date d2 = new Date(cal.getTimeInMillis() + (1000 * 60 * 60 * 24));

        System.out.println("Webservice Anwesenheit GET from Date=" + d1.toString() + " To " + d2.toString() + " klasse=" + kl);
        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbyKlasse", AnwesenheitEintrag.class);
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", d1);
        query.setParameter("paramToDate", d2);
         List<AnwesenheitEintrag> anwesenheit = query.getResultList();
        
        Query qb = em.createNamedQuery("findBemerkungbyDate");
        qb.setParameter("paramFromDate", d1);
        qb.setParameter("paramToDate", d2);
        
        List<String> ids = new ArrayList<>();
        for (AnwesenheitEintrag ae:anwesenheit) {
            ids.add(""+ae.getID_SCHUELER());
        }
        List<Bemerkung> bemerkungen=null;
        qb.setParameter("idList", ids);
        if (ids.size()>0) {
            bemerkungen = qb.getResultList();
            System.out.println("Result List Bemerkunken:" + bemerkungen);               
        }
        return getData(anwesenheit,bemerkungen);
    }

    @GET
    @Path("/{klasse}/{from}")
    public List<AnwesenheitObjekt> getAnwesenheitFrom(@PathParam("klasse") String kl, @PathParam("from") Date from) {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Date d = new Date(cal.getTimeInMillis());
        System.out.println("Webservice Anwesenheit GET klasse=" + kl + " from=" + from + " to=" + d);
        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbyKlasse", AnwesenheitEintrag.class);
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", from);
        query.setParameter("paramToDate", d);
        List<AnwesenheitEintrag> anwesenheit = query.getResultList();
        return getData(anwesenheit,null);
    }

    @GET
    @Path("/{klasse}/{from}/{to}")
    public List<AnwesenheitObjekt> getAnwesenheitFrom(@PathParam("klasse") String kl, @PathParam("from") Date from, @PathParam("to") Date to) {

        System.out.println("Webservice Anwesenheit GET from=" + from + " to=" + to);
        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbyKlasse", AnwesenheitEintrag.class);
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", from);
        query.setParameter("paramToDate", to);
        List<AnwesenheitEintrag> anwesenheit = query.getResultList();
        return getData(anwesenheit,null);
    }

    private List<AnwesenheitObjekt> getData(List<AnwesenheitEintrag> anwesenheit,List<Bemerkung> bemerkungen) {
         
        //System.out.println("Results:="+anwesenheit);
        List<AnwesenheitObjekt> anw = new ArrayList();
        int id = 0;
        AnwesenheitObjekt ao = new AnwesenheitObjekt();
        for (int i = 0; i < anwesenheit.size(); i++) {
            if (anwesenheit.get(i).getID_SCHUELER() != id) {
                id = anwesenheit.get(i).getID_SCHUELER();
                ao = new AnwesenheitObjekt(id);
                anw.add(ao);
            }
            anwesenheit.get(i).setParseError(!VerspaetungsUtil.isValid(anwesenheit.get(i)));
            ao.getEintraege().add(anwesenheit.get(i));
        }
        
        for (AnwesenheitObjekt ano:anw) {
            ano=VerspaetungsUtil.parse(ano);
        }
        
        if (bemerkungen != null) {
            for (AnwesenheitObjekt anwo:anw) {
                List<AnwesenheitEintrag> eintr = anwo.getEintraege();
                for (AnwesenheitEintrag anwe:eintr) {
                    int ids = anwe.getID_SCHUELER();
                    Timestamp ts = anwe.getDATUM();
                    for (Bemerkung bem:bemerkungen) {
                        if (bem.getID_SCHUELER()==ids && bem.getDATUM().equals(ts)) {
                            System.out.println("Habe eine Bemerkung zum Anwesenheitseintrag gefunden");
                            anwe.setBEMERKUNG(bem.getBEMERKUNG());
                        }
                    }
                }
            }
        }
        return anw;
    }

}
