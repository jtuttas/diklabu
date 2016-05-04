/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.config.Config;
import de.tuttas.entities.Ausbilder;
import de.tuttas.entities.Bemerkung;
import de.tuttas.entities.Betrieb;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Schueler;
import de.tuttas.restful.Data.AnwesenheitEintrag;
import de.tuttas.restful.Data.AnwesenheitObjekt;
import de.tuttas.restful.Data.BildObject;
import de.tuttas.restful.Data.SchuelerObject;
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
import java.util.List;
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
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.CacheControl;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.Response;

/**
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
     * Liste der Anwesenheit für einen Schüler über einen Bereich
     * @param id id des Schülers
     * @param from Startdatum (inclusiv)
     * @param to EndDatum (inclusiv)
     * @return Liste der Anwesenheitsobjekte
     */
    @GET
    @Path("/{sid}/{from}/{to}")
    public List<AnwesenheitObjekt> getAnwesenheitFrom(@Context HttpHeaders httpHeaders,@PathParam("sid") int sid, @PathParam("from") Date from, @PathParam("to") Date to) {
        String authToken = httpHeaders.getHeaderString(HTTPHeaderNames.AUTH_TOKEN);
        Authenticator a = Authenticator.getInstance();
        String user = a.getUser(authToken);
        Log.d("get Anwesenheit auth_token="+authToken+" User="+user );
        if (user==null || Integer.parseInt(user)!=sid) {
            return null;
        }
        to = new Date(to.getTime()+24*60*60*1000);
        Log.d("Webservice Anwesenheit GET from=" + from + " to=" + to);
        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbySchueler", AnwesenheitEintrag.class);
        query.setParameter("paramIdSchueler", sid);
        query.setParameter("paramFromDate", from);
        query.setParameter("paramToDate", to);        
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
        
        for (AnwesenheitObjekt ano:anw) {
            ano=VerspaetungsUtil.parse(ano);
        }        
        return anw;
    }
    
       @GET
    @Path("/{idschueler}")
    @Produces({"application/json; charset=iso-8859-1"})
    public SchuelerObject getPupil(@Context HttpHeaders httpHeaders,@PathParam("idschueler") int idschueler) {
        Log.d("Abfrage Schueler mit der ID " + idschueler);
        Schueler s = em.find(Schueler.class, idschueler);
        String authToken = httpHeaders.getHeaderString(HTTPHeaderNames.AUTH_TOKEN);
        Authenticator aut = Authenticator.getInstance();
        String user = aut.getUser(authToken);
        Log.d("get Anwesenheit auth_token="+authToken+" User="+user );
        if (user==null || Integer.parseInt(user)!=idschueler) {
            return null;
        }
        if (s != null) {
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
    public Response getFile(@Context HttpHeaders httpHeaders,@PathParam("idschueler") int idschueler) {
        String authToken = httpHeaders.getHeaderString(HTTPHeaderNames.AUTH_TOKEN);
        Authenticator aut = Authenticator.getInstance();
        String user = aut.getUser(authToken);
        Log.d("get Bild  auth_token="+authToken+" User="+user );
        if (user==null || Integer.parseInt(user)!=idschueler) {
            return Response.status(Response.Status.UNAUTHORIZED).build();
        }
        String filename = Config.IMAGE_FILE_PATH + idschueler + ".jpg";
        Log.d("Lade  file " + filename);
        File file = new File(filename);
        if (!file.exists()) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        return Response.status(Response.Status.OK).build();
    }
    
     @GET
    @Path("/bild64/{idschueler}")

    public BildObject getFile64(@Context HttpHeaders httpHeaders,@PathParam("idschueler") int idschueler) {
        String authToken = httpHeaders.getHeaderString(HTTPHeaderNames.AUTH_TOKEN);
        Authenticator aut = Authenticator.getInstance();
        String user = aut.getUser(authToken);
        Log.d("get Bild  auth_token="+authToken+" User="+user );
        if (user==null || Integer.parseInt(user)!=idschueler) {
            return null;
        }
        BildObject bo = new BildObject();
        bo.setId(idschueler);
        String filename = Config.IMAGE_FILE_PATH + idschueler + ".jpg";
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
