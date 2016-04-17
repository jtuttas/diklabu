
package de.tuttas.entities;

import java.io.Serializable;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;


/**
 * Klasse bzw. Kurs Entity
 * @author Jörg
 */
@Entity
@NamedQueries({

   @NamedQuery(name = "findKlassebyKurswunsch", query= "select k from Klasse k JOIN Schueler_Klasse sk ON k.ID=sk.ID_KLASSE JOIN Schueler s on s.ID=sk.ID_SCHUELER where (k.ID= :paramWunsch1ID OR k.ID= :paramWunsch2ID OR k.ID= :paramWunsch3ID) AND s.ID= :paramIDSchueler"),
   @NamedQuery(name = "findKlassebyName", query= "select k from Klasse k where k.KNAME= :paramKName"),
   @NamedQuery(name = "findKlassenbySchuelerID", query= "select k from Klasse k JOIN Schueler_Klasse sk ON k.ID=sk.ID_KLASSE  where sk.ID_SCHUELER= :paramIDSchueler"),
   @NamedQuery(name = "findAllKlassen", query= "select NEW de.tuttas.restful.Data.KlasseShort(k.ID,k.ID_LEHRER,k.KNAME) from Klasse k ORDER BY k.KNAME"),
   @NamedQuery(name = "findSchuelerEinerBenanntenKlasse", query= "select s from Schueler s JOIN Schueler_Klasse sk ON s.ID=sk.ID_SCHUELER JOIN Klasse k ON k.ID=sk.ID_KLASSE where k.KNAME like :paramNameKlasse AND s.ABGANG not like 'J' order BY s.NNAME")
})

public class Klasse implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
      @GeneratedValue(strategy=GenerationType.IDENTITY)
    /**
     * Primärschlüssel
     */
    private Integer ID;
    /**
     * ID des Lehrers
     */
    private String  ID_LEHRER;
    /**
     * Name der Klasse des Kurses
     */
    private String TITEL;
    private String KNAME;
    private String NOTIZ;
    private String TERMINE;
    private Integer ID_KATEGORIE;

    public void setID_KATEGORIE(Integer ID_KATEGORIE) {
        this.ID_KATEGORIE = ID_KATEGORIE;
    }

    public void setTERMINE(String TERMINE) {
        this.TERMINE = TERMINE;
    }

    public String getTERMINE() {
        return TERMINE;
    }

    public Integer getID_KATEGORIE() {
        return ID_KATEGORIE;
    }
           
    
    public String getNOTIZ() {
        return NOTIZ;
    }

    public void setNOTIZ(String NOTIZ) {
        this.NOTIZ = NOTIZ;
    }
    
    

    public String getKNAME() {
        return KNAME;
    }

    public void setKNAME(String KNAME) {
        this.KNAME = KNAME;
    }
    
    

    /**
     * Setzen des Names der Klasse des Kurses
     * @param TITEL der Name
     */
    public void setTITEL(String TITEL) {
        this.TITEL = TITEL;
    }

    /**
     * Setzen des Primärschlüssels für den Lehrer der Klasse des Kurses
     * @param ID_LEHRER der Primärschlüssel
     */
    public void setID_LEHRER(String ID_LEHRER) {
        this.ID_LEHRER = ID_LEHRER;
    }

    /**
     * Abfrage des Titels der Klasse des Kurses
     * @return 
     */
    public String getTITEL() {
        return TITEL;
    }

    /**
     * Abfrage des Primärschlüssels des Lehrer des Kurses
     * @return der Primärschlüssel
     */
    public String getID_LEHRER() {
        return ID_LEHRER;
    }
    
    
    /**
     * Abfrage des Primrschlüssels des Kurses
     * @return der Primärschlüssel
     */
    public Integer getId() {
        return ID;
    }

    /**
     * Setzen des Primärschlüssels des Kurses
     * @param id der Primärschlüssel
     */
    public void setId(Integer id) {
        this.ID = id;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (ID != null ? ID.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        if (!(object instanceof Klasse)) {
            return false;
        }
        Klasse other = (Klasse) object;
        if ((this.ID == null && other.ID != null) || (this.ID != null && !this.ID.equals(other.ID))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Klasse[ id=" + ID + " KNAME="+KNAME+"]";
    }
    
}
