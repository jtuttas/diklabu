/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.restful.Data.KlasseDetails;
import de.tuttas.config.Config;
import de.tuttas.entities.Betrieb;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Lehrer;
import de.tuttas.entities.Schueler;
import de.tuttas.entities.Schueler_Klasse;
import de.tuttas.restful.Data.AnwesenheitEintrag;
import de.tuttas.restful.Data.AusbilderObject;
import de.tuttas.restful.Data.BildObject;
import de.tuttas.restful.Data.PlanObject;
import de.tuttas.restful.Data.ResultObject;
import de.tuttas.restful.Data.SchuelerObject;
import de.tuttas.util.ImageUtil;
import de.tuttas.util.Log;
import de.tuttas.util.PlanType;
import de.tuttas.util.StundenplanUtil;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.ejb.Stateless;
import javax.imageio.ImageIO;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;

/**
 *
 * @author Jörg
 */
@Path("klasse")
@Stateless
public class KlassenManager {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    @GET
    @Path("/{klasse}")
     @Produces({"application/json; charset=iso-8859-1"})
    public List<Schueler> getPupil(@PathParam("klasse") String kl) {
        Log.d("Webservice klasse GET: klasse=" + kl);

        Query query = em.createNamedQuery("findSchuelerEinerBenanntenKlasse");
        query.setParameter("paramNameKlasse", kl);
        List<Schueler> schueler = query.getResultList();
        Log.d("Result List:" + schueler);
        return schueler;
    }
    
    @GET
    @Path("/info/{klasse}")
    public List<Klasse> getKlasse(@PathParam("klasse") String kl) {
        Log.d("Webservice klasse GET: klasse=" + kl);
        Query query = em.createNamedQuery("findKlassebyName");
        query.setParameter("paramKName", kl);
        List<Klasse> klassen = query.getResultList();
        Log.d("Result List:" + klassen);
        return klassen;
    }
    
    @POST
    @Path("/add")
     @Produces({"application/json; charset=iso-8859-1"})
    public ResultObject addSchuelerToKlasse(Schueler_Klasse sk) {        
        Log.d("Schüler einer Klasse zuweisen:"+sk.toString());
        Schueler s = em.find(Schueler.class, sk.getID_SCHUELER());
        Klasse k = em.find(Klasse.class, sk.getID_KLASSE());
        ResultObject ro = new ResultObject();
        if (s!=null && k!=null) {
            em.persist(sk);        
            ro.setMsg("Schüler "+s.getVNAME()+" "+s.getNNAME()+" zugewiesen zur Klasse "+k.getKNAME());
            ro.setSuccess(true);
        }
        else {
            ro.setSuccess(false);
            ro.setMsg("Klasse "+k+" oder Schüler "+s+" nicht gefunden!");
        }
        return ro;
       
    }
    
    @DELETE
    @Path("/{idschueler}/{idklasse}")
    @Produces({"application/json; charset=iso-8859-1"})
    public ResultObject deleteSchuelerfromKlasse(@PathParam("idschueler") int sid,@PathParam("idklasse") int kid) {
        Log.d("Webservice delete Schüler "+sid+" von Klasse:" + kid);
        ResultObject ro = new ResultObject();
        Query query = em.createNamedQuery("findSchuelerKlasse");
        query.setParameter("paramidSchueler", sid);
        query.setParameter("paramidKlasse", kid);
        List<Schueler_Klasse> sk = query.getResultList();
        if (sk.size()!=0) {
            em.remove(sk.get(0));
            ro.setSuccess(true);
            ro.setMsg("Schüler mit der id="+sid+" aus der Klasse "+kid+" entfernt!");
        }
        else {
            ro.setMsg("Kann keine zugehörigkeit des Schülers mit der id="+sid+" mit der Klasse "+kid+" finden");
            ro.setSuccess(false);
        }
        return ro;
    }
    
    @DELETE
    @Path("/{idklasse}")
    @Produces({"application/json; charset=iso-8859-1"})
    public ResultObject deleteKlasse(@PathParam("idklasse") int kid) {
        Log.d("Webservice delete Klasse:" + kid);
        ResultObject ro = new ResultObject();
        Klasse k = em.find(Klasse.class, kid);
        if (k!=null) {
            
            Query query = em.createNamedQuery("findSchuelerEinerBenanntenKlasse");
            query.setParameter("paramNameKlasse", k.getKNAME());
            List<Schueler> schueler = query.getResultList();
            if (schueler.size()!=0) {
                ro.setMsg("Kann Klasse nicht löschen, da die Klasse noch Schüler hat");
                ro.setSuccess(false);
            }
            else {
                em.remove(k);
                ro.setMsg("Klasse gelöscht");
                ro.setSuccess(true);
            }
        }
        else {
            ro.setMsg("Kann Klasse mit id="+kid+" nicht finden");
            ro.setSuccess(false);
        }
        return ro;
    }
    
