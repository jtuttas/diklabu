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
                usersStorage.put(l.getIdplain(), "mmbbs");
                rolesStorage.put(l.getIdplain(), Roles.toString(Roles.LEHRER));
            }

            // Lehrer Testzugang
            usersStorage.put("zzz", "mmbbs");
            rolesStorage.put("zzz", Roles.toString(Roles.LEHRER));
            // Schüler Testzugang
            usersStorage.put("fisi14a.aue", "mmbbs");
            rolesStorage.put("fisi14a.aue", Roles.toString(Roles.SCHUELER));
            // Schüler Testzugang
            usersStorage.put("fisi14a.zzz", "mmbbs");
            rolesStorage.put("fisi14a.zzz", Roles.toString(Roles.SCHUELER));
        }

    }

    public static Authenticator getInstance() {
        if (authenticator == null) {
            authenticator = new Authenticator();
        }

        return authenticator;
    }

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
                    Log.d("Login Successfull! u=" + u + " authToken=" + authToken);
                    rolesStorage.put(username, u.getRole());
                    return u;
                }
                throw new LoginException("Don't Come Here Again!");
            } catch (Exception ex) {
                Logger.getLogger(Authenticator.class.getName()).log(Level.SEVERE, null, ex);
            }
            throw new LoginException("Don't Come Here Again!");
        } else {
            Log.d("Login im Debug Mode serviceKey=" + serviceKey);

            if (usersStorage.containsKey(username)) {
                String passwordMatch = usersStorage.get(username);
                Log.d("Benuter "+username+" im userStorage enthalten!");
                if (passwordMatch.equals(password)) {
                    
                    String authToken = UUID.randomUUID().toString();
                    authorizationTokensStorage.put(authToken, username);
                    liveTimeStorage.put(authToken, System.currentTimeMillis());
                    LDAPUser u = new LDAPUser();
                    u.setShortName(username);
                    u.setAuthToken(authToken);
                    // Diese Daten kommen eigentlich über LDAP
                    u.setVName("Marcel");
                    u.setNName(username.substring(username.indexOf(".")+1));
                    u.setRole(rolesStorage.get(username));
                    for (int i = 0; i < Config.getInstance().adminusers.length; i++) {
                        if (Config.getInstance().adminusers[i].equals(username.toUpperCase())) {
                            u.setRole(Roles.toString(Roles.ADMIN));
                        }
                    }
                    rolesStorage.put(username, u.getRole());
                    return u;
                }
            }
            throw new LoginException("Don't Come Here Again!");
        }
    }

    /**
     * The method that pre-validates if the client which invokes the REST API is
     * from a authorized and authenticated source.
     *
     * @param authToken The authorization token generated after login
     * @return TRUE for acceptance and FALSE for denied.
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

    public String getRole(String authToken) {
        String user = authorizationTokensStorage.get(authToken);
        Log.d("User mit token " + authToken + " ist " + user);
        return rolesStorage.get(user);
    }
    
    public void setRole(String username,String role) {
        rolesStorage.put(username, role);
    }
    
    public String getUser(String authToken) {
        return authorizationTokensStorage.get(authToken);
    }
    
    public void setUser(String authToken,String user) {
        authorizationTokensStorage.put(authToken, user);
    }
}
