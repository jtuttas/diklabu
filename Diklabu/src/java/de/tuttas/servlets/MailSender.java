/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.servlets;

import de.tuttas.config.Config;
import de.tuttas.util.Log;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Properties;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

/**
 *
 * @author Jörg
 */
public class MailSender implements Runnable {

    
    private Properties properties = new Properties();
    private Thread runner;
    private ArrayList<MailObject> mails = new ArrayList();

    public MailSender() {

        // sets SMTP server properties
        properties.put("mail.smtp.host", Config.getInstance().smtphost);
        properties.put("mail.smtp.port", Config.getInstance().port);
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        runner = new Thread(this);
        runner.start();

    }

    private void transmitMail(MailObject mo) throws MessagingException {

        // creates a new session with an authenticator
        Authenticator auth = new Authenticator() {
            public PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(Config.getInstance().user, Config.getInstance().pass);
            }
        };
        Session session = Session.getInstance(properties, auth);
        // creates a new e-mail message
        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(mo.getFrom()));
        InternetAddress[] toAddresses =  mo.getRecipient();
        msg.setRecipients(Message.RecipientType.TO, toAddresses);
        InternetAddress[] bccAdresses = mo.getBcc();
        msg.setRecipients(Message.RecipientType.BCC, bccAdresses);
        msg.setSubject(mo.getSubject());
        msg.setSentDate(new Date());
        msg.setText(mo.getContent());
        // sends the e-mail
        // TODO Kommentar entfernen
        Transport.send(msg);        
    }

    private String getFile(String fileName) {
        StringBuilder result = new StringBuilder("");
        //Get file from resources folder
        ClassLoader classLoader = getClass().getClassLoader();
        File file = new File(classLoader.getResource(fileName).getFile());
        try (Scanner scanner = new Scanner(file)) {
            while (scanner.hasNextLine()) {
                String line = scanner.nextLine();
                result.append(line).append("\n");
            }
            scanner.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return result.toString();
    }

    @Override
    public void run() {
        while (true) {
            if (mails.size()!=0) {
                try {
                    transmitMail(mails.get(0));
                    Log.d("Mail erfolgreich versandt an:"+mails.get(0).toString());
                    mails.remove(0);
                } catch (MessagingException ex) {
                    ex.printStackTrace();
                    Log.d("Fehler beim Versenden der Mail");
                    Logger.getLogger(MailSender.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
            try {
                Thread.sleep(1000);
            } catch (InterruptedException ex) {
                Logger.getLogger(MailSender.class.getName()).log(Level.SEVERE, null, ex);
            }
        }        
    }

    void sendMail(MailObject mo) {
        mails.add(mo);
    }

}
