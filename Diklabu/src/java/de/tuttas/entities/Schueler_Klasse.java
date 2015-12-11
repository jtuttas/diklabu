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
public class Schueler_Klasse implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;
    private Integer ID_SCHUELER;
    private Integer ID_KLASSE;

    public void setID_KLASSE(Integer ID_KLASSE) {
        this.ID_KLASSE = ID_KLASSE;
    }

    public Integer getID_KLASSE() {
        return ID_KLASSE;
    }

    public void setID_SCHUELER(Integer ID_SCHUELER) {
        this.ID_SCHUELER = ID_SCHUELER;
    }

    public Integer getID_SCHUELER() {
        return ID_SCHUELER;
    }
    
    

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (id != null ? id.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        if (!(object instanceof Schueler_Klasse)) {
            return false;
        }
        Schueler_Klasse other = (Schueler_Klasse) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Schueler_Klasse[ id=" + id + " ]";
    }
    
}
