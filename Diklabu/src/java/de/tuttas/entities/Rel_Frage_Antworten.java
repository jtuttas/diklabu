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
public class Rel_Frage_Antworten implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    private Integer ID_FRAGE;
    @Id
    private Integer ID_ANTWORT;

    public void setID_ANTWORT(Integer ID_ANTOWRT) {
        this.ID_ANTWORT = ID_ANTOWRT;
    }

    public void setID_FRAGE(Integer ID_FRAGE) {
        this.ID_FRAGE = ID_FRAGE;
    }

    public Integer getID_ANTWORT() {
        return ID_ANTWORT;
    }

    public Integer getID_FRAGE() {
        return ID_FRAGE;
    }
      


    @Override
    public int hashCode() {
        int hash = 0;
        hash += (ID_FRAGE != null ? ID_FRAGE.hashCode() : 0);
         hash += (ID_ANTWORT != null ? ID_ANTWORT.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Rel_Frage_Antworten)) {
            return false;
        }
        Rel_Frage_Antworten other = (Rel_Frage_Antworten) object;
        if ((this.ID_FRAGE == null && other.ID_FRAGE != null) || (this.ID_FRAGE != null && !this.ID_FRAGE.equals(other.ID_FRAGE))) {
            return false;
        }
        if ((this.ID_ANTWORT == null && other.ID_ANTWORT != null) || (this.ID_ANTWORT != null && !this.ID_ANTWORT.equals(other.ID_ANTWORT))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Rel_Frage_Antwort[ id_frage=" + ID_FRAGE + " id_antwort="+ID_ANTWORT+" ]";
    }
    
}
