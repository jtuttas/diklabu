/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import java.util.ArrayList;
import org.json.simple.JSONObject;

/**
 * ErgebnisObjekt mit Warnungen und Meldungen
 * @author Jörg
 */
public class ResultObject {
    private boolean success=false;
    private String msg="";
    private boolean warning=false;
    private ArrayList<String> warningMsg= new ArrayList<>();

    public void setWarning(boolean warning) {
        this.warning = warning;
    }

    public void setWarningMsg(ArrayList<String> warningMsg) {
        this.warningMsg = warningMsg;
    }

    public ArrayList<String> getWarningMsg() {
        return warningMsg;
    }
    
    public boolean isWarning() {
        return warning;
    }

    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    @Override
    public String toString() {
        return "{\"success\":"+success+",\"msg\":\""+msg+"\"}";
    }    

}
