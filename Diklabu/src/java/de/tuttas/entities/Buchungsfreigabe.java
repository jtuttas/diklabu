package de.tuttas.entities;

import java.io.Serializable;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;

/**
 * Buchungsfreigabe Entity (´Kurs_ID's der freigegebenen Kurse)
 * @author Jörg
 */
@Entity
@NamedQueries({
   @NamedQuery(name = "getSelectedKlassen", query= "select k from Buchungsfreigabe b JOIN Klasse k on b.ID_KURS=k.ID"),    
   @NamedQuery(name = "findBuchungsfreigabe", query= "select k from Klasse k JOIN Buchungsfreigabe bf on bf.ID_KURS=k.ID")
})

public class Buchungsfreigabe implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    /**
     * ID des freigebenen Kurses
     */
    private Integer ID_KURS;

    public Buchungsfreigabe() {
    }      

    public Buchungsfreigabe(Integer ID_KURS) {
        this.ID_KURS = ID_KURS;
    }
    

    /**
     * Abfrage der ID
     * @return die ID
     */
    public Integer getID_KURS() {
        return ID_KURS;
    }

    public void setID_KURS(Integer ID_KURS) {
        this.ID_KURS = ID_KURS;
    }
    
    @Override
    public String toString() {
        return "de.tuttas.entities.Buchungsfreigabe[ id=" + ID_KURS + " ]";
    }
    
}
