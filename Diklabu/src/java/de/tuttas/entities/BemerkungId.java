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
 * Zusammengesetzter Primärschlüssel für eine Bemerkung zu einem Anwesenheitseintrag
 * @author Jörg
 */
public class BemerkungId implements Serializable {
    @Id
    private int ID_SCHUELER;    
     @Id
    private Timestamp DATUM;
    

    public BemerkungId() {
    }

    /**
     * Primärschlüssel erzeugen
     * @param Datum Datum des Eintrages
     * @param ID_SCHUELER ID des Schülers
     */
    public BemerkungId(Timestamp Datum,int ID_SCHUELER) {
        this.ID_SCHUELER = ID_SCHUELER;
        this.DATUM=Datum;
    }

    public Timestamp getDATUM() {
        return DATUM;
    }


    public int getID_SCHUELER() {
        return ID_SCHUELER;
    }
    
    @Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result;
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
		if (ID_SCHUELER != other.ID_SCHUELER)
			return false;
                if (!DATUM.equals(other.DATUM)) {
                    return false;
                }
		return true;
	}
    
}
