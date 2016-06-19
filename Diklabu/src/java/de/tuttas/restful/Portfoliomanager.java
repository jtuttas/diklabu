/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;


import de.tuttas.entities.Klasse_all;
import de.tuttas.entities.Noten_all;

import de.tuttas.entities.Schuljahr;
import de.tuttas.restful.Data.NotenObjekt;
import de.tuttas.restful.Data.Portfolio;
import de.tuttas.restful.Data.PortfolioEintrag;
import de.tuttas.util.Log;
import java.util.ArrayList;
import java.util.List;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;

/**
 *
 * @author Jörg
 */
@Path("portfolio")
@Stateless
public class Portfoliomanager {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    /**
     * Portfolio für eine Klasse anzeigen
     *
     * @param kid
     * @return Portfolio
     */
    @GET
    @Path("/{klassenID}")
    public List<PortfolioEintrag> getPortfolio(@PathParam("klassenID") int kid) {
        Log.d("Webservice Portfolio GET: KlassenID=" + kid);
        Query query = em.createNamedQuery("findPortfolio");
        query.setParameter("paramIdKlasse", kid);
        List<Noten_all> noten_all = query.getResultList();
        Log.d("Results List="+noten_all);
               
        List<PortfolioEintrag> plist = new ArrayList<>();
        PortfolioEintrag pe=null;        
        int oldSchuelerid=-1;
        
        for (Noten_all na : noten_all) {                   
            Klasse_all ka = em.find(Klasse_all.class, na.getID_KLASSEN_ALL());            
            if (oldSchuelerid==-1) {
                oldSchuelerid = na.getID_SCHUELER();
                pe = new PortfolioEintrag(na.getID_SCHUELER());
                
            }
            if (oldSchuelerid!=na.getID_SCHUELER()) {
                oldSchuelerid = na.getID_SCHUELER();
                plist.add(pe);
                pe = new PortfolioEintrag(na.getID_SCHUELER());
                
            }
            
            Schuljahr schuljahr = em.find(Schuljahr.class, ka.getID_Schuljahr());
            Portfolio p = new Portfolio(ka.getKNAME(), ka.getTitel(), na.getWERT(), ka.getNotiz(),na.getID_KLASSEN_ALL(),ka.getID_KATEGORIE(),ka.getID_Schuljahr(),schuljahr.getNAME());
            pe.getEintraege().add(p);
        }
        if (pe!=null) plist.add(pe);
        return plist;                
    }

}
