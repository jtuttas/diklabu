/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import de.tuttas.util.Log;
import java.io.Serializable;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;

/**
 * Relations Entity zwischen SCHUELER und Klasse (Kurs)
 * @author Jörg
 */
@Entity
@NamedQueries({
    // Finden der Kurswünsche eines Schülers   
    @NamedQuery(name = "findKlasseByUserId", query= "select c from Kurswunsch rel JOIN Klasse c ON rel.ID_KURS=c.ID where rel.ID_SCHUELER = :paramId ORDER BY rel.PRIORITAET"),
    @NamedQuery(name = "findWunschByKlassenId", query= "select c from Kurswunsch c where c.ID_KURS = :paramId"),
    @NamedQuery(name = "findWunschBySchuelerId", query= "select c from Kurswunsch c where c.ID_SCHUELER = :paramId"),  
    @NamedQuery(name = "findWunschByKlasseAndPrio", query= "select s from Schueler s Join Kurswunsch kw on s.ID=kw.ID_SCHUELER where kw.ID_KURS = :paramId and kw.PRIORITAET = :paramPrio and kw.GEBUCHT = :paramGebucht")
})
@IdClass(KurswunschId.class)
public class Kurswunsch implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id    
    private Integer ID_SCHUELER;    
    @Id
    private Integer ID_KURS;
    /**
     * Mit dieser Priorität
     */
    private String PRIORITAET;
    private String GEBUCHT;

    public Kurswunsch() {
    }

    /**
     * Konstruktor
     * @param ID_SCHUELER ID des Schülers 
     * @param ID_KURS ID des Kurses
     * @param PRIORITAET  Priorität
     * @param GEBUCHT  GEBUCHT
     */
    public Kurswunsch(Integer ID_SCHUELER, Integer ID_KURS, String PRIORITAET, String GEBUCHT) {
        Log.d("Erzeuge Kurswunsch vom Schueler ID="+ID_SCHUELER+" für Kurs="+ID_KURS+" mit Priorität "+PRIORITAET);
        this.ID_SCHUELER = ID_SCHUELER;
        this.ID_KURS = ID_KURS;
        this.PRIORITAET = PRIORITAET;
        this.GEBUCHT=GEBUCHT;
    }

    public void setGEBUCHT(String GEBUCHT) {
        this.GEBUCHT = GEBUCHT;
    }

    public String getGEBUCHT() {
        return GEBUCHT;
    }
        
    
    public void setID_KURS(Integer ID_KURS) {
        this.ID_KURS = ID_KURS;
    }

    public Integer getID_KURS() {
        return ID_KURS;
    }

    public void setID_SCHUELER(Integer ID_SCHUELER) {
        this.ID_SCHUELER = ID_SCHUELER;
    }

    public Integer getID_SCHUELER() {
        return ID_SCHUELER;
    }

    public void setPRIORITAET(String PRIORITAET) {
        this.PRIORITAET = PRIORITAET;
    }

    public String getPRIORITAET() {
        return PRIORITAET;
    }            

    @Override
    public String toString() {
        return "de.tuttas.entities.Kurswunsch[ id_Schueler=" + ID_SCHUELER + " id_kurs="+ID_KURS+"]";
    }
    
}
