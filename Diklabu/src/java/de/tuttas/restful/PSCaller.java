/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.restful.Data.Auth;
import de.tuttas.restful.Data.PSCallerObject;
import de.tuttas.util.Log;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

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
@Path("manager/pscaller")
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
            if (auth.validAdminUser()) {
            try {
                Runtime runtime = Runtime.getRuntime();
                Process proc = runtime.exec("powershell " + pso.getScript());
                
                InputStream is = proc.getInputStream();
                InputStreamReader isr = new InputStreamReader(is);
                BufferedReader reader = new BufferedReader(isr);
                String line;
                String out = "";
                while ((line = reader.readLine()) != null) {
                    out = out + line;
                }
                reader.close();
                proc.getOutputStream().close();
                out = "{\"result\":" + out + "}";
                Log.d("out=" + out);                
                
                pso.setResult(out);
                pso.setSuccess(true);
                
            } catch (IOException ex) {
                Log.d("IOException:" + ex.getMessage());
                Logger.getLogger(PSCaller.class.getName()).log(Level.SEVERE, null, ex);
                pso.setMsg(ex.getMessage());
                pso.setSuccess(false);
            }
            }
            else {
                pso.setSuccess(false);
                pso.setMsg("You are not alles to access the script");                
            }
        } else {
            pso.setSuccess(false);
            pso.setMsg("No Auth");
        }
        return pso;
    }
    
}
