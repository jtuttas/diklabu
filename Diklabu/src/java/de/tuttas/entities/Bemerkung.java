/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.io.Serializable;
import java.sql.Timestamp;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Transient;

/**
 *
 * @author Jörg
 */
@Entity
@NamedQueries({  
     @NamedQuery(name = "findBemerkungbySchuelerId", query= "select b from Bemerkung b where b.ID_SCHUELER= :paramSchuelerId order by b.DATUM DESC"),
     @NamedQuery(name = "findBemerkungbyDate", query= "select b from Bemerkung b where b.DATUM BETWEEN :paramFromDate AND :paramToDate AND b.ID_SCHUELER IN :idList")
})
@IdClass(BemerkungId.class)
public class Bemerkung implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    private int ID_SCHUELER;
    @Id
    private Timestamp DATUM;    
    private String ID_LEHRER;    
    private String BEMERKUNG;
    @Transient
    private boolean success;
    @Transient
    private String msg;

    public Bemerkung() {
    }

    public Bemerkung(Timestamp datum, int id_schueler) {
        this.DATUM=datum;
        this.ID_SCHUELER=id_schueler;
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
        return "de.tuttas.entities.Bemerkung[ ID_SCHUELER=" + ID_SCHUELER +" ID_LEHRER="+ID_LEHRER+ " Datum="+DATUM+" Bemerkung="+BEMERKUNG+"]";
    }
    
}
