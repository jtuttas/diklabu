/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import com.sun.xml.wss.util.DateUtils;
import de.tuttas.util.DatumUtil;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

/**
 * Anwesenheit eines Schülers
 * @author Jörg
 */
public class AnwesenheitObjekt {
    private int id_Schueler;
    private int summeFehltage=0;
    private int summeFehltageEntschuldigt=0;
    private int anzahlVerspaetungen=0;
    private int summeMinutenVerspaetungen=0;
    private int summeMinutenVerspaetungenEntschuldigt=0;
    private List<AnwesenheitEintrag> parseErrors = new ArrayList<>();
    private List<AnwesenheitEintrag> fehltageEntschuldigt = new ArrayList<>();
    private List<AnwesenheitEintrag> fehltageUnentschuldigt = new ArrayList<>();
    private List<AnwesenheitEintrag> eintraege = new ArrayList();

    /**
     * Liste der Fehltage die entschuldigt sind
     * @param fehltageEntschuldig Liste der Fehltage die Antschuldigt sind
     */
    public void setFehltageEntschuldigt(List<AnwesenheitEintrag> fehltageEntschuldig) {
        this.fehltageEntschuldigt = fehltageEntschuldig;
    }

    /**
     * Liste der Fehltage die unentschuldigt sind
     * @param fehltageUnentschuldigt Liste der Fehltage die unentschuldigt sind
     */
    public void setFehltageUnentschuldigt(List<AnwesenheitEintrag> fehltageUnentschuldigt) {
        this.fehltageUnentschuldigt = fehltageUnentschuldigt;
    }

    /**
     * Abfrage der entschuldigen Fehltage
     * @return Liste der Fehltage die entschuldigt sind
     */
    public List<AnwesenheitEintrag> getFehltageEntschuldigt() {
        return fehltageEntschuldigt;
    }

    /**
     * Abfrage der unentschuldigten Fehltage
     * @return Liste der Fehltage die unentschuldigt sind
     */
    public List<AnwesenheitEintrag> getFehltageUnentschuldigt() {
        return fehltageUnentschuldigt;
    }
    
    /**
     * Abfrage der Summe der Fehltage
     * @return Anzahl der Fehltage gesammt (entschuldigt und unentschuldigt)
     */
    public int getSummeFehltage() {
        return summeFehltage;
    }

    public void setSummeFehltage(int summeFehltage) {
        this.summeFehltage = summeFehltage;
    }

    /**
     * Abfrage der Summer der entschuldigten Fehltage
     * @return Anzahl der entschuldigten Fehltage
     */
    public int getSummeFehltageEntschuldigt() {
        return summeFehltageEntschuldigt;
    }

    public void setSummeFehltageEntschuldigt(int summeFehltageEntschuldigt) {
        this.summeFehltageEntschuldigt = summeFehltageEntschuldigt;
    }

    /**
     * Abdfrage der Anzahl der Verspätungen
     * @return Anzahl der Verspätungen (entschuldigt / unentschuldigt)
     */
    public int getAnzahlVerspaetungen() {
        return anzahlVerspaetungen;
    }

    public void setAnzahlVerspaetungen(int anzahlVerspaetungen) {
        this.anzahlVerspaetungen = anzahlVerspaetungen;
    }

    /**
     * Summe der Verspätungen (Minuten)
     * @return Summe der Verspätungen in Minuten
     */
    public int getSummeMinutenVerspaetungen() {
        return summeMinutenVerspaetungen;
    }

    public void setSummeMinutenVerspaetungen(int summeMinutenVerspaetungen) {
        this.summeMinutenVerspaetungen = summeMinutenVerspaetungen;
    }

    /**
     * Summe der Verspätungen in Minuten, die entshculdigt sind
     * @return Summe
     */
    public int getSummeMinutenVerspaetungenEntschuldigt() {
        return summeMinutenVerspaetungenEntschuldigt;
    }

    public void setSummeMinutenVerspaetungenEntschuldigt(int summeMinutenVerspaetungenEntschuldigt) {
        this.summeMinutenVerspaetungenEntschuldigt = summeMinutenVerspaetungenEntschuldigt;
    }

    /**
     * Eintragfehler abfragen
     * @return Liste der Anwesenheitseinträge die nicht der Norm entsprechen
     */
    public List<AnwesenheitEintrag> getParseErrors() {
        return parseErrors;
    }

