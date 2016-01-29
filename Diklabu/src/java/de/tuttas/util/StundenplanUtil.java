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
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Jörg
 */
public class StundenplanUtil {
    public static final String klassListStundenplan = "http://stundenplan.mmbbs.de/plan1011/lehrkraft/plan/frames/navbar.htm";
    public static final String stundenPlanURL = "http://stundenplan.mmbbs.de/plan1011/lehrkraft/plan/";
    public static final String klassListVertretungsplan = "http://stundenplan.mmbbs.de/plan1011/ver_kla/frames/navbar.htm";
    public static final String vertertungsPlanURL = "http://stundenplan.mmbbs.de/plan1011/ver_kla/";
    public static HashMap klassenMap;
    
    public static PlanObject getPlanObject(String kl,String url,String basicUrl) {
        PlanObject po = new PlanObject();
        try {
            klassenMap = generateKlassMap(url);
            System.out.println(" index von kl=" + kl + " ist " + klassenMap.get(kl));
            if (klassenMap!=null && klassenMap.get(kl) != null) {
                po.setSuccess(true);
                po.setMsg("Klassenliste geladen");
                po.setUrl(generatePlanUrl(kl, basicUrl));
            } else {
                po.setSuccess(false);
                po.setMsg("Kann Stundenplan von Klasse " + kl + " nicht finden!");
            }

        } catch (MalformedURLException ex) {
            po.setSuccess(false);
            po.setMsg(ex.getMessage());
            Logger.getLogger(Plan.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            po.setSuccess(false);
            po.setMsg(ex.getMessage());
            Logger.getLogger(Plan.class.getName()).log(Level.SEVERE, null, ex);
        }
        return po;
    }

    
    public static String getPlan(String kl, String url,String basicUrl) {
        PlanObject po = getPlanObject(kl, url,basicUrl);
        try {
            return filterHtml(po.getUrl());
        } catch (IOException ex) {
            Logger.getLogger(StundenplanUtil.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }
    
    private static HashMap generateKlassMap(String url) throws MalformedURLException, IOException {
        URL oracle = new URL(url);
        BufferedReader in = new BufferedReader(
                new InputStreamReader(oracle.openStream()));

        String inputLine;

        while ((inputLine = in.readLine()) != null) {

            if (inputLine.startsWith(" var classes = [")) {
                System.out.println("found:" + inputLine);
                HashMap map = new HashMap();
                String r = inputLine.substring(inputLine.indexOf("[") + 1, inputLine.indexOf("]"));
                r = r.replace("\"", "");
                System.out.println("r=" + r);
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
    
      private static String generatePlanUrl(String kl, String u) {
        int id = (int) klassenMap.get(kl);
        id++;
        String sid = "";
        if (id < 10) {
            sid = "c0000" + id;
        } else if (id < 100) {
            sid = "c000" + id;
        } else {
            sid = "c00" + id;
        }
        Calendar cal = Calendar.getInstance();

        int kw = cal.get(Calendar.WEEK_OF_YEAR);
        String skw = "" + kw;
        if (kw < 10) {
            skw = "0" + skw;
        }
        return u + skw + "/c/" + sid + ".htm";

    }
      
      private static String filterHtml(String url) throws MalformedURLException, IOException {
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
        out=out.replace("<BR>", "<BR></BR>\n");
        
       // out=removeTag("font",out);
          System.out.println("HTML="+out);
        return out;

    }

   

    

}
