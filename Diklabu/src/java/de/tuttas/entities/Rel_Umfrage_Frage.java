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
public class Rel_Umfrage_Frage implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id  
    private Integer ID_UMFRAGE;
    @Id  
    private Integer ID_FRAGE;

    public Integer getID_FRAGE() {
        return ID_FRAGE;
    }

    public Integer getID_UMFRAGE() {
        return ID_UMFRAGE;
    }

    public void setID_FRAGE(Integer ID_FRAGE) {
        this.ID_FRAGE = ID_FRAGE;
    }

    public void setID_UMFRAGE(Integer ID_UMFRAGE) {
        this.ID_UMFRAGE = ID_UMFRAGE;
    }
    

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (ID_UMFRAGE != null ? ID_UMFRAGE.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Rel_Umfrage_Frage)) {
            return false;
        }
        Rel_Umfrage_Frage other = (Rel_Umfrage_Frage) object;
        if ((this.ID_UMFRAGE == null && other.ID_UMFRAGE != null) || (this.ID_UMFRAGE != null && !this.ID_UMFRAGE.equals(other.ID_UMFRAGE))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Rel_Umfrage_Frage[ id=" + ID_UMFRAGE + " ]";
    }
    
}
