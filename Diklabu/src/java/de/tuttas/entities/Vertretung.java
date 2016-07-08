/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;
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
     @NamedQuery(name = "findVertretungbyDate", query= "select v from Vertretung v where v.absenzAm between :paramFromDate and :paramToDate ORDER BY v.absenzAm "),
    
})

public class Vertretung implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String eingereichtVon;
    private Timestamp eingereichtAm;
    private String absenzVon;
    private Timestamp absenzAm;
    private String jsonString;
    private String kommentar;

    public Vertretung() {
    }

    public Vertretung(String eingereichtVon, Timestamp eingereichtAm, String absenzVon, Timestamp absenzAm, String jsonString) {
        this.eingereichtVon = eingereichtVon;
        this.eingereichtAm = eingereichtAm;
        this.absenzVon = absenzVon;
        this.absenzAm = absenzAm;
        this.jsonString = jsonString;
    }

    public void setKommentar(String kommentar) {
        this.kommentar = kommentar;
    }

    public String getKommentar() {
        return kommentar;
    }
    
    

    public String getEingereichtVon() {
        return eingereichtVon;
    }

    public void setEingereichtVon(String eingereichtVon) {
        this.eingereichtVon = eingereichtVon;
    }

    public Timestamp getEingereichtAm() {
        return eingereichtAm;
    }

    public void setEingereichtAm(Timestamp eingereichtAm) {
        this.eingereichtAm = eingereichtAm;
    }

    public String getAbsenzVon() {
        return absenzVon;
    }

    public void setAbsenzVon(String absenzVon) {
        this.absenzVon = absenzVon;
    }

    public Timestamp getAbsenzAm() {
        return absenzAm;
    }

    public void setAbsenzAm(Timestamp absenzAm) {
        this.absenzAm = absenzAm;
    }

    public String getJsonString() {
        return jsonString;
    }

    public void setJsonString(String jsonString) {
        this.jsonString = jsonString;
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
        if (!(object instanceof Vertretung)) {
            return false;
        }
        Vertretung other = (Vertretung) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Vertertung[ id=" + id + " eingereichtVon"+eingereichtVon+" eingereichtAm:"+eingereichtAm+"]";
    }
    
}
