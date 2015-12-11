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
   @NamedQuery(name = "getSelectedKlassen", query= "select k from Buchungsfreigabe b JOIN Klasse k on b.ID_KURS=k.ID")
})

public class Buchungsfreigabe implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Integer id;

    /**
     * ID des freigebenen Kurses
     */
    private Integer ID_KURS;

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
    
    

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (id != null ? id.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        if (!(object instanceof Buchungsfreigabe)) {
            return false;
        }
        Buchungsfreigabe other = (Buchungsfreigabe) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Buchungsfreigabe[ id=" + id + " ]";
    }
    
}
