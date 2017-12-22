/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.MetadataException;
import de.tuttas.config.Config;
import de.tuttas.entities.Anwesenheit;
import de.tuttas.entities.AnwesenheitId;
import de.tuttas.entities.Bemerkung;
import de.tuttas.entities.BemerkungId;
import de.tuttas.restful.Data.AnwesenheitEintrag;

import de.tuttas.restful.Data.AnwesenheitObjekt;
import de.tuttas.restful.Data.ResultObject;
import de.tuttas.util.ImageUtil;
import de.tuttas.util.Log;
import de.tuttas.util.VerspaetungsUtil;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Date;
import java.sql.Timestamp;

import java.util.ArrayList;
import java.util.Calendar;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ejb.Stateless;
import javax.imageio.ImageIO;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.ResponseBuilder;
import org.apache.commons.io.IOUtils;
import org.glassfish.jersey.media.multipart.FormDataContentDisposition;
import org.glassfish.jersey.media.multipart.FormDataParam;

/**
 * Restful Service zum Verwalten der Anwesenheit (/api/v1/anwesenheit)
 *
 * @author Jörg
 *
 */
@Path("anwesenheit")
@Stateless
public class AnwesenheitsManager {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    /**
     * Löschen eines Anwesenhietseintrages Adresse
     * /api/v1/anwesenheit/{ids}/{datum}
     *
     * @param ids ID des Schülers
     * @param dat Datum des Anwesenheit
     * @return Anwesenheit die gelöscht wurde, oder null bei Fehler
     */
    @DELETE
    @Path("/{ids}/{datum}")
    public Anwesenheit delAnwesenheit(@PathParam("ids") Integer ids, @PathParam("datum") Date dat) {
        Log.d("ids=" + ids + " Datum=" + dat);
        Anwesenheit a = em.find(Anwesenheit.class, new AnwesenheitId(ids, new Timestamp(dat.getTime())));
        if (a != null) {
            em.remove(a);
        } else {
            Log.d("Kann Anwesenheit nicht finden!");
        }
        return a;
    }

    /**
     * Krankmeldung herunterladen
     * @param filename
     * @return 
     */
    @GET
    @Path("/schueler/{filename}")
    @Produces(MediaType.APPLICATION_OCTET_STREAM)
    public Response getFile(@PathParam("filename") String filename) {
        File file = new File(Config.getInstance().ATEST_FILE_PATH + "/" + filename);
        ResponseBuilder response = Response.ok((Object) file);
        response.header("Content-Disposition", "attachment; filename="+filename);
        return response.build();
    }

    /**
     * Krankmeldung hochladen
     *
     * @param idschueler
     * @param uploadedInputStream
     * @param fileDetail
     */
    @POST
    @Path("/schueler/{idschueler}")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    public ResultObject uploadFile(
            @PathParam("idschueler") int idschueler,
            @FormDataParam("file") InputStream uploadedInputStream,
            @FormDataParam("file") FormDataContentDisposition fileDetail) {

        ResultObject r = new ResultObject();
        if (fileDetail.getFileName().endsWith(".pdf") || fileDetail.getFileName().endsWith(".jpg")) {
            String suffix = fileDetail.getFileName().substring(fileDetail.getFileName().lastIndexOf("."));
            String filename = idschueler + "_" + System.currentTimeMillis() + suffix;
            String fileLocation = Config.getInstance().ATEST_FILE_PATH + filename;
            Log.d("upload  File for " + idschueler + " file=" + fileDetail.getFileName());
            try {
                // save it
                writeToFile(uploadedInputStream, fileLocation);
                r.setSuccess(true);
                r.setMsg(filename);
            } catch (IOException ex) {
                r.setSuccess(false);
                r.setMsg(ex.getMessage());
                Logger.getLogger(AnwesenheitsManager.class.getName()).log(Level.SEVERE, null, ex);
            }
        } else {
            r.setSuccess(false);
            r.setMsg("Nur pdf oder jpg ist erlaubt!");
        }
        return r;
    }

    // save uploaded file to new location
    private void writeToFile(InputStream uploadedInputStream,
            String uploadedFileLocation) throws FileNotFoundException, IOException {

        OutputStream out = new FileOutputStream(new File(
                uploadedFileLocation));
        int read = 0;
        byte[] bytes = new byte[1024];

        out = new FileOutputStream(new File(uploadedFileLocation));
        while ((read = uploadedInputStream.read(bytes)) != -1) {
            out.write(bytes, 0, read);
        }
        out.flush();
        out.close();

    }

