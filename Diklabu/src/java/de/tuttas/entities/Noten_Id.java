/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

/**
 * Zusammengesetzter Primärschlüssel für einen Noteneintrag
 * @author Jörg
 */
public class Noten_Id {
  private Integer ID_SCHUELER;
   
    private String ID_LERNFELD;   

    public Noten_Id() {
    }

    /**
     * Primärschlüssel Noteneintrag erzeugen
     * @param ID_SCHUELER ID des Schülers
     * @param ID_LERNFELD  ID des Lernfeldes
     */
    public Noten_Id(Integer ID_SCHUELER, String ID_LERNFELD) {
        this.ID_SCHUELER = ID_SCHUELER;
        this.ID_LERNFELD = ID_LERNFELD;
    }

    public String getID_LERNFELD() {
        return ID_LERNFELD;
    }

    public Integer getID_SCHUELER() {
        return ID_SCHUELER;
    }

    public void setID_LERNFELD(String ID_LERNFELD) {
        this.ID_LERNFELD = ID_LERNFELD;
    }

    public void setID_SCHUELER(Integer ID_SCHUELER) {
        this.ID_SCHUELER = ID_SCHUELER;
    }
    
    
}
