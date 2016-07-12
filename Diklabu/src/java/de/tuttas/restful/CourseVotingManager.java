/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Buchungsfreigabe;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Konfig;
import de.tuttas.entities.Kurswunsch;
import de.tuttas.entities.KurswunschId;
import de.tuttas.entities.Schueler;
import de.tuttas.entities.Schueler_Klasse;
import de.tuttas.restful.Data.PsResultObject;
import de.tuttas.restful.Data.ResultObject;
import de.tuttas.util.Log;
import java.util.List;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;

/**
 * Manager zum Verwalten der Kursbuchung
 * @author Jörg
 */
@Path("coursevoting")
@Stateless
public class CourseVotingManager {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;
    
    /**
     * Einen Kurs zur Kurswahl hinzufügen
     * @param kid die ID des Kurses
     * @return Antwort Objekt mit Nachrichten
     */
    @POST
    @Path("admin/{idklasse}")
    @Produces({"application/json; charset=iso-8859-1"})
    public ResultObject addCourse(@PathParam("idklasse") int kid) {
        Log.d("Kurs zur Kurwahl hinzufügen:" + kid);
        ResultObject ro = new ResultObject();
        Klasse k = em.find(Klasse.class, kid);
        if (k != null) {
            Buchungsfreigabe bf = em.find(Buchungsfreigabe.class, kid);
            if (bf == null) {
                bf = new Buchungsfreigabe(kid);
                em.persist(bf);
                ro.setSuccess(true);
                ro.setMsg("Kurs " + k.getKNAME() + " zur Kurswahl hinzugefügt!");
            } else {
                ro.setSuccess(false);
                ro.setMsg("Kurs " + k.getKNAME() + " bereits in Kurswahl enthalten!");
            }
        } else {
            ro.setSuccess(false);
            ro.setMsg("Kann keinen Kurs mit der ID " + kid + " finden!");
        }
        return ro;
    }
    
    /**
     * Einen Kurs aus der Kurswahl entfernen
     * @param kid ID des Kurses
     * @return Antwort Objekt mit Nachrichten
     */
    @DELETE
    @Path("admin/{idklasse}")
    @Produces({"application/json; charset=iso-8859-1"})
    public PsResultObject deleteCourse(@PathParam("idklasse") int kid
    ) {
        Log.d("Kurs " + kid + " Aus Kurswahl entfernen");
        PsResultObject ro = new PsResultObject();
        Klasse k = em.find(Klasse.class, kid);
        if (k != null) {
            Buchungsfreigabe bf = em.find(Buchungsfreigabe.class, kid);
            if (bf != null) {
                Query query = em.createNamedQuery("findWunschByKlassenId");
                query.setParameter("paramId", kid);
                List<Kurswunsch> wunsche = query.getResultList();
                if (wunsche.size() == 0) {
                    em.remove(bf);
                    ro.setSuccess(true);
                    ro.setMsg("Kurs " + k.getKNAME() + " aus Kurswahl entfernt!");
                } else {
                    ro.setSuccess(false);
                    ro.setMsg("Kurs " + k.getKNAME() + " kann nicht aus Kurswahl entfernt werden, da er bereits gewählt wurde!");
                    int[] ids = new int[wunsche.size()];
                    for (int i = 0; i < wunsche.size(); i++) {
                        ids[i] = wunsche.get(i).getID_SCHUELER();
                    }
                    ro.setIds(ids);
                }
            } else {
                ro.setSuccess(false);
                ro.setMsg("Kann Kurs " + k.getKNAME() + " nicht in der Kurswahl finden!");
            }
        } else {
            ro.setSuccess(false);
            ro.setMsg("Kann Kurs mit id " + kid + " nicht finden!");
        }
        return ro;
    }
    
    /**
     * Kurswahl freischalten (1) oder sperren (0)
     * @param v v=1 Kurswahl freigeschlatet, v=0 Kurswahl gesperrt
     * @return ResultObjekt mit Nachrichten
     */
    @POST
    @Path("admin/voting/{state}")
    @Produces({"application/json; charset=iso-8859-1"})
    public ResultObject enableDisableVoting(@PathParam("state") int v) {
        Log.d("Kurswahl freischalten/sperren = " + v);
        ResultObject ro = new ResultObject();
        Konfig k = em.find(Konfig.class, "kursbuchung");
        k.setSTATUS(v);
        em.merge(k);
        if (v == 1) {
            ro.setMsg("Kurswahl freigeschaltet");
        } else {
            ro.setMsg("Kurswahl gesperrt");
        }
        ro.setSuccess(true);
        return ro;
    }
    
    /**
     * Kurswahl eines Schülers löschen
     * @param sid ID des Schülers
     * @return Egebnis Objekt mit Meldungen
     */
    @DELETE
    @Path("admin/schueler/{idschueler}") 
    @Produces({"application/json; charset=iso-8859-1"})
    public ResultObject deleteCourseVoting(@PathParam("idschueler") int sid) {
        Log.d("Schüler " + sid + " Kurswunsch zurück setzten");
        ResultObject ro = new ResultObject();
        Query query = em.createNamedQuery("findWunschBySchuelerId");
        query.setParameter("paramId", sid);
        List<Kurswunsch> wunsche = query.getResultList();
        for (Kurswunsch kw : wunsche) {
            em.remove(kw);
        }
        ro.setMsg("Kurswüsche entfernt");
        ro.setSuccess(true);
        return ro;
    }
    
