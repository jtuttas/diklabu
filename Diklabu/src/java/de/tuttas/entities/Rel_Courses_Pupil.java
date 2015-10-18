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
       @NamedQuery(name = "findCoursesByUserId", query= "select c from Rel_Courses_Pupil rel JOIN Courses c ON rel.COURSE_ID=c.ID where rel.PUPIL_ID = :paramId"),
})
public class Rel_Courses_Pupil implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer ID;
    private Integer COURSE_ID;
    private Integer PUPIL_ID;
    private Integer PRIORITY;

    public Rel_Courses_Pupil() {
        
    }

    public Rel_Courses_Pupil(Integer COURSE_ID, Integer PUPIL_ID, Integer PRIORITY) {
        this.COURSE_ID = COURSE_ID;
        this.PUPIL_ID = PUPIL_ID;
        this.PRIORITY = PRIORITY;
    }
    
    
    public void setCOURSE_ID(Integer COURSE_ID) {
        this.COURSE_ID = COURSE_ID;
    }

    public void setPRIORITY(Integer PRIORITY) {
        this.PRIORITY = PRIORITY;
    }

    public void setPUPIL_ID(Integer PUPIL_ID) {
        this.PUPIL_ID = PUPIL_ID;
    }

    public Integer getCOURSE_ID() {
        return COURSE_ID;
    }

    public Integer getPRIORITY() {
        return PRIORITY;
    }

    public Integer getPUPIL_ID() {
        return PUPIL_ID;
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
        if (!(object instanceof Rel_Courses_Pupil)) {
            return false;
        }
        Rel_Courses_Pupil other = (Rel_Courses_Pupil) object;
        if ((this.ID == null && other.ID != null) || (this.ID != null && !this.ID.equals(other.ID))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.model.Rel_Courses_Pupil[ id=" + ID + " ]";
    }
    
}
