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
 *
 * @author Jörg
 */
@Entity
@NamedQueries({
   @NamedQuery(name = "getAllCourses", query= "select c from Courses c"),
})

public class Courses implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer ID;
    private String TEACHER_SHORTCUT;
    private String TITLE;

    public String getTEACHER_SHOTCUR() {
        return TEACHER_SHORTCUT;
    }

    public String getTITLE() {
        return TITLE;
    }

    public void setTEACHER_SHOTCUR(String TEACHER_SHOTCUR) {
        this.TEACHER_SHORTCUT = TEACHER_SHOTCUR;
    }

    public void setTITLE(String TITLE) {
        this.TITLE = TITLE;
    }

    
    public Integer getId() {
        return ID;
    }

    public void setId(Integer id) {
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
        if (!(object instanceof Courses)) {
            return false;
        }
        Courses other = (Courses) object;
        if ((this.ID == null && other.ID != null) || (this.ID != null && !this.ID.equals(other.ID))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.model.Courses[ id=" + ID+" Titel="+ TITLE + " ]";
    }
    
}
