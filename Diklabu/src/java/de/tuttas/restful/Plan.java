/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.restful.Data.PlanObject;
import de.tuttas.util.PlanType;
import de.tuttas.util.StundenplanUtil;
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

    
    
    @GET
    @Path("/stundenplanurl/{klasse}")
    public PlanObject getStundenplan(@PathParam("klasse") String kl) {        
        System.out.println("Get Stundenplan von Klasse " + kl);        
        return StundenplanUtil.getInstance().getPlanObject(kl,PlanType.STDPlanSchueler);
    }

    @GET
    @Path("/stundenplan/{klasse}")
    @Produces("text/html")
    public String getStundenplanHtml(@PathParam("klasse") String kl) {
        System.out.println("Get Stundenplan HTML von Klasse " + kl);
        return StundenplanUtil.getInstance().getPlan(kl,PlanType.STDPlanSchueler);
    }

    @GET
    @Path("/vertertungsplanurl/{klasse}")
    public PlanObject getVertretungsplan(@PathParam("klasse") String kl) {
        return StundenplanUtil.getInstance().getPlanObject(kl,PlanType.VERTRPlanSchueler);
    }

    @GET
    @Path("/vertertungsplan/{klasse}")
    @Produces("text/html")
    public String getVerterungsplanHtml(@PathParam("klasse") String kl) {
        return StundenplanUtil.getInstance().getPlan(kl,PlanType.VERTRPlanSchueler);        
    }

}
