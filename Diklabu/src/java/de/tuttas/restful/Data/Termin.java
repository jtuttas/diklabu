/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import java.sql.Timestamp;

/**
 *
 * @author Jörg
 */
public class Termin {
    private Timestamp date;

    public Termin() {
    }

    public Termin(Timestamp date) {
        this.date = date;
    }
    
    public void setDate(Timestamp date) {
        this.date = date;
    }

    public Timestamp getDate() {
        return date;
    }
    
    
}
