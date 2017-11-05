/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.auth;

import com.itextpdf.text.pdf.XfaXpathConstructor;
import de.tuttas.config.Config;
import de.tuttas.restful.auth.Authenticator;
import de.tuttas.util.Log;
import java.io.IOException;
import java.util.logging.Logger;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.container.PreMatching;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.Provider;

@Provider
@PreMatching
public class RESTRequestFilter implements ContainerRequestFilter {

    private final static Logger log = Logger.getLogger(RESTRequestFilter.class.getName());

    /**
     * Request Filter, URLs mit noauth können von unangemeldeten Benutzer (also jedem) abgefragt werdn, URLS mit sauth können von Nutzern mit der Schüler Rolle abngefragt wreden, alle anderen Dienste nur von Nutzen mit Lehrer Rolle, bei URLs mit admin im Namen sind zudem Admin Rechte nötig!
     * @param requestCtx Request Context
     * @throws IOException Wenn etwas schief geht
     */
    @Override
    public void filter(ContainerRequestContext requestCtx) throws IOException {

        String path = requestCtx.getUriInfo().getPath();
        log.info("Filtering request path: " + path);

        // IMPORTANT!!! First, Acknowledge any pre-flight test from browsers for this case before validating the headers (CORS stuff)
        if (requestCtx.getRequest().getMethod().equals("OPTIONS")) {
            requestCtx.abortWith(Response.status(Response.Status.OK).build());

            return;
        }

        // Then check is the service key exists and is valid.
        Authenticator demoAuthenticator = Authenticator.getInstance();
        String serviceKey = requestCtx.getHeaderString(HTTPHeaderNames.SERVICE_KEY);
        Log.d("path=(" + path + ")");
        if (path.startsWith("/noauth") || !Config.getInstance().auth) {
            Log.d("path start with noauth auth State=" + Config.getInstance().auth);
        } else {
            /*
             if (!demoAuthenticator.isServiceKeyValid(serviceKey)) {
             log.info("no Service Key found");
             // Kick anyone without a valid service key
             requestCtx.abortWith(Response.status(Response.Status.UNAUTHORIZED).build());

             return;
             }
             log.info("found Valid Key");
             */
            // For any pther methods besides login, the authToken must be verified
            if (!path.startsWith("/auth/login") && !path.startsWith("/auth/logout") && !path.startsWith("/auth/setpin") ) {
                String authToken = requestCtx.getHeaderString(HTTPHeaderNames.AUTH_TOKEN);
                Log.d("auth Token=" + authToken);
                // if it isn't valid, just kick them out.
                if (!demoAuthenticator.isAuthTokenValid(authToken)) {
                    requestCtx.abortWith(Response.status(Response.Status.UNAUTHORIZED).build());
                } // Schauen ob der Zugriff auf den Service mit der Rolle erlaubt ist
                else {
                    String userRole = demoAuthenticator.getRole(authToken);
                    Log.d("User hat die Rolle " + userRole+" auth_toke="+authToken);
                    if (userRole.equals(Roles.toString(Roles.ADMIN))) {
                        // Admin darf alles
                    } 
                    else if (userRole.equals(Roles.toString(Roles.VERWALTUNG))) {
                        // Verwaltung dürfen die Services Nutzen, die das Wort verwaltung im Namen haben
                        if (path.contains("admin")) {
                            Log.d("Nicht genügend Rechte");
                            requestCtx.abortWith(Response.status(Response.Status.UNAUTHORIZED).build());
                        }
                    }
                    else if (userRole.equals(Roles.toString(Roles.LEHRER))) {
                        // Lehrer dürfen keine Services Nutzen, die das Wort Admin oder Verwaltung im Namen haben
                        if (path.contains("admin") || path.contains("verwaltung")) {
                            Log.d("Nicht genügend Rechte");
                            requestCtx.abortWith(Response.status(Response.Status.UNAUTHORIZED).build());
                        }
                    }
                    else if (userRole.equals(Roles.toString(Roles.SCHUELER))) {
                        // Schüler dürfen Nur auf Dienste zugreifen, die 'sauth' im Namen haben
                        if (path.contains("sauth")) {
                            
                        }
                        else {
                            Log.d("Nicht genügend Rechte");
                            requestCtx.abortWith(Response.status(Response.Status.UNAUTHORIZED).build());
                        }
                    }
                }
            }
        }
    }


}
