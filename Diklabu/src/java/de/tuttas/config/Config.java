/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.config;

import de.tuttas.util.Log;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

/**
 * Konfigurationsklasse <br>
 *  <h3>Beispielhaftes JSON File</h3>
 * <hr>
 *   {<br>
 *   "debug": true,<br>
 *   "auth": true,<br>
 *   "IMAGE_FILE_PATH": "c:\\Temp\\",<br>
 *   "ATEST_FILE_PATH": "c:\\Temp\\",<br>
 *   "adminusers":["TU","TUTTAS","KEMMRIES"],<br>
 *   "verwaltung:["BÜ"],
 *   "AUTH_TOKE_TIMEOUT" : 432000000,<br>
 *       <br>
 *   "ldaphost": "ldap://192.168.178.147:389",<br>
 *   "binduser": "CN=Administrator,CN=Users,DC=tuttas,DC=de",<br>
 *   "bindpassword":"geheim",<br>
 *   "context": "OU=mmbbs,DC=tuttas,DC=de",<br>
 *   <br>
 *   "smtphost": "smtp.uni-hannover.de",<br>
 *   "port": "587",<br>
 *   "user": "joerg.tuttas@ifbe.uni-hannover.de",<br>
 *   "pass": "geheim"<br>
 *   "clientConfig" : {<br>
 *       "SERVER": "http://localhost:8080",<br>
 *       "WEBSOCKET": "ws://",<br>
 *       "DIKLABUNAME":"DiKlaBu@MMBbS"<br>
 *    }<br>
 *   }<br>
 * <br>
 * <hr>
 * @author  Jörg
 */
public class Config {
    private static Config instance;
    /**
     * Version Nummer
     */
    public final static String VERSION="V 2.0";
    
    /**
     * JSON Objekt für die Client Seite
     */
    public JSONObject clientConfig;
    
    /**

     */

    private Config() {
        BufferedReader br = null;
        try { 
            String pathConfig=System.getProperty("catalina.base")+File.separator+"config.json";
            
            br = new BufferedReader(new FileReader(pathConfig));
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();
            while (line != null) { 
                sb.append(line);
                sb.append(System.lineSeparator());
                line = br.readLine();
            }
            String conf = sb.toString();
                JSONParser parser = new JSONParser();
                JSONObject jo = (JSONObject) parser.parse(conf);
                debug = (boolean)jo.get("debug");
               
                auth = (boolean)jo.get("auth");
                IMAGE_FILE_PATH = (String)jo.get("IMAGE_FILE_PATH");   
                ATEST_FILE_PATH = (String)jo.get("ATEST_FILE_PATH");   
                Log.d("IMage_File_Path="+IMAGE_FILE_PATH); 
                JSONArray ja = (JSONArray) jo.get("adminusers");               
                adminusers = new String[ja.size()];
                for (int i=0;i<adminusers.length;i++) { 
                    adminusers[i]=(String) ja.get(i);
                }
                ja = (JSONArray) jo.get("verwaltung");                 
                verwaltung = new String[ja.size()];
                for (int i=0;i<verwaltung.length;i++) { 
                    verwaltung[i]=(String) ja.get(i);
                    Log.d("Setzte Verwaltung "+(String)ja.get(i));
                }
       
                
                AUTH_TOKE_TIMEOUT=(long)jo.get("AUTH_TOKE_TIMEOUT");
                
                // LDAP Konfiguration
                ldaphost = (String)jo.get("ldaphost"); 
                bindUser = (String) jo.get("binduser");
                bindPassword =(String)jo.get("bindpassword");
                userContext=(String)jo.get("context");
                
                // SMTP Server Konfiguration
                smtphost=(String)jo.get("smtphost");
                port=(String)jo.get("port");
                user=(String)jo.get("user");
                pass=(String)jo.get("pass");
                
                // Client Configuration
                clientConfig = (JSONObject) jo.get("clientConfig");
                clientConfig.put("VERSION",Config.VERSION);
                                 
        } catch (UnsupportedEncodingException ex) {
            Logger.getLogger(Config.class.getName()).log(Level.SEVERE, null, ex);
            ex.printStackTrace();
        } catch (IOException ex) {
            ex.printStackTrace();
            Logger.getLogger(Config.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ParseException ex) {
            ex.printStackTrace();
            Logger.getLogger(Config.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (br!=null) br.close();
            } catch (IOException ex) {
                Logger.getLogger(Config.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }
    
    /**
     * Abfrage der Instanz
     * @return die Instanz
     */
    public static Config getInstance() {
        if (instance==null) {
            instance=new Config();
        }
        return instance;
    }
    
    
    /**
     * Debug Modus
     */
    public static boolean debug=true;

    /**
     * Pfad an dem die Bilder gespeichert werden
     */
    public String IMAGE_FILE_PATH = "c:\\Temp\\";
    public String ATEST_FILE_PATH = "c:\\Temp\\";
    // Nutzer mit Admin Rechten 
    /**
     * Liste der ADMIN Benutzer
     */
    public  String[] adminusers = new String[]{"TU","TUTTAS"};
    
    public  String[] verwaltung = new String[]{"BÜ"};
    
    // Authentifizierung für die RestFul Services notwenig (im debug mode ist das Kennwort mmbbs und der Benutzername das Lehrerkürzel
    /**
     * Authentifizierung bei den Restful Services notwendig
     */
    public boolean auth=true; 
    
    // Zeitspanne in ms, bis zu der ein auth_token verworfen wird 
    /**
     * Lebenszeit des AUTH Tokens in ms
     */
    public long AUTH_TOKE_TIMEOUT=5*24*60*60*1000;
    
    // LDAP Konfiguration
    /**
     * LDAP Bind Benutzer
     */
    public String bindUser;
    /**
     * LDAP BIND KENNWORT
     */
    public String bindPassword;
    /**
     * LDAP Server Adresse
     */
    public String ldaphost;
    /**
     * Context in der der Bind Unser zu finden ist
     */
    public String userContext;
    
    // SMTP Server Konfiguration
    /**
     * SMTP Server
     */
    public String smtphost;
    /**
     * SMTP Port
     */
    public String port;
    /**
     * SMTP Benutzer
     */
    public String user;
    /**
     * SMTP Kennwort
     */
    public String pass;
    
     
}
 
