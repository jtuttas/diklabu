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
    private Integer Schuljahr;
    private String schuljahrName;
    private String KName;
    private String Titel;
    private String Wert;
    private String Notiz;
    private Integer ID_Schueler;

    public Portfolio() {
    }

    public Portfolio(Integer Schuljahr,String schuljahrName, String KName, String Titel, String Wert, String Notiz, Integer ID_Schueler) {
        this.Schuljahr = Schuljahr;
        this.KName = KName;
        this.Titel = Titel;
        this.Wert = Wert;
        this.Notiz = Notiz;
        this.ID_Schueler = ID_Schueler;
        this.schuljahrName=schuljahrName;
    }

    public void setSchuljahrName(String schuljahrName) {
        this.schuljahrName = schuljahrName;
    }

    public String getSchuljahrName() {
        return schuljahrName;
    }
    
    

    public Integer getSchuljahr() {
        return Schuljahr;
    }

    public void setSchuljahr(Integer Schuljahr) {
        this.Schuljahr = Schuljahr;
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

    public Integer getID_Schueler() {
        return ID_Schueler;
    }

    public void setID_Schueler(Integer ID_Schueler) {
        this.ID_Schueler = ID_Schueler;
    }
    
    
}
