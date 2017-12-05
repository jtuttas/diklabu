/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

/**
 *
 * @author jtutt
 */
public class Lehrer_KlasseId {
  private Integer ID_KLASSE;
  private String ID_LEHRER;

    public Lehrer_KlasseId() {
    }

    public Lehrer_KlasseId(int ID_KLASSE, String ID_LEHRER) {
        this.ID_KLASSE = ID_KLASSE;
        this.ID_LEHRER = ID_LEHRER;
    }

    public Integer getID_KLASSE() {
        return ID_KLASSE;
    }

    public void setID_KLASSE(Integer ID_KLASSE) {
        this.ID_KLASSE = ID_KLASSE;
    }

    public String getID_LEHRER() {
        return ID_LEHRER;
    }

    public void setID_LEHRER(String ID_LEHRER) {
        this.ID_LEHRER = ID_LEHRER;
    }

    

   @Override
    public int hashCode() {
        int hash = 0;
        hash += (ID_LEHRER != null ? ID_LEHRER.hashCode() : 0);
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
        if ((this.ID_LEHRER == null && other.getID_SCHUELER()!= null) || (this.ID_LEHRER != null && !this.ID_LEHRER.equals(other.getID_SCHUELER()))) {
            return false;
        }
        return true;
    }
    
  
}
