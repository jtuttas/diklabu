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
    private String key;
    private int anzahlFragenBeantwortet;
    private int anzahlFragen;
    
    public Beteiligung() {
    }

    public Beteiligung(String key, int anzahlFragenBeantwortet, int anzahlFragen) {
        this.key = key;
        this.anzahlFragenBeantwortet = anzahlFragenBeantwortet;
        this.anzahlFragen=anzahlFragen;
    }

    public int getAnzahlFragen() {
        return anzahlFragen;
    }

    public void setAnzahlFragen(int anzahlFragen) {
        this.anzahlFragen = anzahlFragen;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getKey() {
        return key;
    }

    

    public int getAnzahlFragenBeantwortet() {
        return anzahlFragenBeantwortet;
    }

    public void setAnzahlFragenBeantwortet(int anzahlFragenBeantwortet) {
        this.anzahlFragenBeantwortet = anzahlFragenBeantwortet;
    }
    
    
    
}
