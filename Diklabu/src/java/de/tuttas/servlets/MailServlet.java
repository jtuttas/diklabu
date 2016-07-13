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
import de.tuttas.util.Log;
import de.tuttas.util.StringUtil;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.mail.internet.AddressException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Jörg
 */
@WebServlet(name = "MailServlet", urlPatterns = {"/MailServlet"})
public class MailServlet extends HttpServlet {

   
    private MailSender mailSender;

    public void init() {
        
        mailSender = MailSender.getInstance();
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
        String auth = request.getParameter("auth_token");
        String service = request.getParameter("service_key");
        Log.d("MailServlet doPost: auth_token=" + auth);

        if (Config.getInstance().debug || service != null && auth != null && de.tuttas.restful.auth.Authenticator.getInstance().isAuthTokenValid(auth)) {
            response.setContentType("application/json;charset=UTF-8");
            ResultObject result = new ResultObject();
            // reads form fields
            String recipient = request.getParameter("toMail");
            String from = request.getParameter("fromMail");
            String subject = request.getParameter("subjectMail");
            String content = request.getParameter("emailBody");
            String klassenName = request.getParameter("klassenName");
            String lehrerID = request.getParameter("lehrerId");
            String report = request.getParameter("report");
            String bcc = request.getParameter("bcc");
            String cc = request.getParameter("cc");
            Log.d("MailServlet doPost: toMail=" + recipient+ " fromMail="+from+" cc="+cc+" bcc="+bcc+"subject="+subject+" emailBody="+content+" report="+report);            

            if (subject == null || subject.length() == 0) {
                Log.d("subject = null");
                result.setSuccess(false);
                result.setMsg("Fehler beim EMail Versand: kein Betreff angegeben!");
            } else if (content == null || content.length() == 0) {
                result.setSuccess(false);
                result.setMsg("Fehler beim EMail Versand: kein Inhalt angegeben!");
            } else {
                try {
                    MailObject mo = new MailObject(from, subject, content);
                    mo.addRecipient(recipient);
                    if (bcc!=null) mo.addBcc(bcc.split(";"));
                    if (cc!=null) mo.addCC(cc.split(";"));
                    Log.d("Mail to send:"+mo.toString());
                    mailSender.sendMail(mo);
                    result.setSuccess(true);
                    result.setMsg("EMail erfolgreich versandt");
                    if (report==null || (report!=null && report.compareTo("false")!=0)) {
                        createPdf(response, recipient, content, klassenName, lehrerID);
                    }
                    else {
                        response.setStatus(HttpServletResponse.SC_OK);
                        
                    }
                } catch (AddressException ex) {
                    ex.printStackTrace();
                    try (PrintWriter out = response.getWriter()) {
                        out.println("Adress Exception:"+ex.getMessage());
                    }
                } catch (MailFormatException ex) {
                    ex.printStackTrace();
                    result.setSuccess(false);
                    result.setMsg(ex.getMessage());
                }
            }
            
            try (PrintWriter out = response.getWriter()) {
                out.println(result.toString());
            }
            
        } else {
            response.setContentType("text/html;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.println("<!DOCTYPE html>");
                out.println("<html>");
                out.println("<head>");
                out.println("<title>Mail Servlet</title>");
                out.println("</head>");
                out.println("<body>");
                out.println("<h1>You are not authorized</h1>");
                out.println("</body>");
                out.println("</html>");
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

    private void createPdf(HttpServletResponse response, String recipient, String content, String klasse, String lehrerId) {
        OutputStream out = null;
        try {
            out = response.getOutputStream();
            Log.d("Mail versandt erfolgreich erzeuge pdf Dokumentation! out=" + out);
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

            String body = "";
            body += "<table align='center' width='100%'>";
            body += "<tr><td><h3 align=\"center\">Empfänger:" + recipient + "</h3></td></tr>";
            Log.d("Content=" + StringUtil.addBR(content));
            body += "<tr><td style=\"font-size: 12;\">" + StringUtil.addBR(content) + "</td></tr>";
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
                if (image != null) {
                    document.add(image);
                }
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
