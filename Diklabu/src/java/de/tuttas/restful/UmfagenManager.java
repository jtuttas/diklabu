/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.config.Config;
import de.tuttas.entities.Antworten;
import de.tuttas.entities.Antwortskalen;
import de.tuttas.entities.Anwesenheit;
import de.tuttas.entities.Betrieb;
import de.tuttas.entities.Fragen;
import de.tuttas.entities.Lehrer;
import de.tuttas.entities.LoginSchueler;
import de.tuttas.entities.Schueler;
import de.tuttas.entities.Teilnehmer;
import de.tuttas.entities.Umfrage;
import de.tuttas.entities.Verlauf;
import de.tuttas.restful.Data.ActiveUmfrage;
import de.tuttas.restful.Data.AntwortSkalaObjekt;
import de.tuttas.restful.Data.AntwortUmfrage;
import de.tuttas.restful.Data.AnwesenheitEintrag;
import de.tuttas.restful.Data.Beteiligung;
import de.tuttas.restful.Data.FragenObjekt;
import de.tuttas.restful.Data.KlasseDetails;
import de.tuttas.restful.Data.ResultObject;
import de.tuttas.restful.Data.TeilnehmerObjekt;
import de.tuttas.restful.Data.UmfrageObjekt;
import de.tuttas.restful.Data.UmfrageResult;
import de.tuttas.servlets.MailObject;
import de.tuttas.servlets.MailSender;
import de.tuttas.util.Log;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ejb.Stateless;
import javax.mail.internet.AddressException;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
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
        Log.d("Antworten und Fragen der Umfrage mit id=" + id);
        Map<Integer, AntwortSkalaObjekt> antworten = new HashMap();
        em.getEntityManagerFactory().getCache().evictAll();
        Umfrage u = em.find(Umfrage.class, id);
        if (u == null) {
            return null;
        }
        Log.d("Umfrage ist " + u.getNAME());
        UmfrageObjekt uo = new UmfrageObjekt(u.getNAME());
        System.out.println("Aktive Umfrage mit Titel" + u.getNAME());
        System.out.println("Die Umfrage hat FRagen n=" + u.getFragen().size());
        Collection<Fragen> fr = u.getFragen();
        for (Fragen f : fr) {
            FragenObjekt fo = new FragenObjekt(f.getTITEL());
            fo.setId(f.getID_FRAGE());
            Collection<Antwortskalen> aw = f.getAntwortskalen();
            for (Antwortskalen as : aw) {
                System.out.println("size=" + fo.getIDantworten().size());
                Integer key = new Integer(as.getID());
                fo.getIDantworten().add(key);
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
    @Produces({"application/json; charset=iso-8859-1"})
    public List<ActiveUmfrage> getUmfragen() {
        System.out.println("Umfragen abfragen");
        Query query = em.createNamedQuery("findAllUmfragen");
        List<ActiveUmfrage> umfrage = query.getResultList();
        Log.d("Result List:" + umfrage);
        return umfrage;
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
        Query q = em.createQuery("SELECT a.teilnehmer,COUNT(a.teilnehmer) from Antworten a inner join Teilnehmer t on a.teilnehmer=t inner join Schueler s on t.SCHUELERID=s.ID inner join Schueler_Klasse sk on s.ID=sk.ID_SCHUELER inner join Klasse k on sk.ID_KLASSE=k.ID WHERE t.umfrage.ID_UMFRAGE=" + uid + " AND k.KNAME like '" + kname + "' Group by a.teilnehmer");
        List<Object[]> r = q.getResultList();
        for (int i = 0; i < r.size(); i++) {
            Object[] ro = r.get(i);
            System.out.println("Der Teilnehmer mit der ID " + ro[0] + " hat " + ro[1] + " Fragen beantwortet!");
            Teilnehmer t = (Teilnehmer) ro[0];
            Long fragen = (Long) ro[1];
            Beteiligung b = new Beteiligung(t.getKey(), fragen.intValue(), u.getFragen().size(), t.getSCHUELERID(), t.getBETRIEBID(), t.getLEHRERID());
            beteiligungen.add(b);
        }
        return beteiligungen;
    }

    @GET
    @Path("auswertung/{uid}/{klassenname}")
    @Produces({"application/json; charset=iso-8859-1"})
    public List<UmfrageResult> getAntwortenKlasse(@PathParam("uid") int uid, @PathParam("klassenname") String kname) {
        System.out.println("Get Antworten f. Umfrage " + uid + " und Klasse =" + kname);
        em.getEntityManagerFactory().getCache().evictAll();
        List<UmfrageResult> resultList = new ArrayList<UmfrageResult>();
        Umfrage u = em.find(Umfrage.class, uid);
        if (u == null) {
            return null;
        }
        for (Fragen f : u.getFragen()) {
            UmfrageResult ur = new UmfrageResult(f.getTITEL(), f.getID_FRAGE());
            Map<Integer, AntwortSkalaObjekt> antworten = new HashMap();
            for (Antwortskalen skalen : f.getAntwortskalen()) {
                antworten.put(skalen.getID(), new AntwortSkalaObjekt(skalen.getNAME(), skalen.getID(), 0));
            }
            //Query q = em.createQuery("select aska.NAME,count(a.antwortskala) from Antworten a inner join a.antwortskala aska inner join Schueler s on a.ID_SCHUELER=s.ID inner join Schueler_Klasse sk on s.id=sk.ID_SCHUELER inner join Klasse k on k.ID=sk.IK_KLASSE Group by a.fragenAntworten");
            System.out.println("Frage=" + f);
            Query q = em.createQuery("SELECT a.antwortskala,COUNT(a.antwortskala) from Antworten a inner join a.antwortskala aska inner join Teilnehmer t on a.teilnehmer = t inner join Schueler s on s.ID=t.SCHUELERID inner join Schueler_Klasse sk on t.SCHUELERID=sk.ID_SCHUELER inner join Klasse k on sk.ID_KLASSE=k.ID WHERE t.umfrage.ID_UMFRAGE=" + uid + " AND k.KNAME like '" + kname + "' and a.fragenAntworten.ID_FRAGE=" + f.getID_FRAGE() + " Group by a.antwortskala");
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
        System.out.println("resultList=" + resultList);
        return resultList;
    }

    @GET
    @Path("admin/frage/{fid}")
    @Produces({"application/json; charset=iso-8859-1"})
    public FragenObjekt getFrage(@PathParam("fid") int fid) {
        System.out.println("get Fragen:" + fid);
        Fragen f = em.find(Fragen.class, fid);
        if (f != null) {

            FragenObjekt fro = new FragenObjekt(f.getTITEL());
            fro.setId(f.getID_FRAGE());
            for (Antwortskalen skalen : f.getAntwortskalen()) {
                fro.getIDantworten().add(skalen.getID());
                fro.getStringAntworten().add(skalen.getNAME());
            }
            return fro;
        }
        return null;
    }

    @POST
    @Path("admin/frage")
    @Produces({"application/json; charset=iso-8859-1"})
    public FragenObjekt newFrage(FragenObjekt fo) {
        System.out.println("newFragenobjekt:" + fo);
        Fragen f = new Fragen(fo.getFrage());
        em.persist(f);
        em.flush();
        FragenObjekt fro = new FragenObjekt(f.getTITEL());
        fro.setId(f.getID_FRAGE());
        return fro;
    }

    @PUT
    @Path("admin/frage/{fid}")
    @Produces({"application/json; charset=iso-8859-1"})
    public FragenObjekt setFrage(FragenObjekt fo) {
        System.out.println("setFragenobjekt:" + fo);
        Fragen f = em.find(Fragen.class, fo.getId());
        if (f != null) {
            f.setTITEL(fo.getFrage());
            em.merge(f);
            em.flush();
            FragenObjekt fro = new FragenObjekt(f.getTITEL());
            fro.setId(f.getID_FRAGE());
            return fro;
        }
        return null;
    }

    @DELETE
    @Path("admin/frage/{fid}")
    @Produces({"application/json; charset=iso-8859-1"})
    public FragenObjekt setFrage(@PathParam("fid") int fid) {
        System.out.println("Detele Fragenobjekt id=:" + fid);
        FragenObjekt fro = new FragenObjekt();
        Fragen f = em.find(Fragen.class, fid);
        if (f != null) {
            em.remove(f);
            em.flush();
            fro.setFrage(f.getTITEL());
            fro.setId(f.getID_FRAGE());
            fro.setSuccess(true);
            fro.setMsg("Frage '"+f.getTITEL()+"' entfernt!");
        }
        else {
            fro.setSuccess(false);
            fro.setMsg("Kann Frage mit ID="+fid+" nicht finden!");
        }
        return fro;
    }

    @GET
    @Path("admin/antwort/{aid}")
    @Produces({"application/json; charset=iso-8859-1"})
    public AntwortSkalaObjekt getAntwort(@PathParam("aid") int aid) {
        System.out.println("get Antwort:" + aid);
        Antwortskalen a = em.find(Antwortskalen.class, aid);
        if (a != null) {
            AntwortSkalaObjekt aso = new AntwortSkalaObjekt();
            aso.setId(a.getID());
            aso.setName(a.getNAME());
            return aso;
        }
        return null;
    }

    @GET
    @Path("admin/antwort/")
    @Produces({"application/json; charset=iso-8859-1"})
    public List<AntwortSkalaObjekt> listAntwort() {

        System.out.println("list Antworten:");
        Query query = em.createNamedQuery("getAntwortenSkalen");
        List<Antwortskalen> as = query.getResultList();
        List<AntwortSkalaObjekt> asol = new ArrayList<>();
        for (int i = 0; i < as.size(); i++) {
            Antwortskalen a = as.get(i);
            AntwortSkalaObjekt aso = new AntwortSkalaObjekt();
            aso.setId(a.getID());
            aso.setName(a.getNAME());
            asol.add(aso);
        }
        return asol;

    }

    @GET
    @Path("admin/frage/")
    @Produces({"application/json; charset=iso-8859-1"})
    public List<FragenObjekt> listFrage() {

        System.out.println("list Fragen:");
        Query query = em.createNamedQuery("getFragen");
        List<Fragen> fr = query.getResultList();
        List<FragenObjekt> frol = new ArrayList<>();
        for (int i = 0; i < fr.size(); i++) {
            Fragen f = fr.get(i);
            FragenObjekt fo = new FragenObjekt();
            fo.setId(f.getID_FRAGE());
            fo.setFrage(f.getTITEL());
            for (Antwortskalen as : f.getAntwortskalen()) {
                fo.getIDantworten().add(as.getID());
                fo.getStringAntworten().add(as.getNAME());
            }
            frol.add(fo);
        }
        return frol;

    }

    @POST
    @Path("admin/antwort")
    @Produces({"application/json; charset=iso-8859-1"})
    public AntwortSkalaObjekt newAntwort(AntwortSkalaObjekt ao) {
        System.out.println("newAntwortobjekt:" + ao);
        Antwortskalen a = new Antwortskalen();
        a.setNAME(ao.getName());
        em.persist(a);
        em.flush();
        ao.setId(a.getID());
        return ao;
    }

    @PUT
    @Path("admin/antwort")
    @Produces({"application/json; charset=iso-8859-1"})
    public AntwortSkalaObjekt setAntwort(AntwortSkalaObjekt ao) {
        System.out.println("setAntwortobjekt:" + ao);
        Antwortskalen a = em.find(Antwortskalen.class, ao.getId());
        if (a != null) {
            a.setNAME(ao.getName());
            em.merge(a);
            em.flush();
            return ao;
        }
        return null;
    }

    @DELETE
    @Path("admin/antwort/{aid}")
    @Produces({"application/json; charset=iso-8859-1"})
    public AntwortSkalaObjekt setAntwort(@PathParam("aid") int aid) {
        System.out.println("Detele Antwortobjekt id=:" + aid);
        Antwortskalen a = em.find(Antwortskalen.class, aid);
        if (a != null) {
            em.remove(a);
            em.flush();
            AntwortSkalaObjekt aso = new AntwortSkalaObjekt();
            aso.setId(a.getID());
            aso.setName(a.getNAME());
            return aso;
        }
        return null;
    }

    @POST
    @Path("admin/add/{fid}/{aid}")
    @Produces({"application/json; charset=iso-8859-1"})
    public ResultObject addAntwort(@PathParam("fid") int fid, @PathParam("aid") int aid) {
        System.out.println("addAntwort: ID=" + aid + " to Frage ID=" + fid);
        ResultObject ro = new ResultObject();
        Fragen f = em.find(Fragen.class, fid);
        if (f != null) {
            Antwortskalen as = em.find(Antwortskalen.class, aid);
            if (as != null) {
                if (f.getAntwortskalen().contains(as)) {
                    ro.setSuccess(false);
                    ro.setMsg("Die Frage (" + f.getTITEL() + ") enthält bereits die Antwort (" + as.getNAME() + ") !");
                } else {
                    f.getAntwortskalen().add(as);
                    em.merge(f);
                    ro.setSuccess(true);
                    ro.setMsg("Habe der Frage (" + f.getTITEL() + ") die Antwort (" + as.getNAME() + ") hinzugefügt!");
                }
            } else {
                ro.setMsg("Kann Antwort mit ID=" + aid + " nicht finden!");
                ro.setSuccess(false);
            }
        } else {
            ro.setSuccess(false);
            ro.setMsg("Kann Frage mit ID=" + fid + " nicht finden!");
        }
        return ro;
    }

    @POST
    @Path("admin/remove/{fid}/{aid}")
    @Produces({"application/json; charset=iso-8859-1"})
    public ResultObject removeAntwort(@PathParam("fid") int fid, @PathParam("aid") int aid) {
        System.out.println("removeAntwort: ID=" + aid + " from Frage ID=" + fid);
        ResultObject ro = new ResultObject();
        Fragen f = em.find(Fragen.class, fid);
        if (f != null) {
            Antwortskalen as = em.find(Antwortskalen.class, aid);
            if (as != null) {
                if (f.getAntwortskalen().contains(as)) {
                    f.getAntwortskalen().remove(as);
                    em.merge(f);
                    ro.setSuccess(true);
                    ro.setMsg("Habe die Antwort (" + as.getNAME() + ") aus der Frage (" + f.getTITEL() + ") entfernt!");
                } else {
                    ro.setSuccess(false);
                    ro.setMsg("Die Antwort (" + as.getNAME() + ") ist nicht in der Frage (" + f.getTITEL() + ") enthalten!");
                }
            } else {
                ro.setMsg("Kann Antwort mit ID=" + aid + " nicht finden!");
                ro.setSuccess(false);
            }

        } else {
            ro.setSuccess(false);
            ro.setMsg("Kann Frage mit ID=" + fid + " nicht finden!");
        }
        return ro;
    }

    @POST
    @Path("admin/")
    @Produces({"application/json; charset=iso-8859-1"})
    public UmfrageObjekt newUmfrage(UmfrageObjekt uo) {
        System.out.println("newUmfrage:" + uo);
        Umfrage u = new Umfrage(uo.getTitel());
        em.persist(u);
        em.flush();
        uo.setId(u.getID_UMFRAGE());
        return uo;
    }

    @PUT
    @Path("admin/")
    @Produces({"application/json; charset=iso-8859-1"})
    public UmfrageObjekt setUmfrage(UmfrageObjekt uo) {
        System.out.println("setUmfragenobjekt:" + uo);
        Umfrage u = em.find(Umfrage.class, uo.getId());
        if (u != null) {
            if (uo.getTitel() != null) {
                u.setNAME(uo.getTitel());
            }
            if (uo.getActive() != null) {
                u.setACTIVE(uo.getActive());
            }
            em.merge(u);
            em.flush();
            uo.setId(u.getID_UMFRAGE());
            uo.setActive(u.getACTIVE());
            uo.setTitel(u.getNAME());
            uo.setFragen(null);
            uo.setAntworten(null);

            return uo;
        }
        return null;
    }

    @DELETE
    @Path("admin/{uid}/{force}")
    @Produces({"application/json; charset=iso-8859-1"})
    public UmfrageObjekt deleteUmfrage(@PathParam("uid") int uid,@PathParam("force") boolean force) {
        System.out.println("Detele Umfrage id=:" + uid);
        Umfrage u = em.find(Umfrage.class, uid);
        UmfrageObjekt uo = new UmfrageObjekt();
        if (u != null) {
            if (!force && u.getTeilnehmer().size()>0) {
                uo.setId(u.getID_UMFRAGE());
                uo.setTitel(u.getNAME());
                uo.setSuccess(false);
                uo.setMsg("Die Umfrage "+u.getNAME()+" hat noch Teilnehmer (evtl. force verwenden)!");
            }
            else {
                em.remove(u);
                em.flush();
                uo.setId(u.getID_UMFRAGE());
                uo.setTitel(u.getNAME());
                uo.setSuccess(true);
                uo.setMsg("Umfrage "+u.getNAME()+" gelöscht!");
            }
        }
        else {
            uo.setSuccess(false);
            uo.setMsg("Kann Umfrage mit ID="+uid+" nicht finden!");
        }
        return uo;
    } 

    @POST
    @Path("admin/addUmfrage/{fid}/{uid}")
    @Produces({"application/json; charset=iso-8859-1"})
    public ResultObject addUmfrage(@PathParam("fid") int fid, @PathParam("uid") int uid) {
        System.out.println("addFrage: ID=" + fid + " to Umfrage ID=" + uid);
        ResultObject ro = new ResultObject();
        Fragen f = em.find(Fragen.class, fid);
        if (f != null) {
            Umfrage u = em.find(Umfrage.class, uid);
            if (u != null) {
                if (u.getFragen().contains(f)) {
                    ro.setSuccess(false);
                    ro.setMsg("Die Frage (" + f.getTITEL() + ") ist bereits in der Umfrage (" + u.getNAME() + ") enthalten!");
                } else {
                    u.getFragen().add(f);
                    em.merge(f);
                    ro.setSuccess(true);
                    ro.setMsg("Habe der Frage (" + f.getTITEL() + ") zur Umgfage (" + u.getNAME() + ") hinzugefügt!");
                }
            } else {
                ro.setMsg("Kann Umfrage mit ID=" + uid + " nicht finden!");
                ro.setSuccess(false);
            }
        } else {
            ro.setSuccess(false);
            ro.setMsg("Kann Frage mit ID=" + fid + " nicht finden!");
        }
        return ro;
    }

    @POST
    @Path("admin/removeUmfrage/{fid}/{uid}")
    @Produces({"application/json; charset=iso-8859-1"})
    public ResultObject removeUmfrage(@PathParam("fid") int fid, @PathParam("uid") int uid) {
        System.out.println("removeFrage: ID=" + fid + " from Umfrage ID=" + uid);
        ResultObject ro = new ResultObject();
        Fragen f = em.find(Fragen.class, fid);
        if (f != null) {
            Umfrage u = em.find(Umfrage.class, uid);
            if (u != null) {
                if (u.getFragen().contains(f)) {
                    u.getFragen().remove(f);
                    em.merge(f);
                    ro.setSuccess(true);
                    ro.setMsg("Habe die Frage (" + f.getTITEL() + ") aus der Umfrage (" + u.getNAME() + ") entfernt!");
                } else {
                    ro.setSuccess(false);
                    ro.setMsg("Die Frage (" + f.getTITEL() + ") ist nicht in der Umfrage (" + u.getNAME() + ") enthalten!");
                }
            } else {
                ro.setMsg("Kann Umfrage mit ID=" + uid + " nicht finden!");
                ro.setSuccess(false);
            }

        } else {
            ro.setSuccess(false);
            ro.setMsg("Kann Frage mit ID=" + fid + " nicht finden!");
        }
        return ro;
    }

    @POST
    @Path("admin/subscriber")
    @Produces({"application/json; charset=iso-8859-1"})
    public TeilnehmerObjekt newTeilnehmer(TeilnehmerObjekt to) {
        System.out.println("new Teilnehmerobjekt:" + to);

        Umfrage u = em.find(Umfrage.class, to.getIdUmfrage());
        if (u == null) {
            to.setSuccess(false);
            to.setMsg("Kann Umfrage mit id " + to.getIdUmfrage() + " nicht finden!");
            return null;
        }
        if (to.getIdBetrieb() == null && to.getIdLehrer() == null && to.getIdSchueler() == null) {
            to.setSuccess(false);
            to.setMsg("Keine ID (Betrien,Schüler,Lehrer) angegeben!");
            return null;
        }
        Teilnehmer te = null;
        String key = null;
        do {
            key = UUID.randomUUID().toString();
            te = em.find(Teilnehmer.class, key);
        } while (te != null);
        Teilnehmer t = new Teilnehmer();
        t.setUmfrage(u);
        t.setINVITED(0);
        t.setKey(key);
        if (to.getIdBetrieb() != null) {
            t.setBETRIEBID(to.getIdBetrieb().intValue());
            Betrieb b = em.find(Betrieb.class, to.getIdBetrieb().intValue());
            if (b == null) {
                to.setSuccess(false);
                to.setMsg("Kann Betrieb mit ID=" + to.getIdBetrieb().intValue() + " nicht finden");
                return to;
            }
            Query query = em.createNamedQuery("findBetriebTeilnehmer");
            query.setParameter("paramBetriebId", to.getIdBetrieb().intValue());
            query.setParameter("paramUmfrage", u);
            List<Teilnehmer> betriebe = query.getResultList();
            if (betriebe.size() > 0) {
                to.setSuccess(false);
                to.setMsg("Betrieb mit ID=" + to.getIdSchueler().intValue() + " nimmt bereits an der Umfrage " + u.getNAME() + " teil!");
                to.setKey(betriebe.get(0).getKey());
                return to;
            }
            to.setMsg("Betrieb " + b.getNAME() + " zur Umfrage " + u.getNAME() + " hinzugefügt");
        }
        if (to.getIdSchueler() != null) {
            t.setSCHUELERID(to.getIdSchueler().intValue());
            Schueler s = em.find(Schueler.class, to.getIdSchueler().intValue());
            if (s == null) {
                to.setSuccess(false);
                to.setMsg("Kann Schüler mit ID=" + to.getIdSchueler().intValue() + " nicht finden");
                return to;
            }
            Query query = em.createNamedQuery("findSchuelerTeilnehmer");
            query.setParameter("paramSchuelerId", to.getIdSchueler().intValue());
            query.setParameter("paramUmfrage", u);
            List<Teilnehmer> teilnehmer = query.getResultList();
            if (teilnehmer.size() > 0) {
                to.setSuccess(false);
                to.setMsg("Schüler mit ID=" + to.getIdSchueler().intValue() + " nimmt bereits an der Umfrage " + u.getNAME() + " teil!");
                to.setKey(teilnehmer.get(0).getKey());
                return to;
            }
            to.setMsg("Schueler " + s.getVNAME() + " " + s.getNNAME() + " zur Umfrage " + u.getNAME() + " hinzugefügt");
        }
        if (to.getIdLehrer() != null) {
            t.setLEHRERID(to.getIdLehrer());
            Lehrer l = em.find(Lehrer.class, to.getIdLehrer());
            if (l == null) {
                to.setSuccess(false);
                to.setMsg("Kann Lehrer mit ID=" + to.getIdLehrer() + " nicht finden");
                return to;
            }
            Query query = em.createNamedQuery("findLehrerTeilnehmer");
            query.setParameter("paramLehrerId", to.getIdLehrer());
            query.setParameter("paramUmfrage", u);
            List<Teilnehmer> lehrer = query.getResultList();
            if (lehrer.size() > 0) {
                to.setSuccess(false);
                to.setMsg("Lehrer mit ID=" + to.getIdSchueler().intValue() + " nimmt bereits an der Umfrage " + u.getNAME() + " teil!");
                to.setKey(lehrer.get(0).getKey());
                return to;
            }
            to.setMsg("Lehrer " + to.getIdLehrer() + " zur Umfrage " + u.getNAME() + " hinzugefügt");
        }
        em.persist(t);
        em.flush();
        to.setSuccess(true);
        to.setKey(key);
        return to;

    }

    @GET
    @Path("admin/subscriber/{uid}")
    @Produces({"application/json; charset=iso-8859-1"})
    public List<TeilnehmerObjekt> getTeilnehmer(@PathParam("uid") int uid) {
        Umfrage u = em.find(Umfrage.class, uid);
        if (u == null) {
            return null;
        }
        Query query = em.createNamedQuery("findTeilnehmer");
        query.setParameter("paramUmfrage", u);
        List<Teilnehmer> teilnehmer = query.getResultList();
        List<TeilnehmerObjekt> lto = new ArrayList<>();
        for (Teilnehmer t : teilnehmer) {
            TeilnehmerObjekt to = new TeilnehmerObjekt();
            to.setIdBetrieb(t.getBETRIEBID());
            to.setIdLehrer(t.getLEHRERID());
            to.setIdSchueler(t.getSCHUELERID());
            to.setIdUmfrage(uid);
            to.setKey(t.getKey());
            to.setInvited(t.getINVITED());
            lto.add(to);
        }
        return lto;
    }

    @DELETE
    @Path("admin/subscriber/{key}/{force}")
    @Produces({"application/json; charset=iso-8859-1"})
    public TeilnehmerObjekt deleteTeilnehmer(@PathParam("key") String key,@PathParam("force") boolean force) {
        System.out.println("Lösche Teilnehmer force="+force);
        Teilnehmer t = em.find(Teilnehmer.class, key);
        TeilnehmerObjekt to = new TeilnehmerObjekt();
        if (t == null) {
            to.setMsg("Kann Teilnehmer mit KEY "+key+" nicht finden!");
            to.setSuccess(false);
            to.setKey(key);
            return to;
            
        }
        if (!force && t.getAntworten().size()!=0) {
            to.setMsg("Der Teilnehmer hat bereits Antworten eingereicht (force setzen um zu löschen)");
            to.setSuccess(false);
            to.setKey(key);
            to.setIdUmfrage(t.getUmfrage().getID_UMFRAGE());
            return to;
        }
        em.remove(t);
        to.setIdBetrieb(t.getBETRIEBID());
        to.setIdLehrer(t.getLEHRERID());
        to.setIdSchueler(t.getSCHUELERID());
        to.setIdUmfrage(t.getUmfrage().getID_UMFRAGE());
        to.setKey(t.getKey());
        to.setInvited(t.getINVITED());
        to.setMsg("Teilnehmer aus Umfrage entfernt!");
        to.setSuccess(true);
        return to;
    }

    @GET
    @Path("admin/invite/{key}")
    @Produces({"application/json; charset=iso-8859-1"})
    public List<ResultObject> inviteTeilnehmer(@PathParam("key") String key) {
        ArrayList<ResultObject> rol = new ArrayList<>();
        ResultObject ro = new ResultObject();

        Teilnehmer t = em.find(Teilnehmer.class, key);
        if (t == null) {
            ro.setSuccess(false);
            ro.setMsg("Kann Teilmnehmer mit Key=" + key + " nicht finden");
            rol.add(ro);
            return rol;
        }
        if (t.getINVITED()==1) {
            ro.setSuccess(false);
            ro.setMsg("Der Teilnehmer mit Key=" + key + " wurde bereits eingeladen");
            rol.add(ro);
            return rol;
        }
        Umfrage u = t.getUmfrage();
        if (u.getACTIVE() != 1) {
            ro.setSuccess(false);
            ro.setMsg("Umfrage " + u.getNAME() + " ist nicht aktiv");
            rol.add(ro);
            return rol;
        }
        String pathTemplate = Config.class.getProtectionDomain().getCodeSource().getLocation().getPath();
        pathTemplate = pathTemplate.substring(0, pathTemplate.indexOf("Config.class"));
        pathTemplate = pathTemplate + File.separator + "templateSchuelerumfrage.txt";
        Log.d("Path=" + pathTemplate);
        BufferedReader br;
        StringBuilder sb = new StringBuilder();
        try {
            br = new BufferedReader(new FileReader(pathTemplate));

            String line = br.readLine();
            while (line != null) {
                sb.append(line);
                sb.append(System.lineSeparator());
                line = br.readLine();
            }
            Log.d("Habe gelesen:" + sb);
        } catch (FileNotFoundException ex) {
            Logger.getLogger(UmfagenManager.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(UmfagenManager.class.getName()).log(Level.SEVERE, null, ex);
        }
        MailSender mailSender = new MailSender();
        if (t.getSCHUELERID() != null) {
            ro = new ResultObject();
            Schueler s = em.find(Schueler.class, t.getSCHUELERID());
            if (s != null) {
                LoginSchueler lo = em.find(LoginSchueler.class, s.getId());
                if (lo != null) {
                    String sbn = new String(sb.toString());
                    sbn = sbn.replace("[[VNAME]]", s.getVNAME());
                    sbn = sbn.replace("[[NNAME]]", s.getNNAME());
                    sbn = sbn.replace("[[TITEL]]", u.getNAME());
                    sbn = sbn.replace("[[LINK]]", Config.getInstance().clientConfig.get("SERVER") + "/Diklabu/dev/umfrage.html?ID=" + t.getKey());
                    System.out.println("Nachricht = " + sbn);
                    MailObject mo = new MailObject("tuttas@mmbbs.de", "Einladung zur Umfrage " + u.getNAME(), sbn);
                    try {
                        mo.addRecipient(lo.getLOGIN() + "@mmbbs.eduplaza.de");
                        mailSender.sendMail(mo);
                        ro.setSuccess(true);
                        ro.setMsg("Habe " + s.getVNAME() + " " + s.getNNAME() + " (" + lo.getLOGIN() + "@mmbbs.eduplaza.de) Zur Umfrage '" + u.getNAME() + "' eingeladen!");
                        t.setINVITED(1);
                        em.persist(t);
                        em.flush();
                    } catch (AddressException ex) {
                        ro.setSuccess(false);
                        ro.setMsg(ex.getMessage());
                        Logger.getLogger(UmfagenManager.class.getName()).log(Level.SEVERE, null, ex);
                    }

                } else {
                    ro.setSuccess(false);
                    ro.setMsg("Keine Mail Adresse für  " + s.getVNAME() + " " + s.getNNAME() + " gefunden!");
                }
            } else {
                ro.setSuccess(false);
                ro.setMsg("Kann Schüler mit ID=" + t.getSCHUELERID() + " nicht finden!");
            }
            rol.add(ro);
        }
        return rol;

    }
}
