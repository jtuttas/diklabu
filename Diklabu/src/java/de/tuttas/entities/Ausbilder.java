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
 * Ausbilder
 * @author Jörg
 */
@Entity
@NamedQueries({

   @NamedQuery(name = "findAusbilder", query= "select a from Ausbilder a "),
   @NamedQuery(name = "findAusbilderByName", query= "select a from Ausbilder a where a.NNAME like :paramAusbildername"),
   @NamedQuery(name = "findAusbilderByBetriebId", query= "select a from Ausbilder a where a.ID_BETRIEB = :paramBetriebId"),
})
public class Ausbilder implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer ID;
    private Integer ID_BETRIEB;
    private String ANREDE;
    private String NNAME;
    private String EMAIL;
    private String TELEFON;
    private String FAX;

    
    
    
    public Integer getID() {
        return ID;
    }

    public void setID(Integer ID) {
        this.ID = ID;
    }

    public Integer getID_BETRIEB() {
        return ID_BETRIEB;
    }

    public void setID_BETRIEB(Integer ID_BETRIEB) {
        this.ID_BETRIEB = ID_BETRIEB;
    }

    public String getANREDE() {
        return ANREDE;
    }

    public void setANREDE(String ANREDE) {
        this.ANREDE = ANREDE;
    }

    public String getNNAME() {
        return NNAME;
    }

    public void setNNAME(String NNAME) {
        this.NNAME = NNAME;
    }

    public String getEMAIL() {
        return EMAIL;
    }

    public void setEMAIL(String EMAIL) {
        this.EMAIL = EMAIL;
    }

    public String getTELEFON() {
        return TELEFON;
    }

    public void setTELEFON(String TELEFON) {
        this.TELEFON = TELEFON;
    }

    public String getFAX() {
        return FAX;
    }

    public void setFAX(String FAX) {
        this.FAX = FAX;
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
        if (!(object instanceof Ausbilder)) {
            return false;
        }
        Ausbilder other = (Ausbilder) object;
        if ((this.ID == null && other.ID != null) || (this.ID != null && !this.ID.equals(other.ID))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "Asubilder[ id=" + ID + " NNAME="+NNAME+" ]";
    }
    
}
