/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.auth;

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
        Log.d("path=("+path+")");
        if (path.startsWith("/noauth") || path.startsWith("/kurswahl") || Config.debug) {
            Log.d("path start with noauth");
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
            if (!path.startsWith("/auth/login/") ) {
                String authToken = requestCtx.getHeaderString(HTTPHeaderNames.AUTH_TOKEN);
                Log.d("auth Token="+authToken);
                // if it isn't valid, just kick them out.
                if (!demoAuthenticator.isAuthTokenValid(serviceKey, authToken)) {
                    requestCtx.abortWith(Response.status(Response.Status.UNAUTHORIZED).build());
                }
            }
        }
    }
}
