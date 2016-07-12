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
import javax.persistence.IdClass;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;

/**
 * Relations Entität Schüler in Klasse
 * @author Jörg
 */
@Entity
@NamedQueries({
   @NamedQuery(name = "findKlassenids", query= "select sk from Schueler_Klasse sk where sk.ID_SCHUELER = :paramidSchueler "),
   @NamedQuery(name = "findSchulerEinerKlasse", query= "select s from Schueler s inner join Schueler_Klasse sk on sk.ID_SCHUELER=s.ID  where sk.ID_KLASSE = :paramidKlasse "),
   @NamedQuery(name = "findSchuelerKlasse", query= "select sk from Schueler_Klasse sk where sk.ID_SCHUELER = :paramidSchueler and sk.ID_KLASSE = :paramidKlasse")        
})
@IdClass(Schueler_KlasseId.class)
public class Schueler_Klasse implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    private Integer ID_SCHUELER;
    @Id
    private Integer ID_KLASSE;

    public Schueler_Klasse() {
    }

    public Schueler_Klasse(Integer ID_SCHUELER, Integer ID_KLASSE) {
        this.ID_SCHUELER = ID_SCHUELER;
        this.ID_KLASSE = ID_KLASSE;
    }

    
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
