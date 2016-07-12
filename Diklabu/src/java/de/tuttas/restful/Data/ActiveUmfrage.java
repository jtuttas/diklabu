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
    public ActiveUmfrage(int id, String titel) {
        this.id = id;
        this.titel = titel;
    }

    /**
     * Aktive Umfrage
     * @param id ID der Umfrage
     * @param titel Titel der Umfrage
     * @param active 1=aktiv sonst 0
     */
    public ActiveUmfrage(int id, String titel, int active) {
        this.id = id;
        this.titel = titel;
        this.active = active;
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
