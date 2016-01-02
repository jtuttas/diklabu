/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import de.tuttas.entities.Klasse;
import java.sql.Date;
import java.util.List;

/**
 *
 * @author Jörg
 */
public class SchuelerObject {
    
    private Auth auth;
    private List<Klasse>klassen;
    private String name;
    private String vorname;
    private int id;
    private Date gebDatum;

    
    

    public Auth getAuth() {
        return auth;
    }

    public void setAuth(Auth auth) {
        this.auth = auth;
    }

    public List<Klasse> getKlassen() {
        return klassen;
    }

    public void setKlassen(List<Klasse> klassen) {
        this.klassen = klassen;
    }

    
    public void setGebDatum(Date gebDatum) {
        this.gebDatum = gebDatum;
    }

    public Date getGebDatum() {
        return gebDatum;
    }
    
    public int getId() {
        return id;
    }


    public void setId(int id) {
        this.id = id;
    }


    public String getName() {
        return name;
    }

    public String getVorname() {
        return vorname;
    }

    public void setName(String Name) {
        this.name = Name;
    }

    public void setVorname(String Vorname) {
        this.vorname = Vorname;
    }

    
    
    
}
