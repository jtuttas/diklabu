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
public class Ausbilder implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer ID;
    private int ID_BETRIEB;
    private String ANREDE;
    private String NNAME;
    private String EMAIL;
    private String TELEFON;
    private String FAX;

    public Ausbilder() {
    }

  
    public Ausbilder(Integer ID, int ID_BETRIEB, String ANREDE, String NNAME, String EMAIL, String TELEFON, String FAX) {
        this.ID = ID;
        this.ID_BETRIEB = ID_BETRIEB;
        this.ANREDE = ANREDE;
        this.NNAME = NNAME;
        this.EMAIL = EMAIL;
        this.TELEFON = TELEFON;
        this.FAX = FAX;
    }
    
    
    public Integer getID() {
        return ID;
    }

    public void setID(Integer ID) {
        this.ID = ID;
    }

    public int getID_BETRIEB() {
        return ID_BETRIEB;
    }

    public void setID_BETRIEB(int ID_BETRIEB) {
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
    
    

    public Integer getId() {
        return ID;
    }

    public void setId(Integer id) {
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
        return "de.tuttas.entities.Ausbilder[ id=" + ID + " ]";
    }
    
}
