/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import java.sql.Date;

/**
 *
 * @author Jörg
 */
public class Credential {
    private String name;
    private String vorName;
    private Date gebDatum;
    private boolean login=false;
    private String msg;
    private int id;

    public void setId(int id) {
        this.id = id;
    }

    public int getId() {
        return id;
    }
       

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public String getMsg() {
        return msg;
    }

    
    public void setGebDatum(Date gebDatum) {
        this.gebDatum = gebDatum;
    }

    public void setLogin(boolean login) {
        this.login = login;
    }

    public boolean getLogin() {
        return login;
    }
    
    public void setName(String name) {
        this.name = name;
    }

    public void setVorName(String vorName) {
        this.vorName = vorName;
    }

    public Date getGebDatum() {
        return gebDatum;
    }

    public String getName() {
        return name;
    }

    public String getVorName() {
        return vorName;
    }
    
 @Override
    public String toString() {
        return "de.tuttas.model.Pupil[ Name="+name+" Vorname="+vorName+" GebDatum="+gebDatum  +"]";
    }
    
}
