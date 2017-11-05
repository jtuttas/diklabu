/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.config.Config;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Lehrer;
import de.tuttas.entities.Schueler;
import de.tuttas.restful.AuthRESTResourceProxy;
import de.tuttas.restful.Data.Auth;
import de.tuttas.restful.auth.Authenticator;

import de.tuttas.restful.auth.HTTPHeaderNames;
import de.tuttas.restful.auth.Roles;
import de.tuttas.util.LDAPUser;
import de.tuttas.util.Log;
import java.math.BigDecimal;
import java.security.GeneralSecurityException;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ejb.Stateless;
import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.security.auth.login.LoginException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.ws.rs.Consumes;
import javax.ws.rs.FormParam;
import javax.ws.rs.core.CacheControl;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

/**
 * Anmeldung und Abmeldung am System
 * @author Jörg
 */
@Stateless(name = "DemoBusinessRESTResource", mappedName = "ejb/DemoBusinessRESTResource")
public class AuthRESTResource implements AuthRESTResourceProxy {

    private static final long serialVersionUID = -6663599014192066936L;

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    
    /**
     * Login
     * @param httpHeaders Header mit Service-Key
     * @param a Auth Objekt mit Benutzernamen und Kennwort
     * @return Je nach Rolle (Schüler oder Lehrer) werden Daten in ein JSON Antwort Objekt übertragen. Bei erfolgreicher Anmeldung wird zudem der auth_key erzeugt!
     */
    @Override
    @Consumes(MediaType.APPLICATION_JSON)
    public Response login(
            @Context HttpHeaders httpHeaders,
            Auth a) {
        String uid = UUID.randomUUID().toString();
        Log.d("Session="+uid);
        String username = a.getBenutzer();
        String password = a.getKennwort();
        Log.d("login post empfangen f. " + a.toString() + " debug=" + Config.getInstance().debug);
        Authenticator demoAuthenticator = Authenticator.getInstance();
        try {
            LDAPUser u = demoAuthenticator.login(username, password);
            Log.d("Rest Login u=(" + u+")");
            JsonObjectBuilder jsonObjBuilder = Json.createObjectBuilder();
            if (u.getRole().equals(Roles.toString(Roles.SCHUELER))) {
                
                Query query = em.createNamedQuery("findSchuelerByNameAndKlasse");
                query.setParameter("paramVNAME", u.getVName());
                query.setParameter("paramNNAME", u.getNName());
                query.setParameter("paramKLASSE", u.getCourse());
                List<Schueler> schueler = query.getResultList();
                Log.d("Result List:" + schueler);
                
                if (schueler.size() != 0) {
                    u.setShortName("" + schueler.get(0).getId());
                    Schueler s = schueler.get(0);
                    if (s != null && u.getEMail() != null && !u.getEMail().equals(s.getEMAIL())) {
                        Log.d("Aktualisiere EMails für Schüler aus der AD auf " + u.getEMail());
                        s.setEMAIL(u.getEMail());
                        em.merge(s);
                    }                    
                    jsonObjBuilder.add("nameKlasse", u.getCourse());
                    query = em.createNamedQuery("findKlassebyName");
                    query.setParameter("paramKName", u.getCourse().toUpperCase());
                    List<Klasse> klasse = query.getResultList();
                    if (klasse.size() != 0) { 
                        jsonObjBuilder.add("idKlasse", klasse.get(0).getId());
                    }
                    jsonObjBuilder.add("VNAME", u.getVName());
                    jsonObjBuilder.add("NNAME", u.getNName());
                    jsonObjBuilder.add("msg", "Login erfolgreich! Rolle ist "+u.getRole());
                    jsonObjBuilder.add("success", true);
                    jsonObjBuilder.add("auth_token", u.getAuthToken());

                } else {
                    if (u.getCourse()!=null) {
                        jsonObjBuilder.add("msg", "Anmeldedaten OK, aber kann keinen Schüler mit "+u.getVName()+" "+u.getNName()+" im Diklabu in der Klasse "+u.getCourse()+" finden!");
                    }
                    else {
                        jsonObjBuilder.add("msg", "Anmeldedaten OK, aber kann keinen Schüler mit "+u.getVName()+" "+u.getNName()+" hat keine Gruppenzugehörigkeit!");                        
                    }
                    jsonObjBuilder.add("success", false);
                    try {
                        demoAuthenticator.logout(u.getAuthToken());
                    } catch (GeneralSecurityException ex) {
                        Logger.getLogger(AuthRESTResource.class.getName()).log(Level.SEVERE, null, ex);
                    }
                }
            } else if (u.getRole().equals(Roles.toString(Roles.LEHRER)) || u.getRole().equals(Roles.toString(Roles.ADMIN)) || u.getRole().equals(Roles.toString(Roles.VERWALTUNG))) {
                Lehrer l = em.find(Lehrer.class, u.getShortName());
                /*
                if (l != null && u.getEMail() != null && !l.getEMAIL().equals(u.getEMail())) {
                    Log.d("Aktualisiere EMails für Lehrer aus der AD auf " + u.getEMail());
                    l.setEMAIL(u.getEMail());
                    em.merge(l);
                }
                */
                if (l==null) {
                    jsonObjBuilder.add("msg", "Anmeldedaten OK, aber kann keinen Lehrer mit Kürzel "+u.getShortName()+" in Klassenbuch DB finden!");
                    jsonObjBuilder.add("success", false);
                    try {
                        demoAuthenticator.logout(u.getAuthToken());
                    } catch (GeneralSecurityException ex) {
                        Logger.getLogger(AuthRESTResource.class.getName()).log(Level.SEVERE, null, ex);
                    }
                }
                else {
                    Log.d("TWOFA="+Config.getInstance().clientConfig.get("TWOFA"));
                    if (!(Boolean)Config.getInstance().clientConfig.get("TWOFA")) {
                        jsonObjBuilder.add("msg", "Login erfolgreich! Rolle ist "+u.getRole());
                        jsonObjBuilder.add("success", true);                    
                        jsonObjBuilder.add("auth_token", u.getAuthToken());
                        if (l.getEMAIL()!=null) {
                            jsonObjBuilder.add("email", l.getEMAIL());
                        }
                    }
                    else {
                        if (u.getPhone()==null) {
                            jsonObjBuilder.add("msg", "Anmeldedaten OK, aber keine Telefonnummer zur zwei Faktoren Authentifizierung hinterlegt!");
                            jsonObjBuilder.add("success", false);                                                
                        }
                        else {
                            jsonObjBuilder.add("msg", "PIN gesendet an "+u.getPhone());
                            jsonObjBuilder.add("success", true);   
                            jsonObjBuilder.add("uid", uid);   
                            long pin = (long) (Math.random()*9000)+1000; 
                            a.setPin(pin);
                            demoAuthenticator.setPin(uid,u,a);
                            Config.getInstance().sendSMS(u.getPhone(), "Ihre PIN f. das digitale Klassebuch lautet: "+pin);
                        }
                    }
                }
            }

            jsonObjBuilder.add("ID", u.getShortName());
            jsonObjBuilder.add("idPlain", u.getIdPlain());

            jsonObjBuilder.add("role", u.getRole());
            Log.d("User zurück:" + u);
            JsonObject jsonObj = jsonObjBuilder.build();
            return getNoCacheResponseBuilder(Response.Status.OK).entity(jsonObj.toString()).build();

        } catch (final LoginException ex) {
            JsonObjectBuilder jsonObjBuilder = Json.createObjectBuilder();
            jsonObjBuilder.add("message", "Problem matching service key, username and password");
            JsonObject jsonObj = jsonObjBuilder.build();
            return getNoCacheResponseBuilder(Response.Status.UNAUTHORIZED).entity(jsonObj.toString()).build();
        }
    }
    
