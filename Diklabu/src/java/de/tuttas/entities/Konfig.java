/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.io.Serializable;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;

/**
 * Konfiguration
 * @author Jörg
 */
@Entity
@NamedQueries({
   @NamedQuery(name = "findTitel", query= "select k from Konfig k where k.TITEL like :paramTitel")
})

public class Konfig implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    private String TITEL;
    private int STATUS;

    public void setSTATUS(int STATUS) {
        this.STATUS = STATUS;
    }

    public int getSTATUS() {
        return STATUS;
    }

    public void setTITEL(String TITEL) {
        this.TITEL = TITEL;
    }

    public String getTITEL() {
        return TITEL;
    }
    
    


    @Override
    public int hashCode() {
        int hash = 0;
        hash += (TITEL != null ? TITEL.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        if (!(object instanceof Konfig)) {
            return false;
        }
        Konfig other = (Konfig) object;
        if ((this.TITEL == null && other.TITEL != null) || (this.TITEL != null && !this.TITEL.equals(other.TITEL))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Konfig[ TITEL=" + TITEL + " Status="+STATUS +" ]";
    }
    
}
