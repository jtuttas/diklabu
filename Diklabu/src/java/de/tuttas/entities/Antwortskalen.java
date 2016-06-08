/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.io.Serializable;
import java.util.Collection;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;

/**
 *
 * @author Jörg
 */
@Entity
@NamedQueries({
    @NamedQuery(name = "getAntwortenSkalen", query = "select a from Antwortskalen a")
    })
public class Antwortskalen implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
     @Column(name = "ID")
    private Integer ID;
    private String NAME;
    private int WERT;
    
    @ManyToMany (mappedBy = "antwortskalen")
    private Collection<Fragen> fragen;
    
    @OneToMany(mappedBy = "antwortskala")
    private Collection<Antworten> antworten;

    public void setAntworten(Collection<Antworten> antworten) {
        this.antworten = antworten;
    }

    public Collection<Antworten> getAntworten() {
        return antworten;
    }
    
    
   
    public void setFragen(Collection<Fragen> fragen) {
        this.fragen = fragen;
    }

    public Collection<Fragen> getFragen() {
        return fragen;
    }
    
    

    public void setWERT(int WERT) {
        this.WERT = WERT;
    }

    public int getWERT() {
        return WERT;
    }
        

    public void setNAME(String TITEL) {
        this.NAME = TITEL;
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
        if (!(object instanceof Antwortskalen)) {
            return false;
        }
        Antwortskalen other = (Antwortskalen) object;
        if ((this.ID == null && other.ID != null) || (this.ID != null && !this.ID.equals(other.ID))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Antworten[ id=" + ID + " Name="+NAME+" ]";
    }
    
}
