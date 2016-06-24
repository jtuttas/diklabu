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
 *
 * @author  Jörg
 */
public class Config {
    private static Config instance;
    public final static String VERSION="V 1.96";
    
    public JSONObject clientConfig;
    
    /**
     * Beispielhaftes JSON File
    {
    "debug": true,
    "auth": true,
    "IMAGE_FILE_PATH": "c:\\Temp\\",
    "adminusers":["TU","TUTTAS","KEMMRIES"],
    "AUTH_TOKE_TIMEOUT" : 432000000,
        
    "ldaphost": "ldap://192.168.178.147:389",
    "binduser": "CN=Administrator,CN=Users,DC=tuttas,DC=de",
    "bindpassword":"geheim",
    "context": "OU=mmbbs,DC=tuttas,DC=de",
    
    "smtphost": "smtp.uni-hannover.de",
    "port": "587",
    "user": "joerg.tuttas@ifbe.uni-hannover.de",
    "pass": "geheim"
    "clientConfig" : {
        "SERVER": "http://localhost:8080",
        "WEBSOCKET": "ws://",
        "DIKLABUNAME":"DiKlaBu@MMBbS"
    }
    }

     */

    private Config() {
        BufferedReader br = null;
        try { 
            String pathConfig=System.getProperty("catalina.base")+File.separator+"config.json";
            Log.d("Config Path="+pathConfig);  
            
            br = new BufferedReader(new FileReader(pathConfig));
            StringBuilder sb = new StringBuilder();
            String line = br.readLine();
            while (line != null) { 
                sb.append(line);
                sb.append(System.lineSeparator());
                line = br.readLine();
            }
            Log.d("Habe gelesen:"+sb);
            String conf = sb.toString();
                JSONParser parser = new JSONParser();
                JSONObject jo = (JSONObject) parser.parse(conf);
                debug = (boolean)jo.get("debug");
                auth = (boolean)jo.get("auth");
                IMAGE_FILE_PATH = (String)jo.get("IMAGE_FILE_PATH");   
                Log.d("IMage_File_Path="+IMAGE_FILE_PATH); 
                JSONArray ja = (JSONArray) jo.get("adminusers");               
                adminusers = new String[ja.size()];
                for (int i=0;i<adminusers.length;i++) {
                    adminusers[i]=(String) ja.get(i);
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
                System.out.println("!ClientConfig="+clientConfig.toJSONString());
                                
        } catch (UnsupportedEncodingException ex) {
            Logger.getLogger(Config.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(Config.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ParseException ex) {
            Logger.getLogger(Config.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                br.close();
            } catch (IOException ex) {
                Logger.getLogger(Config.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }
    
    public static Config getInstance() {
        if (instance==null) {
            instance=new Config();
        }
        return instance;
    }
    
    
    public boolean debug=true;
    
    public String IMAGE_FILE_PATH = "c:\\Temp\\";
    //public static final String IMAGE_FILE_PATH = "/home/pi/diklabuimages/";    
    //public static final String IMAGE_FILE_PATH = "C:\\ProgramData\\digitales Klassenbuch\\SchuelerBilder\\";
    
    //public String LDAP_CONF_PATH="c:\\Temp\\ldapconfig.json";
    //public static final String LDAP_CONF_PATH = "/home/pi/ldapconfig.json";    
    //public static final String LDAP_CONF_PATH="c:\\ProgramData\\digitales Klassenbuch\\ldapconfig.json";
    
    // Nutzer mit Admin Rechten 
    public  String[] adminusers = new String[]{"TU","TUTTAS"};
    
    // Authentifizierung für die RestFul Services notwenig (im debug mode ist das Kennwort mmbbs und der Benutzername das Lehrerkürzel
    public boolean auth=true; 
    
    // Zeitspanne in ms, bis zu der ein auth_token verworfen wird 
    public long AUTH_TOKE_TIMEOUT=5*24*60*60*1000;
    
    // LDAP Konfiguration
    public String bindUser;
    public String bindPassword;
    public String ldaphost;
    public String userContext;
    
    // SMTP Server Konfiguration
    public String smtphost;
    public String port;
    public String user;
    public String pass;
    
     
}
 
