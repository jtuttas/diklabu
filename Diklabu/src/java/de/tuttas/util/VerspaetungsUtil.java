/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.util;

import de.tuttas.restful.Data.AnwesenheitEintrag;
import de.tuttas.restful.Data.AnwesenheitObjekt;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * @author Jörg
 */
public class VerspaetungsUtil {

    public static AnwesenheitObjekt parse(AnwesenheitObjekt ao) {

        for (AnwesenheitEintrag ae : ao.getEintraege()) {
            String vermerk = ae.getVERMERK();
            vermerk = vermerk.replace((char) 160, ' ');
            vermerk = vermerk.trim();
            System.out.println("parse (" + vermerk + ")");
            if (vermerk.length() > 0) {
                if (vermerk.charAt(0) == 'a') {
                    if (vermerk.length() > 1 && vermerk.charAt(1) == 'g') {
                        ao.incVerspaetungen();
                        ao.addMinutenVerspaetung(filterMinuten(vermerk, "ag"));
                        if (istEntschuldigt(vermerk, "ag")) {
                            ao.addMinutenVerspaetungEntschuldigt(filterMinuten(vermerk, "ag"));
                        }
                    }
                } else if (vermerk.charAt(0) == 'f') {
                    ao.incFehltage();
                } else if (vermerk.charAt(0) == 'e') {
                    ao.incFehltage();
                    ao.incFehltageEntschuldigt();
                } else if (vermerk.charAt(0) == 'v') {
                    ao.incVerspaetungen();
                    ao.addMinutenVerspaetung(filterMinuten(vermerk, "v"));
                    if (istEntschuldigt(vermerk, "v")) {
                        ao.addMinutenVerspaetungEntschuldigt(filterMinuten(vermerk, "v"));
                    }
                    // Test auf v40xG90
                } else {
                    ao.getParseErrors().add(ae);
                    
                }
            }
        }
        return ao;
    }

    public static boolean isValid(AnwesenheitEintrag ae) {
        String vermerk = ae.getVERMERK();
        return isValid(vermerk);
    }
    
    public static boolean isValid(String vermerk) {
        
         vermerk = vermerk.replace((char) 160, ' ');
            vermerk = vermerk.trim();
            vermerk = vermerk.toLowerCase();
            System.out.println("Test parse Error ("+vermerk+")");
        if (vermerk.length() > 0) {
            if (vermerk.charAt(0) == 'a') {
                return true;
            } else if (vermerk.charAt(0) == 'f') {
                return true;

            } else if (vermerk.charAt(0) == 'e') {
                return true;

            } else if (vermerk.charAt(0) == 'v') {
                return true;
            } else {
                return false;
            }
        }
        return false;
    }

    /**
     * Ermittels die Fehlminuten
     *
     * @param v Der String z.B v90
     * @param firstChar Beginn der Zeichenkette "v" f. Verspätungen "ag" f.
     * anwesend gegangen
     * @return Anzahl der Fehlminuten
     */
    public static int filterMinuten(String v, String firstChar) {
        v = v.toLowerCase();
        Pattern p = Pattern.compile("^" + firstChar + "?\\d+");
        Matcher m = p.matcher(v);
        while (m.find()) {
            String f = m.group().substring(firstChar.length());
            return Integer.parseInt(f);
        }
        return 0;
    }

    /**
     * Überprüft ob die Fehlzeiten entschuldigt sind
     *
     * @param v Der String z.B. v90e
     * @param firstChar Beginn der Zeichenkette "v" f. Verspätungen "ag" f.
     * anwesend gegangen
     * @return true f. entschuldigt, f für unentschuldigt
     */
    public static boolean istEntschuldigt(String v, String firstChar) {
        v = v.toLowerCase();
        Pattern p = Pattern.compile("^" + firstChar + "?\\d+e");
        Matcher m = p.matcher(v);
        while (m.find()) {
            return true;
        }
        return false;
    }

    public static void main(String[] args) {
        //System.out.println("v60test=" + filterMinuten("v60test"));
        System.out.println("v60test2=" + filterMinuten("v60test2", "v"));
        System.out.println("d60test2=" + filterMinuten("d60test2", "v"));
        System.out.println("v60etest=" + filterMinuten("v60etest", "v"));
        System.out.println("av60etest=" + filterMinuten("av60etest", "v"));
        System.out.println("aversuch90=" + filterMinuten("aversuch90", "v"));

        System.out.println("v60test2=" + istEntschuldigt("v60test2", "v"));
        System.out.println("d60test2=" + istEntschuldigt("d60test2", "v"));
        System.out.println("v60etest=" + istEntschuldigt("v60etest", "v"));
        System.out.println("av60etest=" + istEntschuldigt("av60etest", "v"));
        System.out.println("aversuch90=" + istEntschuldigt("aversuch90", "v"));
    }
}
