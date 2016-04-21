/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.auth;

/**
 *
 * @author Jörg
 */
public enum Roles {
    SCHUELER,LEHRER,ADMIN;
    
    public static String toString(Roles r) {
        switch (r) {
            case ADMIN:
                return "Admin";
            case LEHRER:
                return "Lehrer";
            case SCHUELER:
                return "Schueler";                       
        }
        return null;
    }
}
