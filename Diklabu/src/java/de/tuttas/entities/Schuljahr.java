/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.io.Serializable;
import java.sql.Date;
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
    @NamedQuery(name = "getLatestSchuljahr", query = "select s from Schuljahr s ORDER BY s.ID DESC")
})
public class Schuljahr implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer ID;
    private String NAME;
    private Date ZEUGNISDATUM;

    public void setZEUGNISDATUM(Date ZEUGNISDATUM) {
        this.ZEUGNISDATUM = ZEUGNISDATUM;
    }

    public Date getZEUGNISDATUM() {
        return ZEUGNISDATUM;
    }

    
    
    public void setNAME(String NAME) {
        this.NAME = NAME;
    }

    public String getNAME() {
        return NAME;
    }
        
    public Integer getID() {
        return ID;
    }

    public void setID(Integer id) {
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
        if (!(object instanceof Schuljahr)) {
            return false;
        }
        Schuljahr other = (Schuljahr) object;
        if ((this.ID == null && other.ID != null) || (this.ID != null && !this.ID.equals(other.ID))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Schuljahr[ id=" + ID + " Name="+NAME+" ]";
    }
    
}
