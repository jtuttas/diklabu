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
 *
 * @author Jörg
 */
public class FragenObjekt {
    private List<Integer> antworten;
    private String frage;
    private int id;

    public FragenObjekt() {
        antworten = new ArrayList<>();
    }

    public FragenObjekt(String frage) {
        this.frage = frage;
        antworten = new ArrayList<>();
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getId() {
        return id;
    }

    
    public void setAntworten(List<Integer> antworten) {
        this.antworten = antworten;
    }

    public List<Integer> getAntworten() {
        return antworten;
    }
           


    public String getFrage() {
        return frage;
    }

    public void setFrage(String frage) {
        this.frage = frage;
    }

}
