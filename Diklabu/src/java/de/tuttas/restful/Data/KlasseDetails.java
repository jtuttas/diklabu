/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import de.tuttas.entities.Klasse;
import de.tuttas.entities.Lehrer;

/**
 *
 * @author Jörg
 */
public class KlasseDetails {
     private Integer ID;
    private String  ID_LEHRER;
    private String TITEL;
    private String KNAME;
    private String NOTIZ;
    private String LEHRER_NNAME;
    private String LEHRER_VNAME;
    private String LEHRER_TELEFON;
    private String LEHRER_EMAIL;

    public KlasseDetails() {
    }

        
    public KlasseDetails(Klasse k,Lehrer l) {
        this.ID=k.getId();
        this.ID_LEHRER=k.getID_LEHRER();
        this.TITEL=k.getTITEL();
        this.KNAME=k.getKNAME();
        this.NOTIZ=k.getNOTIZ();
        this.LEHRER_EMAIL=l.getEMAIL();
        this.LEHRER_NNAME=l.getNNAME();
        this.LEHRER_TELEFON=l.getTELEFON();
        this.LEHRER_VNAME=l.getVNAME();
    }

    public String getLEHRER_NNAME() {
        return LEHRER_NNAME;
    }

    public void setLEHRER_NNAME(String LEHRER_NNAME) {
        this.LEHRER_NNAME = LEHRER_NNAME;
    }

    public String getLEHRER_VNAME() {
        return LEHRER_VNAME;
    }

    public void setLEHRER_VNAME(String LEHRER_VNAME) {
        this.LEHRER_VNAME = LEHRER_VNAME;
    }

    public String getLEHRER_TELEFON() {
        return LEHRER_TELEFON;
    }

    public void setLEHRER_TELEFON(String LEHRER_TELEFON) {
        this.LEHRER_TELEFON = LEHRER_TELEFON;
    }

    public String getLEHRER_EMAIL() {
        return LEHRER_EMAIL;
    }

    public void setLEHRER_EMAIL(String LEHRER_EMAIL) {
        this.LEHRER_EMAIL = LEHRER_EMAIL;
    }

    
    
    public Integer getID() {
        return ID;
    }

    public void setID(Integer ID) {
        this.ID = ID;
    }

    public String getID_LEHRER() {
        return ID_LEHRER;
    }

    public void setID_LEHRER(String ID_LEHRER) {
        this.ID_LEHRER = ID_LEHRER;
    }

    public String getTITEL() {
        return TITEL;
    }

    public void setTITEL(String TITEL) {
        this.TITEL = TITEL;
    }

    public String getKNAME() {
        return KNAME;
    }

    public void setKNAME(String KNAME) {
        this.KNAME = KNAME;
    }

    public String getNOTIZ() {
        return NOTIZ;
    }

    public void setNOTIZ(String NOTIZ) {
        this.NOTIZ = NOTIZ;
    }
    
    
    
}
