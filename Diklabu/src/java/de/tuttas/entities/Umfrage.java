/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.io.Serializable;
import java.util.Collection;
import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;

/**
 *
 * @author Jörg
 */
@Entity
@NamedQueries({
     @NamedQuery(name = "findActiveUmfrage", query= "select new de.tuttas.restful.Data.ActiveUmfrage(u.ID_UMFRAGE,u.NAME,1)  from Umfrage u where u.ACTIVE=1"),
     @NamedQuery(name = "findAllUmfragen", query= "select new de.tuttas.restful.Data.ActiveUmfrage(u.ID_UMFRAGE,u.NAME,u.ACTIVE)  from Umfrage u "),
})
public class Umfrage implements Serializable {
    private static final long serialVersionUID = 1L;
    private String NAME;
    private int ACTIVE;
     @JoinTable(name="REL_UMFRAGE_FRAGE",
            joinColumns =  { 
                   @JoinColumn(name = "ID_UMFRAGE")
            }, 
            inverseJoinColumns = { 
                   @JoinColumn(name = "ID_FRAGE")
            }
    )
    @ManyToMany
    private Collection<Fragen> fragen;         
     
    @OneToMany(mappedBy = "umfrage",cascade = CascadeType.REMOVE)
    private Collection<Teilnehmer> teilnehmer;
     
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer ID_UMFRAGE;

    public Umfrage() {
    }

    public void setTeilnehmer(Collection<Teilnehmer> teilnehmer) {
        this.teilnehmer = teilnehmer;
    }

    public Collection<Teilnehmer> getTeilnehmer() {
        return teilnehmer;
    }
    
    

    public static long getSerialVersionUID() {
        return serialVersionUID;
    }

    
    public Umfrage(String titel) {
        this.NAME=titel;
    }
    

    public void setFragen(Collection<Fragen> fragen) {
        this.fragen = fragen;
    }

    public Collection<Fragen> getFragen() {
        return fragen;
    }
        

    public void setACTIVE(int ACTIVE) {
        this.ACTIVE = ACTIVE;
    }

    public int getACTIVE() {
        return ACTIVE;
    }

    public void setNAME(String NAME) {
        this.NAME = NAME;
    }

    public String getNAME() {
        return NAME;
    }

    public void setID_UMFRAGE(Integer ID_UMFRAGE) {
        this.ID_UMFRAGE = ID_UMFRAGE;
    }

    public Integer getID_UMFRAGE() {
        return ID_UMFRAGE;
    }

    
    
   
    @Override
    public int hashCode() {
        int hash = 0;
        hash += (ID_UMFRAGE != null ? ID_UMFRAGE.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Umfrage)) {
            return false;
        }
        Umfrage other = (Umfrage) object;
        if ((this.ID_UMFRAGE == null && other.ID_UMFRAGE != null) || (this.ID_UMFRAGE != null && !this.ID_UMFRAGE.equals(other.ID_UMFRAGE))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Umfrage[ id=" + ID_UMFRAGE + " ]";
    }
    
}
