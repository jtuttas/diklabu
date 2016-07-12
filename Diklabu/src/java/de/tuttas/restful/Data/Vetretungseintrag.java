/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import org.json.simple.JSONObject;

/**
 * Vertertungsvorschlag für absenten Kollegen
 * @author Jörg
 */
public class Vetretungseintrag {
    private int stunde;
    private String klasse;
    private int idKlasse;
    private String aktion;
    private String vertreter;
    private String kommentar;

    public Vetretungseintrag() {
    }

    /**
     * Vertertungsvorschlag erzeugen
     * @param stunde Stunde 
     * @param Klasse name der Klasse
     * @param idKlasse ID der Klasse
     * @param aktion entfällt, Vertertung, Betreuung
     * @param vertreter Kürzel des Vertretenden Kollegen
     * @param kommentar  ggf. Kommentar (zieht vor etc.)
     */
    public Vetretungseintrag(int stunde, String Klasse, int idKlasse, String aktion, String vertreter, String kommentar) {
        this.stunde = stunde;
        this.klasse = Klasse;
        this.idKlasse = idKlasse;
        this.aktion = aktion;
        this.vertreter = vertreter;
        this.kommentar = kommentar;
    }

    public int getStunde() {
        return stunde;
    }

    public void setStunde(int stunde) {
        this.stunde = stunde;
    }

    public String getKlasse() {
        return klasse;
    }

    public void setKlasse(String Klasse) {
        this.klasse = Klasse;
    }

    public int getIdKlasse() {
        return idKlasse;
    }

    public void setIdKlasse(int idKlasse) {
        this.idKlasse = idKlasse;
    }

    public String getAktion() {
        return aktion;
    }

    public void setAktion(String aktion) {
        this.aktion = aktion;
    }

    public String getVertreter() {
        return vertreter;
    }

    public void setVertreter(String vertreter) {
        this.vertreter = vertreter;
    }

    public String getKommentar() {
        return kommentar;
    }

    public void setKommentar(String kommentar) {
        this.kommentar = kommentar;
    }

    public JSONObject toJson() {
        JSONObject jo = new JSONObject();
        jo.put("stunde", stunde);
        jo.put("Klasse", klasse);
        jo.put("idKlasse", idKlasse);
        jo.put("Aktion", aktion);
        jo.put("Vertreter", vertreter);
        jo.put("Kommentar", kommentar);
        return jo;
    }
    
    
    
}
