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
public class UmfrageResult {
    private String frage;
    private int id;
    private List<AntwortSkalaObjekt>skalen = new ArrayList<>();

    public UmfrageResult() {
    }

    public UmfrageResult(String frage,int id) {
        this.frage = frage;
        this.id=id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getId() {
        return id;
    }

    
    public void setFrage(String frage) {
        this.frage = frage;
    }

    public String getFrage() {
        return frage;
    }

    public void setSkalen(List<AntwortSkalaObjekt> skalen) {
        this.skalen = skalen;
    }

    public List<AntwortSkalaObjekt> getSkalen() {
        return skalen;
    }
}
