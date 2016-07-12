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
import javax.persistence.IdClass;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Transient;

/**
 * Alle Noten (auch über mehrere Schuljahre hinweg)
 * @author Jörg
 */
@Entity
@NamedQueries({
   @NamedQuery(name = "findNoteneinerKlasse", query= "select n from Noten_all n INNER JOIN Schueler s on n.ID_SCHUELER=s.ID INNER JOIN Schueler_Klasse sk on s.ID=sk.ID_SCHUELER INNER JOIN Klasse k on sk.ID_KLASSE=k.ID where k.KNAME=:paramNameKlasse and n.ID_SCHULJAHR=:paramIDSchuljahr ORDER BY n.ID_SCHUELER,n.ID_LERNFELD"),
   //findNoteByKlassenID
   @NamedQuery(name = "findNoteByKlassenID", query= "select n from Noten_all n where n.ID_SCHUELER=:paramSchuelerID and n.ID_LERNFELD=:paramLernfeldID"),
   @NamedQuery(name = "findNoteneinesSchuelers", query= "select n from Noten_all n where n.ID_SCHUELER=:paramNameSchuelerID and n.ID_SCHULJAHR = :paramIDSchuljahr ORDER BY n.ID_LERNFELD"),    
   //@NamedQuery(name = "findPortfolioeinerKlasse", query= "select n from Noten_all n INNER JOIN Schueler s on n.ID_SCHUELER=s.ID INNER JOIN Klasse_all ka on n.ID_KLASSE_ALL=ka.ID inner join Schueler_Klasse sk on s.ID=sk.ID_SCHUELER where sk.ID_KLASSE =:paramIdKlasse and ka.ID_KATEGORIE=1 ORDER BY n.ID_SCHUELER,n.ID_LERNFELD"), 
   @NamedQuery(name = "findPortfolio", query= "select n from Noten_all n INNER JOIN Schueler s on n.ID_SCHUELER=s.ID INNER JOIN Klasse_all ka on n.ID_KLASSEN_ALL=ka.ID inner join Schueler_Klasse sk on s.ID=sk.ID_SCHUELER where sk.ID_KLASSE =:paramIdKlasse and ka.ID_KATEGORIE in (1,9) ORDER BY n.ID_SCHUELER,n.ID_SCHULJAHR,n.ID_LERNFELD"),  
})
@IdClass(Noten_all_Id.class)
public class Noten_all implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id     
    private Integer ID_SCHUELER;
    @Id     
    private String ID_LERNFELD;
    private String ID_LK;
    private String WERT; 
    private Date Datum;
    private Integer ID_SCHUELER_ORG;
    @Id    
    private Integer ID_SCHULJAHR;
    private String ID_LERNFELD_ORG;
    private Integer ID_KLASSEN_ALL;
    @Transient
    private String NameLernfeld;

    public void setNameLernfeld(String NameLernfeld) {
        this.NameLernfeld = NameLernfeld;
    }

    public String getNameLernfeld() {
        return NameLernfeld;
    }
    
    

    public void setID_KLASSEN_ALL(Integer ID_KLASSEN_ALL) {
        this.ID_KLASSEN_ALL = ID_KLASSEN_ALL;
    }

    public Integer getID_KLASSEN_ALL() {
        return ID_KLASSEN_ALL;
    }
            
   
    
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
    
    

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (ID_SCHUELER != null ? ID_SCHUELER.hashCode() : 0);
        hash += (ID_LERNFELD != null ? ID_LERNFELD.hashCode() : 0);
        hash += (ID_SCHULJAHR != null ? ID_SCHULJAHR.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Noten_all)) {
            return false;
        }
        Noten_all other = (Noten_all) object;
        if ((this.ID_LERNFELD == null && other.getID_LERNFELD() != null) || (this.ID_LERNFELD != null && !this.ID_LERNFELD.equals(other.getID_LERNFELD()))) {
            return false;
        }
        if ((this.ID_SCHUELER == null && other.getID_SCHUELER()!= null) || (this.ID_SCHUELER != null && !this.ID_SCHUELER.equals(other.getID_SCHUELER()))) {
            return false;
        }
        if ((this.ID_SCHULJAHR == null && other.getID_SCHULJAHR()!= null) || (this.ID_SCHULJAHR != null && !this.ID_SCHULJAHR.equals(other.getID_SCHULJAHR()))) {
            return false;
        }

        return true;
    }

    @Override
    public String toString() {
        return "Noten_all[ ID_SCHUELR=" + ID_SCHUELER + " LF="+ID_LERNFELD+" LK="+ID_LK+" WERT="+WERT+" KLASSE_ALL="+ID_KLASSEN_ALL+"]";
    }
    
}
