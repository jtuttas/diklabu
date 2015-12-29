/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import de.tuttas.util.StringUtil;
import java.io.Serializable;
import javax.persistence.Column;
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
   @NamedQuery(name = "findAllTeachers", query= "select l from Lehrer l ORDER BY l.id"),   
})
public class Lehrer implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(length=3)
    private String id;
    private String NNAME;
    private String VNAME;
    
    @Transient
    private String idplain;

    public String getIdplain() {
        return StringUtil.removeGermanCharacters(this.id);
    }

    public void setIdplain(String idplain) {
        this.idplain = idplain;
    }
    
    

    public void setNNAME(String NNAME) {
        this.NNAME = NNAME;
    }

    
    public String getNNAME() {
        return NNAME;
    }

    public void setVNAME(String VNAME) {
        this.VNAME = VNAME;
    }

    public String getVNAME() {
        return VNAME;
    }
        

    public String getId() {
        return id;
    }

    public void setId(String id) {
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
        if (!(object instanceof Lehrer)) {
            return false;
        }
        Lehrer other = (Lehrer) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Lehrer[ id=" + id + " ]";
    }
    
}
