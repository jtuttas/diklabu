/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import de.tuttas.util.DatumUtil;
import java.io.Serializable;
import java.sql.Timestamp;
import javax.persistence.Id;

/**
 *
 * @author Jörg
 */
public class BemerkungId implements Serializable {
    @Id
    private int ID_SCHUELER;    
     @Id
    private Timestamp DATUM;
    @Id
    private String ID_LEHRER;    

    public BemerkungId() {
    }

    public BemerkungId(int ID_SCHUELER, String ID_LEHRER, Timestamp Datum) {
        this.ID_SCHUELER = ID_SCHUELER;
        this.ID_LEHRER = ID_LEHRER;
        this.DATUM=Datum;
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
    
    @Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result
				+ ((ID_LEHRER == null) ? 0 : ID_LEHRER.hashCode());
		result = prime * result + ID_SCHUELER+DatumUtil.hash(DATUM) ;                
		return result;
	}
 
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		BemerkungId other = (BemerkungId) obj;
		if (ID_LEHRER == null) {
			if (other.ID_LEHRER != null)
				return false;
		} else if (!ID_LEHRER.equals(other.ID_LEHRER))
			return false;
		if (ID_SCHUELER != other.ID_SCHUELER)
			return false;
                if (!DATUM.equals(other.DATUM)) {
                    return false;
                }
		return true;
	}
    
}