    /**
     * Löschen einer Krankmeldung
     *
     * @param ids ID des Schülers
     * @param dat Datum der Krankmeldung
     * @return Anwesenheitseintrag
     */
    @DELETE
    @Path("/schueler/{ids}/{datum}")
    public ResultObject delKrankmeldung(@PathParam("ids") Integer ids, @PathParam("datum") Date dat) {
        Log.d("ids=" + ids + " Datum=" + dat);
        ResultObject ro = new ResultObject();
        Anwesenheit a = em.find(Anwesenheit.class, new AnwesenheitId(ids, new Timestamp(dat.getTime())));
        if (a != null) {
            a.setKRANKMELDUNG(null);
            em.merge(a);
            ro.setSuccess(true);
            ro.setMsg("Krankmeldung von " + a.getID_SCHUELER() + " am " + dat + " gelöscht!");
        } else {
            Log.d("Kann Anwesenheit nicht finden!");
            ro.setSuccess(false);
            ro.setMsg("Kann keinen Anwesenheitseintrag vom Schüler mit ID " + ids + " am " + dat + " finden!");
        }
        return ro;
    }

    @PUT
    @Path("/schueler/{ids}/{datum}")
    public ResultObject setKrankmeldung(@PathParam("ids") Integer ids, @PathParam("datum") Date dat, String krankmeldung) {
        Log.d("ids=" + ids + " Datum=" + dat);
        ResultObject ro = new ResultObject();
        Anwesenheit a = em.find(Anwesenheit.class, new AnwesenheitId(ids, new Timestamp(dat.getTime())));
        if (a != null) {
            a.setKRANKMELDUNG(krankmeldung);
            em.merge(a);
            ro.setSuccess(true);
            ro.setMsg("Krankmeldung von Schüler mit ID " + a.getID_SCHUELER() + " am " + dat + " hinzugefügt");
        } else {
            Log.d("Kann Anwesenheit nicht finden!");
            ro.setSuccess(false);
            ro.setMsg("Kann keinen Anwesenheitseintrag vom Schüler mit ID " + ids + " am " + dat + " finden!");
        }
        return ro;
    }

    /**
     * Setzen eines Anwesenheitseintrages
     *
     * @param ae der Anwesenheitseintrag
     * @return der Anwesenheitseintrag oder null bei Fehler
     */
    @POST
    public AnwesenheitEintrag addAnwesenheit(AnwesenheitEintrag ae) {
        em.getEntityManagerFactory().getCache().evictAll();
        Log.d("POST Anwesenheitseintrag = " + ae.toString());
        Anwesenheit a = em.find(Anwesenheit.class, new AnwesenheitId(ae.getID_SCHUELER(), ae.getDATUM()));

        if (a != null) {
            Log.d("Es gibt schon einen Eintrag, also updaten");

            if (ae.getID_LEHRER() != null) {
                a.setID_LEHRER(ae.getID_LEHRER());
            }
            if (ae.getVERMERK() != null) {
                a.setVERMERK(ae.getVERMERK());
            }
            if (ae.getKRANKMELDUNG() != null) {
                a.setKRANKMELDUNG(ae.getKRANKMELDUNG());
            }
            em.merge(a);
            Log.d(a.toString());
        } else {
            Log.d("Ein neuer Eintrag");
            a = new Anwesenheit(ae.getID_SCHUELER(), ae.getDATUM());
            if (ae.getID_LEHRER() != null) {
                a.setID_LEHRER(ae.getID_LEHRER());
            }
            if (ae.getVERMERK() != null) {
                a.setVERMERK(ae.getVERMERK());
            }
            if (ae.getKRANKMELDUNG() != null) {
                a.setKRANKMELDUNG(ae.getKRANKMELDUNG());
            }
            em.persist(a);
        }
        if (ae.getBEMERKUNG() != null) {
            Log.d("Es gibt eine Bemerkung");
            BemerkungId bemId = new BemerkungId(ae.getDATUM(), ae.getID_SCHUELER());

            Bemerkung fb = em.find(Bemerkung.class, bemId);
            if (fb == null) {
                Log.d("eine neue Bemerkung");
                Bemerkung b = new Bemerkung(ae.getDATUM(), ae.getID_SCHUELER());
                b.setID_LEHRER(ae.getID_LEHRER());
                b.setBEMERKUNG(ae.getBEMERKUNG());
                em.persist(b);
            } else {
                Log.d("eine alte Bemerkung also update");
                fb.setID_LEHRER(ae.getID_LEHRER());
                fb.setBEMERKUNG(ae.getBEMERKUNG());
                em.merge(fb);
            }
        } else {
            Log.d("Es gibt KEINE Bemerkung,schauen ob es eine alte Bemerkung gibt");
            BemerkungId bemId = new BemerkungId(ae.getDATUM(), ae.getID_SCHUELER());
            Bemerkung fb = em.find(Bemerkung.class, bemId);
            if (fb != null) {
                Log.d("ja es gab eine alte Bemerkung, diese löschen!");
                em.remove(fb);
            }
        }
        em.flush();
        ae.setParseError(!VerspaetungsUtil.isValid(ae));
        return ae;
    }

