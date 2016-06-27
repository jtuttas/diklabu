/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.sql.Timestamp;

/**
 *
 * @author Jörg
 */
public class AnwesenheitId {

    private Integer ID_SCHUELER;
    private Timestamp DATUM;

    public AnwesenheitId() {
    }

    public AnwesenheitId(Integer ID_SCHUELER, Timestamp DATUM) {
        this.ID_SCHUELER = ID_SCHUELER;
        this.DATUM = DATUM;
    }

    public void setDATUM(Timestamp DATUM) {
        this.DATUM = DATUM;
    }

    public void setID_SCHUELER(Integer ID_SCHUELER) {
        this.ID_SCHUELER = ID_SCHUELER;
    }

    public Timestamp getDATUM() {
        return DATUM;
    }

    public Integer getID_SCHUELER() {
        return ID_SCHUELER;
    }
    
    
}
