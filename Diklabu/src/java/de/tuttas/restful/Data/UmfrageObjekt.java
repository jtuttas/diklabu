/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * Umfrage
 * @author Jörg
 */
public class UmfrageObjekt extends ResultObject{
    
    private int id;
    private List<AntwortSkalaObjekt> antworten;
    private List<FragenObjekt> fragen ;
    private String titel;
    private Integer active;


    public UmfrageObjekt() {
        fragen = new ArrayList<>();
        antworten = new ArrayList<>();
    }

    /**
     * Neues Umfrage Objekt erzeugen
     * @param titel Titel der Umfrage
     */
    public UmfrageObjekt(String titel) {
        this.titel = titel;
        fragen = new ArrayList<>();
        antworten = new ArrayList<>();
    }

    public void setActive(Integer active) {
        this.active = active;
    }

    public Integer getActive() {
        return active;
    }

    
    
    public void setId(int id) {
        this.id = id;
    }

    public int getId() {
        return id;
    }
 
    
    
    public List<FragenObjekt> getFragen() {
        return fragen;
    }

    public List<AntwortSkalaObjekt> getAntworten() {
        return antworten;
    }

    public void setAntworten(List<AntwortSkalaObjekt> antworten) {
        this.antworten = antworten;
    }
        
    public void setFragen(List<FragenObjekt> fragen) {
        this.fragen = fragen;
    }

    public String getTitel() {
        return titel;
    }

    public void setTitel(String titel) {
        this.titel = titel;
    }
    
    
    
    
    
}