    /**
     * Heutige Anwesenheit einer Klasse Adresse /api/v1/anwesenheit/{Name der
     * Klasse}
     *
     * @param kl Name der Klasse
     * @return Liste von AnwesenheitsObjekten
     */
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

        Log.d("Webservice Anwesenheit GET from Date=" + d1.toString() + " To " + d2.toString() + " klasse=" + kl);
        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbyKlasse", AnwesenheitEintrag.class);
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", d1);
        query.setParameter("paramToDate", d2);
        List<AnwesenheitEintrag> anwesenheit = query.getResultList();

        Query qb = em.createNamedQuery("findBemerkungbyDate");
        qb.setParameter("paramFromDate", d1);
        qb.setParameter("paramToDate", d2);

        List<String> ids = new ArrayList<>();
        for (AnwesenheitEintrag ae : anwesenheit) {
            ids.add("" + ae.getID_SCHUELER());
        }
        List<Bemerkung> bemerkungen = null;
        qb.setParameter("idList", ids);
        if (ids.size() > 0) {
            bemerkungen = qb.getResultList();
            Log.d("Result List Bemerkunken:" + bemerkungen);
        }
        return getData(anwesenheit, bemerkungen);
    }

    /**
     * Anwesenheit einer Klasse an einem bestimmten Tag abfragen Adresse
     * /api/v1/anwesenheit/{Name der Klasse}/{Datum}
     *
     * @param kl Name der Klasse
     * @param from Das Datum
     * @return Liste von Anwesenheitsobjekten
     */
    @GET
    @Path("/{klasse}/{from}")
    public List<AnwesenheitObjekt> getAnwesenheit(@PathParam("klasse") String kl, @PathParam("from") Date from) {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);

        Date d = new Date(from.getTime() + 1000 * 60 * 60 * 24 - 1);
        Log.d("Webservice Anwesenheit GET klasse=" + kl + " from=" + from + " to=" + d);
        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbyKlasse", AnwesenheitEintrag.class);
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", from);
        query.setParameter("paramToDate", d);
        List<AnwesenheitEintrag> anwesenheit = query.getResultList();

        Query qb = em.createNamedQuery("findBemerkungbyDate");
        qb.setParameter("paramFromDate", from);
        qb.setParameter("paramToDate", d);

        List<String> ids = new ArrayList<>();
        for (AnwesenheitEintrag ae : anwesenheit) {
            ids.add("" + ae.getID_SCHUELER());
        }
        List<Bemerkung> bemerkungen = null;
        qb.setParameter("idList", ids);
        if (ids.size() > 0) {
            bemerkungen = qb.getResultList();
            Log.d("Result List Bemerkunken:" + bemerkungen);
        }
        return getData(anwesenheit, bemerkungen);

    }

    /**
     * Liste der Anwesenheit einer Klasse über einen Bereich Adresse
     * /api/v1/anwesenheit/{Name der Klasse}/{von Datum}/{bis Datum}
     *
     * @param kl Name der Klasse
     * @param from Startdatum (inclusiv)
     * @param to EndDatum (inclusiv)
     * @return Liste der Anwesenheitsobjekte
     */
    @GET
    @Path("/{klasse}/{from}/{to}")
    public List<AnwesenheitObjekt> getAnwesenheit(@PathParam("klasse") String kl, @PathParam("from") Date from, @PathParam("to") Date to) {
        to = new Date(to.getTime() + 24 * 60 * 60 * 1000);
        Log.d("Webservice Anwesenheit GET from=" + from + " to=" + to);
        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbyKlasse", AnwesenheitEintrag.class);
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", from);
        query.setParameter("paramToDate", to);

        List<AnwesenheitEintrag> anwesenheit = query.getResultList();

        Query qb = em.createNamedQuery("findBemerkungbyDate");
        qb.setParameter("paramFromDate", from);
        qb.setParameter("paramToDate", to);

        List<String> ids = new ArrayList<>();
        for (AnwesenheitEintrag ae : anwesenheit) {
            ids.add("" + ae.getID_SCHUELER());
        }
        List<Bemerkung> bemerkungen = null;
        qb.setParameter("idList", ids);
        if (ids.size() > 0) {
            bemerkungen = qb.getResultList();
            Log.d("Result List Bemerkunken:" + bemerkungen);
        }
        return getData(anwesenheit, bemerkungen);
    }

    private List<AnwesenheitObjekt> getData(List<AnwesenheitEintrag> anwesenheit, List<Bemerkung> bemerkungen) {

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

        if (bemerkungen != null) {
            for (AnwesenheitObjekt anwo : anw) {
                List<AnwesenheitEintrag> eintr = anwo.getEintraege();
                for (AnwesenheitEintrag anwe : eintr) {
                    int ids = anwe.getID_SCHUELER();
                    Timestamp ts = anwe.getDATUM();
                    for (Bemerkung bem : bemerkungen) {
                        if (bem.getID_SCHUELER() == ids && bem.getDATUM().equals(ts)) {
                            Log.d("Habe eine Bemerkung zum Anwesenheitseintrag gefunden");
                            anwe.setBEMERKUNG(bem.getBEMERKUNG());
                        }
                    }
                }
            }
        }
        return anw;
    }

    /**
     * Liste der Fehltage für einen Schüler über einen Bereich
     *
     * @param httpHeaders auth_key zur Verifikation
     * @param sid ID des Schülers
     * @param from Bereich von
     * @param to Bereich bis
     * @return Liste von Anwesenheitsobjekten
     */
    @GET
    @Path("schueler/{sid}/{from}/{to}")
    public List<AnwesenheitObjekt> getAnwesenheit(@PathParam("sid") int sid, @PathParam("from") Date from, @PathParam("to") Date to) {
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

        Query qb = em.createNamedQuery("findBemerkungbyDate");
        qb.setParameter("paramFromDate", from);
        qb.setParameter("paramToDate", to);
        List<String> ids = new ArrayList<>();
        ids.add("" + sid);
        qb.setParameter("idList", ids);
        List<Bemerkung> bem = qb.getResultList();
        Log.d("Bemerkungen=" + bem);
        return getDataf(anwesenheit, bem);
    }

    private List<AnwesenheitObjekt> getDataf(List<AnwesenheitEintrag> anwesenheit, List<Bemerkung> bem) {
        //Log.d("Results:="+anwesenheit);
        List<AnwesenheitObjekt> anw = new ArrayList();
        int id = 0;
        AnwesenheitObjekt ao = new AnwesenheitObjekt();
        for (int i = 0; i < anwesenheit.size(); i++) {
            if (!anwesenheit.get(i).getVERMERK().startsWith("a")) {
                if (anwesenheit.get(i).getID_SCHUELER() != id) {
                    id = anwesenheit.get(i).getID_SCHUELER();
                    ao = new AnwesenheitObjekt(id);
                    anw.add(ao);

                }

                anwesenheit.get(i).setParseError(!VerspaetungsUtil.isValid(anwesenheit.get(i)));
                for (Bemerkung b : bem) {
                    //Log.d("Teste "+b.getDATUM()+" ist "+anwesenheit.get(i).getDATUM()+" und ID="+b.getID_SCHUELER()+" ist "+anwesenheit.get(i).getID_SCHUELER());
                    if (b.getID_SCHUELER() == anwesenheit.get(i).getID_SCHUELER() && b.getDATUM().equals(anwesenheit.get(i).getDATUM())) {
                        anwesenheit.get(i).setBEMERKUNG(b.getBEMERKUNG());
                        //Log.d("sertze Bemerkung auf "+b.getBEMERKUNG());
                    }
                }
                //anwesenheit.get(i).setBEMERKUNG(null);
                ao.getEintraege().add(anwesenheit.get(i));
            }
        }

        for (AnwesenheitObjekt ano : anw) {
            ano = VerspaetungsUtil.parse(ano);
        }
        return anw;
    }

}
