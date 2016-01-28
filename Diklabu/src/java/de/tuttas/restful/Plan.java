/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.restful.Data.PlanObject;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Calendar;
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.ejb.Stateless;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;

/**
 *
 * @author Jörg
 */
@Path("noauth/plan")
@Stateless
public class Plan {

    public static final String klassListStundenplan = "http://stundenplan.mmbbs.de/plan1011/lehrkraft/plan/frames/navbar.htm";
    public static final String stundenPlanURL = "http://stundenplan.mmbbs.de/plan1011/lehrkraft/plan/";
    public static final String klassListVertretungsplan = "http://stundenplan.mmbbs.de/plan1011/ver_kla/frames/navbar.htm";
    public static final String vertertungsPlanURL = "http://stundenplan.mmbbs.de/plan1011/ver_kla/";
    public HashMap klassenMap;
    
    @GET
    @Path("/stundenplanurl/{klasse}")
    public PlanObject getStundenplan(@PathParam("klasse") String kl) {
        PlanObject po = new PlanObject();
        System.out.println("Get Stundenplan von Klasse " + kl);
        try {
            klassenMap = generateKlassMap(klassListStundenplan);
            System.out.println(" index von kl=" + kl + " ist " + klassenMap.get(kl));
            if (klassenMap.get(kl) != null) {
                po.setSuccess(true);
                po.setMsg("Klassenliste geladen");
                po.setUrl(generatePlanUrl(kl, stundenPlanURL));
            } else {
                po.setSuccess(false);
                po.setMsg("Kann Stundenplan von Klasse " + kl + " nicht finden!");
            }

        } catch (MalformedURLException ex) {
            Logger.getLogger(Plan.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(Plan.class.getName()).log(Level.SEVERE, null, ex);
        }
        return po;
    }

    @GET
    @Path("/stundenplan/{klasse}")
    @Produces("text/html")
    public String getStundenplanHtml(@PathParam("klasse") String kl) {

        System.out.println("Get Stundenplan HTML von Klasse " + kl);
        try {
            klassenMap = generateKlassMap(klassListStundenplan);
            System.out.println(" index von kl=" + kl + " ist " + klassenMap.get(kl));
            if (klassenMap.get(kl) != null) {
                String url = generatePlanUrl(kl, stundenPlanURL);
                return filterHtml(url);
            } else {
                return null;
            }

        } catch (MalformedURLException ex) {
            Logger.getLogger(Plan.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(Plan.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    @GET
    @Path("/vertertungsplanurl/{klasse}")
    public PlanObject getVertretungsplan(@PathParam("klasse") String kl) {
        PlanObject po = new PlanObject();
        System.out.println("Get Vertretungsplan von Klasse " + kl);
        try {
            klassenMap = generateKlassMap(klassListVertretungsplan);
            System.out.println(" index von kl=" + kl + " ist " + klassenMap.get(kl));
            if (klassenMap.get(kl) != null) {
                po.setSuccess(true);
                po.setMsg("Klassenliste geladen");
                po.setUrl(generatePlanUrl(kl, vertertungsPlanURL));
            } else {
                po.setSuccess(false);
                po.setMsg("Kann Stundenplan von Klasse " + kl + " nicht finden!");
            }

        } catch (MalformedURLException ex) {
            Logger.getLogger(Plan.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(Plan.class.getName()).log(Level.SEVERE, null, ex);
        }
        return po;
    }

    @GET
    @Path("/vertertungsplan/{klasse}")
    @Produces("text/html")
    public String getVerterungsplanHtml(@PathParam("klasse") String kl) {

        System.out.println("Get Verterungsplan HTML von Klasse " + kl);
        try {
            klassenMap = generateKlassMap(klassListVertretungsplan);
            if (klassenMap.get(kl) != null) {
                String url = generatePlanUrl(kl, vertertungsPlanURL);
                return filterHtml(url);
            } else {
                return null;
            }

        } catch (MalformedURLException ex) {
            Logger.getLogger(Plan.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(Plan.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    private String generatePlanUrl(String kl, String u) {
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
        return out;

    }

    private HashMap generateKlassMap(String url) throws MalformedURLException, IOException {
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
}
