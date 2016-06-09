/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.config.Config;
import de.tuttas.entities.Antworten;
import de.tuttas.entities.Antwortskalen;
import de.tuttas.entities.Ausbilder;
import de.tuttas.entities.Bemerkung;
import de.tuttas.entities.Betrieb;
import de.tuttas.entities.Fragen;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Schueler;
import de.tuttas.entities.Teilnehmer;
import de.tuttas.entities.Umfrage;
import de.tuttas.restful.Data.ActiveUmfrage;
import de.tuttas.restful.Data.AntwortSkalaObjekt;
import de.tuttas.restful.Data.AntwortUmfrage;
import de.tuttas.restful.Data.AnwesenheitEintrag;
import de.tuttas.restful.Data.AnwesenheitObjekt;
import de.tuttas.restful.Data.BildObject;
import de.tuttas.restful.Data.FragenObjekt;
import de.tuttas.restful.Data.SchuelerObject;
import de.tuttas.restful.Data.UmfrageObjekt;
import de.tuttas.restful.auth.Authenticator;
import de.tuttas.restful.auth.HTTPHeaderNames;
import de.tuttas.util.ImageUtil;
import de.tuttas.util.Log;
import de.tuttas.util.VerspaetungsUtil;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.ejb.Stateless;
import javax.imageio.ImageIO;
import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.CacheControl;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.Response;

/**
 * Diese Dienste sind aus der Schülerrolle ausrufbar!
 *
 * @author Jörg
 */
