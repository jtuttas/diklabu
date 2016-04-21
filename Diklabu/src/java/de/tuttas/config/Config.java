/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.config;

/**
 *
 * @author Jörg
 */
public class Config {
    public static final boolean debug=true;
    
    //public static final String IMAGE_FILE_PATH = "c:\\Temp\\";
    public static final String IMAGE_FILE_PATH = "/home/pi/diklabuimages/";    
    //public static final String IMAGE_FILE_PATH = "C:\\ProgramData\\digitales Klassenbuch\\SchuelerBilder\\";
    
    //public static final String LDAP_CONF_PATH="c:\\Temp\\ldapconfig.json";
    public static final String LDAP_CONF_PATH = "/home/pi/ldapconfig.json";    
    //public static final String LDAP_CONF_PATH="c:\\ProgramData\\digitales Klassenbuch\\ldapconfig.json";
    
    // Nutzer mit Admin Rechten
    public static final String[] adminusers = new String[]{"TU","TUTTAS"};
    
    // Authentifizierung für die RestFul Services notwenig (im debug mode ist das Kennwort mmbbs und der Benutzername das Lehrerkürzel
    public static boolean auth=true;
    
    
}
