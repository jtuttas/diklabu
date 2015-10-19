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
//  @NamedQuery(name = "findKlasseByUserId", query= "select c from Kurswunsch rel JOIN Klasse c ON rel.ID_KURS=c.ID where rel.ID_SCHUELER = :paramId"),
@NamedQueries({
   @NamedQuery(name = "getSelectedKlassen", query= "select k from Buchungsfreigabe b JOIN Klasse k on b.ID_KURS=k.ID")
})

public class Buchungsfreigabe implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;
    private Integer ID_KURS;

    public Integer getID_KURS() {
        return ID_KURS;
    }

    public void setID_KURS(Integer ID_KURS) {
        this.ID_KURS = ID_KURS;
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
        if (!(object instanceof Buchungsfreigabe)) {
            return false;
        }
        Buchungsfreigabe other = (Buchungsfreigabe) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Buchungsfreigabe[ id=" + id + " ]";
    }
    
}
