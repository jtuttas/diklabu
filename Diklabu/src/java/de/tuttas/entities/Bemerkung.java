/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.GregorianCalendar;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Transient;

/**
 *
 * @author Jörg
 */
@Entity
@NamedQueries({  
     @NamedQuery(name = "findBemerkungbyKlasse", query= "select b from Bemerkung b INNER JOIN Schueler s on b.ID_SCHUELER=s.ID INNER JOIN Schueler_Klasse sk on sk.ID_SCHUELER=s.ID INNER JOIN Klasse k on k.ID=sk.ID_KLASSE where k.KNAME like :paramKName order by s.NNAME")
})
public class Bemerkung implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    private int ID_SCHUELER;    
    private Timestamp DATUM;
    private String ID_LEHRER;    
    private String BEMERKUNG;
    @Transient
    private boolean success;
    @Transient
    private String msg;

    public Bemerkung() {
    }

    public Bemerkung(int ID_SCHUELER, String ID_LEHRER, String BEMERKUNG) {
        this.ID_SCHUELER = ID_SCHUELER;
        this.DATUM = new Timestamp(GregorianCalendar.getInstance().getTimeInMillis());
        this.ID_LEHRER = ID_LEHRER;
        this.BEMERKUNG = BEMERKUNG;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMsg() {
        return msg;
    }

    public boolean getSuccess() {
        return success;
    }        
    public String getBEMERKUNG() {
        return BEMERKUNG;
    }

    public void setBEMERKUNG(String BEMERKUNG) {
        this.BEMERKUNG = BEMERKUNG;
    }
    
        
    public int getID_SCHUELER() {
        return ID_SCHUELER;
    }

    public void setID_SCHUELER(int ID_SCHUELER) {
        this.ID_SCHUELER = ID_SCHUELER;
    }

    public Timestamp getDATUM() {
        return DATUM;
    }

    public void setDATUM(Timestamp DATUM) {
        this.DATUM = DATUM;
    }

    public String getID_LEHRER() {
        return ID_LEHRER;
    }

    public void setID_LEHRER(String ID_LEHRER) {
        this.ID_LEHRER = ID_LEHRER;
    }

    

   
    
    
    @Override
    public String toString() {
        return "de.tuttas.entities.Bemerkung[ ID_SCHUELER=" + ID_SCHUELER +" ID_LEHRER="+ID_LEHRER+ " ]";
    }
    
}
