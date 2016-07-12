/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;


import java.util.ArrayList;
import java.util.List;

/**
 * Eintrag ins Portfolio
 * @author Jörg
 */
public class PortfolioEintrag {
    
    private Integer ID_Schueler;
    private List<Portfolio> eintraege = new ArrayList<Portfolio>();

    public PortfolioEintrag() {
    }

    /**
     * Portfolio Eintrag erzeugen
     * @param ID_Schueler ID des Schülers
     */
    public PortfolioEintrag(Integer ID_Schueler) {
        this.ID_Schueler = ID_Schueler;
    }
    
    

    public void setID_Schueler(Integer ID_Schueler) {
        this.ID_Schueler = ID_Schueler;
    }

    public Integer getID_Schueler() {
        return ID_Schueler;
    }

       
    
    public void setEintraege(List<Portfolio> eintraege) {
        this.eintraege = eintraege;
    }

    public List<Portfolio> getEintraege() {
        return eintraege;
    }
    
    
}
