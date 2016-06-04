/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Antworten;
import de.tuttas.entities.Antwortskalen;
import de.tuttas.entities.Anwesenheit;
import de.tuttas.entities.Fragen;
import de.tuttas.entities.Schueler;
import de.tuttas.entities.Umfrage;
import de.tuttas.entities.Verlauf;
import de.tuttas.restful.Data.AntwortSkalaObjekt;
import de.tuttas.restful.Data.AntwortUmfrage;
import de.tuttas.restful.Data.AnwesenheitEintrag;
import de.tuttas.restful.Data.Beteiligung;
import de.tuttas.restful.Data.FragenObjekt;
import de.tuttas.restful.Data.ResultObject;
import de.tuttas.restful.Data.UmfrageObjekt;
import de.tuttas.restful.Data.UmfrageResult;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;

/**
 * GET: /umfrage/fragen/{UMFRAGE ID} .. zeigt alle Fragen und
 * Antwortsmöglichkeiten an ! POST: /umfrage/antwort/ mit AntortObjekt ..
 * (setzten einer Antwort) GET: /umfrage/antworten/{ID_KLASSE} .. alle Antworten
 * einer Klasse GET: /umfrage/antworten/regex/{regex} .. alle Antworten der
 * Klassennamen die dem Regex entsprechen
 *
 * @author Jörg
 */
@Path("umfrage")
@Stateless
public class UmfagenManager {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    /**
     * Liefert eine Liste von Fragen und Antwortsmöglichkeiten für eine Umfrage
     *
     * @param id ID der Umfrage
     * @return Liste von Umfrageobjekten
     */
    @GET
    @Path("fragen/{id}")
    @Produces({"application/json; charset=iso-8859-1"})
    public UmfrageObjekt getUmfrage(@PathParam("id") int id) {
        
        Map<Integer, AntwortSkalaObjekt> antworten = new HashMap();
        em.getEntityManagerFactory().getCache().evictAll();
        Umfrage u = em.find(Umfrage.class, id);
        UmfrageObjekt uo = new UmfrageObjekt(u.getNAME());
        System.out.println("Aktive Umfrage mit Titel" + u.getNAME());
        System.out.println("Die Umfrage hat FRagen n=" + u.getFragen().size());
        Collection<Fragen> fr = u.getFragen();
        for (Fragen f : fr) {
            FragenObjekt fo = new FragenObjekt(f.getTITEL());
            fo.setId(f.getID_FRAGE());
            Collection<Antwortskalen> aw = f.getAntwortskalen();
            for (Antwortskalen as : aw) {
                System.out.println("size=" + fo.getAntworten().size());
                Integer key = new Integer(as.getID());
                fo.getAntworten().add(key);
                if (antworten.get(key) == null) {
                    System.out.println("Eine neue Antwort (" + as.getNAME() + ")");
                    antworten.put(key, new AntwortSkalaObjekt(as.getNAME(), key, as.getWERT()));
                    uo.getAntworten().add(new AntwortSkalaObjekt(as.getNAME(), key, as.getWERT()));
                    System.out.println("Antworten size=" + uo.getAntworten().size());
                }

            }
            uo.getFragen().add(fo);
            System.out.println("size=" + uo.getFragen().size() + "Frage:" + f.getTITEL());
        }
        return uo;
    }

    @GET
    @Path("antworten/{uid}/{sid}")
    public List<AntwortUmfrage> getAntworten(@PathParam("uid") int uid, @PathParam("sid") int sid) {
        System.out.println("Get Antworten f. Umfrage " + uid + " und Schüler =" + sid);
        Query q = em.createNamedQuery("getAntworten");
        q.setParameter("paramUmfrageID", uid);
        q.setParameter("paramSchuelerID", sid);
        List<Antworten> anw = q.getResultList();
        List<AntwortUmfrage> au = new ArrayList<>();
        System.out.println("Result=" + anw);
        for (Antworten a : anw) {
            AntwortUmfrage antU = new AntwortUmfrage();
            antU.setIdUmfrage(uid);
            antU.setIdSchueler(sid);
            antU.setFrage(a.getFragenAntworten().getTITEL());
            antU.setIdFrage(a.getFragenAntworten().getID_FRAGE());
            antU.setAntwort(a.getAntwortskala().getNAME());
            antU.setIdAntwort(a.getAntwortskala().getID());
            au.add(antU);
        }
        return au;
    }

    @GET
    @Path("beteiligung/{uid}/{kname}")
    public List<Beteiligung> getBeteiligung(@PathParam("uid") int uid, @PathParam("kname") String kname) {
        System.out.println("Get Beteiligung f. Umfrage " + uid + " und Klasse =" + kname);
        em.getEntityManagerFactory().getCache().evictAll();
        Umfrage u = em.find(Umfrage.class, uid);
        if (u == null) {
            return null;
        }        
        List<Beteiligung> beteiligungen = new ArrayList<>();
        Query q = em.createQuery("SELECT a.ID_SCHUELER,COUNT(a.ID_SCHUELER) from Antworten a inner join Schueler s on a.ID_SCHUELER=s.ID inner join Schueler_Klasse sk on s.ID=sk.ID_SCHUELER inner join Klasse k on sk.ID_KLASSE=k.ID WHERE a.ID_UMFRAGE=" + uid + " AND k.KNAME like '" + kname + "' Group by a.ID_SCHUELER");
        List<Object[]> r = q.getResultList();
        for (int i = 0; i < r.size(); i++) {
            Object[] ro = r.get(i);            
            System.out.println("Der Schueler mit der ID " + ro[0] + " hat " + ro[1] + " Fragen beantwortet!");
            Integer idSchueler = (Integer) ro[0];
            Long fragen=(Long) ro[1];
            Beteiligung b = new Beteiligung(idSchueler.intValue(),fragen.intValue(),u.getFragen().size());
            beteiligungen.add(b);
        }
        return beteiligungen;
    }

