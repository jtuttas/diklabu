/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.util;

import java.util.Date;
import java.util.GregorianCalendar;

/**
 *
 * @author Jörg
 */
public class DatumUtil {

    static final String[] WOCHENTAGE = {"So.","Mo.","Di.","Mi.","Do.","Fr.","Sa."};
    
    public static String getWochentag(int v) {   
        v--;
        return WOCHENTAGE[v];
    }
    
    public static  String format(Date d) {
        GregorianCalendar c = (GregorianCalendar) GregorianCalendar.getInstance();
        c.setTime(d);
        return ""+c.get(GregorianCalendar.DATE) + "." + (c.get(GregorianCalendar.MONTH) + 1) + "." + c.get(GregorianCalendar.YEAR);
    }
    
    public static int hash(Date d) {
        return (int) (d.getTime()/(1000*60));
    }

    public static String minuteTimeStamp(long timeInMillis) {
        GregorianCalendar c = (GregorianCalendar) GregorianCalendar.getInstance();        
        c.setTime(new Date(timeInMillis));
        return ""+c.get(GregorianCalendar.DATE) + "." + (c.get(GregorianCalendar.MONTH) + 1) + "." + c.get(GregorianCalendar.YEAR)+" "+c.get(GregorianCalendar.HOUR_OF_DAY)+":"+c.get(GregorianCalendar.MINUTE)+":"+c.get(GregorianCalendar.SECOND);        
    }
    
}
