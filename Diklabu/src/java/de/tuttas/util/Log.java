/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.util;

import de.tuttas.config.Config;

/**
 *
 * @author Jörg
 */
public class Log {
    
    public static void d(String msg) {
        //if (Config.debug) {
            System.out.println(msg);
        //}
    }
}
