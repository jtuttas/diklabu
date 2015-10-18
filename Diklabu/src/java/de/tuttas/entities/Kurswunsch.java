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
 *
 * @author Jörg
 */
@Entity
@NamedQueries({
       @NamedQuery(name = "findKlasseByUserId", query= "select c from Kurswunsch rel JOIN Klasse c ON rel.ID_KURS=c.ID where rel.ID_SCHUELER = :paramId"),
})
public class Kurswunsch implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;
    private Integer ID_SCHUELER;
    private Integer ID_KURS;
    private String PRIORITAET;

    public Kurswunsch() {
    }

    public Kurswunsch(Integer ID_SCHUELER, Integer ID_KURS, String PRIORITAET) {
        this.ID_SCHUELER = ID_SCHUELER;
        this.ID_KURS = ID_KURS;
        this.PRIORITAET = PRIORITAET;
    }

    
    
    public void setID_KURS(Integer ID_KURS) {
        this.ID_KURS = ID_KURS;
    }

    public Integer getID_KURS() {
        return ID_KURS;
    }

    public void setID_SCHUELER(Integer ID_SCHUELER) {
        this.ID_SCHUELER = ID_SCHUELER;
    }

    public Integer getID_SCHUELER() {
        return ID_SCHUELER;
    }

    public void setPRIORITAET(String PRIORITAET) {
        this.PRIORITAET = PRIORITAET;
    }

    public String getPRIORITAET() {
        return PRIORITAET;
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
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Kurswunsch)) {
            return false;
        }
        Kurswunsch other = (Kurswunsch) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Kurswunsch[ id=" + id + " ]";
    }
    
}
