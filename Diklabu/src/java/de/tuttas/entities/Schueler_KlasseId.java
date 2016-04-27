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
    private int ID_SCHUELER;
    private int ID_KLASSE;

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

    public int getID_KLASSE() {
        return ID_KLASSE;
    }

    public int getID_SCHUELER() {
        return ID_SCHUELER;
    }
    
    
}
