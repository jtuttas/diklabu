/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import de.tuttas.util.DatumUtil;
import java.io.Serializable;
import java.sql.Timestamp;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.TimeZone;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.TableGenerator;
import javax.persistence.Transient;
import org.apache.jasper.Constants;

/**
 *
 * @author Jörg
 */
@Entity
@NamedQueries({
    @NamedQuery(name = "findVerlaufbyKlasse", query = "select v from Verlauf v INNER JOIN Klasse k on v.ID_KLASSE=k.ID where k.KNAME like :paramKName and (v.DATUM between :paramFromDate and :paramToDate) ORDER BY v.DATUM,v.STUNDE "),
    @NamedQuery(name = "findVerlaufbyDatumStundeAndKlassenID", query = "select v from Verlauf v where v.ID_KLASSE= :paramKlassenID and v.DATUM=:paramDatum and v.STUNDE = :paramStunde"),})
public class Verlauf implements Serializable {

    private static final long serialVersionUID = 1L;
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Id
    private Integer ID;
    private int ID_KLASSE;
    private Timestamp DATUM;
    private String STUNDE;
    private String ID_LEHRER;
    private String ID_LERNFELD;
    private String INHALT;
    private String BEMERKUNG;
    private String AUFGABE;

    @Transient
    private String Wochentag;
    @Transient
    private int kw;

    public void setKw(int kw) {
        this.kw = kw;
    }

    public int getKw() {
        Calendar c = Calendar.getInstance();
        c.setTime(DATUM);
        return c.get(Calendar.WEEK_OF_YEAR);
    }

    public void setWochentag(String Wochentag) {
        this.Wochentag = Wochentag;
    }

    public String getWochentag() {
        Calendar c = Calendar.getInstance();
        c.setTime(DATUM);
        int dayOfWeek = c.get(Calendar.DAY_OF_WEEK);
        return DatumUtil.getWochentag(dayOfWeek);
    }

    public Verlauf() {
    }

    public Verlauf(int ID_KLASSE, Timestamp DATUM, String STUNDE, String ID_LEHRER, String ID_LERNFELD, String INHALT, String BEMERKUNG, String AUFGABE) {
        this.ID_KLASSE = ID_KLASSE;
        this.DATUM = DATUM;
        this.STUNDE = STUNDE;
        this.ID_LEHRER = ID_LEHRER;
        this.ID_LERNFELD = ID_LERNFELD;
        this.INHALT = INHALT;
        this.BEMERKUNG = BEMERKUNG;
        this.AUFGABE = AUFGABE;
    }

    public Integer getID() {
        return ID;
    }

    public void setID(Integer ID) {
        this.ID = ID;
    }

    public int getID_KLASSE() {
        return ID_KLASSE;
    }

    public void setID_KLASSE(int ID_KLASSE) {
        this.ID_KLASSE = ID_KLASSE;
    }

    public Timestamp getDATUM() {
        return DATUM;
    }

    public void setDATUM(Timestamp DATUM) {
        this.DATUM = DATUM;
    }

    public String getSTUNDE() {
        return STUNDE;
    }

    public void setSTUNDE(String STUNDE) {
        this.STUNDE = STUNDE;
    }

    public String getID_LEHRER() {
        return ID_LEHRER;
    }

    public void setID_LEHRER(String ID_LEHRER) {
        this.ID_LEHRER = ID_LEHRER;
    }

    public String getID_LERNFELD() {
        return ID_LERNFELD;
    }

    public void setID_LERNFELD(String ID_LERNFELD) {
        this.ID_LERNFELD = ID_LERNFELD;
    }

    public String getINHALT() {
        return INHALT;
    }

    public void setINHALT(String INHALT) {
        this.INHALT = INHALT;
    }

    public String getBEMERKUNG() {
        return BEMERKUNG;
    }

    public void setBEMERKUNG(String BEMERKUNG) {
        this.BEMERKUNG = BEMERKUNG;
    }

    public String getAUFGABE() {
        return AUFGABE;
    }

    public void setAUFGABE(String AUFGABE) {
        this.AUFGABE = AUFGABE;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (ID != null ? ID.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        // TODO: Warning - this method won't work in the case the id fields are not set
        if (!(object instanceof Verlauf)) {
            return false;
        }
        Verlauf other = (Verlauf) object;
        if ((this.ID == null && other.ID != null) || (this.ID != null && !this.ID.equals(other.ID))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "de.tuttas.entities.Verlauf[ ID=" + ID + " Datum=" + DATUM + " Klasse=" + ID_KLASSE + " Stunde=" + STUNDE + " Wochentag=" + this.getWochentag() + "]\n";
    }

    public String toHTML() {
        String h = "";
        h += "<tr>";
        h += "<td width='3%' style=\"font-size: 11;border: 1px solid black;\">" + getID_LEHRER() + "</td>";
        h += "<td width='5%' style=\"font-size: 11;border: 1px solid black;\">" + getID_LERNFELD() + "</td>";
        h += "<td width='7%' style=\"font-size: 11;border: 1px solid black;\">" + getSTUNDE() + "</td>";
        h += "<td style=\"font-size: 11;border: 1px solid black;\">" + getINHALT() + "</td>";
        h += "<td style=\"font-size: 11;border: 1px solid black;\">" + getBEMERKUNG() + "</td>";
        h += "<td style=\"font-size: 11;border: 1px solid black;\">" + getAUFGABE() + "</td>";
        h += "</tr>";
        return h;
    }

    public static String getTRHead() {
        String tagZeile = "";
        tagZeile += ("<tr >");
        tagZeile += ("<td  width='3%' style=\"font-size: 11;border: 1px solid black;\"><b>LK</b></td>");
        tagZeile += ("<td  width='5%' style=\"font-size: 11;border: 1px solid black;\"><b>LF</b></td>");
        tagZeile += ("<td  width='7%' style=\"font-size: 11;border: 1px solid black;\"><b>Stunde</b></td>");
        tagZeile += ("<td  style=\"font-size: 11;border: 1px solid black;\"><b>Inhalt</b></td>");
        tagZeile += ("<td  style=\"font-size: 11;border: 1px solid black;\"><b>Bemerkungen</b></td>");
        tagZeile += ("<td  style=\"font-size: 11;border: 1px solid black;\"><b>Lernsituation</b></td>");
        tagZeile += ("</tr>");
        return tagZeile;
    }

}
