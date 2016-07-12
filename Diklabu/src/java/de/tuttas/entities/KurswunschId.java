/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

/**
 * Zusammengesetzter Primärschlüssel für einen Kurswunsch
 * @author Jörg
 */
public class KurswunschId {
    private Integer ID_SCHUELER;
    private Integer ID_KURS;

    public KurswunschId() {
    }

    /**
     * Kurswunsch Primärschlüssel erzeugen
     * @param ID_SCHUELER ID des Schülers
     * @param ID_KURS  ID des Kurses
     */
    public KurswunschId(Integer ID_SCHUELER, Integer ID_KURS) {
        this.ID_SCHUELER = ID_SCHUELER;
        this.ID_KURS = ID_KURS;
    }

    public void setID_KURS(Integer ID_KURS) {
        this.ID_KURS = ID_KURS;
    }

    public Integer getID_KURS() {
        return ID_KURS;
    }

    public void setID_SCHUELER(Integer ID_SCHUELER) {
        this.ID_SCHUELER = ID_SCHUELER;
    }

    public Integer getID_SCHUELER() {
        return ID_SCHUELER;
    }
    
    
}
