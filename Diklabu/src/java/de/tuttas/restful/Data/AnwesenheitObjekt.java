/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import java.util.ArrayList;
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
    
    
}
