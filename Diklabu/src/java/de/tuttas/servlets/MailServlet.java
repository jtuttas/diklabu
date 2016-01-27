/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.servlets;

import com.itextpdf.text.BadElementException;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Image;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.tool.xml.XMLWorkerHelper;
import de.tuttas.config.Config;
import de.tuttas.restful.Data.ResultObject;
import de.tuttas.util.StringUtil;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Properties;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.mail.AuthenticationFailedException;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

/**
 *
 * @author Jörg
 */
@WebServlet(name = "MailServlet", urlPatterns = {"/MailServlet"})
public class MailServlet extends HttpServlet {

    private String host;
    private String port;
    private String user;
    private String pass;
    private static final String EMAIL_PATTERN
            = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
            + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
    private Pattern pattern;
    private Matcher matcher;

    public void init() {
        pattern = Pattern.compile(EMAIL_PATTERN);
        try {
            // reads SMTP server setting from web.xml file
            String conf = this.getFile("/de/tuttas/servlets/mailconfig.json");
            JSONParser parser = new JSONParser();

            JSONObject jo = (JSONObject) parser.parse(conf);
            host = (String) jo.get("host");
            port = (String) jo.get("port");
            user = (String) jo.get("user");
            pass = (String) jo.get("pass");
            System.out.println("host=" + host);
        } catch (ParseException ex) {
            Logger.getLogger(MailServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
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

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet MailServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet MailServlet</h1>");
            out.println("<form action=\"/Diklabu/MailServlet\" method=\"POST\"><br>");
            out.println("<input type=\"hidden\" value=\"TU\" name=\"lehrerId\" id=\"lehrerId\">");
            out.println("<input type=\"hidden\" value=\"FISI13A\" name=\"klassenName\" id=\"klassenName\">");            
            out.println("<input type=\"text\" placeholder=\"jtuttas@gmx.net\" value=\"juttas@gmx.net\" name=\"fromMail\" id=\"fromMail\"><br>");
            out.println("<input type=\"text\" placeholder=\"tuttas@mmbbs.de\" value=\"tuttas@mmbbs.de\" name=\"toMail\" id=\"toMail\"><br>");
            out.println("<input type=\"text\" placeholder=\"Subject\" value=\"Dies ist ein Test\" name=\"subjectMail\" id=\"subjectMail\"><br>");
            out.println("<textarea rows=\"10\" id=\"emailBody\" name=\"emailBody\">Hier steht der Inhalt</textarea><br>");
            out.println("<input type=\"submit\" value=\"Submit\">");
            out.println("</form>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("POST MailServlet toMail=" + request.getParameter("toMail"));
        response.setContentType("application/json;charset=UTF-8");
        ResultObject result = new ResultObject();
        // reads form fields
        String recipient = request.getParameter("toMail");
        String from = request.getParameter("fromMail");
        String subject = request.getParameter("subjectMail");
        String content = request.getParameter("emailBody");
        String klassenName = request.getParameter("klassenName");
        String lehrerID = request.getParameter("lehrerId");
        
        if (Config.debug) {
            recipient="tuttas@mmbbs.de";
        }
        
        boolean fromMailOk=false;
        if (from!=null && from.length()!=0){
            matcher = pattern.matcher(from);
            fromMailOk = matcher.matches();
        }
        boolean toMailOk=false;
        if (recipient!=null && recipient.length()!=0) {
            matcher = pattern.matcher(recipient);
            toMailOk = matcher.matches();
        }

        if (subject==null || subject.length() == 0) {
            System.out.println("subject = null");
            result.setSuccess(false);
            result.setMsg("Fehler beim EMail Versand: kein Betreff angegeben!");
        } else if (content==null || content.length() == 0) {
            result.setSuccess(false);
            result.setMsg("Fehler beim EMail Versand: kein Inhalt angegeben!");
        } else if (!fromMailOk) {
            result.setSuccess(false);
            result.setMsg("Fehler beim EMail Versand: Falsche Absender EMail Adresse!");
        } else if (!toMailOk) {
            result.setSuccess(false);
            result.setMsg("Fehler beim EMail Versand: Falsche Adresse EMail Adresse!");
        } else {
            try {
                // sets SMTP server properties
                Properties properties = new Properties();
                properties.put("mail.smtp.host", host);
                properties.put("mail.smtp.port", port);
                properties.put("mail.smtp.auth", "true");
                properties.put("mail.smtp.starttls.enable", "true");

                // creates a new session with an authenticator
                Authenticator auth = new Authenticator() {
                    public PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(user, pass);
                    }
                };
                Session session = Session.getInstance(properties, auth);
                // creates a new e-mail message
                Message msg = new MimeMessage(session);
                msg.setFrom(new InternetAddress(from));
                InternetAddress[] toAddresses = {new InternetAddress(recipient)};
                msg.setRecipients(Message.RecipientType.TO, toAddresses);
                msg.setSubject(subject);
                msg.setSentDate(new Date());
                msg.setText(content);
                // sends the e-mail
                // TODO Kommentar entfernen
                //Transport.send(msg);
                result.setSuccess(true);
                result.setMsg("EMail erfolgreich versandt");
                createPdf(response, recipient,content,klassenName,lehrerID);

            } catch (AddressException ex) {
                result.setSuccess(false);
                result.setMsg("Fehler beim EMail Versand:" + ex.getMessage());
            } catch (MessagingException ex) {
                result.setSuccess(false);
                result.setMsg("Fehler beim EMail Versand:" + ex.getMessage());
            }
        }
        if (!result.isSuccess()) {
            try (PrintWriter out = response.getWriter()) {
                out.println(result.toString());
            }
        }
    }
    
    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

    private void createPdf(HttpServletResponse response, String recipient, String content,String klasse,String lehrerId) {
        OutputStream out = null;
        try {
            out = response.getOutputStream();
            System.out.println("Mail versandt erfolgreich erzeuge pdf Dokumentation! out="+out);
            response.setContentType("application/pdf");
            response.addHeader("Content-Disposition", "attachment; filename=Fehlzeitenbericht_" + recipient + ".pdf");
            String kopf = "";
            kopf += ("<table border='1' align='center' width='100%'>");
            kopf += ("<tr>");
            kopf += ("<td rowspan=\"3\" width='150px'></td>");
            kopf += ("<td align='center'><h2>Multi Media Berufsbildende Schulen Hannover</h2></td>");
            kopf += ("<td colspan=\"2\" align='center'><b>Digitales Klassenbuch Fehlzeitenbericht</b></td>");
            kopf += ("</tr>");
            kopf += ("<tr>");
            kopf += ("<td  align='center' rowspan=\"2\"><h3>Klasse/ Kurs: " + klasse + "</h3></td>");
            kopf += ("<td  style=\"font-size: 11;\">Verantwortlicher: " + lehrerId + "</td>");
            kopf += ("<td  style=\"font-size: 11;\">geprüft</td>");
            kopf += ("</tr>");
            kopf += ("<tr>");
            DateFormat df = new SimpleDateFormat("dd.MM.yyyy");
            Calendar c = df.getCalendar();
            c.setTimeInMillis(System.currentTimeMillis());
            String dat = c.get(Calendar.DAY_OF_MONTH) + "." + (c.get(Calendar.MONTH) + 1) + "." + c.get(Calendar.YEAR);
            kopf += ("<td  style=\"font-size: 11;\">Ausdruck am: " + dat + "</td>");
            kopf += ("<td  style=\"font-size: 11;\">Datum</td>");
            kopf += ("</tr>");
            kopf += ("</table>");
            kopf += ("<p>&nbsp;</p>");
            
            Document document = new Document();
            /* Basic PDF Creation inside servlet */
            PdfWriter writer = PdfWriter.getInstance(document, out);
            StringBuilder htmlString = new StringBuilder();
            htmlString.append(kopf);
            
            String body="";
            body += "<table align='center' width='100%'>";
            body += "<tr><td><h3 align=\"center\">Empfänger:"+recipient+"</h3></td></tr>";
            System.out.println("Content="+StringUtil.addBR(content));
            body += "<tr><td style=\"font-size: 12;\">"+StringUtil.addBR(content)+"</td></tr>";
            body += "</table>";
            htmlString.append(body);
            
            document.open();
            // Dokument erzeugen
            InputStream is = new ByteArrayInputStream(htmlString.toString().getBytes());
            // Bild einfügen
            String url = "http://www.mmbbs.de/fileadmin/template/mmbbs/gfx/mmbbs_logo_druck.gif";
            Image image;
            try {
                image = Image.getInstance(url);
                image.setAbsolutePosition(45f, 720f);
                image.scalePercent(50f);
                if (image!=null)  document.add(image);
            } catch (BadElementException ex) {
                Logger.getLogger(MailServlet.class.getName()).log(Level.SEVERE, null, ex);
            } catch (IOException ex) {
                Logger.getLogger(MailServlet.class.getName()).log(Level.SEVERE, null, ex);
            }
            XMLWorkerHelper.getInstance().parseXHtml(writer, document, is);
            document.close();
            out.close();
        } catch (IOException ex) {
            Logger.getLogger(MailServlet.class.getName()).log(Level.SEVERE, null, ex);
        } catch (DocumentException ex) {
            Logger.getLogger(MailServlet.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                if (out != null) {
                    out.close();
                }
            } catch (IOException ex) {
                Logger.getLogger(MailServlet.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

}