    /**
     * Alle Kurswünsche löschen
     * @return Ergebnisobjekt mit Meldungen
     */
     @DELETE
    @Path("admin/")
    @Produces({"application/json; charset=iso-8859-1"})
    public ResultObject deleteCourseVotings() {
        Log.d("Alle Kurswünsch zurück setzten");
        ResultObject ro = new ResultObject();
        Query q3 = em.createNativeQuery("DELETE FROM Kurswunsch");
        q3.executeUpdate();
        
        ro.setMsg("Alle Kurswüsche entfernt");
        ro.setSuccess(true);
        return ro;
    }
    
    /**
     * Abfrage der Kurswahl
     * @param kid ID des Kurses
     * @param prio Priorität des Wunsches
     * @param gebucht Filter gebucht=true, es werden nur gebuchte Kurse gelistet, sonst alle Kurse
     * @return Liste der Schüler die den Kurs gewählt haben
     */
    @GET
    @Path("{klassenid}/{prio}/{gebucht}")
    @Produces({"application/json; charset=iso-8859-1"})
    public List<Schueler> getVotings(@PathParam("klassenid") int kid,@PathParam("prio") String prio,@PathParam("gebucht") String gebucht) {
        
        Query query = em.createNamedQuery("findWunschByKlasseAndPrio");
        query.setParameter("paramId", kid);
        query.setParameter("paramPrio", prio);
        if (gebucht.equals("True")) query.setParameter("paramGebucht", "1");
        else query.setParameter("paramGebucht", "0");
        List<Schueler> schueler = query.getResultList();
        return schueler;
    }
    
    /**
     * Liste alle Kurse die zur Wahl stehen
     * @return Liste mit Klassen die zur Kurswahl stehen
     */
    @GET
    @Produces({"application/json; charset=iso-8859-1"})
    public List<Klasse> listVotings() {        
        Query query = em.createNamedQuery("findBuchungsfreigabe");
        List<Klasse> klassen = query.getResultList();
        return klassen;
    }
    
    /**
     * Kurswunsch eines Schülers setzen
     * @param kw Das Kurswunsch Objekt
     * @return Ergebnisobjekt mit Meldungen
     */
    @POST
    @Path("admin/schueler/")
    @Produces({"application/json; charset=iso-8859-1"})
    public ResultObject setVoting(Kurswunsch kw) {
        Log.d("setzte Kurswunsch = " + kw);
        ResultObject ro = new ResultObject();
        Schueler s = em.find(Schueler.class, kw.getID_SCHUELER());
        if (s!=null) {
            Klasse k = em.find(Klasse.class, kw.getID_KURS());
            Log.d("Klasse ist:"+k);
            if (k!=null) {
                Kurswunsch sk = em.find(Kurswunsch.class, new KurswunschId(kw.getID_SCHUELER(),kw.getID_KURS()));
                if (sk==null) {
                    em.persist(kw);
                    em.flush();
                    ro.setSuccess(true);
                    ro.setMsg("Schüler "+s.getVNAME()+" "+s.getNNAME()+" hat Kurs '"+k.getTITEL()+"' mit Priorität "+kw.getPRIORITAET()+" gewählt");
                }
                else {
                    ro.setSuccess(false);
                    ro.setMsg("Schüler "+s.getVNAME()+" "+s.getNNAME()+" hatte bereits Kurs '"+k.getTITEL()+"' gewählt");                    
                }
            }
            else {
                ro.setMsg("Kann Klasse mit id "+kw.getID_KURS()+" nicht finden!");
                ro.setSuccess(false);                                
            }
        }
        else {
            ro.setMsg("Kann Schüler mit id "+kw.getID_SCHUELER()+" nicht finden!");
            ro.setSuccess(false);
        }
                
        return ro;
    }
    
    /**
     * Kurswünsche als gebucht vermerken
     * @param sid ID des Schülers
     * @return Ergebnisobjekt mit Medlungen
     */
    @PUT
    @Path("admin/schueler/{idschueler}")
    @Produces({"application/json; charset=iso-8859-1"})
    public ResultObject changeVoting(@PathParam("idschueler") int sid) {
        Log.d("Gebucht Kurswunsch für = " + sid);
        ResultObject ro = new ResultObject();
        Query query = em.createNamedQuery("findWunschBySchuelerId");
        query.setParameter("paramId", sid);
        List<Kurswunsch> wunsche = query.getResultList();
        if (wunsche.size()!=0) {
            for (Kurswunsch kw : wunsche) {
                kw.setGEBUCHT("1");
                em.merge(kw);
            }
            ro.setMsg("Kurswüsche als gebucht vermerkt");
            ro.setSuccess(true);
        }
        else {
            ro.setMsg("Kann keine Kurswünsche f. Schüler mit id "+sid+" finden!");
            ro.setSuccess(false);
            
        }
        return ro;
    }
}
