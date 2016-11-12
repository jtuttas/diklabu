/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.restful.Data.PlanObject;
import de.tuttas.util.Log;
import de.tuttas.util.PlanType;
import de.tuttas.util.StundenplanUtil;
import javax.ejb.Stateless;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;

/**
 * Webservice zum Abfragen des Stundenplans / Vertertungsplans
 * @author Jörg
 */
@Path("noauth/plan")
@Stateless
public class Plan {

    
    /**
     * Stundenplan URL einer Klasse abfragen
     * @param kl Name der Klasse
     * @return PlanObjekt
     */
    @GET
    @Path("/stundenplanurl/{klasse}")
    public PlanObject getStundenplan(@PathParam("klasse") String kl) {        
        Log.d("Get Stundenplan von Klasse " + kl);        
        return StundenplanUtil.getInstance().getPlanObject(kl,PlanType.STDPlanSchueler);
    }

    /**
     * Stundenplan eines Lehrer abfragen
     * @param lehrerName Name des Lehrers 
     * @return HTML Code des Stundenplans
     */
    @GET
    @Path("/stundenplanlehrer/{lehrerName}")
    @Produces("text/html")
    public String getLehrerStundenplanHtml(@PathParam("lehrerName") String lehrerName) {
        Log.d("Get Stundenplan HTML für Lehrer " + lehrerName);
        return StundenplanUtil.getInstance().getPlan(lehrerName,PlanType.STDPlanLehrer);
    }
    
    /**
     * Stundenplan eines Lehrer abfragen
     * @param lehrerName Name des Lehrers 
     * @return HTML Code des Stundenplans
     */
    @GET
    @Path("/stundenplanlehrer/{kw}/{lehrerName}")
    @Produces("text/html")
    public String getLehrerStundenplanHtml(@PathParam("kw") int kw,@PathParam("lehrerName") String lehrerName) {
        Log.d("Get Stundenplan HTML für Lehrer " + lehrerName+" kw="+kw);
        return StundenplanUtil.getInstance().getPlan(kw,lehrerName,PlanType.STDPlanLehrer);
    }

    /**
     * Vertertungsplan eines Lehrer Abfragen
     * @param lehrerName Name des Lehrers 
     * @return HTML Code des Vertertungsplans
     */
    @GET
    @Path("/vertretungsplanlehrer/{lehrerName}")
    @Produces("text/html")
    public String getLehrerVertretungsplanHtml(@PathParam("lehrerName") String lehrerName) {
        Log.d("Get Vertretungsplan HTML für Lehrer " + lehrerName);
        return StundenplanUtil.getInstance().getPlan(lehrerName,PlanType.VERTRPlanLehrer);
    } 
    

    /**
     * Stundenplan einer Klasse abfragen
     * @param kl Name der Klasse
     * @return HTML Code des Stundenplans
     */
    @GET
    @Path("/stundenplan/{klasse}")
    @Produces("text/html")
    public String getStundenplanHtml(@PathParam("klasse") String kl) {
        Log.d("Get Stundenplan HTML von Klasse " + kl);
        return StundenplanUtil.getInstance().getPlan(kl,PlanType.STDPlanSchueler);
    }

     /**
     * Stundenplan einer Klasse abfragen
     * @param kw Kalender Woche
     * @param kl Name der Klasse
     * @return HTML Code des Stundenplans
     */
    @GET
    @Path("/stundenplan/{kw}/{klasse}")
    @Produces("text/html")
    public String getStundenplanHtml(@PathParam("kw") int kw,@PathParam("klasse") String kl) {
        Log.d("Get Stundenplan HTML von Klasse " + kl+" für kw="+kw);
        return StundenplanUtil.getInstance().getPlan(kw,kl,PlanType.STDPlanSchueler);
    }

    /**
     * Vertertungsplan URL einer Klasse Abfragen
     * @param kl Name der Klasse
     * @return PlanObjekt
     */
    @GET
    @Path("/vertertungsplanurl/{klasse}")
    public PlanObject getVertretungsplan(@PathParam("klasse") String kl) {
        return StundenplanUtil.getInstance().getPlanObject(kl,PlanType.VERTRPlanSchueler);
    }

    /**
     * Vertretungsplan einer Klasse Abfragen
     * @param kl Name der Klasse
     * @return HTML Code des Vertertungsplans
     */
    @GET
    @Path("/vertertungsplan/{klasse}")
    @Produces("text/html")
    public String getVerterungsplanHtml(@PathParam("klasse") String kl) {
        return StundenplanUtil.getInstance().getPlan(kl,PlanType.VERTRPlanSchueler);        
    }

}
