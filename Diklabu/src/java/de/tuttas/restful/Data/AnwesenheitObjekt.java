/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

/**
 *
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

    public int getSummeFehltage() {
        return summeFehltage;
    }

    public void setSummeFehltage(int summeFehltage) {
        this.summeFehltage = summeFehltage;
    }

    public int getSummeFehltageEntschuldigt() {
        return summeFehltageEntschuldigt;
    }

    public void setSummeFehltageEntschuldigt(int summeFehltageEntschuldigt) {
        this.summeFehltageEntschuldigt = summeFehltageEntschuldigt;
    }

    public int getAnzahlVerspaetungen() {
        return anzahlVerspaetungen;
    }

    public void setAnzahlVerspaetungen(int anzahlVerspaetungen) {
        this.anzahlVerspaetungen = anzahlVerspaetungen;
    }

    public int getSummeMinutenVerspaetungen() {
        return summeMinutenVerspaetungen;
    }

    public void setSummeMinutenVerspaetungen(int summeMinutenVerspaetungen) {
        this.summeMinutenVerspaetungen = summeMinutenVerspaetungen;
    }

    public int getSummeMinutenVerspaetungenEntschuldigt() {
        return summeMinutenVerspaetungenEntschuldigt;
    }

    public void setSummeMinutenVerspaetungenEntschuldigt(int summeMinutenVerspaetungenEntschuldigt) {
        this.summeMinutenVerspaetungenEntschuldigt = summeMinutenVerspaetungenEntschuldigt;
    }

    public List<AnwesenheitEintrag> getParseErrors() {
        return parseErrors;
    }

    public void setParseErrors(List<AnwesenheitEintrag> parseErrors) {
        this.parseErrors = parseErrors;
    }
    
    
    
    private List<AnwesenheitEintrag> eintraege = new ArrayList();

    public AnwesenheitObjekt() {
    }

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
    
    public static String getTRHead() {
         String tagZeile = "";
        tagZeile += "<tr >";
        tagZeile += "<td width=\"25%\" rowspan=\"2\" style=\"padding:5px;font-size: 11;border: 1px solid black;\"><h3>Name</h3></td>";
        tagZeile += "<td colspan=\"2\" style=\"padding:5px;font-size: 11;border: 1px solid black;\"><h3>Fehltage</h3></td>";
        tagZeile += "<td colspan=\"2\" style=\"padding:5px;font-size: 11;border: 1px solid black;\"><h3>Verspätungen</h3></td>";
        tagZeile += "<td rowspan=\"2\" style=\"padding:5px;font-size: 11;border: 1px solid black;\"><h3>Eintragsfehler</h3></td>";
        tagZeile += "</tr>";
        tagZeile += "<tr >";        
        tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\"><b>gesamt</b></td>";
        tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\"><b>entschuldigt</b></td>";
        tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\"><b>Anzahl (Minuten)</b></td>";
        tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\"><b>Minuten entschuldigt</b></td>";
        tagZeile += "</tr>";
        return tagZeile;
    }

    public String toHTML(String schuelerName) {
         String tagZeile = "<tr>";
         tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\">"+schuelerName+"</td>";         
         tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\">"+this.getSummeFehltage()+"</td>";         
         tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\">"+this.getSummeFehltageEntschuldigt()+"</td>";         
         tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\">"+this.getAnzahlVerspaetungen()+" ("+this.getSummeMinutenVerspaetungen()+")</td>";         
         tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\">"+this.getSummeMinutenVerspaetungenEntschuldigt()+"</td>";         
         tagZeile += "<td style=\"font-size: 11;border: 1px solid black;\">";         
         for (AnwesenheitEintrag ae : parseErrors) {
             DateFormat df = new SimpleDateFormat("dd.MM.yyyy");
             Calendar c = df.getCalendar();
             c.setTimeInMillis(ae.getDATUM().getTime());
             String dat = c.get(Calendar.DAY_OF_MONTH) + "." + (c.get(Calendar.MONTH) + 1) + "." + c.get(Calendar.YEAR);
             tagZeile+=ae.getID_LEHRER()+" ("+ae.getVERMERK()+") "+dat+" ";
         }
         tagZeile += "</td></tr>";
         return tagZeile;
    }
    
    
}
