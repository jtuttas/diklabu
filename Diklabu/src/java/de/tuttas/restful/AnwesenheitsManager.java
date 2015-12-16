/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Anwesenheit;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Schueler;
import de.tuttas.restful.Data.AnwesenheitEintrag;
import de.tuttas.restful.Data.AnwesenheitObjekt;
import java.sql.Date;
import java.sql.Timestamp;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;

import java.util.GregorianCalendar;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;

/**
 *
 * @author Jörg
 */
@Path("anwesenheit")
@Stateless
public class AnwesenheitsManager {
        /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName="DiklabuPU")
    EntityManager em;
    
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
        Date d2 = new Date(cal.getTimeInMillis()+(1000*60*60*24));
        
        
       System.out.println ("Webservice Anwesenheit GET from Date="+d1.toString()+" To "+d2.toString()+" klasse="+kl);        
        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbyKlasse",AnwesenheitEintrag.class);        
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", d1);
        query.setParameter("paramToDate", d2);
        return getData(query);        
    }
    
    @GET   
    @Path("/{klasse}/{from}")
    public List<AnwesenheitObjekt> getAnwesenheitFrom(@PathParam("klasse") String kl,@PathParam("from") Date  from ) {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        Date d = new Date(cal.getTimeInMillis());      
        System.out.println ("Webservice Anwesenheit GET klasse="+kl+" from="+from+" to="+d);        
        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbyKlasse",AnwesenheitEintrag.class);        
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", from);
        query.setParameter("paramToDate", d);
        return getData(query);        
    }
    
    
    @GET   
    @Path("/{klasse}/{from}/{to}")
    public List<AnwesenheitObjekt> getAnwesenheitFrom(@PathParam("klasse") String kl,@PathParam("from") Date from,@PathParam("to") Date to ) {
        
        System.out.println ("Webservice Anwesenheit GET from="+from+" to="+to);        
        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbyKlasse",AnwesenheitEintrag.class);        
        query.setParameter("paramKName", kl);
        query.setParameter("paramFromDate", from);
        query.setParameter("paramToDate", to);
        return getData(query);        
    }
    
    private List<AnwesenheitObjekt> getData(TypedQuery query) {
        List<AnwesenheitEintrag> anwesenheit = query.getResultList();
        //System.out.println("Results:="+anwesenheit);
        List<AnwesenheitObjekt> anw = new ArrayList();
        int id=0;
        AnwesenheitObjekt ao = new AnwesenheitObjekt();
        for (int i=0;i<anwesenheit.size();i++) {
            if (anwesenheit.get(i).getID_SCHUELER()!=id) {
                id=anwesenheit.get(i).getID_SCHUELER();
                ao = new AnwesenheitObjekt(id);
                anw.add(ao);
            }
            ao.getEintraege().add(anwesenheit.get(i));
        }
        return anw;  
    }
    
}
