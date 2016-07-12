/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

/**
 *
 * @author Jörg
 */
public class AntwortSkalaObjekt {
    private String name;
    private int id;
    private long anzahl;

    /**
     * Antwortskalen Objekt erzeugen
     * @param name Name der Antwortmöglichkeit
     * @param id ID der Antwortmöglichkeit
     * @param anzahl ??
     */
    public AntwortSkalaObjekt(String name, int id, long anzahl) {
        this.name = name;
        this.id = id;
        this.anzahl = anzahl;
    }

    public AntwortSkalaObjekt() {
    }
        

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public long getAnzahl() {
        return anzahl;
    }

    public void setAnzahl(long anzahl) {
        this.anzahl = anzahl;
    }
    
    
}
