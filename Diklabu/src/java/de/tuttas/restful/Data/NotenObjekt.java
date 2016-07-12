/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import de.tuttas.entities.Noten;
import de.tuttas.entities.Noten_all;
import java.util.ArrayList;
import java.util.List;

/**
 * Klasse für einen Noteneintrag
 * @author Jörg
 */
public class NotenObjekt extends ResultObject{
    private int schuelerID;
    private List<Noten_all> noten = new ArrayList<>();
    private String schuljahrName;

    public void setSchuljahrName(String schuljahrName) {
        this.schuljahrName = schuljahrName;
    }

    public String getSchuljahrName() {
        return schuljahrName;
    }
    
    

    public int getSchuelerID() {
        return schuelerID;
    }

    public void setSchuelerID(int schuelerID) {
        this.schuelerID = schuelerID;
    }

    public List<Noten_all> getNoten() {
        return noten;
    }

    public void setNoten(List<Noten_all> noten) {
        this.noten = noten;
    }

    
}
