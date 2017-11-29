/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.auth;

import de.tuttas.config.Config;
import de.tuttas.entities.Lehrer;
import de.tuttas.restful.Data.Auth;
import de.tuttas.util.LDAPUser;
import de.tuttas.util.LDAPUtil;
import de.tuttas.util.Log;
import de.tuttas.util.StringUtil;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.security.GeneralSecurityException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;
import javax.persistence.Query;
import javax.security.auth.login.LoginException;

/**
 * Authentifizierungs Klasse
 *
 * @author Jörg
 */
public final class Authenticator {

    private static Authenticator authenticator = null;


    // An authentication token storage which stores <auth_token,  LDAPUser>.
    private final Map<String, LDAPUser> authorizationTokensStorage = new HashMap();

    // Session ID and PIN Map
    private final Map<String, Long> pinStorage = new HashMap();
    private final Map<String, LDAPUser> userStorage = new HashMap();
    
    
    private Authenticator() {
        /*
        if (Config.getInstance().debug) {
            EntityManagerFactory emf = Persistence.createEntityManagerFactory("DiklabuPU");
            EntityManager em = emf.createEntityManager();
            Query query = em.createNamedQuery("findAllTeachers");
            List<Lehrer> lehrer = query.getResultList();

            for (Lehrer l : lehrer) {
                Log.d("Anlegen Benutzer (" + l.getId() + ")");
                LDAPUser lu = new LDAPUser();
                lu.setEMail(l.getEMAIL());
                lu.setIdPlain(l.getIdplain());
                lu.setNName(l.getNNAME());
                lu.setVName(l.getVNAME());
                lu.setPhone(l.getTELEFON());
                usersStorage.put(l.getId(), "mmbbs");
                rolesStorage.put(l.getId(), Roles.toString(Roles.LEHRER));
            }

            // Lehrer Testzugang
            usersStorage.put("ZZZ", "mmbbs");
            rolesStorage.put("ZZZ", Roles.toString(Roles.LEHRER));
            // Schüler Testzugang
            usersStorage.put("FISI14A.AUE", "mmbbs");
            rolesStorage.put("FISI14A.AUE", Roles.toString(Roles.SCHUELER));
            // Schüler Testzugang
            usersStorage.put("FISI15B.MUSTERFRAU", "mmbbs");
            rolesStorage.put("FISI15B.MUSTERFRAU", Roles.toString(Roles.SCHUELER));
            // Schüler Testzugang
            usersStorage.put("FISI14A.ZZZ", "mmbbs");
            rolesStorage.put("FISI14A.ZZZ", Roles.toString(Roles.SCHUELER));
        }
        */
    }

    /**
     * Instanz der Authentifizierungsklasse abfragen
     *
     * @return Instanz der Authentifizierungsklasse
     */
    public static Authenticator getInstance() {
        if (authenticator == null) {
            authenticator = new Authenticator();
        }

        return authenticator;
    }

