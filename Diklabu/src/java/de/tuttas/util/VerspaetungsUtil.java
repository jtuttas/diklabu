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
 * Hilfsmethoden um Verpätungen zu ermitteln
 * @author Jörg
 */
public class VerspaetungsUtil {

    /**
     * Ermittle fehtage etcc.
     * @param ao das Anwesenheitsobjekt
     * @return das Anwesenheitsobjekt mit Eintragungen
     */
    public static AnwesenheitObjekt parse(AnwesenheitObjekt ao) {

        for (AnwesenheitEintrag ae : ao.getEintraege()) {
            String vermerk = ae.getVERMERK().toLowerCase();
            vermerk = vermerk.replace((char) 160, ' ');
            vermerk = vermerk.trim();
            Log.d("parse (" + vermerk + ")");
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
                    ao.getFehltageUnentschuldigt().add(ae);
                    ao.incFehltage();
                } else if (vermerk.charAt(0) == 'e') {
                    ao.incFehltage();
                    ao.incFehltageEntschuldigt();
                    ao.getFehltageEntschuldigt().add(ae);
                } else if (vermerk.charAt(0) == 'v') {
                    ao.incVerspaetungen();
                    int min = filterMinuten(vermerk, "v");
                    Log.d("V-Minuten sind " + min);
                    boolean e = false;
                    ao.addMinutenVerspaetung(min);
                    String regex = "^v?\\d+";
                    if (istEntschuldigt(vermerk, "v")) {
                        ao.addMinutenVerspaetungEntschuldigt(filterMinuten(vermerk, "v"));
                        e = true;
                        regex = "^v?\\d+e";
                    }
                    // Test auf v40xG90
                    int i = 0;
                    if (e) {
                        i++;
                    }
                    try {
                        Pattern pattern = Pattern.compile(regex);
                        Matcher matcher = pattern.matcher(vermerk);
                        String prefix = "";
                        if (matcher.find()) {
                            prefix = matcher.group(0);
                        }
                        vermerk = vermerk.substring(prefix.length());
                        Log.d("Vermerk ist nun (" + vermerk + ")");
                        min = filterMinuten(vermerk, "g");
                        ao.addMinutenVerspaetung(min);
                        if (istEntschuldigt(vermerk, "g")) {
                            ao.addMinutenVerspaetungEntschuldigt(filterMinuten(vermerk, "g"));
                        }
                    } catch (StringIndexOutOfBoundsException ee) {

                    }

                } else {
                    ao.getParseErrors().add(ae);

                }
            }
        }
        return ao;
    }

    
    /**
     * Testet ob der Anwesenheitseintrag ein gültiger Eintrag ist
     * @param ae der Anwesenheitseintrag
     * @return das Ergebnis der Prüfung
     */
    public static boolean isValid(AnwesenheitEintrag ae) {
        String vermerk = ae.getVERMERK();
        return isValid(vermerk);
    }

    /**
     * Testet ob der Vermekr ein gültiger ist
     * @param vermerk der Vermerk (z.B. ag90e)
     * @return das Ergebnis der Prüfung
     */
    public static boolean isValid(String vermerk) {

        vermerk = vermerk.replace((char) 160, ' ');
        vermerk = vermerk.trim();
        vermerk = vermerk.toLowerCase();
        Log.d("Test parse Error (" + vermerk + ")");
        Pattern p = Pattern.compile("(^v\\d+(e(g\\d+(e|)|)|g\\d+(e|)|)|^a(g\\d+(e|)|)|^e|^f)");
        Matcher m = p.matcher(vermerk);
        while (m.find()) {
            Log.d("is Valid ist (" + m.group() + ")");
            return true;
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
        Log.d("FilterMinuten: v=" + v);
        Pattern p = Pattern.compile("^" + firstChar + "?\\d+");
        Matcher m = p.matcher(v);
        while (m.find()) {
            Log.d("m.goup: m.goup=" + m.group());
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
        //Log.d("v60test=" + filterMinuten("v60test"));
        Log.d("v60test2=" + filterMinuten("v60test2", "v"));
        Log.d("d60test2=" + filterMinuten("d60test2", "v"));
        Log.d("v60etest=" + filterMinuten("v60etest", "v"));
        Log.d("av60etest=" + filterMinuten("av60etest", "v"));
        Log.d("aversuch90=" + filterMinuten("aversuch90", "v"));
        Log.d("v90g90" + filterMinuten("v90g90", "v"));
        Log.d("--");
        Log.d("v60test2=" + istEntschuldigt("v60test2", "v"));
        Log.d("d60test2=" + istEntschuldigt("d60test2", "v"));
        Log.d("v60etest=" + istEntschuldigt("v60etest", "v"));
        Log.d("av60etest=" + istEntschuldigt("av60etest", "v"));
        Log.d("aversuch90=" + istEntschuldigt("aversuch90", "v"));
    }
}
