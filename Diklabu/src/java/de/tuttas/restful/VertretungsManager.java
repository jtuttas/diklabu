/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.config.Config;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Lehrer;
import de.tuttas.entities.Verlauf;
import de.tuttas.entities.Vertretung;
import de.tuttas.restful.Data.AnwesenheitEintrag;
import de.tuttas.restful.Data.VertretungsObject;
import de.tuttas.restful.Data.Vetretungseintrag;
import de.tuttas.servlets.MailObject;
import de.tuttas.servlets.MailSender;
import de.tuttas.util.Log;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ejb.Stateless;
import javax.mail.internet.AddressException;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;

/**
 *
 * @author Jörg
 */
@Path("vertretung")
@Stateless
public class VertretungsManager {
    private final Map<String, String> klassenlehrerStorage = new HashMap();

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    @GET
    @Path("/{from}/{to}")
    public List<Vertretung> getVertretung(@PathParam("from") Date from, @PathParam("to") Date to) {
        Log.d("Webservice Vertretung GET from=" + from + " to=" + to);
        Query qb = em.createNamedQuery("findVertretungbyDate");
        qb.setParameter("paramFromDate", from);
        qb.setParameter("paramToDate", to);
         List<Vertretung> v = qb.getResultList();
         return v;
    }
    
    @POST
    public VertretungsObject setVertretung(VertretungsObject vo) {
        Log.d("POST Vertretungsmanager");
        Vertretung v = new Vertretung(vo.getEingereichtVon(), null, vo.getAbsenzLehrer(), new Timestamp(vo.getAbsenzAm().getTime()), "");
        v.setKommentar(vo.getKommentar());
        v.setEingereichtAm(new Timestamp(System.currentTimeMillis()));
        Log.d("setVertertung " + v.toString());
        JSONArray ja = new JSONArray();
        if (vo.getEintraege() != null) {
            String vorschlag="";
            klassenlehrerStorage.clear();
            String content = loadTemplate();
            Lehrer absentLehrer = em.find(Lehrer.class, vo.getAbsenzLehrer());
            if (absentLehrer==null) {
                vo.setSuccess(false);
                vo.setMsg("Kann Lehrer mit Kürzel "+vo.getAbsenzLehrer()+" nicht finden!");
                return vo;
            }
            Lehrer absender = em.find(Lehrer.class, vo.getEingereichtVon());
            if (absender==null) {
                vo.setSuccess(false);
                vo.setMsg("Kann Absender Lehrer mit Kürzel "+vo.getEingereichtVon()+" nicht finden!");
                return vo;
            }
            content=content.replace("[[ABSENZ]]", absentLehrer.getVNAME()+" "+absentLehrer.getNNAME());
            content=content.replace("[[DATUM]]", vo.getAbsenzAm().toString());
            content=content.replace("[[ABS]]", absender.getVNAME()+" "+absender.getNNAME());
            content=content.replace("[[KOMMENTAR]]", vo.getKommentar());
                        
            String subject = "Vertretungsvorschlag für " + absentLehrer.getVNAME()+" "+absentLehrer.getNNAME() +"("+absentLehrer.getId()+") am " + vo.getAbsenzAm().toString();            
            MailObject mo = new MailObject(absender.getEMAIL(), subject, null);
            
            for (Vetretungseintrag e : vo.getEintraege()) {
                ja.add(e.toJson());
                Klasse klasse = em.find(Klasse.class, e.getIdKlasse());
                if (klasse==null) {
                    vo.setSuccess(false);
                    vo.setMsg("Kann Klasse mit ID "+e.getIdKlasse()+" nicht finden!");
                    return vo;
                }
                Lehrer klassenlehrer = em.find(Lehrer.class, klasse.getID_LEHRER());
                if (klassenlehrer==null) {
                    vo.setSuccess(false);
                    vo.setMsg("Kann Klassenlehrer der Klasse "+klasse.getKNAME()+" mit Kürzel "+klasse.getID_LEHRER()+" nicht finden!");
                    return vo;
                }
                if (!klassenlehrerStorage.containsKey(klassenlehrer.getId())) {
                    klassenlehrerStorage.put(klassenlehrer.getId(), klassenlehrer.getEMAIL());
                    try {
                        mo.addCC(klassenlehrer.getEMAIL());
                    } catch (AddressException ex) {
                        vo.setSuccess(false);
                        vo.setMsg(ex.getMessage());
                        return vo;
                    }
                }
                if (e.getVertreter()!=null && !e.getVertreter().equals("")) {
                    Lehrer vertreter = em.find(Lehrer.class, e.getVertreter());
                    if (vertreter==null) {
                        vo.setSuccess(false);
                        vo.setMsg("Kann Vertretungslehrer mit Kürzel "+e.getVertreter()+" nicht finden!");
                        return vo;
                    }
                    vorschlag+=" Stunde:"+e.getStunde()+" Klasse:"+e.getKlasse()+" ("+klasse.getID_LEHRER()+") ["+e.getAktion()+"] "+vertreter.getVNAME()+" "+vertreter.getNNAME()+" ("+vertreter.getId()+") "+e.getKommentar()+"\n";
                }
                else {
                    vorschlag+=" Stunde:"+e.getStunde()+" Klasse:"+e.getKlasse()+" ("+klasse.getID_LEHRER()+") ["+e.getAktion()+"] "+e.getKommentar()+"\n";
                }
            }
            content=content.replace("[[VOSCHLAEGE]]", vorschlag);            
            mo.setContent(content);
            v.setJsonString(ja.toJSONString());
            em.merge(v);
            em.flush();
            try {
                mo.addRecipient("stundenplan@mmbbs.de");
            } catch (AddressException ex) {
                Logger.getLogger(VertretungsManager.class.getName()).log(Level.SEVERE, null, ex);
            }
            
            MailSender.getInstance().sendMail(mo);
            vo.setSuccess(true);
            vo.setMsg("Vertretung eingereicht! EMail vesrendet an stundenplan@mmbbs.de und Kollegen und Kolleginnen benachtichtig!");
        } else {
            vo.setSuccess(false);
            vo.setMsg("Keine Vertretungseinträge");
        }
        return vo;
    }

    private String loadTemplate() {
        String pathTemplate = Config.class.getProtectionDomain().getCodeSource().getLocation().getPath();
        pathTemplate = pathTemplate.substring(0, pathTemplate.indexOf("Config.class"));
        pathTemplate = pathTemplate + File.separator + "templateVertretung.txt";
        Log.d("Path=" + pathTemplate);
        BufferedReader br;
        StringBuilder sb = new StringBuilder();
        try {
            br = new BufferedReader(new InputStreamReader(new FileInputStream(pathTemplate), "UTF8"));

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
        return sb.toString();
    }
}