    @Override
    @Consumes(MediaType.APPLICATION_JSON)
    public Response setPin(
            @Context HttpHeaders httpHeaders,
            Auth a) {
        String uid = a.getUid();
        Log.d("Session="+uid);
        Log.d("PIN="+a.getPin());
        Authenticator demoAuthenticator = Authenticator.getInstance();
        JsonObjectBuilder jsonObjBuilder = Json.createObjectBuilder(); 
        
        LDAPUser u = demoAuthenticator.matchPin(uid,a.getPin());
        if (u!=null) {
            jsonObjBuilder.add("msg", "Login erfolgreich!");
            jsonObjBuilder.add("success", true);  
            jsonObjBuilder.add("auth_token", u.getAuthToken());
            jsonObjBuilder.add("email", u.getEMail());
            jsonObjBuilder.add("ID", u.getShortName());
            jsonObjBuilder.add("idPlain", u.getIdPlain());
            jsonObjBuilder.add("role", u.getRole());
        }
        else {
            jsonObjBuilder.add("msg", "Fehlerhafte PIN");
            jsonObjBuilder.add("success", false);                    
        }
        
        JsonObject jsonObj = jsonObjBuilder.build();
        return getNoCacheResponseBuilder(Response.Status.OK).entity(jsonObj.toString()).build();
    }
     
   
    /**
     * Abmelden
     * @param httpHeaders mit auth_token zur Identifikatioon
     * @return Ergebnisobjekt
     */
    @Override
    public Response logout(
            @Context HttpHeaders httpHeaders) {
        try {
            Authenticator demoAuthenticator = Authenticator.getInstance();
            String authToken = httpHeaders.getHeaderString(HTTPHeaderNames.AUTH_TOKEN);
            demoAuthenticator.logout(authToken);

            return getNoCacheResponseBuilder(Response.Status.NO_CONTENT).build();
        } catch (final GeneralSecurityException ex) {
            return getNoCacheResponseBuilder(Response.Status.INTERNAL_SERVER_ERROR).build();
        }
    }

    private Response.ResponseBuilder getNoCacheResponseBuilder(Response.Status status) {
        CacheControl cc = new CacheControl();
        cc.setNoCache(true);
        cc.setMaxAge(-1);
        cc.setMustRevalidate(true);

        return Response.status(status).cacheControl(cc);
    }
}