    @POST
    public List<Klasse> addKlasse(Klasse k) {
        em.getEntityManagerFactory().getCache().evictAll();
        Log.d("Webservice klasse POST add: klasse=" + k);
        Query query = em.createNamedQuery("findKlassebyName");
        query.setParameter("paramKName", k.getKNAME());
        List<Klasse> klassen = query.getResultList();
        if (klassen.size()==0) {
            em.persist(k);
            query = em.createNamedQuery("findKlassebyName");
            query.setParameter("paramKName", k.getKNAME());
            klassen = query.getResultList();            
        }
        else {
            Klasse kl = klassen.get(0);
            kl.setID_LEHRER(k.getID_LEHRER());
            kl.setNOTIZ(k.getNOTIZ());
            kl.setTITEL(k.getTITEL());
            kl.setID_KATEGORIE(k.getID_KATEGORIE());
            kl.setTERMINE(k.getTERMINE());
            em.merge(kl);
            klassen.set(0, kl);            
        }
        return klassen;
    }
    
    @GET
    @Path("/betriebe/{klasse}")
    public List<AusbilderObject> getCompanyPupil(@PathParam("klasse") String kl) {
        Log.d("Webservice Betriebe Klasse GET: klasse=" + kl);

        TypedQuery<AusbilderObject> query = em.createNamedQuery("findBetriebeEinerBenanntenKlasse", AusbilderObject.class);
        query.setParameter("paramNameKlasse", kl);
        List<AusbilderObject> ausbilder = query.getResultList();
        Log.d("Result List:" + ausbilder);
        return ausbilder;
    }

    @GET
    @Path("/details/{id}")
    public KlasseDetails getDetails(@PathParam("id") int id) {
        Log.d("Webservice klasse GET details: klasse=" + id);
        Klasse k = em.find(Klasse.class, id);
        if (k == null) {
            return null;
        }
        Log.d("Klasse = " + k.toString());
        Lehrer l = em.find(Lehrer.class, k.getID_LEHRER());
        Log.d("Klassenlehrer = " + l.toString());
        KlasseDetails d = new KlasseDetails(k, l);
        PlanObject po = StundenplanUtil.getInstance().getPlanObject(k.getKNAME(),PlanType.STDPlanSchueler);
        d.setStundenplan(po.getUrl());
        po = StundenplanUtil.getInstance().getPlanObject(k.getKNAME(),PlanType.VERTRPlanSchueler);
        d.setVertretungsplan(po.getUrl());        
        return d;
    }

    @POST
    @Path("/details/{id}")
    public Klasse setDetails(@PathParam("id") int id, Klasse k) {
        Log.d("Webservice klasse POST details: klasse=" + id);
        Klasse kl = em.find(Klasse.class, id);

        if (kl != null) {
            kl.setNOTIZ(k.getNOTIZ());
            Log.d("Klasse = " + kl.toString());
            em.merge(kl);
            Log.d("Eintrag aktualisiert");
            return k;
        }
        return null;
    }

    @GET
    @Path("/{klasse}/bilder64/{height}")
    public List<BildObject> getBilder(@PathParam("klasse") String kl, @PathParam("height") int height) {
        Log.d("Webservice klasse GET bilder64: klasse=" + kl + " scale=" + height);
        Query query = em.createNamedQuery("findSchuelerEinerBenanntenKlasse");
        query.setParameter("paramNameKlasse", kl);
        List<Schueler> schueler = query.getResultList();
        Log.d("Result List:" + schueler);
        List<BildObject> bilder = new ArrayList<>();
        for (Schueler s : schueler) {
            BildObject bo = new BildObject();
            bo.setId(s.getId());
            String filename = Config.IMAGE_FILE_PATH + s.getId() + ".jpg";
            Log.d("Lade file " + filename);
            File file = new File(filename);
            if (!file.exists()) {
            } else {
                BufferedImage img = null;
                try {
                    img = ImageIO.read(file);
                    if (img!=null) {
                    Log.d("Original Width = " + img.getWidth() + " Height = " + img.getHeight());
                    double ow = img.getWidth();
                    double oh = img.getHeight();
                    double ratio = (double) (height * ow) / oh;
                    Log.d("ratio=" + ratio + " New Width=" + (int) ratio);

                    int type = img.getType() == 0 ? BufferedImage.TYPE_INT_ARGB : img.getType();
                    img = ImageUtil.resizeImage(img, type, (int) ratio, height);
                    Log.d("Resized Width = " + img.getWidth() + " Height = " + img.getHeight());
                    img = ImageUtil.cropImage(img, type, height);
                    Log.d("Cropped Width = " + img.getWidth() + " Height = " + img.getHeight());
                    bo.setBase64(ImageUtil.encodeToString(img, "jpeg"));
                    }
                } catch (IOException e) {
                }
            }
            bilder.add(bo);
        }
        return bilder;
    }
}
