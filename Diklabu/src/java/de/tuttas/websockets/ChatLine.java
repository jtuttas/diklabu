/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.websockets;

import java.util.Date;

/**
 *
 * @author Jörg
 */
public class ChatLine {
    private String from;
    private String msg;
    private Date time;

    public ChatLine(String from, String msg) {
        this.from = from;
        this.msg = msg;
        this.time = new Date();        
    }

    public String getFrom() {
        return from;
    }

    public void setFrom(String from) {
        this.from = from;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    String toJson() {
        return "{\"from\":\""+from+"\",\"msg\":\""+msg+"\"}";
    }
    
    
    
}
