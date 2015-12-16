/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import java.sql.Date;
import java.sql.Timestamp;

/**
 *
 * @author Jörg
 */
public class AnwesenheitEintrag {
    private Timestamp DATUM;
    private String ID_LEHRER;
    private int ID_SCHUELER;
    private String VERMERK;

    public AnwesenheitEintrag() {
    }

    public AnwesenheitEintrag(Timestamp DATUM, String ID_LEHRER, int ID_SCHUELER, String VERMERK) {
        this.DATUM = DATUM;
        this.ID_LEHRER = ID_LEHRER;
        this.ID_SCHUELER = ID_SCHUELER;
        this.VERMERK = VERMERK;
    }

    public void setDATUM(Timestamp DATUM) {
        this.DATUM = DATUM;
    }

    public void setID_LEHRER(String ID_LEHRER) {
        this.ID_LEHRER = ID_LEHRER;
    }

    public void setID_SCHUELER(int ID_SCHUELER) {
        this.ID_SCHUELER = ID_SCHUELER;
    }

    public void setVERMERK(String VERMERK) {
        this.VERMERK = VERMERK;
    }

    public Timestamp getDATUM() {
        return DATUM;
    }

    public String getID_LEHRER() {
        return ID_LEHRER;
    }

    public int getID_SCHUELER() {
        return ID_SCHUELER;
    }

    public String getVERMERK() {
        return VERMERK;
    }

    @Override
    public String toString() {
        return "Anwesenheit ID_SCHUELER="+ID_SCHUELER+" ID_LEHRER="+ID_LEHRER+" VERMERK="+VERMERK+" Datum="+DATUM+"\n";
    }
    
    

    
    
}
