/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.util;

import de.tuttas.restful.Data.PlanObject;
import de.tuttas.restful.Plan;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Hilfsmethoden zum ermitteln des Stundenplans
 * @author Jörg
 */
public class StundenplanUtil {

    public static StundenplanUtil instance;
    private static long timestamp;

    // Schüler Pläne
    private final String klassListStundenplan = "http://stundenplan.mmbbs.de/plan1011/lehrkraft/plan/frames/navbar.htm";
    private final String stundenPlanURL = "http://stundenplan.mmbbs.de/plan1011/lehrkraft/plan/";
    private final String klassListVertretungsplan = "http://stundenplan.mmbbs.de/plan1011/ver_kla/frames/navbar.htm";
    private final String vertertungsPlanURL = "http://stundenplan.mmbbs.de/plan1011/ver_kla/";

    // LehrePläne
    private final String lehrerListStundenplan = "http://stundenplan.mmbbs.de/plan1011/lehrkraft/plan/frames/navbar.htm";
    private final String lehrerPlanUrl = "http://stundenplan.mmbbs.de/plan1011/lehrkraft/plan/";
    private final String lehrerListVertretungsplan = "http://stundenplan.mmbbs.de/plan1011/ver_leh/frames/navbar.htm";
    private final String lehrerVPlanUrl = "http://stundenplan.mmbbs.de/plan1011/ver_leh/";

    
    private HashMap klassenStdMap;
    private HashMap klassenVertrMap;
    private HashMap lehrerStdMap;
    private HashMap lehrerVertrMap;

    /**
     * Abfragen der Instanz
     * @return die Instanz
     */
    public static StundenplanUtil getInstance() {
        if (instance == null) {
            timestamp = new Date().getTime();
            instance = new StundenplanUtil();
            return instance;
        }
        if (timestamp < new Date().getTime()-1000*60*60) {
            Log.d("Instanz von StundenplanUtil ist zu alt, also eine neuer erzeugen!");
            timestamp = new Date().getTime();
            instance = new StundenplanUtil();
            return instance;
        }
        return instance;
    }

