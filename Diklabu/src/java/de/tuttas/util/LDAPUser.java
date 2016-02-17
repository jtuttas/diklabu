/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.util;

/**
 *
 * @author Jörg
 */
public class LDAPUser {
    private String NName;
    private String VName;
    private String EMail;
    private String ShortName;
    private String authToken;
    // ShortName ohne deutsche Umlaute
    private String idPlain;

    public LDAPUser() {
    }

    public LDAPUser(String NName, String VName, String EMail, String ShortName) {
        this.NName = NName;
        this.VName = VName;
        this.EMail = EMail;
        this.ShortName = ShortName;
        this.idPlain=StringUtil.removeGermanCharacters(ShortName);
    }

    @Override
    public String toString() {
        return "NName="+NName+" VName="+VName+" EMail="+EMail+" Kürzel="+ShortName;
    }

    public void setIdPlain(String idPlan) {
        this.idPlain = idPlan;
    }

    public String getIdPlain() {
        return idPlain;
    }

    
    public void setAuthToken(String authToken) {
        this.authToken = authToken;
    }

    public String getAuthToken() {
        return authToken;
    }
    
    

    public String getNName() {
        return NName;
    }

    public void setNName(String NName) {
        this.NName = NName;
    }

    public String getVName() {
        return VName;
    }

    public void setVName(String VName) {
        this.VName = VName;
    }

    public String getEMail() {
        return EMail;
    }

    public void setEMail(String EMail) {
        this.EMail = EMail;
    }

    public String getShortName() {
        return ShortName;
    }

    public void setShortName(String ShortName) {
        this.ShortName = ShortName;
        this.idPlain=StringUtil.removeGermanCharacters(ShortName);
    }
    
    
    
}