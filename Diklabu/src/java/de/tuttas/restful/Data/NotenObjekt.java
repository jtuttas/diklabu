/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import de.tuttas.entities.Noten;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Jörg
 */
public class NotenObjekt extends ResultObject{
    private int schuelerID;
    private List<Noten> noten = new ArrayList<>();

    public int getSchuelerID() {
        return schuelerID;
    }

    public void setSchuelerID(int schuelerID) {
        this.schuelerID = schuelerID;
    }

    public List<Noten> getNoten() {
        return noten;
    }

    public void setNoten(List<Noten> noten) {
        this.noten = noten;
    }

    
}
