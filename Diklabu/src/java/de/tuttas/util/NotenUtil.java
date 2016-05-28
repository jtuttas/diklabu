/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.util;

/**
 *
 * @author Jörg
 */
public class NotenUtil {
    
    private static final String NOTENWERT[] = {"?","sehr gut","gut","befriedigend","ausreichend","mangelhaft","ungenügend","teilgenommen"};
    
    public static String getNote(String Wert) {        
        try {
            return NOTENWERT[Integer.parseInt(Wert)];
        }
        catch (java.lang.NumberFormatException ne) {
            return Wert;
        }
    }
}
