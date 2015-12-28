/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.servlets;

import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Image;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.tool.xml.XMLWorkerHelper;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Verlauf;
import de.tuttas.restful.Authenticator;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;

import java.util.Date;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.PersistenceContext;
import javax.persistence.PersistenceUnit;
import javax.persistence.Query;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 * @author Jörg
 */
public class DokuServlet extends HttpServlet {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String auth = request.getParameter("auth_token");
        String service = request.getParameter("service_key");
        System.out.println("auth_token="+auth);
        if (request.getParameter("cmd") == null || request.getParameter("idklasse") == null || request.getParameter("from") == null) {
            System.out.println("Info zeigen");
            response.setContentType("text/html;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                /* TODO output your page here. You may use following sample code. */
                out.println("<!DOCTYPE html>");
                out.println("<html>");
                out.println("<head>");
                out.println("<title>Doku Servlet Usage</title>");
                out.println("</head>");
                out.println("<body>");
                out.println("<h1>Doku Servlet @ " + request.getContextPath() + "</h1>");
                out.println("<a href='?cmd=verlauf&idklasse=3608&from=2015-09-08' target='_pdf'>Usage: ?cmd=verlauf&idklasse=3608&from=2015-09-08</a>");
                out.println("</body>");
                out.println("</html>");
            }
        } else {
            if (service!=null && auth!=null && Authenticator.getInstance().isAuthTokenValid(service, auth)) {
                Klasse kl = em.find(Klasse.class, Integer.parseInt(request.getParameter("idklasse")));
                System.out.println("Klasse=" + kl.getID_LEHRER());
                response.addHeader("Content-Disposition", "attachment; filename=verlauf.pdf");
                response.setContentType("application/pdf");
                //Get the output stream for writing PDF object        
                OutputStream out = response.getOutputStream();
                try {
                    Document document = new Document();
                    /* Basic PDF Creation inside servlet */
                    PdfWriter writer = PdfWriter.getInstance(document, out);
                    StringBuilder htmlString = new StringBuilder();
                    /* Nun das Template laden */
                    /*
                     ServletContext cntxt = this.getServletContext();
                     String fName = "/temp-verlauf.html";
                     System.out.println("Lade Template: " + cntxt.getRealPath(fName));
                     InputStream ins = cntxt.getResourceAsStream(fName);
                     if (ins != null) {
                     InputStreamReader isr = new InputStreamReader(ins);
                     BufferedReader reader = new BufferedReader(isr);
                     String word = "";
                     while ((word = reader.readLine()) != null) {
                     System.out.println("word=" + word);
                     htmlString.append(word);
                     }
                     } else {
                     System.out.println("Kann Template nicht finden");
                     }
                     */
                    htmlString.append("<table border='1' align='center' width='100%'>");
                    htmlString.append("<tr>");
                    htmlString.append("<td rowspan=\"3\" width='150px'></td>");
                    htmlString.append("<td align='center'><h2>Multi Media Berufsbildende Schulen Hannover</h2></td>");
                    htmlString.append("<td colspan=\"2\" align='center'><b>Digitales Klassenbuch Unterrichtsverlauf</b></td>");
                    htmlString.append("</tr>");
                    htmlString.append("<tr>");
                    htmlString.append("<td  align='center' rowspan=\"2\"><h3>Klasse/ Kurs: " + kl.getKNAME() + "</h3></td>");
                    htmlString.append("<td  style=\"font-size: 11;\">Verantwortlicher: " + kl.getID_LEHRER() + "</td>");
                    htmlString.append("<td  style=\"font-size: 11;\">geprüft</td>");
                    htmlString.append("</tr>");
                    htmlString.append("<tr>");
                    DateFormat df = new SimpleDateFormat("dd.MM.yyyy");
                    Calendar c = df.getCalendar();
                    c.setTimeInMillis(System.currentTimeMillis());
                    String dat = c.get(Calendar.DAY_OF_MONTH) + "." + (c.get(Calendar.MONTH) + 1) + "." + c.get(Calendar.YEAR);
                    htmlString.append("<td  style=\"font-size: 11;\">Ausdruck am: " + dat + "</td>");
                    htmlString.append("<td  style=\"font-size: 11;\">Datum</td>");
                    htmlString.append("</tr>");
                    htmlString.append("</table>");
                    htmlString.append("<p>&nbsp;</p>");

                    /* Verlauf einfügen */
                    Query query = em.createNamedQuery("findVerlaufbyKlasse");
                    query.setParameter("paramKName", kl.getKNAME());
                    DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                    Date parsed = (Date) dateFormat.parse(request.getParameter("from"));
                    query.setParameter("paramFromDate", new java.sql.Date(parsed.getTime()));
                    System.out.println("setze From auf " + new java.sql.Date(parsed.getTime()));
                    if (request.getParameter("to") == null) {

                        query.setParameter("paramToDate", new java.sql.Date(System.currentTimeMillis()));
                    } else {
                        dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                        parsed = (Date) dateFormat.parse(request.getParameter("to"));
                        query.setParameter("paramToDate", new java.sql.Date(parsed.getTime()));
                    }

                    List<Verlauf> verlauf = query.getResultList();
                    System.out.println("Result List:" + verlauf);
                    htmlString.append("<table  align='center' width='100%' style=\"border: 2px solid black; border-collapse: collapse;\">");
                    htmlString.append("<tr >");
                    htmlString.append("<td  width='12%' style=\"font-size: 11;border: 1px solid black; \"><b>Datum</b></td>");
                    htmlString.append("<td  width='3%' style=\"font-size: 11;border: 1px solid black;\"><b>LK</b></td>");
                    htmlString.append("<td  width='5%' style=\"font-size: 11;border: 1px solid black;\"><b>LF</b></td>");
                    htmlString.append("<td  width='7%' style=\"font-size: 11;border: 1px solid black;\"><b>Stunde</b></td>");
                    htmlString.append("<td  style=\"font-size: 11;border: 1px solid black;\"><b>Inhalt</b></td>");
                    htmlString.append("<td  style=\"font-size: 11;border: 1px solid black;\"><b>Bemerkungen</b></td>");
                    htmlString.append("<td  style=\"font-size: 11;border: 1px solid black;\"><b>Lernsituation</b></td>");

                    htmlString.append("</tr>");
                    for (Verlauf v : verlauf) {
                        htmlString.append("<tr>");
                        String str = v.getDATUM().toString();
                        htmlString.append("<td width='12%' style=\"font-size: 11;border: 1px solid black;\">" + str.substring(0, str.indexOf(" ")) + "</td>");
                        htmlString.append("<td width='3%' style=\"font-size: 11;border: 1px solid black;\">" + v.getID_LEHRER() + "</td>");
                        htmlString.append("<td width='5%' style=\"font-size: 11;border: 1px solid black;\">" + v.getID_LERNFELD() + "</td>");
                        htmlString.append("<td width='7%' style=\"font-size: 11;border: 1px solid black;\">" + v.getSTUNDE() + "</td>");
                        htmlString.append("<td style=\"font-size: 11;border: 1px solid black;\">" + v.getINHALT() + "</td>");
                        htmlString.append("<td style=\"font-size: 11;border: 1px solid black;\">" + v.getBEMERKUNG() + "</td>");
                        htmlString.append("<td style=\"font-size: 11;border: 1px solid black;\">" + v.getAUFGABE() + "</td>");

                        htmlString.append("</tr>");

                    }
                    htmlString.append("</table>");

                    document.open();
                    //document.add(new Paragraph("Tutorial to Generate PDF using Servlet"));
                    InputStream is = new ByteArrayInputStream(htmlString.toString().getBytes());
                    // Bild einfügen
                    String url = "http://www.mmbbs.de/fileadmin/template/mmbbs/gfx/mmbbs_logo_druck.gif";
                    Image image = Image.getInstance(url);
                    image.setAbsolutePosition(45f, 720f);
                    image.scalePercent(50f);
                    document.add(image);

                    XMLWorkerHelper.getInstance().parseXHtml(writer, document, is);
                    document.close();

                } catch (DocumentException exc) {
                    throw new IOException(exc.getMessage());
                } catch (ParseException ex) {
                    Logger.getLogger(DokuServlet.class.getName()).log(Level.SEVERE, null, ex);
                } finally {
                    out.close();
                }

            } else {
                response.setContentType("text/html;charset=UTF-8");
                try (PrintWriter out = response.getWriter()) {
                    out.println("<!DOCTYPE html>");
                    out.println("<html>");
                    out.println("<head>");
                    out.println("<title>Doku Servlet Usage</title>");
                    out.println("</head>");
                    out.println("<body>");
                    out.println("<h1>You are not authorized</h1>");
                    out.println("</body>");
                    out.println("</html>");
                }
            }
        }
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
        processRequest(request, response);
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
        processRequest(request, response);
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

}
