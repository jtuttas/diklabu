/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.config.Config;
import de.tuttas.restful.AuthRESTResourceProxy;
import de.tuttas.restful.Data.Auth;
import de.tuttas.restful.auth.Authenticator;

import de.tuttas.restful.auth.HTTPHeaderNames;
import de.tuttas.util.LDAPUser;
import de.tuttas.util.Log;
import java.security.GeneralSecurityException;
import javax.ejb.Stateless;
import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;
import javax.security.auth.login.LoginException;
import javax.ws.rs.Consumes;
import javax.ws.rs.FormParam;
import javax.ws.rs.core.CacheControl;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Stateless( name = "DemoBusinessRESTResource", mappedName = "ejb/DemoBusinessRESTResource" )
public class AuthRESTResource implements AuthRESTResourceProxy {

    private static final long serialVersionUID = -6663599014192066936L;

    @Override
    @Consumes(MediaType.APPLICATION_JSON)
    public Response login(
        @Context HttpHeaders httpHeaders,
        Auth a) {

        String username=a.getBenutzer();
        String password=a.getKennwort();
        Log.d("login post empfangen f. "+a.toString()+" debug="+Config.debug);
        Authenticator demoAuthenticator = Authenticator.getInstance();
        String serviceKey = httpHeaders.getHeaderString( HTTPHeaderNames.SERVICE_KEY );

        try {
            LDAPUser u = demoAuthenticator.login( serviceKey, username, password );
            JsonObjectBuilder jsonObjBuilder = Json.createObjectBuilder();
            jsonObjBuilder.add( "auth_token", u.getAuthToken() );
            jsonObjBuilder.add( "ID_LEHRER", u.getShortName() );
            jsonObjBuilder.add( "idPlain", u.getIdPlain());
            jsonObjBuilder.add( "role", u.getRole());
            
            JsonObject jsonObj = jsonObjBuilder.build();
            return getNoCacheResponseBuilder( Response.Status.OK ).entity( jsonObj.toString() ).build();

        } catch ( final LoginException ex ) {
            JsonObjectBuilder jsonObjBuilder = Json.createObjectBuilder();
            jsonObjBuilder.add( "message", "Problem matching service key, username and password" );
            JsonObject jsonObj = jsonObjBuilder.build();

            return getNoCacheResponseBuilder( Response.Status.UNAUTHORIZED ).entity( jsonObj.toString() ).build();
        }
    }

  
    @Override
    public Response logout(
        @Context HttpHeaders httpHeaders ) {
        try {
            Authenticator demoAuthenticator = Authenticator.getInstance();
            String serviceKey = httpHeaders.getHeaderString( HTTPHeaderNames.SERVICE_KEY );
            String authToken = httpHeaders.getHeaderString( HTTPHeaderNames.AUTH_TOKEN );

            demoAuthenticator.logout( serviceKey, authToken );

            return getNoCacheResponseBuilder( Response.Status.NO_CONTENT ).build();
        } catch ( final GeneralSecurityException ex ) {
            return getNoCacheResponseBuilder( Response.Status.INTERNAL_SERVER_ERROR ).build();
        }
    }

    private Response.ResponseBuilder getNoCacheResponseBuilder( Response.Status status ) {
        CacheControl cc = new CacheControl();
        cc.setNoCache( true );
        cc.setMaxAge( -1 );
        cc.setMustRevalidate( true );

        return Response.status( status ).cacheControl( cc );
    }
}
