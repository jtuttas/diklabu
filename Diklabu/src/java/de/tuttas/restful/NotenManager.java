/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.Kategorie;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Klasse_all;
import de.tuttas.entities.Lehrer;
import de.tuttas.entities.Lernfeld;
import de.tuttas.entities.Noten;
import de.tuttas.entities.Noten_Id;
import de.tuttas.entities.Noten_all;
import de.tuttas.entities.Noten_all_Id;

import de.tuttas.entities.Schueler;
import de.tuttas.entities.Schueler_Klasse;
import de.tuttas.entities.Schueler_KlasseId;
import de.tuttas.entities.Schuljahr;
import de.tuttas.entities.Verlauf;
import de.tuttas.restful.Data.NotenObjekt;
import de.tuttas.restful.Data.ResultObject;
import de.tuttas.util.Log;
import de.tuttas.util.NotenUtil;
import java.sql.Date;
import java.util.ArrayList;
import java.util.GregorianCalendar;
import java.util.List;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;

/**
 * Werbservice zum Verwalten der Noten
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
     * @param kl Name der Klasse
     * @param ids ID des Schuljahres
     * @return Liste von Notenobjekten
     */
    @GET
    @Path("/{klasse}/{IDSchuljahr}")
    public List<NotenObjekt> getNoten(@PathParam("klasse") String kl, @PathParam("IDSchuljahr") int ids) {
        em.getEntityManagerFactory().getCache().evictAll();
        Log.d("Webservice noten GET: klasse=" + kl + " für Schuljahr ID=" + ids);
        Query query = em.createNamedQuery("findNoteneinerKlasse");
        query.setParameter("paramNameKlasse", kl);
        query.setParameter("paramIDSchuljahr", ids);
        List<Noten_all> noten = query.getResultList();
        Log.d("Result List:" + noten);
        List<NotenObjekt> lno = new ArrayList<>();
        int sid = 0;
        NotenObjekt no = null;
        for (Noten_all n : noten) {
            if (sid != n.getID_SCHUELER()) {
                no = new NotenObjekt();
                no.setSchuelerID(n.getID_SCHUELER());
                no.setSuccess(true);
                lno.add(no);
                sid = n.getID_SCHUELER();
            }
            n.setNameLernfeld(em.find(Lernfeld.class, n.getID_LERNFELD()).getBEZEICHNUNG());
            no.getNoten().add(n);
        }
        Log.d("lno=" + lno);
        return lno;
    }

    /**
     * Noten eines Schülers abfragen
     * @param sid ID des Schülers
     * @param ids ID des Schuljahres
     * @return Notenobjekt
     */
    @GET
    @Path("/schueler/{schuelerID}/{IDSchuljahr}")
    public NotenObjekt getNoten(@PathParam("schuelerID") int sid, @PathParam("IDSchuljahr") int ids) {
        Log.d("Webservice noten GET: schuelerID=" + sid + " Schuljahr ID=" + ids);
        Query query = em.createNamedQuery("findNoteneinesSchuelers");
        query.setParameter("paramNameSchuelerID", sid);
        query.setParameter("paramIDSchuljahr", ids);
        List<Noten_all> noten = query.getResultList();
        Log.d("Result List:" + noten);
        NotenObjekt no = new NotenObjekt();
        no.setSchuelerID(sid);
        no.setNoten(noten);
        no.setSuccess(true);
        return no;
    }

    
    /**
     * Einen Noteneintrag löschen
     * @param lfid ID der Lernfeldes
     * @param sid ID des Schülers
     * @return Ergebnisobjekt mit Meldungen
     */
    @DELETE
    @Path("/{lfid}/{sid}") 
    public ResultObject deleteNote(@PathParam("lfid") String lfid, @PathParam("sid") int sid) {
        ResultObject ro = new ResultObject();
        Schueler s = em.find(Schueler.class, sid);
        if (s!=null) {
            Lernfeld lf = em.find(Lernfeld.class, lfid);
            if (lf!=null) {
                Noten n = em.find(Noten.class, new Noten_Id(sid, lfid));
                if (n!=null) {
                    em.remove(n);
                    em.flush();
                     Query query = em.createNamedQuery("getLatestSchuljahr").setMaxResults(1);
                     List<Schuljahr> jahre = query.getResultList();
                    int jahrid = jahre.get(0).getID();
                    
                    Noten_all na = em.find(Noten_all.class, new Noten_all_Id(sid, lfid, jahrid));
                    em.remove(na);
                    em.flush();
                    ro.setSuccess(true);
                    ro.setMsg("Note für Schüler "+s.getVNAME()+" "+s.getNNAME()+" für Lernfeld "+lf.getBEZEICHNUNG()+" gelöscht!");
                }
                else {
                    ro.setSuccess(false);
                    ro.setMsg("Kann Note für Schüler "+s.getVNAME()+" "+s.getNNAME()+" für Lernfeld "+lf.getBEZEICHNUNG()+" nicht finden!");
                }
            }
            else {
                ro.setSuccess(false);
                ro.setMsg("Kann Lernfeld mit ID="+lfid+" nicht finden!");
            }
        }
        else {
            ro.setSuccess(false);
            ro.setMsg("Kann Schüler mit ID="+sid+" nicht finden!");
        }
        return ro;
    }
    
    /**
     * Noten eintragen
     * @param kid ID der Klasse
     * @param n Notenobjekt
     * @return  Notenobjekt 
     */
    @POST
    @Path("/{id}")
    public Noten addNote(@PathParam("id") int kid, Noten n) {
        em.getEntityManagerFactory().getCache().evictAll();

        Klasse k = em.find(Klasse.class, kid);
        Log.d("POST Note = " + n.toString() + " für Klasse id=" + kid + "Klasse=" + k);
        if (k != null) {
            Kategorie ka = em.find(Kategorie.class, k.getID_KATEGORIE());
            Log.d("Kategorie = " + ka);
            if (NotenUtil.gradeAllowed4Course(n,ka)) {
                List<Noten> noten=null;
                Query q = em.createNamedQuery("findNote");
                q.setParameter("paramSchuelerID", n.getID_SCHUELER());
                q.setParameter("paramLernfeldID", n.getID_LERNFELD());
                noten = q.getResultList();
                
                Log.d("Result List:" + noten);
                if (noten.size() != 0) {
                    for (Noten no : noten) {
                        if (no.getID_LERNFELD().compareTo(n.getID_LERNFELD()) == 0
                                && no.getID_SCHUELER().intValue() == n.getID_SCHUELER().intValue()
                                && no.getID_LK().compareTo(n.getID_LK()) == 0) {
                            Log.d("Es existier bereits ein Eintrag also Update");
                            no.setWERT(n.getWERT());
                            em.merge(no);
                            em.flush();
                            no.setSuccess(true);
                            no.setMsg("Eintrag aktualisiert!");
                            // Klasse noch eintragen
                            Schueler s = em.find(Schueler.class, n.getID_SCHUELER().intValue());
                            Lernfeld lf = em.find(Lernfeld.class, n.getID_LERNFELD());
                            // Klasse noch eintragen
                            Query q3 = em.createNamedQuery("getLatestSchuljahr").setMaxResults(1);
                            List<Schuljahr> schuljahr = q3.getResultList();
                            Log.d("Schuljahr = " + schuljahr);

                            Log.d(" Finde Note mit ID_Schueler=" + s.getId() + " LF_ID=" + lf.getId() + " Schuljahr=" + schuljahr.get(0).getID());
                            Noten_all na = em.find(Noten_all.class, new Noten_all_Id(s.getId(), lf.getId(), schuljahr.get(0).getID()));
                            if (na == null) {
                                Log.d("Kein Eintrag gefunden!");

                            } else {
                                Log.d("Eintrag gefunden!");
                                // findKlasseEinesJahrgangs
                                na.setID_LK(n.getID_LK());
                                na.setWERT(n.getWERT());
                                em.merge(na);
                            }
                            return no;
                        }
                    }
                    n.setSuccess(false);
                    n.setMsg("Es können nur eigene Noteneinträge geändert werden!");
                    return n;
                } else {
                    Schueler s = em.find(Schueler.class, n.getID_SCHUELER().intValue());
                    Lehrer l = em.find(Lehrer.class, n.getID_LK());
                    Lernfeld lf = em.find(Lernfeld.class, n.getID_LERNFELD());
                    if (s != null && l != null && lf != null) {
                        Log.d("Neuen Noteneintrag erzeugen");
                        em.persist(n);
                        em.flush();

                        n.setSuccess(true);

                        // Klasse noch eintragen
                        Query q3 = em.createNamedQuery("getLatestSchuljahr").setMaxResults(1);
                        List<Schuljahr> schuljahr = q3.getResultList();
                        Log.d("Schuljahr = " + schuljahr);

                        Log.d(" Finde Note mit ID_Schueler=" + s.getId() + " LF_ID=" + lf.getId() + " Schuljahr=" + schuljahr.get(0).getID());
                        Noten_all na = em.find(Noten_all.class, new Noten_all_Id(s.getId(), lf.getId(), schuljahr.get(0).getID()));
                        if (na == null) {
                            Log.d("Kein Eintrag gefunden!");

                        } else {
                            Log.d("Eintrag gefunden!");
                            // findKlasseEinesJahrgangs
                            Query q4 = em.createNamedQuery("findKlasseEinesJahrgangs");
                            q4.setParameter("paramIdSchuljahr", schuljahr.get(0).getID());
                            q4.setParameter("paramIdKlasse", kid);
                            List<Klasse_all> kla = q4.getResultList();
                            Log.d("Klasse all = " + kla);
                            if (kla.size()>0) {
                                na.setID_KLASSEN_ALL(kla.get(0).getID());
                                em.merge(na);
                            }
                            else {
                                Log.d("Kann Klasse ID="+kid+" nicht im Schuljahr "+schuljahr.get(0).getNAME()+" finden!");
                            }
                        }

                        n.setSuccess(true);
                        n.setMsg("Neuer Noteneintrag erfolgt!");

                    } else {
                        Log.d("Neuen Noteneintrag konnte nicht erzeugt werden");
                        n.setSuccess(false);
                        n.setMsg("Neuer Noteneintrag konnte nicht erzeugt werden!");
                    }
                }
            } else {
                n.setSuccess(false);
                n.setMsg("Notentyp kann nicht in einem Kurs der Kategorie "+ka.getKATEGORIE()+" eingetragen werden!");
            }
        } else {
            n.setSuccess(false);
            n.setMsg("Kann Klasse mit ID " + kid + " nicht finden!");
        }
        return n;
    }
}
