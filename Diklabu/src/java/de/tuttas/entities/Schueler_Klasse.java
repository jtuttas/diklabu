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

/**
 *
 * @author Jörg
 */
@Entity
public class Schueler_Klasse implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    private Integer ID_SCHUELER;
    @Id
    private Integer ID_KLASSE;

    public void setID_KLASSE(Integer ID_KLASSE) {
        this.ID_KLASSE = ID_KLASSE;
    }

    public Integer getID_KLASSE() {
        return ID_KLASSE;
    }

    public void setID_SCHUELER(Integer ID_SCHUELER) {
        this.ID_SCHUELER = ID_SCHUELER;
    }

    public Integer getID_SCHUELER() {
        return ID_SCHUELER;
    }
     

    @Override
    public String toString() {
        return "[ sid=" + ID_SCHUELER + " klid="+ID_KLASSE+" ]";
    }
    
}
