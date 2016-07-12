/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import java.util.ArrayList;
import java.util.List;
import java.util.Vector;

/**
 * Frage zu einer Umfrage
 * @author Jörg
 */
public class FragenObjekt extends ResultObject{
    private List<Integer> IDantworten;
    private List<String> StringAntworten;
    private String frage;
    private int id;

    public FragenObjekt() {
        IDantworten = new ArrayList<>();
        StringAntworten = new ArrayList<>();
    }

    /**
     * Fragenobjekt erzeugen
     * @param frage Text der Frage
     */
    public FragenObjekt(String frage) {
        this.frage = frage;
        IDantworten = new ArrayList<>();
        StringAntworten = new ArrayList<>();
    }

    public void setStringAntworten(List<String> StringAntworten) {
        this.StringAntworten = StringAntworten;
    }

    public List<String> getStringAntworten() {
        return StringAntworten;
    }

    public void setIDantworten(List<Integer> IDantworten) {
        this.IDantworten = IDantworten;
    }

    public List<Integer> getIDantworten() {
        return IDantworten;
    }
    
    
    public void setId(int id) {
        this.id = id;
    }

    public int getId() {
        return id;
    }
              


    public String getFrage() {
        return frage;
    }

    public void setFrage(String frage) {
        this.frage = frage;
    }

    @Override
    public String toString() {
        return "Frage="+this.getFrage();
    }
    
    

}
