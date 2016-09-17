/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.util;

import de.tuttas.restful.Data.PSCallerObject;
import de.tuttas.restful.PSCaller;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Jörg
 */
public class CallPowershell {

    public static PSCallerObject call(PSCallerObject pso) {
        try {
            Runtime runtime = Runtime.getRuntime();
            Process proc = runtime.exec("powershell " + pso.getScript());
            Log.d("Proc=" + proc);
            InputStream is = proc.getInputStream();
            InputStream es = proc.getErrorStream();

            InputStreamReader isr = new InputStreamReader(is, "CP850");
            InputStreamReader esr = new InputStreamReader(es, "CP850");
            BufferedReader reader = new BufferedReader(isr);
            BufferedReader ereader = new BufferedReader(esr);
            String line;
            String out = "";
            String err = "";
            while ((line = reader.readLine()) != null) {
                out = out + line;
            }
            while ((line = ereader.readLine()) != null) {
                err = err + line;
            }
            reader.close();
            proc.getOutputStream().close();

            if (err != "") {
                Log.d("Err=" + err);
                pso.setSuccess(false);
                pso.setMsg("Script lieferte Fehler");
                pso.setWarning(true);
                pso.getWarningMsg().add(err);
            } else {
                out = "{\"result\":" + out + "}";
                Log.d("out=" + out);
                pso.setResult(out);
                pso.setSuccess(true);
                pso.setMsg("Script " + pso.getScript() + " ausgeführt!");
            }

        } catch (IOException ex) {
            Log.d("IOException:" + ex.getMessage());
            Logger.getLogger(PSCaller.class.getName()).log(Level.SEVERE, null, ex);
            pso.setMsg(ex.getMessage());
            pso.setSuccess(false);
        }
        return pso;

    }
}
