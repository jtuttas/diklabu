/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import de.tuttas.entities.Ausbilder;
import de.tuttas.entities.Bemerkung;
import de.tuttas.entities.Betrieb;
import de.tuttas.entities.Klasse;
import java.sql.Date;
import java.util.List;

/**
 * Schülerobjekt
 * @author Jörg
 */
public class SchuelerObject  implements Comparable<SchuelerObject> {
    
    private Auth auth;
    private List<Klasse>klassen;
    private String name;
    private String vorname;
    private int id;
    private Date gebDatum;
    private Ausbilder ausbilder;
    private Betrieb betrieb;
    private String email;
    private String info;
    private String eduplazaMail;
    private Integer ldist;
    private String Abgang;
    private Integer ID_MMBBS;

    public SchuelerObject() {
    }

    public void setID_MMBBS(Integer ID_MMBBS) {
        this.ID_MMBBS = ID_MMBBS;
    }

    public Integer getID_MMBBS() {
        return ID_MMBBS;
    }

    
    public void setAbgang(String Abgang) {
        this.Abgang = Abgang;
    }

    public String getAbgang() {
        return Abgang;
    }

    
    public void setLdist(Integer ldist) {
        this.ldist = ldist;
    }

    public Integer getLdist() {
        return ldist;
    }

    
    public void setEduplazaMail(String eduplazaMail) {
        this.eduplazaMail = eduplazaMail;
    }

    public String getEduplazaMail() {
        return eduplazaMail;
    }

    
    
    public void setInfo(String info) {
        this.info = info;
    }

    public String getInfo() {
        return info;
    }

    
    public void setEmail(String email) {
        this.email = email;
    }

    public String getEmail() {
        return email;
    }


    public void setBetrieb(Betrieb betrieb) {
        this.betrieb = betrieb;
    }

    public Betrieb getBetrieb() {
        return betrieb;
    }
    
    

    public void setAusbilder(Ausbilder ausbilder) {
        this.ausbilder = ausbilder;
    }

    public Ausbilder getAusbilder() {
        return ausbilder;
    }
    
    
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

    @Override
    public int compareTo(SchuelerObject o) {        
        return this.ldist.compareTo(o.getLdist());
    }

    
    
    
}
