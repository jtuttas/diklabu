/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.auth;

import de.tuttas.config.Config;
import de.tuttas.entities.Lehrer;
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
 * @author Jörg
 */
public final class Authenticator {

    private static Authenticator authenticator = null;

    // A user storage which stores <username, password>
    private final Map<String, String> usersStorage = new HashMap();

    // An authentication token storage which stores <auth_token,  Benutzername>.
    private final Map<String, String> authorizationTokensStorage = new HashMap();

    // Benutzernamen zu Rollen <Benutzername, Rolle>
    private final Map<String, String> rolesStorage = new HashMap();

    // Live time of a aut_token <auth_token, TimeStamp>
    private final Map<String, Long> liveTimeStorage = new HashMap();

    private Authenticator() {
        if (Config.getInstance().debug) {
            EntityManagerFactory emf = Persistence.createEntityManagerFactory("DiklabuPU");
            EntityManager em = emf.createEntityManager();
            Query query = em.createNamedQuery("findAllTeachers");
            List<Lehrer> lehrer = query.getResultList();

            for (Lehrer l : lehrer) {
                Log.d("Anlegen Benutzer (" + l.getId() + ")");
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
            usersStorage.put("FISI14A.ZZZ", "mmbbs");
            rolesStorage.put("FISI14A.ZZZ", Roles.toString(Roles.SCHUELER));
        }

    }

    /**
     * Instanz der Authentifizierungsklasse abfragen
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
     * @param serviceKey Service Key
     * @param username Benutzernamen
     * @param password Kennwort
     * @return Identifizierter Benutzer
     * @throws LoginException Keine Authentifizierung möglich
     */
    public LDAPUser login(String serviceKey, String username, String password) throws LoginException {
        if (!Config.getInstance().debug) {
            LDAPUtil ldap;
            try {
                ldap = LDAPUtil.getInstance();
                LDAPUser u = ldap.authenticateJndi(username, password);
                if (u != null) {
                    Log.d("found User " + u.toString());
                    serviceKey = StringUtil.removeGermanCharacters(u.getShortName()) + "f80ebc87-ad5c-4b29-9366-5359768df5a1";
                    String authToken = UUID.randomUUID().toString();
                    authorizationTokensStorage.put(authToken, username);
                    liveTimeStorage.put(authToken, System.currentTimeMillis());

                    u.setAuthToken(authToken);
                    
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
                    Log.d("Login Successfull! u=" + u + " authToken=" + authToken+" Rolle ist "+u.getRole());
                    rolesStorage.put(username, u.getRole());
                    return u;
                }
                Log.d("u ist NULL");
                throw new LoginException("Don't Come Here Again!");
            } catch (Exception ex) {
                Log.d("Exception "+ex.getMessage());
                Logger.getLogger(Authenticator.class.getName()).log(Level.SEVERE, null, ex);
            }
            throw new LoginException("Don't Come Here Again!");
        } else {
            Log.d("Login im Debug Mode serviceKey=" + serviceKey);
            
            if (usersStorage.containsKey(username.toUpperCase())) {
                String passwordMatch = usersStorage.get(username.toUpperCase());
                Log.d("Benuter "+username+" im userStorage enthalten! Teste Password "+password);
                if (passwordMatch!=null && passwordMatch.equals(password)) {
                    
                    String authToken = UUID.randomUUID().toString();
                    authorizationTokensStorage.put(authToken, username.toUpperCase());
                    liveTimeStorage.put(authToken, System.currentTimeMillis());
                    LDAPUser u = new LDAPUser();
                    u.setShortName(username);
                    u.setAuthToken(authToken);
                    // Diese Daten kommen eigentlich über LDAP
                    u.setVName("Marcel");
                    u.setNName(username.substring(username.indexOf(".")+1));
                    u.setRole(rolesStorage.get(username.toUpperCase()));
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
                    rolesStorage.put(username, u.getRole());
                    return u;
                }
            }
            else {
                Log.d("Benutzer "+username+" nicht im userStorage enthalten!");
            }
            throw new LoginException("Don't Come Here Again!");
        }
    }

    /**
     * Prüfen ob das Auth_Token (noch) gültig ist
     * @param authToken Das auth_token
     * @return true = gültiges Token
     */
    public boolean isAuthTokenValid(String authToken) {
        if (authorizationTokensStorage.containsKey(authToken)) {
            Long t = liveTimeStorage.get(authToken);
            if (System.currentTimeMillis() < t + Config.getInstance().AUTH_TOKE_TIMEOUT) {
                return true;
            } else {
                Log.d("Auth Token Timed out");
                authorizationTokensStorage.remove(authToken);
                liveTimeStorage.remove(authToken);
            }
        }
        return false;
    }

    /**
     * Abmelden eines Users
     * @param serviceKey Service Key
     * @param authToken das Auth Token
     * @throws GeneralSecurityException  wenn etwas schief ging
     */
    public void logout(String serviceKey, String authToken) throws GeneralSecurityException {

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
     * @param authToken das Auth_Token
     * @return der Name der Rolle
     */
    public String getRole(String authToken) {
        String user = authorizationTokensStorage.get(authToken);
        Log.d("User mit token " + authToken + " ist " + user);
        return rolesStorage.get(user);
    }
    
    /**
     * Rolle für einen Benutzer setzen
     * @param username der Benutzername
     * @param role der name der Rolle
     */
    public void setRole(String username,String role) {
        rolesStorage.put(username, role);
    }
    
    /**
     * Benutzer Abfragen anhand eines Auth-Tokens
     * @param authToken das Auth Tokens
     * @return Benutzername oder ID des Benutzers
     */
    public String getUser(String authToken) {
        return authorizationTokensStorage.get(authToken);
    }
    
    /**
     * Benutzer stzen anhand eines Auth Tokens
     * @param authToken das Auth Token
     * @param user  der Benutzer Oder ID
     */
    public void setUser(String authToken,String user) {
        authorizationTokensStorage.put(authToken, user);
    }
}