@Path("sauth")
@Stateless
public class SAuthServices {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

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
        System.out.println("Get Antworten f. key (" + key + ")");
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
        System.out.println("Result=" + anw);
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
        System.out.println("Aktive Umfrage mit Titel" + u.getNAME());
        System.out.println("Die Umfrage hat FRagen n=" + u.getFragen().size());
        Collection<Fragen> fr = u.getFragen();
        for (Fragen f : fr) {
            FragenObjekt fo = new FragenObjekt(f.getTITEL());
            fo.setId(f.getID_FRAGE());
            Collection<Antwortskalen> aw = f.getAntwortskalen();
            for (Antwortskalen as : aw) {
                System.out.println("size=" + fo.getIDantworten().size());
                Integer k = new Integer(as.getID());
                fo.getIDantworten().add(k);
                if (antworten.get(k) == null) {
                    System.out.println("Eine neue Antwort (" + as.getNAME() + ")");
                    antworten.put(k, new AntwortSkalaObjekt(as.getNAME(), k, as.getWERT()));
                    uo.getAntworten().add(new AntwortSkalaObjekt(as.getNAME(), k, as.getWERT()));
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
    @Path("/umfrage")
    public List<ActiveUmfrage> getActiveUmfrage() {
        System.out.println("Aktive Umfrage abfragen");
        TypedQuery<ActiveUmfrage> query = em.createNamedQuery("findActiveUmfrage", ActiveUmfrage.class
        );
        List<ActiveUmfrage> umfrage = query.getResultList();

        Log.d(
                "Result List:" + umfrage);
        return umfrage;
    }

    /**
     * Liste der Anwesenheit für einen Schüler über einen Bereich
     *
     * @param id id des Schülers
     * @param from Startdatum (inclusiv)
     * @param to EndDatum (inclusiv)
     * @return Liste der Anwesenheitsobjekte
     */
    @GET
    @Path("/{sid}/{from}/{to}")
    public List<AnwesenheitObjekt> getAnwesenheitFrom(@Context HttpHeaders httpHeaders, @PathParam("sid") int sid, @PathParam("from") Date from, @PathParam("to") Date to) {
        String authToken = httpHeaders.getHeaderString(HTTPHeaderNames.AUTH_TOKEN);
        Authenticator a = Authenticator.getInstance();
        String user = a.getUser(authToken);
        Log.d("get Anwesenheit auth_token=" + authToken + " User=" + user);
        if (user == null || Integer.parseInt(user) != sid) {
            return null;
        }
        to = new Date(to.getTime() + 24 * 60 * 60 * 1000);
        Log.d("Webservice Anwesenheit GET from=" + from + " to=" + to);
        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbySchueler", AnwesenheitEintrag.class
        );
        query.setParameter(
                "paramIdSchueler", sid);
        query.setParameter(
                "paramFromDate", from);
        query.setParameter(
                "paramToDate", to);
        List<AnwesenheitEintrag> anwesenheit = query.getResultList();

        return getData(anwesenheit);
    }

    private List<AnwesenheitObjekt> getData(List<AnwesenheitEintrag> anwesenheit) {
        //Log.d("Results:="+anwesenheit);
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

        for (AnwesenheitObjekt ano : anw) {
            ano = VerspaetungsUtil.parse(ano);
        }
        return anw;
    }

    @GET
    @Path("/{idschueler}")
    @Produces({"application/json; charset=iso-8859-1"})
    public SchuelerObject getPupil(@Context HttpHeaders httpHeaders, @PathParam("idschueler") int idschueler) {
        Log.d("Abfrage Schueler mit der ID " + idschueler);
        Schueler s = em.find(Schueler.class, idschueler);
        String authToken = httpHeaders.getHeaderString(HTTPHeaderNames.AUTH_TOKEN);
        Authenticator aut = Authenticator.getInstance();
        String user = aut.getUser(authToken);

        Log.d(
                "get Anwesenheit auth_token=" + authToken + " User=" + user);
        if (user
                == null || Integer.parseInt(user)
                != idschueler) {
            return null;
        }
        if (s
                != null) {
            SchuelerObject so = new SchuelerObject();
            so.setId(idschueler);
            so.setGebDatum(s.getGEBDAT());
            so.setName(s.getNNAME());
            so.setVorname(s.getVNAME());
            so.setEmail(s.getEMAIL());
            so.setInfo(s.getINFO());
            Query query = em.createNamedQuery("findKlassenbySchuelerID");
            query.setParameter("paramIDSchueler", so.getId());
            List<Klasse> klassen = query.getResultList();
            Log.d("Result List:" + klassen);
            so.setKlassen(klassen);

            if (s.getID_AUSBILDER() != null) {
                Ausbilder a = em.find(Ausbilder.class, s.getID_AUSBILDER());
                so.setAusbilder(a);

                if (a != null) {
                    Betrieb b = em.find(Betrieb.class, a.getID_BETRIEB());
                    so.setBetrieb(b);
                }
            }

            return so;
        }

        return null;
    }

    @GET
    @Path("/bild/{idschueler}")
    @Produces("image/jpg")
    public Response getFile(@Context HttpHeaders httpHeaders, @PathParam("idschueler") int idschueler) {
        String authToken = httpHeaders.getHeaderString(HTTPHeaderNames.AUTH_TOKEN);
        Authenticator aut = Authenticator.getInstance();
        String user = aut.getUser(authToken);
        Log.d("get Bild  auth_token=" + authToken + " User=" + user);
        if (user == null || Integer.parseInt(user) != idschueler) {
            return Response.status(Response.Status.UNAUTHORIZED).build();
        }
        String filename = Config.getInstance().IMAGE_FILE_PATH + idschueler + ".jpg";
        Log.d("Lade  file " + filename);
        File file = new File(filename);
        if (!file.exists()) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        return Response.status(Response.Status.OK).build();
    }

    @GET
    @Path("/bild64/{idschueler}")

    public BildObject getFile64(@Context HttpHeaders httpHeaders, @PathParam("idschueler") int idschueler) {
        String authToken = httpHeaders.getHeaderString(HTTPHeaderNames.AUTH_TOKEN);
        Authenticator aut = Authenticator.getInstance();
        String user = aut.getUser(authToken);
        Log.d("get Bild  auth_token=" + authToken + " User=" + user);
        if (user == null || Integer.parseInt(user) != idschueler) {
            return null;
        }
        BildObject bo = new BildObject();
        bo.setId(idschueler);
        String filename = Config.getInstance().IMAGE_FILE_PATH + idschueler + ".jpg";
        Log.d("Lade file " + filename);
        File file = new File(filename);

        if (!file.exists()) {
            return null;
        }
        BufferedImage img = null;
        try {
            img = ImageIO.read(file);
            bo.setBase64(ImageUtil.encodeToString(img, "jpeg"));
            return bo;

        } catch (IOException e) {
            return bo;
        }
    }
}
