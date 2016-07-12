/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

/**
 * Zusammengesetzter Primärschlüssel für alle Noten
 * @author Jörg
 */
public class Noten_all_Id {
    private Integer ID_SCHUELER;
    private String ID_LERNFELD;
    private Integer ID_SCHULJAHR;

    public Noten_all_Id() {
    }

    /**
     * Primärschlüssel für alle Noten erzeugen
     * @param ID_SCHUELER ID des Schülers
     * @param ID_LERNFELD ID der Lernfeldes
     * @param ID_SCHULJAHR  ID des Schuljahres
     */
    public Noten_all_Id(Integer ID_SCHUELER, String ID_LERNFELD, Integer ID_SCHULJAHR) {
        this.ID_SCHUELER = ID_SCHUELER;
        this.ID_LERNFELD = ID_LERNFELD;
        this.ID_SCHULJAHR = ID_SCHULJAHR;
    }

    public Integer getID_SCHUELER() {
        return ID_SCHUELER;
    }

    public void setID_SCHUELER(Integer ID_SCHUELER) {
        this.ID_SCHUELER = ID_SCHUELER;
    }

    public String getID_LERNFELD() {
        return ID_LERNFELD;
    }

    public void setID_LERNFELD(String ID_LERNFELD) {
        this.ID_LERNFELD = ID_LERNFELD;
    }

    public Integer getID_SCHULJAHR() {
        return ID_SCHULJAHR;
    }

    public void setID_SCHULJAHR(Integer ID_SCHULJAHR) {
        this.ID_SCHULJAHR = ID_SCHULJAHR;
    }
    
    @Override
    public int hashCode() {
        int hash = 0;
        hash += (ID_SCHUELER != null ? ID_SCHUELER.hashCode() : 0);
        hash += (ID_LERNFELD != null ? ID_LERNFELD.hashCode() : 0);
        hash += (ID_SCHULJAHR != null ? ID_SCHULJAHR.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Noten_all)) {
            return false;
        }
        Noten_all other = (Noten_all) object;
        if ((this.ID_LERNFELD == null && other.getID_LERNFELD() != null) || (this.ID_LERNFELD != null && !this.ID_LERNFELD.equals(other.getID_LERNFELD()))) {
            return false;
        }
        if ((this.ID_SCHUELER == null && other.getID_SCHUELER()!= null) || (this.ID_SCHUELER != null && !this.ID_SCHUELER.equals(other.getID_SCHUELER()))) {
            return false;
        }
        if ((this.ID_SCHULJAHR == null && other.getID_SCHULJAHR()!= null) || (this.ID_SCHULJAHR != null && !this.ID_SCHULJAHR.equals(other.getID_SCHULJAHR()))) {
            return false;
        }

        return true;
    }
}
