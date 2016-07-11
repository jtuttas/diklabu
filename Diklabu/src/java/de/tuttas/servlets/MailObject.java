/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.servlets;

import de.tuttas.config.Config;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;

/**
 *
 * @author Jörg
 */
public class MailObject {

    private static final String EMAIL_PATTERN
            = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
            + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
    private Pattern pattern;
    private Matcher matcher;
    private String from;
    private ArrayList<InternetAddress> recipient = new ArrayList();
    private ArrayList<InternetAddress> bcc = new ArrayList();
    private ArrayList<InternetAddress> cc = new ArrayList();

    private String subject;
    private String content;

    public MailObject(String from, String subject, String content) throws MailFormatException {
        pattern = Pattern.compile(EMAIL_PATTERN);
        this.setFrom(from);        
        this.subject = subject;
        this.content = content;
    }

    public boolean mailOk(String mailAdress) {
        if (mailAdress==null) return false;
        matcher = pattern.matcher(mailAdress);
        return matcher.matches();
    }

    public String getFrom() {
        return from;
    }

    public void setFrom(String from) throws MailFormatException {
        if (!mailOk(from)) {
            throw new MailFormatException("Absender EMail Adresse ungültig:" + from);
        } else {
            this.from = from;
        }
    }

    public InternetAddress[] getRecipient() {
        InternetAddress[] a = new InternetAddress[1];
        return recipient.toArray(a);
    }

    public InternetAddress[] getBcc() {
        InternetAddress[] a = new InternetAddress[1];
        return bcc.toArray(a);
    }

    public InternetAddress[] getCC() {
        InternetAddress[] a = new InternetAddress[1];
        return cc.toArray(a);
    }

    public void addRecipient(String recipient) throws AddressException, MailFormatException {
        if (!mailOk(recipient)) {
            throw new MailFormatException("An EMail Adresse ist ungültig:" + recipient);
        } else {
            if (Config.getInstance().debug) {
                this.recipient.add(new InternetAddress("jtuttas@gmx.net"));
            } else {
                this.recipient.add(new InternetAddress(recipient));
            }
        }

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
        String s = "Mail Objekt from=" + from + " to=" + recipient.toString() + " bcc=";
        for (int i = 0; i < bcc.size(); i++) {
            s += bcc.get(i).toString() + ";";
        }
        s += " CC=";
        for (int i = 0; i < cc.size(); i++) {
            s += cc.get(i).toString() + ";";
        }
        return s;
    }

    public void addBcc(String[] bccMails) throws AddressException, MailFormatException {
        for (int i = 0; i < bccMails.length; i++) {

            if (!mailOk(bccMails[i])) {
                throw new MailFormatException("BCC Mail Adresse ist ungülltig:" + bccMails[i]);
            } else {
                if (Config.getInstance().debug) {
                    bcc.add(new InternetAddress("jtuttas@gmx.net"));
                } else {
                    bcc.add(new InternetAddress(bccMails[i]));
                }
            }
        }
    }

    public void addCC(String[] ccMails) throws AddressException, MailFormatException {
        for (int i = 0; i < ccMails.length; i++) {
            if (!mailOk(ccMails[i])) {
                throw new MailFormatException("CC Mail Adresse ist ungülltig:" + ccMails[i]);
            } else {
                if (Config.getInstance().debug) {
                    cc.add(new InternetAddress("jtuttas@gmx.net"));
                } else {
                    cc.add(new InternetAddress(ccMails[i]));
                }
            }
        }
    }

    public void addCC(String ccMail) throws AddressException, MailFormatException {
        if (!mailOk(ccMail)) {
            throw new MailFormatException("CC Mail Adresse ist ungülltig:" + ccMail);
        } else {
            if (Config.getInstance().debug) {
                cc.add(new InternetAddress("jtuttas@gmx.net"));
            } else {
                cc.add(new InternetAddress(ccMail));
            }
        }
    }
}
