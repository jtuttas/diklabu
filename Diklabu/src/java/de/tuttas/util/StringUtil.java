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
        String out = "";
        if (id==null) return null;
        for (int i = 0; i < id.length(); i++) {
            char c = id.charAt(i);
            switch (c) {
                case 'ö':
                    out += "oe";
                    break;
                case 'ä':
                    out += "ae";
                    break;
                case 'ü':
                    out += "ue";
                    break;
                case 'ß':
                    out += "ss";
                    break;
                case 'Ä':
                    out += "AE";
                    break;
                case 'Ö':
                    out += "OE";
                    break;
                case 'Ü':
                    out += "UE";
                    break;
                default:
                    out += c;
                    break;
            }
        }
        return out;
    }

    public static String escapeHtml(String string) {
        String escapedTxt = "";
        char tmp = ' ';
        for (int i = 0; i < string.length(); i++) {
            tmp = string.charAt(i);
            switch (tmp) {
                case '<':
                    escapedTxt += "&lt;";
                    break;
                case '>':
                    escapedTxt += "&gt;";
                    break;
                case '&':
                    escapedTxt += "&amp;";
                    break;
                case '"':
                    escapedTxt += "&quot;";
                    break;
                case '\'':
                    escapedTxt += "&#x27;";
                    break;
                case '/':
                    escapedTxt += "&#x2F;";
                    break;
                default:
                    escapedTxt += tmp;
            }
        }
        return escapedTxt;
    }

    public static String addBR(String content) {
        String txt = "";
        char tmp = ' ';
        for (int i = 0; i < content.length(); i++) {
            tmp = content.charAt(i);
            switch (tmp) {
                case 13:
                    txt += "<br></br>";
                    break;
                default:
                    txt += tmp;
            }
        }
        return txt;
    }

}
