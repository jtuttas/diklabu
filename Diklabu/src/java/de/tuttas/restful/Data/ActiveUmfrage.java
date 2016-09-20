/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

/**
 * Klasse für eine Aktive Umfrage
 * @author Jörg
 */
public class ActiveUmfrage {

    private int id;
    private String titel;
    private int active;
    private String owner;

    /**
     * Aktive Umfrage erzeugen
     */
    public ActiveUmfrage() {
    }

    /**
     * Aktive Umfrage 
     * @param id ID der Umfrage
     * @param titel Titel der Umfrage
     */
    public ActiveUmfrage(int id, String titel,String owner) {
        this.id = id;
        this.titel = titel;
        this.owner = owner;
    }

    /**
     * Aktive Umfrage
     * @param id ID der Umfrage
     * @param titel Titel der Umfrage
     * @param active 1=aktiv sonst 0
     */
    public ActiveUmfrage(int id, String titel, int active,String owner) {
        this.id = id;
        this.titel = titel;
        this.active = active;
        this.owner=owner;
    }

    public void setOwner(String owner) {
        this.owner = owner;
    }

    public String getOwner() {
        return owner;
    }
    
    
    

    public void setActive(int active) {
        this.active = active;
    }

    public int getActive() {
        return active;
    }
    
    

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTitel() {
        return titel;
    }

    public void setTitel(String titel) {
        this.titel = titel;
    }
    
    
}
