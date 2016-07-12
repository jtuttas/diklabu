/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

/**
 * Antwort auf eine Umfrage
 * @author Jörg
 */
public class AntwortUmfrage {
    private String key;
    private int idFrage;
    private String frage;
    private int idAntwort;
    private String antwort;
    private String msg;
    private boolean success;
    
    public AntwortUmfrage() {
    }

    /**
     * Antwort eines Teilnehmers auf eine Umfrage
     * @param key KEY des Teilnehmers
     * @param idFrage ID der Frage
     * @param frage Text der Frage
     * @param idAntwort ID der Antwortskala
     * @param antwort  Text der Antwortskala
     */
    public AntwortUmfrage(String key, int idFrage, String frage, int idAntwort, String antwort) {
        this.key = key;
        this.idFrage = idFrage;
        this.frage = frage;
        this.idAntwort = idAntwort;
        this.antwort = antwort;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public String getMsg() {
        return msg;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public boolean getSuccess() {
        return this.success;
    }
    

    public void setKey(String key) {
        this.key = key;
    }

    public String getKey() {
        return key;
    }

   

    public int getIdFrage() {
        return idFrage;
    }

    public void setIdFrage(int idFrage) {
        this.idFrage = idFrage;
    }

    public String getFrage() {
        return frage;
    }

    public void setFrage(String frage) {
        this.frage = frage;
    }

    public int getIdAntwort() {
        return idAntwort;
    }

    public void setIdAntwort(int idAntwort) {
        this.idAntwort = idAntwort;
    }

    public String getAntwort() {
        return antwort;
    }

    public void setAntwort(String antwort) {
        this.antwort = antwort;
    }
    
    
}
