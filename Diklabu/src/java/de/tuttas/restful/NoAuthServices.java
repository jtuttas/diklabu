/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Antworten;
import de.tuttas.entities.Antwortskalen;
import de.tuttas.entities.Fragen;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Lehrer;
import de.tuttas.entities.Lernfeld;
import de.tuttas.entities.Teilnehmer;
import de.tuttas.entities.Termindaten;
import de.tuttas.entities.Termine;
import de.tuttas.entities.Umfrage;
import de.tuttas.restful.Data.AntwortSkalaObjekt;
import de.tuttas.restful.Data.AntwortUmfrage;
import de.tuttas.restful.Data.AnwesenheitEintrag;
import de.tuttas.restful.Data.FragenObjekt;
import de.tuttas.restful.Data.KlasseShort;
import de.tuttas.restful.Data.Termin;
import de.tuttas.restful.Data.UmfrageObjekt;
import de.tuttas.util.Log;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;


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

    
      /**
         * Abfrage der Kuirsliste der Buchbaren Kurse
         * @return Die Liste mit Kursen (Klassen)
         */
     @GET  
     @Path("/getcourses")
    @Consumes(MediaType.APPLICATION_JSON)
    public List<Klasse> getCourses() {
        em.getEntityManagerFactory().getCache().evictAll();
        Log.d ("Webservice courseselect/booking GET:");
        
        Query  query = em.createNamedQuery("getSelectedKlassen");
        List<Klasse> courses = query.getResultList();
        Log.d("Result List:"+courses);
        return courses;                
    }   
      /**
     * Antworten eines Teilnehmers abfragen
     *
     * @param httpHeaders
     * @param key Key der Umfrage
     * @return
     */
    @GET
    @Path("/umfrage/antworten/{key}")
    public List<AntwortUmfrage> getAntworten(@Context HttpHeaders httpHeaders, @PathParam("key") String key) {
        Log.d("Get Antworten f. key (" + key + ")");
        /*
         String authToken = httpHeaders.getHeaderString(HTTPHeaderNames.AUTH_TOKEN);
         Authenticator aut = Authenticator.getInstance();
         String user = aut.getUser(authToken);
         Log.d("get  auth_token=" + authToken + " User=" + user);
         if (user == null || Integer.parseInt(user) != sid) {
         return null;
         }
         */
        Teilnehmer t = em.find(Teilnehmer.class, key);
        if (t == null) {
            return null;
        }

        Query q = em.createNamedQuery("getAntworten");
        q.setParameter("paramTeilnehmer", t);
        List<Antworten> anw = q.getResultList();

        List<AntwortUmfrage> au = new ArrayList<>();
        Log.d("Result=" + anw);
        for (Antworten a : anw) {
            AntwortUmfrage antU = new AntwortUmfrage();
            antU.setFrage(a.getFragenAntworten().getTITEL());
            antU.setIdFrage(a.getFragenAntworten().getID_FRAGE());
            antU.setAntwort(a.getAntwortskala().getNAME());
            antU.setIdAntwort(a.getAntwortskala().getID());
            antU.setKey(key);
            au.add(antU);
        }
        return au;
    }

    /**
     * Umfrageeintrag erzeugen
     *
     * @param httpHeaders
     * @param aw
     * @return
     */
    @POST
    @Path("umfrage")
    public AntwortUmfrage addAntwort(@Context HttpHeaders httpHeaders, AntwortUmfrage aw) {
        /*
         String authToken = httpHeaders.getHeaderString(HTTPHeaderNames.AUTH_TOKEN);
         Authenticator aut = Authenticator.getInstance();
         String user = aut.getUser(authToken);
         Log.d("get  auth_token=" + authToken + " User=" + user);
         if (user == null || Integer.parseInt(user) != aw.getIdSchueler()) {
         return null;
         }
         */

        Fragen f = em.find(Fragen.class, aw.getIdFrage());
        if (f != null) {
            Teilnehmer t = em.find(Teilnehmer.class, aw.getKey());
            if (t != null) {
                Antwortskalen as = em.find(Antwortskalen.class, aw.getIdAntwort());
                if (as != null) {
                    Umfrage u = t.getUmfrage();
                    if (u.getACTIVE()==1) { 
                        Query q = em.createNamedQuery("getAntwort");
                        q.setParameter("paramUmfrage", u);
                        q.setParameter("paramTeilnehmer", t);
                        q.setParameter("paramFrage", f);
                        List<Antworten> anw = q.getResultList();
                        if (anw.size() == 0) {
                            Antworten an = new Antworten(t, f, as);
                            em.persist(an);
                            aw.setSuccess(true);
                            aw.setMsg("Eintrag angelegt");
                        } else {
                            Antworten an = anw.get(0);
                            an.setAntwortskala(as);
                            em.merge(an);
                            aw.setSuccess(true);
                            aw.setMsg("Eintrag aktualisiert");
                        }
                    }
                    else {
                    aw.setSuccess(false);
                    aw.setMsg("Die Umfrage ist nicht mehr aktiv");                        
                    }

                } else {
                    aw.setSuccess(false);
                    aw.setMsg("Kann zur ID " + aw.getIdAntwort() + " keinen Antwort finden!");
                }

            } else {
                aw.setSuccess(false);
                aw.setMsg("Kann zum Key " + aw.getKey() + " keinen Teilnehmer finden!");
            }
        } else {
            aw.setSuccess(false);
            aw.setMsg("Kann zur ID " + aw.getIdFrage() + " keine Frage finden!");
        }
        return aw;

    }

    /**
     * Liefert eine Liste von Fragen und Antwortsmöglichkeiten für einen key
     *
     * @param id key der Umfrage
     * @return Liste von Umfrageobjekten
     */
    @GET
    @Path("umfrage/fragen/{key}")
    @Produces({"application/json; charset=iso-8859-1"})
    public UmfrageObjekt getUmfrage(@PathParam("key") String key) {
        Log.d("Antworten und Fragen der Umfrage für key=" + key);
        em.getEntityManagerFactory().getCache().evictAll();
        Teilnehmer t = em.find(Teilnehmer.class, key);
        if (t == null) { return null; }
        Map<Integer, AntwortSkalaObjekt> antworten = new HashMap();
        
        Umfrage u = t.getUmfrage();
        Log.d("Umfrage ist " + u.getNAME()+" aktive="+u.getACTIVE());
        UmfrageObjekt uo = new UmfrageObjekt(u.getNAME());
        uo.setActive(u.getACTIVE());
        Log.d("Aktive Umfrage mit Titel" + u.getNAME());
        Log.d("Die Umfrage hat FRagen n=" + u.getFragen().size());
        Collection<Fragen> fr = u.getFragen();
        for (Fragen f : fr) {
            FragenObjekt fo = new FragenObjekt(f.getTITEL());
            fo.setId(f.getID_FRAGE());
            Collection<Antwortskalen> aw = f.getAntwortskalen();
            for (Antwortskalen as : aw) {
                Log.d("size=" + fo.getIDantworten().size());
                Integer k = new Integer(as.getID());
                fo.getIDantworten().add(k);
                if (antworten.get(k) == null) {
                    Log.d("Eine neue Antwort (" + as.getNAME() + ")");
                    antworten.put(k, new AntwortSkalaObjekt(as.getNAME(), k, as.getWERT()));
                    uo.getAntworten().add(new AntwortSkalaObjekt(as.getNAME(), k, as.getWERT()));
                    Log.d("Antworten size=" + uo.getAntworten().size());
                }

            }
            uo.getFragen().add(fo);
            Log.d("size=" + uo.getFragen().size() + "Frage:" + f.getTITEL());
        }
        return uo;
    }
    
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
    
    @GET
    @Path("termine")
    public List<Termine> getTermine () {
        Log.d("Webservice Termine GET:");
        Query query = em.createNamedQuery("findAllTermine");
        List<Termine> termine = query.getResultList();
        return termine;        
    }
    
    @GET
    @Path("termine/{from}/{to}/{filter1}/{filter2}")
    public List<Termin> getTermine(@PathParam("from") Date from, @PathParam("to") Date to,@PathParam("filter1") int f1_id,@PathParam("filter2") int f2_id) {
        Log.d("Webservice Termine GET: from:"+from+" to:"+to+" filter1="+f1_id+" filter2="+f2_id);
        
        Termine t1 = em.find(Termine.class, f1_id);
        Termine t2 = em.find(Termine.class, f2_id);
        if (t1!=null) {
            Log.d("t1="+t1.getNAME());
            if (t2!=null) {
                Log.d("t2="+t2.getNAME());                
            }
        }
        else {
            if (t2!=null) {
                Log.d("t2="+t2.getNAME());                
                t1=t2;
            }
        }
        TypedQuery<Termin> query = null;
        List<Termin> termine=null;
        if (t1!=null && t2!=null) {
            query = em.createNamedQuery("findAllTermineTwoFilters",Termin.class);
            query.setParameter("filter1", t1.getId());
            query.setParameter("filter2", t2.getId());
            query.setParameter("fromDate", from);            
            query.setParameter("toDate", to);            
            termine = query.getResultList();
        }
        else if (t1!=null) {
            query = em.createNamedQuery("findAllTermineOneFilter",Termin.class);
            query.setParameter("filter1", t1.getId());
            query.setParameter("fromDate", from);            
            query.setParameter("toDate", to);            
            termine = query.getResultList();
        }
        else {
            termine = new ArrayList<>();
            to.setTime(to.getTime()+24*60*60*1000);
            while (from.before(to)) {
                termine.add(new Termin(new Timestamp(from.getTime())));
                from.setTime(from.getTime()+24*60*60*1000);
            }
        }
        return termine;
    }
}
