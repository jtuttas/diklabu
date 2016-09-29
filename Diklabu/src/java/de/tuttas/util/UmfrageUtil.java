/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.util;

import de.tuttas.entities.Antwortskalen;
import de.tuttas.entities.Fragen;
import de.tuttas.entities.Umfrage;
import de.tuttas.restful.Data.AntwortSkalaObjekt;
import de.tuttas.restful.Data.UmfrageResult;
import de.tuttas.restful.UmfagenManager;
import de.tuttas.restful.auth.Authenticator;
import de.tuttas.restful.auth.Roles;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

/**
 *
 * @author Jörg
 */
public class UmfrageUtil {




    public static String getCharUrl(UmfrageResult ur) {
        // http://chart.apis.google.com/chart?cht=p&chs=450x200&chd=t:1,2,3,4&chdl=trifft+nicht+zu|trifft+weniger+zu|trifft+%C3%BCberwiegend+zu|trifft+voll+zu&chco=3366CC|DC3912|FF9900|109618|990099
        String url = "http://chart.apis.google.com/chart?cht=p&chs=450x200&chd=t:";

        for (AntwortSkalaObjekt as : ur.getSkalen()) {
            url += as.getAnzahl() + ",";
        }
        url = url.substring(0, url.length() - 1);
        url += "&chdl=";
        for (AntwortSkalaObjekt as : ur.getSkalen()) {
            try {
                url += URLEncoder.encode(as.getName() + " ("+as.getAnzahl()+")" , "UTF-8")+ "|";
            } catch (UnsupportedEncodingException ex) {
                Logger.getLogger(UmfrageUtil.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        url = url.substring(0, url.length() - 1);
        url += "&chco=3366CC|DC3912|FF9900|109618|990099";
        Log.d("URL = " + url);
        return url;
    }

    public static List<UmfrageResult> getUmfrageResult(EntityManager em, String authToken, int uid, String filter1) {
        String[] klassen = filter1.split(";");

        String qString = "SELECT a.antwortskala,COUNT(a.antwortskala) from Antworten a inner join a.antwortskala aska inner join Teilnehmer t on a.teilnehmer = t inner join Schueler s on s.ID=t.SCHUELERID inner join Schueler_Klasse sk on t.SCHUELERID=sk.ID_SCHUELER inner join Klasse k on sk.ID_KLASSE=k.ID WHERE (";
        for (int i = 0; i < klassen.length; i++) {
            qString += "k.KNAME like '" + klassen[i] + "'";
            if (i != klassen.length - 1) {
                qString += " or ";
            }

        }
        qString += ") and ";
        Log.d("qString=" + qString + "em=" + em);
        em.getEntityManagerFactory().getCache().evictAll();
        List<UmfrageResult> resultList = new ArrayList<UmfrageResult>();
        Umfrage u = em.find(Umfrage.class, uid);
        if (u == null) {
            Log.d("Keine Umfrage mit ID " + uid + " gefunden!");
            return null;
        }
        Authenticator aut = Authenticator.getInstance();
        String user = aut.getUser(authToken);

        if (u.getOWNER() != null && (!u.getOWNER().equals(user) || !aut.getRole(authToken).equals(Roles.toString(Roles.ADMIN)))) {
            Log.d("Keine Berechtigung die Beteiligung an der Umfrage auszuwerten");
            return null;
        }
        for (Fragen f : u.getFragen()) {
            UmfrageResult ur = new UmfrageResult(f.getTITEL(), f.getID_FRAGE());
            Map<Integer, AntwortSkalaObjekt> antworten = new HashMap();
            for (Antwortskalen skalen : f.getAntwortskalen()) {
                antworten.put(skalen.getID(), new AntwortSkalaObjekt(skalen.getNAME(), skalen.getID(), 0));
            }
            //Query q = em.createQuery("select aska.NAME,count(a.antwortskala) from Antworten a inner join a.antwortskala aska inner join Schueler s on a.ID_SCHUELER=s.ID inner join Schueler_Klasse sk on s.id=sk.ID_SCHUELER inner join Klasse k on k.ID=sk.IK_KLASSE Group by a.fragenAntworten");
            Log.d("Frage=" + f);

            Query q = em.createQuery(qString + " t.umfrage.ID_UMFRAGE=" + uid + " and a.fragenAntworten.ID_FRAGE=" + f.getID_FRAGE() + " Group by a.antwortskala");
            List<Object[]> r = q.getResultList();
            Log.d("Fragen/Antworten Query=" + r);
            for (int i = 0; i < r.size(); i++) {
                Object[] ro = r.get(i);
                Antwortskalen a = (Antwortskalen) ro[0];
                Log.d("Die Antwort " + ro[0] + " Wurde " + ro[1] + " mal gewählt!");
                antworten.put(a.getID(), new AntwortSkalaObjekt(a.getNAME(), a.getID().intValue(), (long) ro[1]));
            }

            Iterator it = antworten.entrySet().iterator();
            while (it.hasNext()) {
                Map.Entry pair = (Map.Entry) it.next();
                Log.d(pair.getKey() + " = " + pair.getValue());
                it.remove(); // avoids a ConcurrentModificationException
                ur.getSkalen().add((AntwortSkalaObjekt) pair.getValue());
            }

            resultList.add(ur);
        }
        Log.d("resultList=" + resultList);
        return resultList;
    }

    public static List<UmfrageResult> getComparableResultList(List<UmfrageResult> hg, List<UmfrageResult> vg) {
        List<UmfrageResult> ret = new ArrayList();
        for (UmfrageResult uhr : hg) {
            for (UmfrageResult uvr : vg) {
                if (uhr.getId()==uvr.getId()) {
                    ret.add(uvr);
                }
            }
        }
        return ret;
    }
}
