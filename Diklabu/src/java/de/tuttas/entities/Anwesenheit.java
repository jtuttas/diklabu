/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import java.io.Serializable;
import java.sql.Timestamp;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;

/**
 * Die Anwesenheit
 * @author Jörg
 */
@Entity
@NamedQueries({
   // @NamedQuery(name = "findAnwesenheitbyKlasse", query= "select a from Anwesenheit a INNER JOIN Schueler s on a.ID_SCHUELER=s.ID INNER JOIN Schueler_Klasse sk on sk.ID_SCHUELER=s.ID INNER JOIN Klasse k on k.ID=sk.ID_KLASSE where k.KNAME='FISI13A' and a.DATUM between '2015-09-08' and '2015-09-10' ORDER BY s.ID ")
     @NamedQuery(name = "findAnwesenheitbyKlasse", query= "select NEW de.tuttas.restful.Data.AnwesenheitEintrag(a.DATUM,a.ID_LEHRER,a.ID_SCHUELER,a.VERMERK,a.KRANKMELDUNG) from Anwesenheit a INNER JOIN Schueler s on a.ID_SCHUELER=s.ID INNER JOIN Schueler_Klasse sk on sk.ID_SCHUELER=s.ID INNER JOIN Klasse k on k.ID=sk.ID_KLASSE where k.KNAME like :paramKName and (a.DATUM between :paramFromDate and :paramToDate) and S.ABGANG=\"N\" and a.ID_KLASSE is null ORDER BY s.NNAME,a.DATUM "),
     @NamedQuery(name = "findAnwesenheitbySchueler", query= "select NEW de.tuttas.restful.Data.AnwesenheitEintrag(a.DATUM,a.ID_LEHRER,a.ID_SCHUELER,a.VERMERK,a.KRANKMELDUNG) from Anwesenheit a INNER JOIN Schueler s on a.ID_SCHUELER=s.ID where s.ID= :paramIdSchueler and a.ID_KLASSE is null and (a.DATUM between :paramFromDate and :paramToDate) ORDER BY a.DATUM "),
     @NamedQuery(name = "findAnwesenheitByidSchueler", query= "select a from Anwesenheit a where a.ID_SCHUELER= :paramidSchueler and a.ID_KLASSE is null"),
   //@NamedQuery(name = "findAnwesenheitbyKlasse", query= "select a from Anwesenheit a where a.ID_SCHUELER=14279 and (a.DATUM between :paramFromDate and :paramToDate)")
     @NamedQuery(name = "findAnwesenheitbyDatumAndSchuelerID", query= "select NEW de.tuttas.restful.Data.AnwesenheitEintrag(a.DATUM,a.ID_LEHRER,a.ID_SCHUELER,a.VERMERK,a.KRANKMELDUNG) from Anwesenheit a INNER JOIN Schueler s on a.ID_SCHUELER=s.ID where a.DATUM=:paramDatum and a.ID_SCHUELER=:paramSchuelerID and a.ID_KLASSE is null ORDER BY s.NNAME")
    
})
@IdClass(AnwesenheitId.class)
public class Anwesenheit implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    private Integer ID_SCHUELER;
    @Id
    private Timestamp DATUM;
    @Column(length=3)
    private String ID_LEHRER;
    private String VERMERK;
    private int ID_KLASSE;
    private String KRANKMELDUNG;

    public Anwesenheit() {
    }

     public Anwesenheit(Integer ID_SCHUELER, Timestamp DATUM) {
        this.ID_SCHUELER = ID_SCHUELER;
        this.DATUM = DATUM;
    }
    /**
     * Anwesenheit erzeugen
     * @param ID_SCHUELER ID des Schülers
     * @param DATUM Datum f. Anwesenheit
     * @param ID_LEHRER der Lehrer (Kürzel)
     * @param VERMERK  Vermerk zur Anwesenheit (z.B. ag90)
     */
    public Anwesenheit(Integer ID_SCHUELER, Timestamp DATUM, String ID_LEHRER, String VERMERK,String KRANKMELDUNG) {
        this.ID_SCHUELER = ID_SCHUELER;
        this.DATUM = DATUM;
        this.ID_LEHRER = ID_LEHRER;
        this.VERMERK = VERMERK;        
        this.KRANKMELDUNG=KRANKMELDUNG;
    }

    public String getKRANKMELDUNG() {
        return KRANKMELDUNG;
    }

    public void setKRANKMELDUNG(String KRANKMELDUNG) {
        this.KRANKMELDUNG = KRANKMELDUNG;
    }

    
    
    public void setDATUM(Timestamp DATUM) {
        this.DATUM = DATUM;
    }

    public void setID_LEHRER(String ID_LEHRER) {
        this.ID_LEHRER = ID_LEHRER;
    }

    public void setID_SCHUELER(Integer ID_SCHUELER) {
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

    public Integer getID_SCHUELER() {
        return ID_SCHUELER;
    }

    public String getVERMERK() {
        return VERMERK;
    }

    public void setID_KLASSE(int ID_KLASSE) {
        this.ID_KLASSE = ID_KLASSE;
    }

    public int getID_KLASSE() {
        return ID_KLASSE;
    }
    
    
    @Override
    public String toString() {
        return "Anwesenheit  ID_SCHUELER="+ID_SCHUELER+" Vermerk="+VERMERK;
    }
    
    
    
    
    

    
}
