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
public class Auth {
    String benutzer;
    String kennwort;

    public Auth() {
    }

    public Auth(String benutzer, String kennwort) {
        this.benutzer = benutzer;
        this.kennwort = kennwort;
    }

    
    
    public String getBenutzer() {
        return benutzer;
    }

    public String getKennwort() {
        return kennwort;
    }

    public void setBenutzer(String benutzer) {
        this.benutzer = benutzer;
    }

    public void setKennwort(String kennwort) {
        this.kennwort = kennwort;
    }
    
    
}
