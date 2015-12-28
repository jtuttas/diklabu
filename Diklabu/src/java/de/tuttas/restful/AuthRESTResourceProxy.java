/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.restful.Data.Auth;
import java.io.Serializable;
import javax.ejb.Local;
import javax.ws.rs.FormParam;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Local
@Path( "auth" )
public interface AuthRESTResourceProxy extends Serializable {

    @POST
    @Path( "login" )
    @Produces( MediaType.APPLICATION_JSON )
    public Response login(
        @Context HttpHeaders httpHeaders,
        Auth a );

   

    @POST
    @Path( "logout" )
    public Response logout(
        @Context HttpHeaders httpHeaders
    );
}