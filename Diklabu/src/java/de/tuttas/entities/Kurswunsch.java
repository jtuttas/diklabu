/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.io.Serializable;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;

/**
 *
 * @author Jörg
 */
@Entity
@NamedQueries({
       @NamedQuery(name = "findKlasseByUserId", query= "select c from Kurswunsch rel JOIN Klasse c ON rel.ID_KURS=c.ID where rel.ID_SCHUELER = :paramId")
})
public class Kurswunsch implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    private Integer ID_SCHUELER;
    private Integer ID_KURS;
    private String PRIORITAET;

    public Kurswunsch() {
    }

    public Kurswunsch(Integer ID_SCHUELER, Integer ID_KURS, String PRIORITAET) {
        System.out.println("Erzeuge Kurswunsch vom Schueler ID="+ID_SCHUELER+" für Kurs="+ID_KURS+" mit Priorität "+PRIORITAET);
        this.ID_SCHUELER = ID_SCHUELER;
        this.ID_KURS = ID_KURS;
        this.PRIORITAET = PRIORITAET;
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
        return "de.tuttas.entities.Kurswunsch[ id_Schueler=" + ID_SCHUELER + " ]";
    }
    
}
