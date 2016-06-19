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
public class Portfolio {
    private String KName;
    private String Titel;
    private String Wert;
    private String Notiz;
    private Integer IDKlasse;
    private Integer IDKategorie;
    private int schuljahr;
    private String schuljahrName;


    public Portfolio() {
    }

    public Portfolio(String KName, String Titel, String Wert, String Notiz,Integer ID_Klasse,Integer ID_Kategorie,Integer schuljahr, String schuljahrName) {
        this.KName = KName;
        this.Titel = Titel;
        this.Wert = Wert;
        this.Notiz = Notiz;
        this.IDKlasse=ID_Klasse;
        this.IDKategorie=ID_Kategorie;
        this.schuljahr=schuljahr;
        this.schuljahrName=schuljahrName;
    }

    public void setSchuljahr(int schuljahr) {
        this.schuljahr = schuljahr;
    }

    public void setSchuljahrName(String schuljahrName) {
        this.schuljahrName = schuljahrName;
    }

    public int getSchuljahr() {
        return schuljahr;
    }

    public String getSchuljahrName() {
        return schuljahrName;
    }

    
    public void setIDKategorie(Integer IDKategorie) {
        this.IDKategorie = IDKategorie;
    }

    public Integer getIDKategorie() {
        return IDKategorie;
    }

    
    public void setIDKlasse(Integer IDKlasse) {
        this.IDKlasse = IDKlasse;
    }

    public Integer getIDKlasse() {
        return IDKlasse;
    }

    

    public String getKName() {
        return KName;
    }

    public void setKName(String KName) {
        this.KName = KName;
    }

    public String getTitel() {
        return Titel;
    }

    public void setTitel(String Titel) {
        this.Titel = Titel;
    }

    public String getWert() {
        return Wert;
    }

    public void setWert(String Wert) {
        this.Wert = Wert;
    }

    public String getNotiz() {
        return Notiz;
    }

    public void setNotiz(String Notiz) {
        this.Notiz = Notiz;
    }
    
}
