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
import javax.persistence.ManyToOne;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;

/**
 * Entität Teilnehmer einer Umfrage
 * @author Jörg
 */
@Entity
@NamedQueries({
    @NamedQuery(name = "findBetriebTeilnehmer", query = "select t from Teilnehmer t where t.umfrage = :paramUmfrage and t.BETRIEBID = :paramBetriebId"),
    @NamedQuery(name = "findSchuelerTeilnehmer", query = "select t from Teilnehmer t where t.umfrage = :paramUmfrage and t.SCHUELERID = :paramSchuelerId"),
    @NamedQuery(name = "findLehrerTeilnehmer", query = "select t from Teilnehmer t where t.umfrage = :paramUmfrage and t.LEHRERID = :paramLehrerId"),
    @NamedQuery(name = "findTeilnehmer", query = "select t from Teilnehmer t where t.umfrage = :paramUmfrage"),
})
public class Teilnehmer implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    private String key;
    private Integer SCHUELERID;
    private Integer BETRIEBID;
    private String LEHRERID;
    private int INVITED;

    @OneToMany(mappedBy = "teilnehmer",cascade = CascadeType.REMOVE)
    private Collection<Antworten> antworten;

    @ManyToOne
    @JoinColumn(name = "UMFRAGE", referencedColumnName = "ID_UMFRAGE")
    private Umfrage umfrage;
    
    public Teilnehmer() {
    }

    /**
     * Teilnehmer erzeugen
     * @param key Key welcher den Teilnehmer idntifiziert
     * @param SCHUELERID ID des Schülers bei Schülerumfrage
     * @param BETRIEBID ID des Betriebes bei Betriebsumfrage
     * @param LEHRERID ID des Lehrers bei Lehrerumfrage
     * @param INVITED =1 wenn bereits eingeladen, sonst 0
     * @param umfrage Umfrage 
     */
    public Teilnehmer(String key, Integer SCHUELERID, Integer BETRIEBID, String LEHRERID, int INVITED, Umfrage umfrage) {
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

    public Integer getSCHUELERID() {
        return SCHUELERID;
    }

    public void setSCHUELERID(Integer SCHUELERID) {
        this.SCHUELERID = SCHUELERID;
    }

    public Integer getBETRIEBID() {
        return BETRIEBID;
    }

    public void setBETRIEBID(Integer BETRIEBID) {
        this.BETRIEBID = BETRIEBID;
    }

    public String getLEHRERID() {
        return LEHRERID;
    }

    public void setLEHRERID(String LEHRERID) {
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
