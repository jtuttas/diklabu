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
public class DatumUtil {

    static final String[] WOCHENTAGE = {"So.","Mo.","Di.","Mi.","Do.","Fr.","Sa."};
    
    public static String getWochentag(int v) {   
        v--;
        return WOCHENTAGE[v];
    }
    
}
