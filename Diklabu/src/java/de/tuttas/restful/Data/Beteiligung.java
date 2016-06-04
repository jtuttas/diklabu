/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

/**
 *
 * @author Jörg
 */
public class Beteiligung {
    private int schuelerId;
    private int anzahlFragenBeantwortet;
    private int anzahlFragen;
    
    public Beteiligung() {
    }

    public Beteiligung(int schuelerId, int anzahlFragenBeantwortet, int anzahlFragen) {
        this.schuelerId = schuelerId;
        this.anzahlFragenBeantwortet = anzahlFragenBeantwortet;
        this.anzahlFragen=anzahlFragen;
    }

    public int getAnzahlFragen() {
        return anzahlFragen;
    }

    public void setAnzahlFragen(int anzahlFragen) {
        this.anzahlFragen = anzahlFragen;
    }

    
    public int getSchuelerId() {
        return schuelerId;
    }

    public void setSchuelerId(int schuelerId) {
        this.schuelerId = schuelerId;
    }

    public int getAnzahlFragenBeantwortet() {
        return anzahlFragenBeantwortet;
    }

    public void setAnzahlFragenBeantwortet(int anzahlFragenBeantwortet) {
        this.anzahlFragenBeantwortet = anzahlFragenBeantwortet;
    }
    
    
    
}