    /**
     * Login einer Users
     * @param username Benutzernamen
     * @param password Kennwort
     * @return Identifizierter Benutzer
     * @throws LoginException Keine Authentifizierung möglich
     */
    public LDAPUser login(String username, String password) throws LoginException {
        if (!Config.getInstance().debug) {
            LDAPUtil ldap;
            try {
                ldap = LDAPUtil.getInstance();
                LDAPUser u = ldap.authenticateJndi(username, password);
                if (u != null) {
                    Log.d("found User " + u.toString());
                    if ((Boolean)Config.getInstance().clientConfig.get("TWOFA") == false ||
                         u.getRole().equals(Roles.toString(Roles.SCHUELER))) {
                        String authToken = UUID.randomUUID().toString();
                        u.setAuthToken(authToken);
                        u.setTimestamp(System.currentTimeMillis());
                    } else {
                        Log.d(" Zwei Faktoren Authentifizierung ist aktiv");
                    }
                    for (int i = 0; i < Config.getInstance().adminusers.length; i++) {
                        if (Config.getInstance().adminusers[i].equals(username.toUpperCase())) {
                            u.setRole(Roles.toString(Roles.ADMIN));
                        }
                    }
                    for (int i = 0; i < Config.getInstance().verwaltung.length; i++) {
                        if (Config.getInstance().verwaltung[i].equals(username.toUpperCase())) {
                            u.setRole(Roles.toString(Roles.VERWALTUNG));
                        }
                    }
                    Log.d("Login Successfull! u=" + u + " authToken=" + u.getAuthToken() + " Rolle ist " + u.getRole());
                    this.authorizationTokensStorage.put(u.getAuthToken(),u);
                    return u;
                }
                Log.d("u ist NULL");
                throw new LoginException("Don't Come Here Again!");
            } catch (Exception ex) {
                Log.d("Exception " + ex.getMessage());
                Logger.getLogger(Authenticator.class.getName()).log(Level.SEVERE, null, ex);
            }
            throw new LoginException("Don't Come Here Again!");
        } else {
            Log.d("Login im Debug Mode!");
            EntityManagerFactory emf = Persistence.createEntityManagerFactory("DiklabuPU");
            EntityManager em = emf.createEntityManager();
            
            Lehrer l = em.find(Lehrer.class, username);
            if (l!=null && password.equals("mmbbs")) {
                String authToken = UUID.randomUUID().toString();
                LDAPUser u = new LDAPUser();
                u.setShortName(username);
                u.setAuthToken(authToken);
                u.setTimestamp(System.currentTimeMillis());
                u.setVName(l.getVNAME());
                u.setNName(l.getNNAME());
                u.setEMail(l.getEMAIL());
                u.setRole(Roles.toString(Roles.LEHRER));
                for (int i = 0; i < Config.getInstance().adminusers.length; i++) {
                    if (Config.getInstance().adminusers[i].equals(username.toUpperCase())) {
                        u.setRole(Roles.toString(Roles.ADMIN));
                    }
                }
                for (int i = 0; i < Config.getInstance().verwaltung.length; i++) {
                    if (Config.getInstance().verwaltung[i].equals(username.toUpperCase())) {
                        u.setRole(Roles.toString(Roles.VERWALTUNG));
                    }
                }
                Log.d("Login Successfull! u=" + u + " authToken=" + u.getAuthToken() + " Rolle ist " + u.getRole());
                this.authorizationTokensStorage.put(u.getAuthToken(),u);
                return u;                
            } else {
                Log.d("Benutzer " + username + " nicht gefunden!");
            }
            throw new LoginException("Don't Come Here Again!");
        }
    }

    /**
     * Prüfen ob das Auth_Token (noch) gültig ist
     *
     * @param authToken Das auth_token
     * @return true = gültiges Token
     */
    public boolean isAuthTokenValid(String authToken) {
        if (authorizationTokensStorage.containsKey(authToken)) {
            LDAPUser u = authorizationTokensStorage.get(authToken);
            Long t = u.getTimestamp();
            if (System.currentTimeMillis() < t + Config.getInstance().AUTH_TOKE_TIMEOUT) {
                return true;
            } else {
                Log.d("Auth Token Timed out");
                authorizationTokensStorage.remove(authToken);
            }
        }
        return false;
    }

    /**
     * Abmelden eines Users
     *
     * @param authToken das Auth Token
     * @throws GeneralSecurityException wenn etwas schief ging
     */
    public void logout(String authToken) throws GeneralSecurityException {

        if (authorizationTokensStorage.containsKey(authToken)) {

            /**
             * When a client logs out, the authentication token will be remove
             * and will be made invalid.
             */
            authorizationTokensStorage.remove(authToken);
            return;
        }
        throw new GeneralSecurityException("Invalid service key and authorization token match.");
    }

    /**
     * Abfrage der Rolle für ein Auth-Token
     *
     * @param authToken das Auth_Token
     * @return der Name der Rolle
     */
    public String getRole(String authToken) {
        LDAPUser u = authorizationTokensStorage.get(authToken);
        Log.d("User mit token " + authToken + " ist " + u);
        return u.getRole();
    }

  
    /**
     * Benutzer Abfragen anhand eines Auth-Tokens
     *
     * @param authToken das Auth Tokens
     * @return Benutzername oder ID des Benutzers
     */
    public LDAPUser getUser(String authToken) {
        return authorizationTokensStorage.get(authToken);
    }


    public void setPin(String sid, LDAPUser u, Auth a) {
        Log.d("set PIN for SID="+sid+" as "+a.getPin());
        pinStorage.put(sid, a.getPin());
        userStorage.put(sid,u);
    }

    public LDAPUser matchPin(String uid, long pin) {
        Log.d("Math PIN "+pin+" with SID="+uid);
        try {
            long tpin = pinStorage.get(uid);
            if (tpin==pin) {
                String authToken = UUID.randomUUID().toString();
                LDAPUser u = userStorage.get(uid);
                u.setAuthToken(authToken);
                u.setTimestamp(System.currentTimeMillis());
                this.authorizationTokensStorage.put(authToken, u);
                return u;
            }
            userStorage.remove(uid);
            pinStorage.remove(uid);
            return null;
        }
        catch (java.lang.NullPointerException e) {
            userStorage.remove(uid);
            pinStorage.remove(uid);
            return null;
        }
    }
}
