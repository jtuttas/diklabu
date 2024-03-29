/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.util;

import de.tuttas.config.Config;
import de.tuttas.restful.auth.Roles;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.net.ConnectException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.naming.CommunicationException;
import javax.naming.Context;
import javax.naming.NamingEnumeration;
import javax.naming.NamingException;
import javax.naming.directory.Attribute;
import javax.naming.directory.InitialDirContext;
import javax.naming.directory.SearchControls;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

/**
 * LDAP Verbindung
 *
 * @author Jörg
 */
public class LDAPUtil {

    private static LDAPUtil instance;

    private InitialDirContext context;
    private SearchControls ctrls;

    /**
     * Abfrage der Instanz der LDAP Verbiundung
     *
     * @return die Instanz
     */
    public static LDAPUtil getInstance() {
        if (instance == null) {
            instance = new LDAPUtil();
        }
        return instance;
    }

    private LDAPUtil() {
    }

    public static void main(String[] args) {
        System.out.println("Starte...");
        LDAPUtil lpd = LDAPUtil.getInstance();
        LDAPUser u;
        try {
            u = lpd.authenticateJndi("Kirk, James", "Test123!");
            Log.d("Habe gefunden " + u);
            Log.d("TWOFA="+Config.getInstance().clientConfig.get("TWOFA"));
        } catch (Exception ex) {
            ex.printStackTrace();
        }

    }

    /**
     * Benutzer aus der LDAP Abfragen
     *
     * @param username Benutzername
     * @param password Kennwort
     * @return der Benutzer
     * @throws Exception Wenn etwas schief ging
     */
    public LDAPUser authenticateJndi(String username, String password) throws Exception {
// Anbindung ans LDAP
        Properties props = new Properties();
        props.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
        props.put(Context.PROVIDER_URL, Config.getInstance().ldaphost);
        props.put(Context.SECURITY_PRINCIPAL, Config.getInstance().bindUser);//adminuser - User with special priviledge, dn user
        props.put(Context.SECURITY_CREDENTIALS, Config.getInstance().bindPassword);//dn user password
        try {
            context = new InitialDirContext(props);
            ctrls = new SearchControls();
            ctrls.setReturningAttributes(new String[]{"description", "mail", "sn", "initials", "givenName", "memberOf", "userPrincipalName", "distinguishedName","telephonenumber","samAccountName"});
            ctrls.setSearchScope(SearchControls.SUBTREE_SCOPE);
            System.out.println("Bind User OK");
        } catch (NamingException ex) {
            Logger.getLogger(LDAPUtil.class.getName()).log(Level.SEVERE, null, ex);
        }
        NamingEnumeration<javax.naming.directory.SearchResult> answers = context.search(Config.getInstance().userContext, "(samAccountName=" + username + ")", ctrls);
        Log.d("answers=" + answers);
        Log.d("answers=" + answers.hasMore());

        if (!answers.hasMore()) {
            return null;
        }

        javax.naming.directory.SearchResult result = answers.nextElement();

        try {
            for (NamingEnumeration ae = result.getAttributes().getAll(); ae.hasMore();) {
                Attribute attr = (Attribute) ae.next();
                Log.d("attribute: " + attr.getID());

                /* print each value */
                for (NamingEnumeration e = attr.getAll(); e.hasMore(); System.out
                        .println("value: " + e.next()))
            ;
            }
        } catch (NamingException e) {
            e.printStackTrace();
        }
        System.out.println("samAccountName="+result.getAttributes().get("samAccountName").getAll().next().toString());
        String inititials = "";
        if (result.getAttributes().get("initials") != null) {
            inititials = result.getAttributes().get("initials").getAll().next().toString();
        }
        LDAPUser u;
        if (result.getAttributes().get("mail") == null) {
            u = new LDAPUser(result.getAttributes().get("sn").getAll().next().toString(),
                    result.getAttributes().get("givenName").getAll().next().toString(),
                    "",
                    inititials);
        } else {
            u = new LDAPUser(result.getAttributes().get("sn").getAll().next().toString(),
                    result.getAttributes().get("givenName").getAll().next().toString(),
                    result.getAttributes().get("mail").getAll().next().toString(),
                    inititials);
        }
        Log.d("Phone Attribute = "+result.getAttributes().get("telephoneNumber"));
        if (result.getAttributes().get("telephoneNumber") != null) {
            u.setPhone(result.getAttributes().get("telephoneNumber").getAll().next().toString());
            Log.d("Phone="+result.getAttributes().get("telephoneNumber").getAll().next().toString());
        }

        String dName = result.getAttributes().get("distinguishedName").getAll().next().toString();
        Log.d("dName=" + dName);
        if (dName.contains("OU=Lehrer")) {
            Log.d("Ich bin ein Lehrer");
            u.setRole(Roles.toString(Roles.LEHRER));
        } else {
            Log.d("Ich bin ein Schüler");
            u.setRole(Roles.toString(Roles.SCHUELER));
            if (result.getAttributes().get("memberOf") != null) {
                NamingEnumeration memberOf = result.getAttributes().get("memberOf").getAll();
                while (memberOf.hasMore()) {
                    String o = (String)memberOf.next().toString();
                    Log.d("Gruppe: "+o);
                    String courseName = o.split(",")[0];
                    courseName = courseName.substring(courseName.indexOf("=")+1);
                    Log.d("Name der Klasse ist " + courseName);
                    u.addCourse(courseName);
                }
            }
        }

        //String user = result.getNameInNamespace();
        String user=dName;
        Log.d("User="+user);
        try {

            props = new Properties();
            props.put(Context.INITIAL_CONTEXT_FACTORY, "com.sun.jndi.ldap.LdapCtxFactory");
            props.put(Context.PROVIDER_URL, Config.getInstance().ldaphost);
            System.out.println("Login as "+user+" password="+password);
            props.put(Context.SECURITY_PRINCIPAL, user);
            props.put(Context.SECURITY_CREDENTIALS, password);
            if (password.length()==0) {
                System.out.println("Empty Password!");
                return null;
            }
            context = new InitialDirContext(props);
            
        } catch (Exception e) {
            System.out.println ("Exception:"+e.getMessage());
            e.printStackTrace();
            return null;
        }
        return u;
    }
}