    @GET
    @Path("auswertung/{uid}/{klassenname}")
    public List<UmfrageResult> getAntwortenKlasse(@PathParam("uid") int uid, @PathParam("klassenname") String kname) {
        System.out.println("Get Antworten f. Umfrage " + uid + " und Klasse =" + kname);
        em.getEntityManagerFactory().getCache().evictAll();
        List<UmfrageResult> resultList = new ArrayList<UmfrageResult>();
        Umfrage u = em.find(Umfrage.class, uid);
        if (u == null) {
            return null;
        }
        for (Fragen f : u.getFragen()) {
            UmfrageResult ur = new UmfrageResult(f.getTITEL());
            Map<Integer, AntwortSkalaObjekt> antworten = new HashMap();
            for (Antwortskalen skalen : f.getAntwortskalen()) {
                antworten.put(skalen.getID(), new AntwortSkalaObjekt(skalen.getNAME(), skalen.getID(), 0));
            }
            //Query q = em.createQuery("select aska.NAME,count(a.antwortskala) from Antworten a inner join a.antwortskala aska inner join Schueler s on a.ID_SCHUELER=s.ID inner join Schueler_Klasse sk on s.id=sk.ID_SCHUELER inner join Klasse k on k.ID=sk.IK_KLASSE Group by a.fragenAntworten");
            System.out.println("Frage=" + f);
            Query q = em.createQuery("SELECT a.antwortskala,COUNT(a.antwortskala) from Antworten a inner join a.antwortskala aska inner join Schueler s on a.ID_SCHUELER=s.ID inner join Schueler_Klasse sk on s.ID=sk.ID_SCHUELER inner join Klasse k on sk.ID_KLASSE=k.ID WHERE a.ID_UMFRAGE=" + uid + " AND k.KNAME like '" + kname + "' and a.fragenAntworten.ID_FRAGE=" + f.getID_FRAGE() + " Group by a.antwortskala");
            List<Object[]> r = q.getResultList();
            for (int i = 0; i < r.size(); i++) {
                Object[] ro = r.get(i);
                Antwortskalen a = (Antwortskalen) ro[0];
                System.out.println("Die Antwort " + ro[0] + " Wurde " + ro[1] + " mal gewählt!");
                antworten.put(a.getID(), new AntwortSkalaObjekt(a.getNAME(), a.getID().intValue(), (long) ro[1]));
            }

            Iterator it = antworten.entrySet().iterator();
            while (it.hasNext()) {
                Map.Entry pair = (Map.Entry) it.next();
                System.out.println(pair.getKey() + " = " + pair.getValue());
                it.remove(); // avoids a ConcurrentModificationException
                ur.getSkalen().add((AntwortSkalaObjekt) pair.getValue());
            }

            resultList.add(ur);
        }

        return resultList;
    }

    @POST
    public ResultObject addAntwort(AntwortUmfrage aw) {
        ResultObject ro = new ResultObject();
        Fragen f = em.find(Fragen.class, aw.getIdFrage());
        if (f != null) {
            Schueler s = em.find(Schueler.class, aw.getIdSchueler());
            if (s != null) {
                Antwortskalen as = em.find(Antwortskalen.class, aw.getIdAntwort());
                if (as != null) {
                    Umfrage u = em.find(Umfrage.class, aw.getIdUmfrage());
                    if (u != null) {
                        Query q = em.createNamedQuery("getAntwort");
                        q.setParameter("paramUmfrageID", aw.getIdUmfrage());
                        q.setParameter("paramSchuelerID", aw.getIdSchueler());
                        q.setParameter("paramFrage", f);
                        List<Antworten> anw = q.getResultList();
                        if (anw.size() == 0) {
                            Antworten an = new Antworten(aw.getIdUmfrage(), aw.getIdSchueler(), f, as);
                            em.persist(an);
                            ro.setSuccess(true);
                            ro.setMsg("Eintrag angelegt");
                        } else {
                            Antworten an = anw.get(0);
                            an.setAntwortskala(as);
                            em.merge(an);
                            ro.setSuccess(true);
                            ro.setMsg("Eintrag aktualisiert");
                        }
                    } else {
                        ro.setSuccess(false);
                        ro.setMsg("Kann zur ID " + aw.getIdUmfrage() + " keine Umfrage finden!");
                    }
                } else {
                    ro.setSuccess(false);
                    ro.setMsg("Kann zur ID " + aw.getIdAntwort() + " keinen Antwort finden!");
                }

            } else {
                ro.setSuccess(false);
                ro.setMsg("Kann zur ID " + aw.getIdSchueler() + " keinen Schüler finden!");
            }
        } else {
            ro.setSuccess(false);
            ro.setMsg("Kann zur ID " + aw.getIdFrage() + " keine Frage finden!");
        }

        return ro;
    }

}
