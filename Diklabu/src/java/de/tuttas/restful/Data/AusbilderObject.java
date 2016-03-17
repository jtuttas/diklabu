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
public class AusbilderObject {
    private int id_schueler;
    private String anrede;
    private String nName;
    private String email;
    private String telefon;
    private String fax;
    private String name;
    private String plz;
    private String ort;
    private String strasse;
    private String nr;

    public AusbilderObject() {
    }
    
    public  AusbilderObject(int id) {
        this.id_schueler=id;
    }

    public AusbilderObject(int id_schueler, String anrede, String nName, String email, String telefon, String fax, String name, String plz, String ort, String strasse, String nr) {
        this.id_schueler = id_schueler;
        this.anrede = anrede;
        this.nName = nName;
        this.email = email;
        this.telefon = telefon;
        this.fax = fax;
        this.name = name;
        this.plz = plz;
        this.ort = ort;
        this.strasse = strasse;
        this.nr = nr;
    }
    
    

    public int getId_schueler() {
        return id_schueler;
    }

    public void setId_schueler(int id_schueler) {
        this.id_schueler = id_schueler;
    }

    public String getAnrede() {
        return anrede;
    }

    public void setAnrede(String anrede) {
        this.anrede = anrede;
    }

    public String getnName() {
        return nName;
    }

    public void setnName(String nName) {
        this.nName = nName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getTelefon() {
        return telefon;
    }

    public void setTelefon(String telefon) {
        this.telefon = telefon;
    }

    public String getFax() {
        return fax;
    }

    public void setFax(String fax) {
        this.fax = fax;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPlz() {
        return plz;
    }

    public void setPlz(String plz) {
        this.plz = plz;
    }

    public String getOrt() {
        return ort;
    }

    public void setOrt(String ort) {
        this.ort = ort;
    }

    public String getStrasse() {
        return strasse;
    }

    public void setStrasse(String strasse) {
        this.strasse = strasse;
    }

    public String getNr() {
        return nr;
    }

    public void setNr(String nr) {
        this.nr = nr;
    }
    
    
    
}
