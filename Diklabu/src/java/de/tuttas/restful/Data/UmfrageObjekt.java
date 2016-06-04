/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Jörg
 */
public class UmfrageObjekt {
    
    private List<AntwortSkalaObjekt> antworten;
    private List<FragenObjekt> fragen ;
    private String titel;


    public UmfrageObjekt() {
        fragen = new ArrayList<>();
        antworten = new ArrayList<>();
    }

    public UmfrageObjekt(String titel) {
        this.titel = titel;
        fragen = new ArrayList<>();
        antworten = new ArrayList<>();
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