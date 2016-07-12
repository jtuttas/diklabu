/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.util;

import java.util.Date;
import java.util.GregorianCalendar;

/**
 * Hilfsmethoden für Datum
 * @author Jörg
 */
public class DatumUtil {

    static final String[] WOCHENTAGE = {"So.","Mo.","Di.","Mi.","Do.","Fr.","Sa."};
    
    /**
     * Wochentag ermitteln
     * @param v Nummer des Wochentages
     * @return Text des Wochentages
     */
    public static String getWochentag(int v) {   
        v--;
        return WOCHENTAGE[v];
    }
    
    /**
     * ein Datum formatiert ausgeben
     * @param d das Datum
     * @return Das Datum formatiert in Tag.Monat.Jahr
     */
    public static  String format(Date d) {
        GregorianCalendar c = (GregorianCalendar) GregorianCalendar.getInstance();
        c.setTime(d);
        return ""+c.get(GregorianCalendar.DATE) + "." + (c.get(GregorianCalendar.MONTH) + 1) + "." + c.get(GregorianCalendar.YEAR);
    }
    
    public static int hash(Date d) {
        return (int) (d.getTime()/(1000*60));
    }

    /**
     * Einen Timestamp Formatiert ausgeben
     * @param timeInMillis Anzahl der Millisekunden
     * @return Ausgabe "Tag.Monat.Jahr Stunde:Minute:Sekunde"
     */
    public static String minuteTimeStamp(long timeInMillis) {
        GregorianCalendar c = (GregorianCalendar) GregorianCalendar.getInstance();        
        c.setTime(new Date(timeInMillis));
        return ""+c.get(GregorianCalendar.DATE) + "." + (c.get(GregorianCalendar.MONTH) + 1) + "." + c.get(GregorianCalendar.YEAR)+" "+c.get(GregorianCalendar.HOUR_OF_DAY)+":"+c.get(GregorianCalendar.MINUTE)+":"+c.get(GregorianCalendar.SECOND);        
    }
    
}
