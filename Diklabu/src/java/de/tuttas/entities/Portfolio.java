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
import javax.persistence.Transient;

/**
 *
 * @author Jörg
 */
@Entity
@NamedQueries({
    @NamedQuery(name = "findPortfolioNote", query = "select p from Portfolio p where p.ID_Schueler=:paramSchuelerID and p.KName = :paramKName and p.Schuljahr= :paramSchuljahr"),    
    @NamedQuery(name = "findPortfolioEinerKlasse", query = "select p from Portfolio p INNER JOIN Schueler s on p.ID_Schueler=s.ID INNER JOIN Schueler_Klasse sk on sk.ID_SCHUELER=s.ID where sk.ID_KLASSE= :paramKlassenID ORDER BY sk.ID_SCHUELER"),        
})
public class Portfolio implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private Integer Schuljahr;
    private String KName;
    private String Titel;
    private String Wert;
    private String Notiz;
    private int ID_Schueler;
    @Transient
    private String SchuljahrName;

    public Portfolio() {
    }
    
    public Portfolio(int Schuljahr,String KName, String Titel, String Notiz, String Wert, int ID_Schueler) {
        this.Schuljahr=Schuljahr;
        this.KName = KName;
        this.Titel = Titel;
        this.Wert = Wert;
        this.ID_Schueler = ID_Schueler;
    }     

    public String getNotiz() {
        if (Notiz==null) return "";
        return Notiz;
    }

    public void setNotiz(String Notiz) {
        this.Notiz = Notiz;
    }
    
    
    
    public void setSchuljahrName(String SchuljahrName) {
        this.SchuljahrName = SchuljahrName;
    }

    public String getSchuljahrName() {
        return SchuljahrName;
    }

    
    
    public void setSchuljahr(Integer Schuljahr) {
        this.Schuljahr = Schuljahr;
    }

    public Integer getSchuljahr() {
        return Schuljahr;
    }

       

    public String getKName() {
        return KName;
    }

    public void setKName(String KName) {
        this.KName = KName;
    }

    public String getTitel() {
        return Titel;
    }

    public void setTitel(String Titel) {
        this.Titel = Titel;
    }

    public String getWert() {
        return Wert;
    }

    public void setWert(String Wert) {
        this.Wert = Wert;
    }

    public int getID_Schueler() {
        return ID_Schueler;
    }

    public void setID_Schueler(int ID_Schueler) {
        this.ID_Schueler = ID_Schueler;
    }
    
    

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (id != null ? id.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Portfolio)) {
            return false;
        }
        Portfolio other = (Portfolio) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Portfolio[ idSchueler=" + ID_Schueler + " Schuljahr="+SchuljahrName+" ]";
    }
    
}
