/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import com.sun.javafx.scene.control.skin.VirtualFlow;
import de.tuttas.entities.Portfolio;
import de.tuttas.entities.Schuljahr;
import de.tuttas.restful.Data.NotenObjekt;
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
        Query query = em.createNamedQuery("findPortfolioEinerKlasse");
        query.setParameter("paramKlassenID", kid);
        List<Portfolio> portfolio = query.getResultList();
        for (Portfolio p : portfolio) {
            Schuljahr sj = em.find(Schuljahr.class, p.getSchuljahr());
            p.setSchuljahrName(sj.getNAME());
        }
        Log.d("Result List:" + portfolio);

        List<PortfolioEintrag> plist = new ArrayList<>();
        PortfolioEintrag pe = new PortfolioEintrag();
        if (portfolio.size() > 0) {
            int oldSchuelerid;
            oldSchuelerid = portfolio.get(0).getID_Schueler();
            for (Portfolio p : portfolio) {
                if (p.getID_Schueler()==oldSchuelerid) {
                    pe.getEintraege().add(p);
                    Log.d("füge hinzu den Eintrag "+p);
                }
                else {
                    plist.add(pe);
                    pe = new PortfolioEintrag();
                    pe.getEintraege().add(p);
                    oldSchuelerid=p.getID_Schueler();
                    Log.d("Neuer Eintrag für id"+oldSchuelerid);
                }
            }
        }
         plist.add(pe);
        return plist;
    }

}
