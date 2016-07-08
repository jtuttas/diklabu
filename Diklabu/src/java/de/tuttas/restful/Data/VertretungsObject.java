/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import java.sql.Date;
import java.util.ArrayList;


/**
 *
 * @author Jörg
 */
public class VertretungsObject extends ResultObject {

    private String eingereichtVon;
    private Date eingereichtAm;
    private String absenzLehrer;
    private Date absenzAm;
    private String kommentar;
    
    
    private ArrayList<Vetretungseintrag> eintraege;

    public VertretungsObject() {
    }

    public VertretungsObject(String eingereichtVon, Date eingereichtAm, String absenzLehrer, Date absenzAm) {
        this.eingereichtVon = eingereichtVon;
        this.eingereichtAm = eingereichtAm;
        this.absenzLehrer = absenzLehrer;
        this.absenzAm = absenzAm;
    }

    public void setKommentar(String kommentar) {
        this.kommentar = kommentar;
    }

    public String getKommentar() {
        return kommentar;
    }

    
    public String getEingereichtVon() {
        return eingereichtVon;
    }

    public void setEingereichtVon(String eingereichtVon) {
        this.eingereichtVon = eingereichtVon;
    }

    public Date getEingereichtAm() {
        return eingereichtAm;
    }

    public void setEingereichtAm(Date eingereichtAm) {
        this.eingereichtAm = eingereichtAm;
    }

    public String getAbsenzLehrer() {
        return absenzLehrer;
    }

    public void setAbsenzLehrer(String absenzLehrer) {
        this.absenzLehrer = absenzLehrer;
    }

    public Date getAbsenzAm() {
        return absenzAm;
    }

    public void setAbsenzAm(Date absenzAm) {
        this.absenzAm = absenzAm;
    }

    public ArrayList<Vetretungseintrag> getEintraege() {
        return eintraege;
    }

    public void setEintraege(ArrayList<Vetretungseintrag> eintraege) {
        this.eintraege = eintraege;
    }
    
    
    
    
    
}
