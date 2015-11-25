/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.entities.LoginSchueler;
import de.tuttas.restful.Data.SchuelerObject;
import de.tuttas.entities.Schueler;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.core.MediaType;

/**
 *
 * @author Jörg
 */
@Path("manager/getchilditems")
@Stateless
public class getChildIItems {
        
        
     @GET   
    @Consumes(MediaType.APPLICATION_JSON)
    public Object getSchueler() {
         System.out.println("receive GET manager/getchildsitems");
         try {
             Runtime runtime = Runtime.getRuntime();
             Process proc = runtime.exec("powershell c:\\temp\\getchilditem.ps1 c:\\Temp");
             System.out.println("proc="+proc);
             InputStream is = proc.getInputStream();
             InputStreamReader isr = new InputStreamReader(is);
             BufferedReader reader = new BufferedReader(isr);
             String line;
             String out="";
             while ((line = reader.readLine()) != null)
             {
                 out=out+line;
             }
             reader.close();
             proc.getOutputStream().close();
             return out;
         } catch (IOException ex) {
             System.out.println("IOException:"+ex.getMessage());
             Logger.getLogger(getChildIItems.class.getName()).log(Level.SEVERE, null, ex);
         }
         return null;
    }
    
}
