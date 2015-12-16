/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.io.Serializable;
import java.sql.Timestamp;
import javax.persistence.Column;
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
   // @NamedQuery(name = "findAnwesenheitbyKlasse", query= "select a from Anwesenheit a INNER JOIN Schueler s on a.ID_SCHUELER=s.ID INNER JOIN Schueler_Klasse sk on sk.ID_SCHUELER=s.ID INNER JOIN Klasse k on k.ID=sk.ID_KLASSE where k.KNAME='FISI13A' and a.DATUM between '2015-09-08' and '2015-09-10' ORDER BY s.ID ")
     @NamedQuery(name = "findAnwesenheitbyKlasse", query= "select NEW de.tuttas.restful.Data.AnwesenheitEintrag(a.DATUM,a.ID_LEHRER,a.ID_SCHUELER,a.VERMERK) from Anwesenheit a INNER JOIN Schueler s on a.ID_SCHUELER=s.ID INNER JOIN Schueler_Klasse sk on sk.ID_SCHUELER=s.ID INNER JOIN Klasse k on k.ID=sk.ID_KLASSE where k.KNAME like :paramKName and (a.DATUM between :paramFromDate and :paramToDate) ORDER BY a.ID_SCHUELER,a.DATUM ")
   //@NamedQuery(name = "findAnwesenheitbyKlasse", query= "select a from Anwesenheit a where a.ID_SCHUELER=14279 and (a.DATUM between :paramFromDate and :paramToDate)")
    
})
public class Anwesenheit implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    private Integer id;
    private Integer ID_SCHUELER;
    private Timestamp DATUM;
    @Column(length=3)
    private String ID_LEHRER;
    private String VERMERK;

    public void setDATUM(Timestamp DATUM) {
        this.DATUM = DATUM;
    }

    public void setID_LEHRER(String ID_LEHRER) {
        this.ID_LEHRER = ID_LEHRER;
    }

    public void setID_SCHUELER(Integer ID_SCHUELER) {
        this.ID_SCHUELER = ID_SCHUELER;
    }

    public void setVERMERK(String VERMERK) {
        this.VERMERK = VERMERK;
    }

    public Timestamp getDATUM() {
        return DATUM;
    }

    public String getID_LEHRER() {
        return ID_LEHRER;
    }

    public Integer getID_SCHUELER() {
        return ID_SCHUELER;
    }

    public String getVERMERK() {
        return VERMERK;
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
        if (!(object instanceof Anwesenheit)) {
            return false;
        }
        Anwesenheit other = (Anwesenheit) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Anwesenheit[ id=" + id + " ]";
    }
    
}
