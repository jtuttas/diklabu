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

/**
 *
 * @author Jörg
 */
@Entity
public class Lernfeld implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private String ID;
    private String BEZEICHNUNG;

    public void setBEZEICHNUNG(String BEZEICHNUNG) {
        this.BEZEICHNUNG = BEZEICHNUNG;
    }

    public String getBEZEICHNUNG() {
        return BEZEICHNUNG;
    }
    
    

    public String getId() {
        return ID;
    }

    public void setId(String id) {
        this.ID = id;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (ID != null ? ID.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Lernfeld)) {
            return false;
        }
        Lernfeld other = (Lernfeld) object;
        if ((this.ID == null && other.ID != null) || (this.ID != null && !this.ID.equals(other.ID))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Lernfeld[ id=" + ID + " ]";
    }
    
}
