/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import java.sql.Timestamp;

/**
 * Termine einer Klasse
 * @author  Jörg
 */
public class Termin {
    private Timestamp date;
    private long milliseconds;

    public Termin() {
    }

    public Termin(Timestamp date) {
        this.date = date;
        this.milliseconds=date.getTime();
    }
    
    public void setDate(Timestamp date) {
        this.date = date;
        this.milliseconds=date.getTime();
    }

    public Timestamp getDate() {
        return date;
    }

    public long getMilliseconds() {
        return milliseconds;
    }

    public void setMilliseconds(long milliseconds) {
        this.milliseconds = milliseconds;
    }

    @Override
    public String toString() {
        return "Termin"+this.date;
    }
    
    
    
    
}
