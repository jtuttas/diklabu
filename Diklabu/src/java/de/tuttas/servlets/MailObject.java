/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.servlets;

import java.util.ArrayList;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;

/**
 *
 * @author Jörg
 */
public class MailObject {
    private String from;
    private ArrayList<InternetAddress> recipient = new ArrayList();
    private String subject;
    private String content;

    public MailObject(String from,  String subject, String content) {
        this.from = from;
        this.subject = subject;
        this.content = content;
    }

    public String getFrom() {
        return from;
    }

    public void setFrom(String from) {
        this.from = from;
    }

    public InternetAddress[] getRecipient() {
        InternetAddress[] a = new InternetAddress[1];
        return recipient.toArray(a);
    }

    public void addRecipient(String recipient) throws AddressException {        
        this.recipient.add(new InternetAddress(recipient));               
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    @Override
    public String toString() {
        return "Mail Objekt from="+from+" to="+recipient.toString();
    }
    
    
    
    
}
