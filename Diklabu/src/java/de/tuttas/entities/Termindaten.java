/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.io.Serializable;
import java.sql.Timestamp;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;

/**
 *
 * @author Jörg
 */
/**
 * select Distinct DATUM from TERMINDATEN as t where DATUM between '2015-09-01' and '2015-11-02'
and exists 
 (select * from TERMINDATEN as t2 where t2.ID_TERMIN=117 and t.DATUM=t2.DATUM)
and exists 
 (select * from TERMINDATEN as t3 where t3.ID_TERMIN=120 and t.DATUM=t3.DATUM)
 
 */

@NamedQueries({
    @NamedQuery(name = "findAllTermine", query = "select distinct NEW de.tuttas.restful.Data.Termin(t.DATUM) from Termindaten t where t.DATUM between :fromDate and :toDate ORDER BY t.DATUM"),
    @NamedQuery(name = "findAllTermineOneFilter", query = "select distinct NEW de.tuttas.restful.Data.Termin(t.DATUM) from Termindaten t where t.ID_TERMIN= :filter1 and t.DATUM between :fromDate and :toDate ORDER BY t.DATUM"),
    @NamedQuery(name = "findAllTermineTwoFilters", query = "select distinct NEW de.tuttas.restful.Data.Termin(t.DATUM) from Termindaten t where t.DATUM between :fromDate and :toDate and exists (select t.DATUM from Termindaten t2 where t2.ID_TERMIN=:filter1 and t.DATUM=t2.DATUM) and exists (select t.DATUM from Termindaten t3 where t3.ID_TERMIN=:filter2 and t.DATUM=t3.DATUM)")
})
@Entity
public class Termindaten implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    private Integer ID_TERMIN;
    @Id
    private Timestamp DATUM;

    public void setDATUM(Timestamp DATUM) {
        this.DATUM = DATUM;
    }

    public void setID_TERMIN(Integer ID_TERMINE) {
        this.ID_TERMIN = ID_TERMINE;
    }

    public Timestamp getDATUM() {
        return DATUM;
    }

    public Integer getID_TERMIN() {
        return ID_TERMIN;
    }
        
    


    @Override
    public String toString() {
        return "de.tuttas.entities.Termiondaten[ id=" + ID_TERMIN + " Datum="+DATUM+" ]";
    }
    
}
