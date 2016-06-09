/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.io.Serializable;
import java.util.Collection;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;

/**
 *
 * @author Jörg
 */
@Entity
@NamedQueries({
    @NamedQuery(name = "getAntworten", query = "select a from Antworten a where a.teilnehmer = :paramTeilnehmer "),
    @NamedQuery(name = "getAntwort", query = "select a from Antworten a inner join Teilnehmer t on a.teilnehmer = t where t.umfrage = :paramUmfrage and a.teilnehmer = :paramTeilnehmer and a.fragenAntworten = :paramFrage"),
    //@NamedQuery(name = "getAntwortenByKlasse", query = "select a from Antworten a inner join Schueler s on a.ID_SCHUELER=s.ID inner join Schueler_Klasse sk on s.id=sk.ID_SCHUELER inner join Klasse k on sk.ID_KLASSE=k.id where a.ID_UMFRAGE = :paramUmfrageID and t.SCHUELERID= :paramSchuelerID and k.KNAME like :paramKlasse ORDER BY s.NNAME")
})
public class Antworten implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "ID_FRAGE", referencedColumnName = "ID_FRAGE")
    private Fragen fragenAntworten;

    @ManyToOne
    @JoinColumn(name = "ID_ANTWORTSKALA", referencedColumnName = "ID")
    private Antwortskalen antwortskala;
    
    @ManyToOne
    @JoinColumn(name = "KEY", referencedColumnName = "KEY")
    private Teilnehmer teilnehmer; 

    public Antworten() {
    }

    public Antworten( Teilnehmer t, Fragen fragenAntworten, Antwortskalen antwortskala) {
        
        this.fragenAntworten = fragenAntworten;
        this.antwortskala = antwortskala;
        this.teilnehmer = t;
    }
           
    
    public void setAntwortskala(Antwortskalen antwortskala) {
        this.antwortskala = antwortskala;
    }

    public void setFragenAntworten(Fragen fragenAntworten) {
        this.fragenAntworten = fragenAntworten;
    }


    public Antwortskalen getAntwortskala() {
        return antwortskala;
    }

    public Fragen getFragenAntworten() {
        return fragenAntworten;
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
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Antworten)) {
            return false;
        }
        Antworten other = (Antworten) object;
        if ((this.id == null && other.id != null) || (this.id != null && !this.id.equals(other.id))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Antworten[ id=" + id + " Antwortskala="+antwortskala+" ]";
    }
    
}
