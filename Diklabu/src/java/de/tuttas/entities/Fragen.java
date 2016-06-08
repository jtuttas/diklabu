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
    @NamedQuery(name = "getFragen", query = "select f from Fragen f")
    })

public class Fragen implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID_FRAGE")
    private Integer ID_FRAGE;
    private String TITEL;
    @JoinTable(name="REL_FRAGE_ANTWORTEN",
            joinColumns =  { 
                   @JoinColumn(name = "ID_FRAGE")
            }, 
            inverseJoinColumns = { 
                   @JoinColumn(name = "ID_ANTWORT")
            }
    )
   @ManyToMany
    private Collection<Antwortskalen> antwortskalen;
    
    @OneToMany(mappedBy = "fragenAntworten")
    private Collection<Antworten> antworten;

    public Fragen() {
    }

    public Fragen(String TITEL) {
        this.TITEL = TITEL;
    }
       
    public void setAntworten(Collection<Antworten> antworten) {
        this.antworten = antworten;
    }

    public Collection<Antworten> getAntworten() {
        return antworten;
    }
    
    

    public void setAntwortskalen(Collection<Antwortskalen> antwortskalen) {
        this.antwortskalen = antwortskalen;
    }

    public Collection<Antwortskalen> getAntwortskalen() {
        return antwortskalen;
    }
 
    public void setTITEL(String TITEL) {
        this.TITEL = TITEL;
    }

    public String getTITEL() {
        return TITEL;
    }
        

    public Integer getID_FRAGE() {
        return ID_FRAGE;
    }

    public void setID_FRAGE(Integer id) {
        this.ID_FRAGE = id;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (ID_FRAGE != null ? ID_FRAGE.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Fragen)) {
            return false;
        }
        Fragen other = (Fragen) object;
        if ((this.ID_FRAGE == null && other.ID_FRAGE != null) || (this.ID_FRAGE != null && !this.ID_FRAGE.equals(other.ID_FRAGE))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Fragen[ id=" + ID_FRAGE + " TITEL="+TITEL+" ]";
    }
    
}
