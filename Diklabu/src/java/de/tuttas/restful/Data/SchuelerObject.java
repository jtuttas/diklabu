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
    private String klasse;
    private String login;
    private int id;
    private Date gebDatum;
    private String msg;
    private boolean success;

    public void setSuccess(boolean success) {
        this.success = success;
    }
    
    public boolean getSuccess() {
        return this.success;
    }
    
    

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public String getMsg() {
        return msg;
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

    public String getLogin() {
        return login;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setLogin(String login) {
        this.login = login;
    }
    
    

    public String getKlasse() {
        return klasse;
    }

    public String getName() {
        return name;
    }

    public String getVorname() {
        return vorname;
    }

    public void setKlasse(String Klasse) {
        this.klasse = Klasse;
    }

    public void setName(String Name) {
        this.name = Name;
    }

    public void setVorname(String Vorname) {
        this.vorname = Vorname;
    }

    @Override
    public String toString() {
        return "SchuelerObject Name="+this.getName()+" Vorname="+this.getVorname()+" Klasse="+this.getKlasse();
    }
    
    
    
}
