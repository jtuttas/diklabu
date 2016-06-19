/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.io.Serializable;
import java.sql.Timestamp;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Transient;

/**
 *
 * @author Jörg
 */
@Entity
@NamedQueries({
  
   @NamedQuery(name = "findNote", query= "select n from Noten n where n.ID_SCHUELER=:paramSchuelerID and n.ID_LERNFELD=:paramLernfeldID")
    
})
@IdClass(Noten_Id.class)
public class Noten implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    private Integer ID_SCHUELER;
    @Id
    private String ID_LERNFELD;
    private String ID_LK;
    private String WERT;
    private Timestamp DATUM;
   
    @Transient
    private boolean success;
    @Transient
    private String msg;

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }            
    
    public Integer getID_SCHUELER() {
        return ID_SCHUELER;
    }
    

    public void setID_SCHUELER(Integer ID_SCHUELER) {
        this.ID_SCHUELER = ID_SCHUELER;
    }

    public String getID_LERNFELD() {
        return ID_LERNFELD;
    }

    public void setID_LERNFELD(String ID_LERNFELD) {
        this.ID_LERNFELD = ID_LERNFELD;
    }

    public String getID_LK() {
        return ID_LK;
    }

    public void setID_LK(String ID_LK) {
        this.ID_LK = ID_LK;
    }

    public String getWERT() {
        return WERT;
    }

    public void setWERT(String WERT) {
        this.WERT = WERT;
    }

    public Timestamp getDATUM() {
        return DATUM;
    }

    public void setDATUM(Timestamp DATUM) {
        this.DATUM = DATUM;
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
        if (!(object instanceof Noten)) {
            return false;
        }
        Noten other = (Noten) object;
        if ((this.ID_SCHUELER == null && other.ID_SCHUELER != null) || (this.ID_SCHUELER != null && !this.ID_SCHUELER.equals(other.ID_SCHUELER))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Noten[ ID_SCHUELER=" + ID_SCHUELER + " ID_LK=("+ID_LK+") ID_LERNFELD=("+ID_LERNFELD+")  Wert="+WERT+" ]";
    }
    
}