    public void setParseErrors(List<AnwesenheitEintrag> parseErrors) {
        this.parseErrors = parseErrors;
    }
    
        

    public AnwesenheitObjekt() {
    }

    /**
     * Neues Anwesenheitsobjekt erzeugen
     * @param id_Schueler ID des Schülers
     */
    public AnwesenheitObjekt(int id_Schueler) {
        this.id_Schueler = id_Schueler;
    }

    public List<AnwesenheitEintrag> getEintraege() {
        return eintraege;
    }

    public void setEintraege(List<AnwesenheitEintrag> eintraege) {
        this.eintraege = eintraege;
    }

    public int getId_Schueler() {
        return id_Schueler;
    }

    public void setId_Schueler(int id_Schueler) {
        this.id_Schueler = id_Schueler;
    }

    public void incFehltage() {
        this.summeFehltage++;
    }

    public void incFehltageEntschuldigt() {
        this.summeFehltageEntschuldigt++;
    }

    public void incVerspaetungen() {
        this.anzahlVerspaetungen++;
    }

    public void addMinutenVerspaetung(int filterMinuten) {
        this.summeMinutenVerspaetungen+=filterMinuten;
    }

    public void addMinutenVerspaetungEntschuldigt(int filterMinuten) {
        this.summeMinutenVerspaetungenEntschuldigt+=filterMinuten;
    }
    
    /**
     * Ausgabe des Tabellenkopfes für eine Anwesenheitsdokumentation
     * @return TR
     */
    public static String getTRHead() {
         String tagZeile = "";
        tagZeile += "<tr >";
        tagZeile += "<td width=\"18%\" rowspan=\"2\" style=\"padding:5px;font-size: 11;border: 1px solid black;\"><h3>Name</h3></td>";
        tagZeile += "<td colspan=\"2\" style=\"padding:5px;font-size: 11;border: 1px solid black;\"><h3>Fehltage</h3></td>";
        tagZeile += "<td colspan=\"2\" style=\"padding:5px;font-size: 11;border: 1px solid black;\"><h3>Verspätungen</h3></td>";
        tagZeile += "<td width=\"18%\" rowspan=\"2\" style=\"padding:5px;font-size: 11;border: 1px solid black;\"><h3>Eintragsfehler</h3></td>";
        tagZeile += "</tr>";
        tagZeile += "<tr >";        
        tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\">gesamt / <b>entschuldigt</b></td>";
        tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\"><b>Tage</b></td>";
        tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\"><b>Anzahl (Minuten)</b></td>";
        tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\"><b>Minuten entschuldigt</b></td>";
        tagZeile += "</tr>";
        return tagZeile;
    }

    /**
     * Ausgabe der Anwesenheit als HTML Tabellen zeile (zur Dokumentation)
     * @param schuelerName
     * @return HTML TR
     */
    public String toHTML(String schuelerName) {
         String tagZeile = "<tr>";
         tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\">"+schuelerName+"</td>";         
         tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\">"+this.getSummeFehltage()+" / <b>"+this.getSummeFehltageEntschuldigt()+"</b></td>";         
         tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\">";
         for (AnwesenheitEintrag ae : fehltageEntschuldigt) {
             tagZeile += "<b>"+DatumUtil.format(ae.getDATUM())+"</b> &nbsp;";
         }
         for (AnwesenheitEintrag ae : fehltageUnentschuldigt) {
             tagZeile += "<i>"+DatumUtil.format(ae.getDATUM())+"</i> &nbsp;";
         }
         tagZeile += "</td>";
         tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\">"+this.getAnzahlVerspaetungen()+" ("+this.getSummeMinutenVerspaetungen()+")</td>";         
         tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\">"+this.getSummeMinutenVerspaetungenEntschuldigt()+"</td>";         
         tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\">";         
         for (AnwesenheitEintrag ae : parseErrors) {
             DateFormat df = new SimpleDateFormat("dd.MM.yyyy");
             Calendar c = df.getCalendar();
             c.setTimeInMillis(ae.getDATUM().getTime());
             String dat = c.get(Calendar.DAY_OF_MONTH) + "." + (c.get(Calendar.MONTH) + 1) + "." + c.get(Calendar.YEAR);
             tagZeile+=ae.getID_LEHRER()+" ("+ae.getVERMERK()+") "+dat+" <br></br>";
         }
         tagZeile += "</td></tr>";
         return tagZeile;
    }
    
    
}
