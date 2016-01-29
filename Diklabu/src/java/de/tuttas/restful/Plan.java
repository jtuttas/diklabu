/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.restful.Data.PlanObject;
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
        return StundenplanUtil.getPlanObject(kl,StundenplanUtil.klassListStundenplan,StundenplanUtil.stundenPlanURL);
    }

    @GET
    @Path("/stundenplan/{klasse}")
    @Produces("text/html")
    public String getStundenplanHtml(@PathParam("klasse") String kl) {
        System.out.println("Get Stundenplan HTML von Klasse " + kl);
        return StundenplanUtil.getPlan(kl,StundenplanUtil.klassListStundenplan,StundenplanUtil.stundenPlanURL);
    }

    @GET
    @Path("/vertertungsplanurl/{klasse}")
    public PlanObject getVertretungsplan(@PathParam("klasse") String kl) {
        return StundenplanUtil.getPlanObject(kl,StundenplanUtil.klassListVertretungsplan,StundenplanUtil.vertertungsPlanURL);
    }

    @GET
    @Path("/vertertungsplan/{klasse}")
    @Produces("text/html")
    public String getVerterungsplanHtml(@PathParam("klasse") String kl) {
        return StundenplanUtil.getPlan(kl,StundenplanUtil.klassListVertretungsplan,StundenplanUtil.vertertungsPlanURL);        
    }

}
