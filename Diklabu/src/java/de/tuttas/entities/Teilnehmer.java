/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.io.Serializable;
import java.util.Collection;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;

/**
 *
 * @author Jörg
 */
@Entity
public class Teilnehmer implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    private String key;
    private int SCHUELERID;
    private int BETRIEBID;
    private int LEHRERID;
    private int INVITED;

    @OneToMany(mappedBy = "teilnehmer")
    private Collection<Antworten> antworten;

    @ManyToOne
    @JoinColumn(name = "UMFRAGE", referencedColumnName = "ID_UMFRAGE")
    private Umfrage umfrage;
    
    public Teilnehmer() {
    }

    public Teilnehmer(String key, int SCHUELERID, int BETRIEBID, int LEHRERID, int INVITED, Umfrage umfrage) {
        this.key = key;
        this.SCHUELERID = SCHUELERID;
        this.BETRIEBID = BETRIEBID;
        this.LEHRERID = LEHRERID;
        this.INVITED = INVITED;
        this.umfrage = umfrage;
    }
    

    public void setUmfrage(Umfrage umfrage) {
        this.umfrage = umfrage;
    }

    public Umfrage getUmfrage() {
        return umfrage;
    }
           
    
    public void setAntworten(Collection<Antworten> antworten) {
        this.antworten = antworten;
    }

    public Collection<Antworten> getAntworten() {
        return antworten;
    }

    

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public int getSCHUELERID() {
        return SCHUELERID;
    }

    public void setSCHUELERID(int SCHUELERID) {
        this.SCHUELERID = SCHUELERID;
    }

    public int getBETRIEBID() {
        return BETRIEBID;
    }

    public void setBETRIEBID(int BETRIEBID) {
        this.BETRIEBID = BETRIEBID;
    }

    public int getLEHRERID() {
        return LEHRERID;
    }

    public void setLEHRERID(int LEHRERID) {
        this.LEHRERID = LEHRERID;
    }

   

    public int getINVITED() {
        return INVITED;
    }

    public void setINVITED(int INVITED) {
        this.INVITED = INVITED;
    }
        
    @Override
    public int hashCode() {
        int hash = 0;
        hash += (key != null ? key.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Teilnehmer)) {
            return false;
        }
        Teilnehmer other = (Teilnehmer) object;
        if ((this.key == null && other.key != null) || (this.key != null && !this.key.equals(other.key))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Teilnehmer[ key=" + key + " ]";
    }
    
}
