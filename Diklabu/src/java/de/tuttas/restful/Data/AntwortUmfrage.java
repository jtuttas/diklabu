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
public class AntwortUmfrage {
    private int idSchueler;
    private int idFrage;
    private String frage;
    private int idAntwort;
    private String antwort;
    private int idUmfrage;

    public AntwortUmfrage() {
    }

    public AntwortUmfrage(int idSchueler, int idFrage, String frage, int idAntwort, String antwort) {
        this.idSchueler = idSchueler;
        this.idFrage = idFrage;
        this.frage = frage;
        this.idAntwort = idAntwort;
        this.antwort = antwort;
    }

    public void setIdUmfrage(int idUmfrage) {
        this.idUmfrage = idUmfrage;
    }

    public int getIdUmfrage() {
        return idUmfrage;
    }

    
    public int getIdSchueler() {
        return idSchueler;
    }

    public void setIdSchueler(int idSchueler) {
        this.idSchueler = idSchueler;
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
