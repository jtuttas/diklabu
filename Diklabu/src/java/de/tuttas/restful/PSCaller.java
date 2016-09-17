/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.restful.Data.Auth;
import de.tuttas.restful.Data.PSCallerObject;
import de.tuttas.util.CallPowershell;
import de.tuttas.util.Log;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ejb.Stateless;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.core.MediaType;

/**
 *
 * @author Jörg
 */
@Path("admin/pscaller")
@Stateless
public class PSCaller {
    
    @GET
    @Consumes(MediaType.APPLICATION_JSON)
    public PSCallerObject get() {
        Auth a = new Auth("admin", "geheim");
        PSCallerObject pso = new PSCallerObject("test.ps1", a);
        return pso;
    }
    
    @POST    
    @Consumes(MediaType.APPLICATION_JSON)
    public PSCallerObject call(PSCallerObject pso) {
        Log.d("receive POST manager/pscaller:" + pso.toString());
        if (pso.getAuth() != null) {
            Auth auth = pso.getAuth();
            
            String fName = pso.getScript();
            if (fName.indexOf(" ")!=-1) {
                fName=fName.substring(0, fName.indexOf(" "));
            }
            File f = new File(fName);
            if(!f.exists()) { 
                Log.d("File not found!"+fName);
                pso.setSuccess(false);
                pso.setMsg("Script-File "+fName+" nicht gefunden!");
                return pso;
            }
            CallPowershell.call(pso);
        } else {
            pso.setSuccess(false);
            pso.setMsg("No Auth");
        }
        return pso;
    }
    
}