    private StundenplanUtil() {
        try {
            klassenStdMap = generateKlassMap(klassListStundenplan," var classes = [");
        } catch (IOException ex) {
            Logger.getLogger(StundenplanUtil.class.getName()).log(Level.SEVERE, null, ex);
        }
        try {
            klassenVertrMap = generateKlassMap(klassListVertretungsplan," var classes = [");
        } catch (IOException ex) {
            Logger.getLogger(StundenplanUtil.class.getName()).log(Level.SEVERE, null, ex);
        }
         try {
            lehrerStdMap = generateKlassMap(lehrerListStundenplan," var teachers = [");
        } catch (IOException ex) {
            Logger.getLogger(StundenplanUtil.class.getName()).log(Level.SEVERE, null, ex);
        }
         try {
            lehrerVertrMap = generateKlassMap(lehrerListVertretungsplan," var teachers = [");
        } catch (IOException ex) {
            Logger.getLogger(StundenplanUtil.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    /**
     * Einen Plan Abfagen
     * @param identifier Klassenbezeichnung oder Lehrerkürzel
     * @param pt Die Art des Plans
     * @return Das Plan Objekt
     */
    public PlanObject getPlanObject(String identifier, PlanType pt) {
        return getPlanObject(-1,identifier, pt);
    }

    
     public PlanObject getPlanObject(int kw,String identifier, PlanType pt) {
        PlanObject po = new PlanObject();

        HashMap theMap = null;
        String basicUrl = "";
        String planType = "";
        char seperator=' ';
        switch (pt) {
            case STDPlanSchueler:
                theMap = klassenStdMap;
                basicUrl = stundenPlanURL;
                planType = "Stundenplan";
                seperator='c';
                break;
            case VERTRPlanSchueler:
                theMap = klassenVertrMap;
                basicUrl = vertertungsPlanURL;
                planType = "Vertertungsplan";
                seperator='c';
                break;
            case STDPlanLehrer:
                theMap = lehrerStdMap;
                basicUrl = lehrerPlanUrl;
                planType = "Stundenplan";
                seperator='t';
                break;
            case VERTRPlanLehrer:
                theMap = lehrerVertrMap;
                basicUrl = lehrerVPlanUrl;
                planType = "Vertretungsplan";
                seperator='t';
                break;
        }
        if (theMap != null && theMap.get(identifier) != null) {
            po.setSuccess(true);
            po.setMsg(planType + " geladen");
            int id = (int) theMap.get(identifier);
            Log.d("Generate URL for id="+id);
            po.setUrl(generatePlanUrl(kw, id, basicUrl,seperator));
        } else {
            Log.d(" Kann "+identifier+" nicht finden");
            po.setSuccess(false);
            po.setMsg("Kann " + planType + " von " + identifier + " nicht finden!");
        }
        return po;
     }

    /**
     * Plan als HTML abfragen
     * @param identifier Lehrerkürzel oder Klassenbezeichnung
     * @param pt Die Art des Plans
     * @return Der HTML Code des Plans
     */
    public String getPlan(String identifier, PlanType pt) {
        PlanObject po = getPlanObject(identifier, pt);
        try {
            return filterHtml(po.getUrl());
        } catch (IOException ex) {
            Logger.getLogger(StundenplanUtil.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    /**
     * Plan als HTML abfragen
     * @param kw Kalendar Woche
     * @param identifier Lehrerkürzel oder Klassenbezeichnung
     * @param pt Die Art des Plans
     * @return Der HTML Code des Plans
     */
    public String getPlan(int kw, String identifier, PlanType pt) {
        PlanObject po = getPlanObject(kw,identifier, pt);
        try {
            return filterHtml(po.getUrl());
        } catch (IOException ex) {
            Logger.getLogger(StundenplanUtil.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }
    
    private HashMap generateKlassMap(String url,String sPattern) throws MalformedURLException, IOException {
        URL oracle = new URL(url);
        BufferedReader in = new BufferedReader(
                new InputStreamReader(oracle.openStream()));

        String inputLine;

        while ((inputLine = in.readLine()) != null) {

            if (inputLine.startsWith(sPattern)) {
                Log.d("found:" + inputLine);
                HashMap map = new HashMap();
                String r = inputLine.substring(inputLine.indexOf("[") + 1, inputLine.indexOf("]"));
                r = r.replace("\"", "");
                //Log.d("r=" + r);
                String[] sa = r.split(",");
                for (int i = 0; i < sa.length; i++) {
                    map.put(sa[i], i);
                }
                in.close();
                return map;
            }
        }
        in.close();
        return null;
    }

    /**
     * Erzeugen der URL
     * @param weekOfYeak Kalendarwoche (-1 = aktuelle Kalenderwoche)
     * @param id
     * @param u
     * @param c
     * @return 
     */
    private String generatePlanUrl(int weekOfYear,int id, String u,char c) {        
        id++;
        String sid = "";
        if (id < 10) {
            sid = c+"0000" + id;
        } else if (id < 100) {
            sid = c+"000" + id;
        } else {
            sid = c+"00" + id;
        }
        
        int kw=weekOfYear;
        if (weekOfYear == -1) {
            Calendar cal = Calendar.getInstance();
            // unsere Kalenderwoche beginnt am Fr. um 17:00
            cal.setTime(new Date (cal.getTime().getTime()+1000*60*60*(48+7)));        
            kw = cal.get(Calendar.WEEK_OF_YEAR);
        }
        String skw = "" + kw;
        if (kw < 10) {
            skw = "0" + skw;
        }
        return u + skw + "/"+c+"/" + sid + ".htm";
    }

    private String filterHtml(String url) throws MalformedURLException, IOException {
        URL oracle = new URL(url);
        BufferedReader in = new BufferedReader(
                new InputStreamReader(oracle.openStream()));

        String inputLine;
        String out = "";
        boolean foundCenter = false;
        while ((inputLine = in.readLine()) != null) {

            if (inputLine.startsWith("<CENTER>")) {
                foundCenter = true;
            }
            if (inputLine.endsWith("</CENTER>")) {
                foundCenter = false;
            }
            if (foundCenter) {
                out += inputLine;
            }
        }
        in.close();
        out = out.replace("<BR>", "<BR></BR>\n");
        Log.d("HTML=" + out);
        return out;

    }
}
