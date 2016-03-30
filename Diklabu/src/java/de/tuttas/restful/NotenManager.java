/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Noten;
import de.tuttas.entities.Schueler;
import de.tuttas.restful.Data.NotenObjekt;
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
@Path("noten")
@Stateless
public class NotenManager {
    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    /**
     * Noten einer Klasse abfragen, sortiert nach Schüler ID und LF
     * @param kl Bezeichnung der Klasse
     * @return Liste der Noten
     */

    @GET
    @Path("/{klasse}")
    public List<NotenObjekt> getNoten(@PathParam("klasse") String kl) {
        Log.d("Webservice noten GET: klasse=" + kl);
        Query query = em.createNamedQuery("findNoteneinerKlasse");
        query.setParameter("paramNameKlasse", kl);
        List<Noten> noten = query.getResultList();
        Log.d("Result List:" + noten);
        List<NotenObjekt> lno = new ArrayList<>();
        int sid=0;
        NotenObjekt no=null;
        for (Noten n : noten) {
            if (sid!=n.getID_SCHUELER()) {
                no=new NotenObjekt();
                no.setSchuelerID(n.getID_SCHUELER());
                no.setSuccess(true);
                lno.add(no);
                sid=n.getID_SCHUELER();
            }
            no.getNoten().add(n);
        }        
        System.out.println("lno="+lno);
        return lno;
    }

    
    /**
     * Noten eines Schülers abfragen
     * @param sid ID des Schülers
     * @return Notenobjekt
     */
    @GET
    @Path("/schueler/{schuelerID}")
    public NotenObjekt getNoten(@PathParam("schuelerID") int sid) {
        Log.d("Webservice noten GET: schuelerID=" + sid);
        Query query = em.createNamedQuery("findNoteneinesSchuelers");
        query.setParameter("paramNameSchuelerID", sid);
        List<Noten> noten = query.getResultList();
        Log.d("Result List:" + noten);
        NotenObjekt no = new NotenObjekt();
        no.setSchuelerID(sid);
        no.setNoten(noten);
        no.setSuccess(true);
        return no;
    }
    
}
