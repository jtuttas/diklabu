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
import javax.persistence.NamedQuery;

/**
 *
 * @author Jörg
 */
@Entity
@NamedQuery(
        name = "findSchuelerLoginbyId", query= "select s from LoginSchueler s where s.ID_SCHUELER=:paramId"
)

public class LoginSchueler implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer ID_SCHUELER;
    private String LOGIN;

    public String getLOGIN() {
        return LOGIN;
    }

    public void setLOGIN(String LOGIN) {
        this.LOGIN = LOGIN;
    }
    
    
    
    
    public Integer getID_SCHUELER() {
        return ID_SCHUELER;
    }

    public void setID_SCHUELER(Integer id) {
        this.ID_SCHUELER = id;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (ID_SCHUELER != null ? ID_SCHUELER.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof LoginSchueler)) {
            return false;
        }
        LoginSchueler other = (LoginSchueler) object;
        if ((this.ID_SCHUELER == null && other.ID_SCHUELER != null) || (this.ID_SCHUELER != null && !this.ID_SCHUELER.equals(other.ID_SCHUELER))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.LoginSchueler[ id=" + ID_SCHUELER + " Login="+LOGIN+" ]";
    }
    
}
