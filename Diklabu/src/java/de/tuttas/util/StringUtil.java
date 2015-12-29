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
public class StringUtil {

    public static String removeGermanCharacters(String id) {
        String out="";
        for (int i=0;i<id.length();i++) {
            char c = id.charAt(i);
            switch (c) {
                case 'ö':
                    out+="oe";
                    break;
                case 'ä':
                    out+="ae";
                    break;
                case 'ü':
                    out+="ue";                    
                    break;
                case 'ß':
                    out+="ss";
                    break;
                case 'Ä':
                    out+="AE";
                    break;
                case 'Ö':
                    out+="OE";
                    break;
                case 'Ü':
                    out+="UE";
                    break;
                default:
                    out+=c;
                    break;
            }
        }
        return out;
    }
    
}
