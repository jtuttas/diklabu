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
   @NamedQuery(name = "findPupilbyCredentials", query= "select p from Pupil p where p.NAME like :paramName and p.VORNAME like :paramVorname and p.GEB_DATUM like :paramGebDatum"),
})
public class Pupil implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;
        private String NAME;
    private String VORNAME;
    private Date GEB_DATUM;

    public Pupil() {
    }

    public Pupil(String NAME, String VORNAME, Date GEB_DATUM) {
        this.NAME = NAME;
        this.VORNAME = VORNAME;
        this.GEB_DATUM = GEB_DATUM;
    }
    
    

    public Date getGEB_DATUM() {
        return GEB_DATUM;
    }

    public String getNAME() {
        return NAME;
    }

    public String getVORNAME() {
        return VORNAME;
    }

    public void setGEB_DATUM(Date GEB_DATUM) {
        this.GEB_DATUM = GEB_DATUM;
    }

    public void setNAME(String NAME) {
        this.NAME = NAME;
    }

    public void setVORNAME(String VORNAME) {
        this.VORNAME = VORNAME;
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
        if (!(object instanceof Pupil)) {
            return false;
        }
        Pupil other = (Pupil) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.model.Pupil[ id="+id+" Name="+NAME+" Vorname="+VORNAME+" GebDatum="+GEB_DATUM  +"]";
    }
    
}
