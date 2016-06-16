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
public class PortfolioEintrag {
    
    private List<Portfolio> eintraege = new ArrayList<Portfolio>();

    public void setEintraege(List<Portfolio> eintraege) {
        this.eintraege = eintraege;
    }

    public List<Portfolio> getEintraege() {
        return eintraege;
    }
    
    
}
