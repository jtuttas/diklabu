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

/**
 *
 * @author Jörg
 */
@Entity
@NamedQueries({
   @NamedQuery(name = "findNoteneinerKlasse", query= "select n from Noten_all n INNER JOIN Schueler s on n.ID_SCHUELER=s.ID INNER JOIN Schueler_Klasse sk on s.ID=sk.ID_SCHUELER INNER JOIN Klasse k on sk.ID_KLASSE=k.ID where k.KNAME=:paramNameKlasse and n.ID_SCHULJAHR=:paramIDSchuljahr ORDER BY n.ID_SCHUELER,n.ID_LERNFELD"),
   @NamedQuery(name = "findNoteneinesSchuelers", query= "select n from Noten_all n where n.ID_SCHUELER=:paramNameSchuelerID and n.ID_SCHULJAHR = :paramIDSchuljahr ORDER BY n.ID_LERNFELD"),    
    
})
public class Noten_all implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer ID;

    private Integer ID_SCHUELER;
    private String ID_LERNFELD;
    private String ID_LK;
    private String WERT;
    private Date Datum;
    private Integer ID_SCHUELER_ORG;
    private Integer ID_SCHULJAHR;
    private String ID_LERNFELD_ORG;

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

    public Date getDatum() {
        return Datum;
    }

    public void setDatum(Date Datum) {
        this.Datum = Datum;
    }

    public Integer getID_SCHUELER_ORG() {
        return ID_SCHUELER_ORG;
    }

    public void setID_SCHUELER_ORG(Integer ID_SCHUELER_ORG) {
        this.ID_SCHUELER_ORG = ID_SCHUELER_ORG;
    }

    public Integer getID_SCHULJAHR() {
        return ID_SCHULJAHR;
    }

    public void setID_SCHULJAHR(Integer ID_SCHULJAHR) {
        this.ID_SCHULJAHR = ID_SCHULJAHR;
    }

    public String getID_LERNFELD_ORG() {
        return ID_LERNFELD_ORG;
    }

    public void setID_LERNFELD_ORG(String ID_LERNFELD_ORG) {
        this.ID_LERNFELD_ORG = ID_LERNFELD_ORG;
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
        if (!(object instanceof Noten_all)) {
            return false;
        }
        Noten_all other = (Noten_all) object;
        if ((this.ID == null && other.ID != null) || (this.ID != null && !this.ID.equals(other.ID))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Noten_all[ id=" + ID + " ]";
    }
    
}
