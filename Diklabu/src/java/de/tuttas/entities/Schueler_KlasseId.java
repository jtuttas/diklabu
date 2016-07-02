/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

/**
 *
 * @author Jörg
 */
public class Schueler_KlasseId {
    private Integer ID_SCHUELER;
    private Integer ID_KLASSE;

    public Schueler_KlasseId() {
    }

    public Schueler_KlasseId(int ID_SCHUELER, int ID_KLASSE) {
        this.ID_SCHUELER = ID_SCHUELER;
        this.ID_KLASSE = ID_KLASSE;
    }

    public void setID_KLASSE(int ID_KLASSE) {
        this.ID_KLASSE = ID_KLASSE;
    }

    public void setID_SCHUELER(int ID_SCHUELER) {
        this.ID_SCHUELER = ID_SCHUELER;
    }

    public Integer getID_KLASSE() {
        return ID_KLASSE;
    }

    public Integer getID_SCHUELER() {
        return ID_SCHUELER;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (ID_SCHUELER != null ? ID_SCHUELER.hashCode() : 0);
        hash += (ID_KLASSE != null ? ID_KLASSE.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Schueler_Klasse)) {
            return false;
        }
        Schueler_Klasse other = (Schueler_Klasse) object;
        if ((this.ID_KLASSE == null && other.getID_KLASSE() != null) || (this.ID_KLASSE != null && !this.ID_KLASSE.equals(other.getID_KLASSE()))) {
            return false;
        }
        if ((this.ID_SCHUELER == null && other.getID_SCHUELER()!= null) || (this.ID_SCHUELER != null && !this.ID_SCHUELER.equals(other.getID_SCHUELER()))) {
            return false;
        }
        return true;
    }
    
    
    
}
