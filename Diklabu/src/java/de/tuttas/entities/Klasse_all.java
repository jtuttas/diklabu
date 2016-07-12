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
 * alle (auch ehemalige Klassen)
 * @author Jörg
 */
@Entity
@NamedQueries({
   @NamedQuery(name = "findKlasseEinesJahrgangs", query= "select ka from Klasse_all ka where ka.ID_Schuljahr = :paramIdSchuljahr and ka.ID_Klasse=:paramIdKlasse "),
})
public class Klasse_all implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer ID;
    private String KNAME;
    private String ID_LEHRER;
    private Integer ID_KATEGORIE;
    private String Termine;
    private String Notiz;
    private String Titel;
    private Integer ID_Schuljahr;
    private Integer ID_Klasse;

    
    public String getKNAME() {
        return KNAME;
    }

    public void setKNAME(String KNAME) {
        this.KNAME = KNAME;
    }

    public String getID_LEHRER() {
        return ID_LEHRER;
    }

    public void setID_LEHRER(String ID_LEHRER) {
        this.ID_LEHRER = ID_LEHRER;
    }

    public Integer getID_KATEGORIE() {
        return ID_KATEGORIE;
    }

    public void setID_KATEGORIE(Integer ID_KATEGORIE) {
        this.ID_KATEGORIE = ID_KATEGORIE;
    }

    public String getTermine() {
        return Termine;
    }

    public void setTermine(String Termine) {
        this.Termine = Termine;
    }

    public String getNotiz() {
        return Notiz;
    }

    public void setNotiz(String Notiz) {
        this.Notiz = Notiz;
    }

    public String getTitel() {
        return Titel;
    }

    public void setTitel(String Titel) {
        this.Titel = Titel;
    }

    public Integer getID_Schuljahr() {
        return ID_Schuljahr;
    }

    public void setID_Schuljahr(Integer ID_Schuljahr) {
        this.ID_Schuljahr = ID_Schuljahr;
    }

    public Integer getID_Klasse() {
        return ID_Klasse;
    }

    public void setID_Klasse(Integer ID_Klasse) {
        this.ID_Klasse = ID_Klasse;
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
        if (!(object instanceof Klasse_all)) {
            return false;
        }
        Klasse_all other = (Klasse_all) object;
        if ((this.ID == null && other.ID != null) || (this.ID != null && !this.ID.equals(other.ID))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.KLasse_all[ id=" + ID + " ]";
    }
    
}
