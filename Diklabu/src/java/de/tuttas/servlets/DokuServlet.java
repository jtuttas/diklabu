/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.servlets;

import com.itextpdf.text.BadElementException;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Font;
import com.itextpdf.text.Image;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.tool.xml.XMLWorkerHelper;
import com.sun.faces.lifecycle.Phase;

import de.tuttas.config.Config;
import de.tuttas.entities.Antwortskalen;
import de.tuttas.entities.Fragen;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Klasse_all;
import de.tuttas.entities.Lernfeld;
import de.tuttas.entities.Noten;
import de.tuttas.entities.Noten_all;

import de.tuttas.entities.Schueler;
import de.tuttas.entities.Schuljahr;
import de.tuttas.entities.Termine;
import de.tuttas.entities.Umfrage;
import de.tuttas.entities.Verlauf;
import de.tuttas.entities.Vertretung;
import de.tuttas.restful.Data.AntwortSkalaObjekt;
import de.tuttas.restful.Data.AnwesenheitEintrag;
import de.tuttas.restful.Data.AnwesenheitObjekt;
import de.tuttas.restful.Data.AusbilderObject;
import de.tuttas.restful.Data.NotenObjekt;
import de.tuttas.restful.Data.Termin;
import de.tuttas.restful.Data.UmfrageResult;
import de.tuttas.restful.UmfagenManager;
import de.tuttas.restful.auth.Authenticator;
import de.tuttas.restful.auth.Roles;
import de.tuttas.util.DatumUtil;
import de.tuttas.util.ExcelUtil;
import de.tuttas.util.Log;
import de.tuttas.util.NotenUtil;
import de.tuttas.util.PlanType;
import de.tuttas.util.StundenplanUtil;
import de.tuttas.util.UmfrageUtil;
import de.tuttas.util.VerspaetungsUtil;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.sql.Timestamp;

import java.util.Date;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;

/**
 * Erzeugt ein pdf zur Dokumentation
 *
 * @author Jörg
 */
public class DokuServlet extends HttpServlet {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;
  @Override
    protected void doOptions(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Send Response
        super.doOptions(request, response);
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Headers", "auth_token, Content-Type, X-Requested-With");
    }
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
        Log.d("auth_token=" + auth);
          response.setHeader("Access-Control-Allow-Origin", "*");
        response.addHeader("Access-Control-Allow-Headers", "auth_token");
        if (request.getParameter("cmd") == null || request.getParameter("idklasse") == null || request.getParameter("from") == null) {
            Log.d("Info zeigen");
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
                out.println("<a href='?cmd=Verlauf&idklasse=3608&from=2015-09-08&debug=" + Config.getInstance().debug + "' target='_pdf'>Usage: ?cmd=verlauf&idklasse=3608&from=2015-09-08</a>");
                out.println("</body>");
                out.println("</html>");
            }
        } else {
            if (Config.getInstance().debug ||  auth != null && Authenticator.getInstance().isAuthTokenValid(auth)) {
                Log.d("ID Klasse = "+request.getParameter("idklasse"));
                Klasse kl = em.find(Klasse.class, Integer.parseInt(request.getParameter("idklasse")));
                String cmd = request.getParameter("cmd");
                String type = request.getParameter("type");
                String sidSchuljahr = request.getParameter("idSchuljahr");
                int idSchuljahr = -1;
                if (sidSchuljahr != null) {
                    try {
                        idSchuljahr = Integer.parseInt(sidSchuljahr);
                    } catch (NumberFormatException nux) {

                    }
                }
                String filter1 = request.getParameter("dokufilter1");
                String filter2 = request.getParameter("dokufilter2");
                int anwFilter1 = 0;
                int anwFilter2 = 0;
                if (request.getParameter("anwfilter1") != null) {
                    anwFilter1 = Integer.parseInt(request.getParameter("anwfilter1"));
                }
                if (request.getParameter("anwfilter2") != null) {
                    anwFilter2 = Integer.parseInt(request.getParameter("anwfilter2"));
                }
                Authenticator a = Authenticator.getInstance();
                String me = a.getUser(auth);
                Log.d("Verlauf Filter1=" + filter1 + " Verlauf Filter2=" + filter2 + " me=" + me);
                Log.d("Anwesenheitsfilter 1 = " + anwFilter1 + " Filter2=" + anwFilter2);
                DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
                Date parsedFrom = null;
                try {
                    parsedFrom = (Date) dateFormat.parse(request.getParameter("from"));
                } catch (ParseException ex) {
                    Logger.getLogger(DokuServlet.class.getName()).log(Level.SEVERE, null, ex);
                }
                Date parsedTo = null;
                if (request.getParameter("to") == null) {
                    parsedTo = new java.sql.Date(System.currentTimeMillis());
                } else {
                    try {
                        parsedTo = (Date) dateFormat.parse(request.getParameter("to"));
                    } catch (ParseException ex) {
                        Logger.getLogger(DokuServlet.class.getName()).log(Level.SEVERE, null, ex);
                    }
                }
                Log.d("setze To auf " + new java.sql.Date(parsedTo.getTime()));
                Log.d("type=" + type + " cmd=" + cmd + " Klasse=" + kl.getKNAME());
                if (type.compareTo("csv") == 0) {
                    
                    MyTableDataModel myModel = null;
                    if (cmd.compareTo("Betriebe") == 0) {
                        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=UTF-8");
                        response.setCharacterEncoding("UTF-8");                        
                        String fileName= cmd + "_" + kl.getKNAME() + "_" + new java.sql.Date(parsedTo.getTime()).toString() + ".xlsx";
                        fileName=URLEncoder.encode(fileName,"UTF-8"); 
                        String contentDisposition = "attachment; filename=\"" + fileName + "\"; filename*=UTF-8''" + fileName;
                        response.addHeader("Content-Disposition", contentDisposition );                                           
                        
                        myModel = getModelBetriebsliste(kl);
                        XSSFWorkbook wb = ExcelUtil.readExcel(Config.getInstance().TEMPLATE_FILE_PATH+cmd+".xlsx",new String[]{"Betriebe"}, myModel.getRows(),myModel.getCols());
                        wb=myModel.toExcel(wb,0);
                        wb.write(response.getOutputStream());
                    } else if (cmd.compareTo("Notenliste") == 0) {                        
                        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=UTF-8");
                        response.setCharacterEncoding("UTF-8");                        
                        String fileName= cmd + "_" + kl.getKNAME() + "_" + new java.sql.Date(parsedTo.getTime()).toString() + ".xlsx";
                        fileName=URLEncoder.encode(fileName,"UTF-8"); 
                        String contentDisposition = "attachment; filename=\"" + fileName + "\"; filename*=UTF-8''" + fileName;
                        response.addHeader("Content-Disposition", contentDisposition );                                           
                        
                        myModel = getModelNotenliste(kl, idSchuljahr);
                        XSSFWorkbook wb = ExcelUtil.readExcel(Config.getInstance().TEMPLATE_FILE_PATH+cmd+".xlsx",new String[]{"Notenliste"}, myModel.getRows(),myModel.getCols());
                        wb=myModel.toExcel(wb,0);
                        wb.write(response.getOutputStream());
                        
                    } else if (cmd.compareTo("Fehlzeiten") == 0) {
                        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=UTF-8");
                        response.setCharacterEncoding("UTF-8");                        
                        String fileName= cmd + "_" + kl.getKNAME() + "_" + new java.sql.Date(parsedFrom.getTime()).toString() + "-" + new java.sql.Date(parsedTo.getTime()).toString() + ".xlsx";
                        fileName=URLEncoder.encode(fileName,"UTF-8"); 
                        String contentDisposition = "attachment; filename=\"" + fileName + "\"; filename*=UTF-8''" + fileName;
                        response.addHeader("Content-Disposition", contentDisposition );                                           
                        
                        myModel = getModelFehlzeiten(kl, parsedFrom, parsedTo);
                        XSSFWorkbook wb = ExcelUtil.readExcel(Config.getInstance().TEMPLATE_FILE_PATH+cmd+".xlsx",new String[]{"Fehlzeiten"}, myModel.getRows(),myModel.getCols());
                        wb=myModel.toExcel(wb,0);
                        wb.write(response.getOutputStream());
                    } else if (cmd.compareTo("Anwesenheit") == 0) {
                        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=UTF-8");
                        response.setCharacterEncoding("UTF-8");                        
                        String fileName= cmd + "_" + kl.getKNAME() + "_" + new java.sql.Date(parsedFrom.getTime()).toString() + "-" + new java.sql.Date(parsedTo.getTime()).toString() + ".xlsx";
                        fileName=URLEncoder.encode(fileName,"UTF-8"); 
                        String contentDisposition = "attachment; filename=\"" + fileName + "\"; filename*=UTF-8''" + fileName;
                        response.addHeader("Content-Disposition", contentDisposition );                                           
                        
                        myModel = getModelAnwesenheit(kl, parsedFrom, parsedTo, anwFilter1, anwFilter2);
                        XSSFWorkbook wb = ExcelUtil.readExcel(Config.getInstance().TEMPLATE_FILE_PATH+cmd+".xlsx",new String[]{"Anwesenheit"}, myModel.getRows(),myModel.getCols());
                        wb=myModel.toExcel(wb,0);
                        wb.write(response.getOutputStream());
                        
                    } else if (cmd.compareTo("Verlauf") == 0) {
                        
                        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=UTF-8");
                        response.setCharacterEncoding("UTF-8");                        
                        String fileName= cmd + "_" + kl.getKNAME() + "_" + new java.sql.Date(parsedFrom.getTime()).toString() + "-" + new java.sql.Date(parsedTo.getTime()).toString()+".xlsx";
                        fileName=URLEncoder.encode(fileName,"UTF-8"); 
                        String contentDisposition = "attachment; filename=\"" + fileName + "\"; filename*=UTF-8''" + fileName;
                        response.addHeader("Content-Disposition", contentDisposition );
                        
                        myModel = getModelVerlauf(kl, parsedFrom, parsedTo, filter1, filter2, me);
                        XSSFWorkbook wb = ExcelUtil.readExcel(Config.getInstance().TEMPLATE_FILE_PATH+cmd+".xlsx",new String[]{"Unterrichtsverlauf"}, myModel.getRows(),myModel.getCols());
                        wb=myModel.toExcel(wb,0);
                        wb.write(response.getOutputStream());
                    } else if (cmd.compareTo("UmfrageAuswertung") == 0) {                        
                        Umfrage u = em.find(Umfrage.class, anwFilter1);
                        Umfrage u2 = em.find(Umfrage.class, anwFilter2);
                        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet; charset=UTF-8");
                        response.setCharacterEncoding("UTF-8");                        
                        String fileName= "Auswertung_"+u.getNAME()+"_vom_"+ new java.sql.Date(parsedTo.getTime()).toString() + ".xlsx";
                        fileName=URLEncoder.encode(fileName,"UTF-8"); 
                        String contentDisposition = "attachment; filename=\"" + fileName + "\"; filename*=UTF-8''" + fileName;
                        response.addHeader("Content-Disposition", contentDisposition );
                        List<UmfrageResult> res1 = UmfrageUtil.getUmfrageResult(em,auth, anwFilter1, filter1);
                        List<UmfrageResult> res2 = UmfrageUtil.getUmfrageResult(em,auth, anwFilter2, filter2);
                        res2=UmfrageUtil.getComparableResultList(res1,res2);
                        myModel = getModelUmfrageAuswertung(res1);                        
                        XSSFWorkbook wb = ExcelUtil.readExcel(Config.getInstance().TEMPLATE_FILE_PATH+u.getNAME()+".xlsx",new String[]{"Hauptgruppe","Vergleichsgruppe","Info"},myModel.getRows(),myModel.getCols());
                        wb=myModel.toExcel(wb,0);
                        myModel = getModelUmfrageAuswertung(res2);                        
                        wb=myModel.toExcel(wb,1);
                        XSSFSheet s = wb.getSheetAt(2);
                        XSSFRow r = s.getRow(0);
                        r.getCell(0).setCellValue(u.getNAME());
                        r.getCell(1).setCellValue(filter1);
                        r=s.getRow(1);
                        r.getCell(0).setCellValue(u2.getNAME());
                        r.getCell(1).setCellValue(filter2);
                        wb.write(response.getOutputStream());                        
                    }else {
                        PrintWriter out = response.getWriter();
                        response.setContentType("application/json; charset=UTF-8");
                        String r = "{\"error\":true,\"msg\":\"Kann für " + cmd + " kein Datenmodell erzeugen!\"}";
                        out.print(r);
                    }
                } else {
                    response.setContentType("application/pdf");
                    //Get the output stream for writing PDF object        
                    OutputStream out = response.getOutputStream();
                    try {
                        String kopf = "";
                        kopf += ("<table border='1' align='center' width='100%'>");
                        kopf += ("<tr>");
                        kopf += ("<td rowspan=\"3\" width='150px'></td>");
                        kopf += ("<td align='center'><h2>Multi Media Berufsbildende Schulen Hannover</h2></td>");
                        if (cmd.compareTo("Verlauf") == 0) {
                            kopf += ("<td colspan=\"2\" align='center'><b>Digitales Klassenbuch Unterrichtsverlauf</b></td>");
                        } else if (cmd.compareTo("Anwesenheit") == 0) {
                            kopf += ("<td colspan=\"2\" align='center'><b>Digitales Klassenbuch Anwesenheit</b></td>");
                        } else if (cmd.compareTo("Fehlzeiten") == 0) {
                            kopf += ("<td colspan=\"2\" align='center'><b>Digitales Klassenbuch Fehlzeiten</b></td>");
                        } else if (cmd.compareTo("Stundenplan") == 0) {
                            kopf += ("<td colspan=\"2\" align='center'><b>Digitales Klassenbuch Stundenplan</b></td>");
                        } else if (cmd.compareTo("Vertretungsplan") == 0) {
                            kopf += ("<td colspan=\"2\" align='center'><b>Digitales Klassenbuch Vertretungsplan</b></td>");
                        } else if (cmd.compareTo("Notenliste") == 0) {
                            kopf += ("<td colspan=\"2\" align='center'><b>Digitales Klassenbuch Notenliste</b></td>");
                        } else if (cmd.compareTo("Betriebe") == 0) {
                            kopf += ("<td colspan=\"2\" align='center'><b>Digitales Klassenbuch Betriebsliste</b></td>");
                        } else if (cmd.compareTo("UmfrageAuswertung") == 0) {
                            kopf += ("<td colspan=\"2\" align='center'><b>Digitales Klassenbuch Auswertung Umfrage</b></td>");
                        }
                        kopf += ("</tr>");
                        kopf += ("<tr>");
                        if (cmd.compareTo("UmfrageAuswertung") == 0) {
                            Umfrage u1 = em.find(Umfrage.class, anwFilter1);
                            Umfrage u2 = em.find(Umfrage.class, anwFilter2);
                            kopf += ("<td  align='center' rowspan=\"2\" style=\"padding:5px;font-size: 11\">Hauptgruppe: (" + u1.getNAME() + "/" + filter1 + ")<br></br> Vergleichsgruppe: (" + u2.getNAME() + "/" + filter2 + ")</td>");
                        } else {
                            kopf += ("<td  align='center' rowspan=\"2\"><h3>Klasse/ Kurs: " + kl.getKNAME() + "</h3></td>");
                        }
                        kopf += ("<td  style=\"font-size: 11;\">Verantwortlicher: " + kl.getID_LEHRER() + "</td>");
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

                        Document document;
                        if (cmd.compareTo("Verlauf") == 0) {
                            response.addHeader("Content-Disposition", "attachment; filename=Verlauf_" + kl.getKNAME() + "_" + new java.sql.Date(parsedFrom.getTime()).toString() + "-" + new java.sql.Date(parsedTo.getTime()).toString() + ".pdf");
                            document = createVerlauf(kl, kopf, parsedFrom, parsedTo, out, filter1, filter2, me);
                        } else if (cmd.compareTo("Portfolio") == 0) {
                            response.addHeader("Content-Disposition", "attachment; filename=Portfolio_" + kl.getKNAME() + ".pdf");
                            document = createPortfolio(kl, out);
                        } else if (cmd.compareTo("Anwesenheit") == 0) {
                            response.addHeader("Content-Disposition", "attachment; filename=Anwesenheit_" + kl.getKNAME() + "_" + new java.sql.Date(parsedFrom.getTime()).toString() + "-" + new java.sql.Date(parsedTo.getTime()).toString() + ".pdf");
                            document = createAnwesenheit(kl, kopf, parsedFrom, parsedTo, out, anwFilter1, anwFilter2);
                        } else if (cmd.compareTo("Fehlzeiten") == 0) {
                            response.addHeader("Content-Disposition", "attachment; filename=Fehlzeiten_" + kl.getKNAME() + "_" + new java.sql.Date(parsedFrom.getTime()).toString() + "-" + new java.sql.Date(parsedTo.getTime()).toString() + ".pdf");
                            MyTableDataModel myModel = getModelFehlzeiten(kl, parsedFrom, parsedTo);
                            document = createFehlzeiten(kl, kopf, parsedFrom, parsedTo, out);
                        } else if (cmd.compareTo("Vertretungsliste") == 0) {
                            response.addHeader("Content-Disposition", "attachment; filename=Vertretungsliste_" + new java.sql.Date(parsedFrom.getTime()).toString() + "-" + new java.sql.Date(parsedTo.getTime()).toString() + ".pdf");
                            document = createVertretungsliste(parsedFrom, parsedTo, out);
                        } else if (cmd.compareTo("Notenliste") == 0) {
                            response.addHeader("Content-Disposition", "attachment; filename=Notenliste_" + kl.getKNAME() + "_" + new java.sql.Date(parsedTo.getTime()).toString() + ".pdf");
                            MyTableDataModel myModel = getModelNotenliste(kl, idSchuljahr);
                            Schuljahr schuljahr = em.find(Schuljahr.class, idSchuljahr);
                            document = createNotenliste(myModel, kopf, out, schuljahr.getNAME());
                        } else if (cmd.compareTo("Betriebe") == 0) {
                            response.addHeader("Content-Disposition", "attachment; filename=Betriebsliste_" + kl.getKNAME() + "_" + new java.sql.Date(parsedTo.getTime()).toString() + ".pdf");
                            MyTableDataModel myModel = getModelBetriebsliste(kl);
                            document = createBetriebsListe(myModel, kopf, out);
                        } else if (cmd.compareTo("UmfrageAuswertung") == 0) {
                            response.addHeader("Content-Disposition", "attachment; filename=UmfrageAuswertung_" + new java.sql.Date(parsedTo.getTime()).toString() + ".pdf");
                            List<UmfrageResult> res1 = UmfrageUtil.getUmfrageResult(em,auth, anwFilter1, filter1);
                            List<UmfrageResult> res2 = UmfrageUtil.getUmfrageResult(em,auth, anwFilter2, filter2);
                            res2=UmfrageUtil.getComparableResultList(res1,res2);
                            if (res1 != null && res2 != null) {
                                Log.d("erzeuge pdf Dokument");
                                document = createUmfrageauswertung(res1, res2, anwFilter1, anwFilter2, filter1, filter2, kopf, out);
                            }
                        }

                    } catch (DocumentException exc) {
                        Log.d("Document Exception " + exc.getMessage());
                        exc.printStackTrace();
                        throw new IOException(exc.getMessage());
                    } catch (ParseException ex) {
                        Log.d("Parse Exception " + ex.getMessage());
                        Logger.getLogger(DokuServlet.class.getName()).log(Level.SEVERE, null, ex);
                    } finally {
                        out.close();
                    }

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

    private MyTableDataModel getModelNotenliste(Klasse kl, int idSchuljahr) {
        Query q = em.createNamedQuery("findSchuelerEinerBenanntenKlasse");
        q.setParameter("paramNameKlasse", kl.getKNAME());
        List<Schueler> schueler = q.getResultList();

        Query query = em.createNamedQuery("findNoteneinerKlasse");
        query.setParameter("paramNameKlasse", kl.getKNAME());
        query.setParameter("paramIDSchuljahr", idSchuljahr);

        List<Noten_all> noten = query.getResultList();
        Log.d("Result List:" + noten);

        List<NotenObjekt> lno = new ArrayList<>();
        List<String> lernfelder = new ArrayList<>();
        List<String> lernfelderNamen = new ArrayList<>();
        int sid = 0;
        NotenObjekt no = null;
        for (Noten_all n : noten) {
            if (!lernfelder.contains(n.getID_LERNFELD())) {
                Log.d("Neues Lernfeld mit id=" + n.getID_LERNFELD());
                lernfelder.add(n.getID_LERNFELD());
                lernfelderNamen.add(em.find(Lernfeld.class, n.getID_LERNFELD()).getBEZEICHNUNG());
            }
            if (sid != n.getID_SCHUELER()) {
                no = new NotenObjekt();
                no.setSchuelerID(n.getID_SCHUELER());
                no.setSuccess(true);
                lno.add(no);
                sid = n.getID_SCHUELER();
            }
            no.getNoten().add(n);
        }
        Log.d("Habe " + schueler.size() + " Schüler und " + lernfelder.size() + " Lernfelder");
        lernfelderNamen.add(0, "Name");
        lernfelder.add(0, "Name");
        String[] headlines = new String[lernfelderNamen.size()];
        for (int n = 0; n < headlines.length; n++) {
            headlines[n] = lernfelderNamen.get(n);
        }
        MyTableDataModel mo = new MyTableDataModel(schueler.size(), headlines);
        Schueler s;
        String lf;
        for (int y = 0; y < schueler.size(); y++) {
            s = schueler.get(y);
            mo.setData(0, y, s.getVNAME() + " " + s.getNNAME());
            Log.d(" Noten f. Schüler " + s.getNNAME() + " ID=" + s.getId());
            for (int x = 1; x < lernfelder.size(); x++) {
                lf = lernfelder.get(x);
                Log.d("LF=" + lf);
                mo.setData(x, y, getNoteSchueler(s.getId(), lf, lno));
            }
        }
        return mo;
    }

    private MyTableDataModel getModelBetriebsliste(Klasse kl) {
        Query q = em.createNamedQuery("findSchuelerEinerBenanntenKlasse");
        q.setParameter("paramNameKlasse", kl.getKNAME());
        List<Schueler> schueler = q.getResultList();

        TypedQuery<AusbilderObject> query = em.createNamedQuery("findBetriebeEinerBenanntenKlasse", AusbilderObject.class);
        query.setParameter("paramNameKlasse", kl.getKNAME());
        List<AusbilderObject> ausbilder = query.getResultList();

        Log.d("schuler = " + schueler.size());
        MyTableDataModel mo = new MyTableDataModel(schueler.size(), new String[]{"Name", "Betrieb", "Ausbilder", "Email", "Tel", "Fax"});
        Log.d("mo=" + mo.toCsv());
        for (int y = 0; y < schueler.size(); y++) {
            Schueler s = schueler.get(y);
            mo.setData(0, y, s.getVNAME() + " " + s.getNNAME());
            AusbilderObject ao = getAusbilder(s.getId(), ausbilder);
            if (ao != null) {
                mo.setData(1, y, ao.getName());
                mo.setData(2, y, ao.getnName());
                mo.setData(3, y, ao.getEmail());
                mo.setData(4, y, ao.getTelefon());
                mo.setData(5, y, ao.getFax());
            }
        }
        return mo;
    }

    private Document createUmfrageauswertung(List<UmfrageResult> res1, List<UmfrageResult> res2, int idUmfrage1, int idUmfrage2, String filter1, String filter2, String kopf, OutputStream out) throws DocumentException, BadElementException, IOException {
        Document document = new Document();
        /* Basic PDF Creation inside servlet */
        Umfrage u1 = em.find(Umfrage.class, idUmfrage1);
        Umfrage u2 = em.find(Umfrage.class, idUmfrage2);

        // Bild einfügen
        String url = "http://www.mmbbs.de/fileadmin/template/mmbbs/gfx/mmbbs_logo_druck.gif";
        Image image = Image.getInstance(url);
        image.setAbsolutePosition(45f, 720f);
        image.scalePercent(50f);
        
        StringBuilder htmlString = new StringBuilder();
        htmlString.append(kopf);
        htmlString.append("<br></br>");

        int maxRows = res1.size();
        if (res2.size() > maxRows) {
            maxRows = res2.size();
        }
        PdfWriter writer = PdfWriter.getInstance(document, out);
        document.open();
        writer.setPageEmpty(false);
        Font boldFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
        Font normalFont = new Font(Font.FontFamily.HELVETICA, 10, Font.ITALIC);
        PdfPTable table = new PdfPTable(new float[]{1, 2, 2});
        PdfPCell qestionCell;
        PdfPCell group1Cell;
        PdfPCell group2Cell;
        int i=0;
        for (i = 0; i < maxRows; i++) {
            Log.d("Print Row "+i);
            if (i % 5 == 0) {
                if (i != 0) {
                    document.add(table);
                    document.newPage();
                    document = printHead(writer,document, htmlString, out,image);
                } else {
                    document = printHead(writer,document, htmlString, out,image);
                }

                table = new PdfPTable(new float[]{1, 2, 2});
                table.setWidthPercentage((float) 100.0);
                qestionCell = new PdfPCell(new Phrase("\nFragen", boldFont));
                group1Cell = new PdfPCell();
                group1Cell.addElement(new Phrase("Hauptgruppe:", boldFont));
                group1Cell.addElement(new Phrase(u1.getNAME() + "\n" + filter1, normalFont));
                group2Cell = new PdfPCell();
                group2Cell.addElement(new Phrase("Vergleichsgruppe:", boldFont));
                group2Cell.addElement(new Phrase(u2.getNAME() + "\n" + filter2, normalFont));
                qestionCell.setBorderWidth(2.0f);
                group1Cell.setBorderWidth(2.0f);
                group2Cell.setBorderWidth(2.0f);
                table.addCell(qestionCell);
                table.addCell(group1Cell);
                table.addCell(group2Cell);
            }
            String url1 = UmfrageUtil.getCharUrl(res1.get(i));
            Log.d("URL1="+url1);
            Image image1 = Image.getInstance(url1);

            Image image2=null;
            if (res2.size()>i) {
                String url2 = UmfrageUtil.getCharUrl(res2.get(i));
                Log.d("URL2="+url2);
                image2 = Image.getInstance(url2);
            }
            Log.d("Write to pdf:"+res1.get(i).getFrage());
            qestionCell = new PdfPCell(new Phrase(res1.get(i).getFrage(), normalFont));
            qestionCell.setBorderWidth(1.0f);
            group1Cell = new PdfPCell(image1, true);
            group1Cell.setBorderWidth(1.0f);
            group1Cell.setPadding(10);
            if (image2!=null) group2Cell = new PdfPCell(image2, true);
            else group2Cell = new PdfPCell();
            group2Cell.setBorderWidth(1.0f);
            group2Cell.setPadding(10);

            table.addCell(qestionCell);
            table.addCell(group1Cell);
            table.addCell(group2Cell);
        }
        if (!(i%5==0)) {
            document.add(table);            
        }

        document.close();
        return document;
    }

    private Document createBetriebsListe(MyTableDataModel mo, String kopf, OutputStream out) throws ParseException, IOException, DocumentException {
        Document document = new Document();
        /* Basic PDF Creation inside servlet */
        PdfWriter writer = PdfWriter.getInstance(document, out);
        StringBuilder htmlString = new StringBuilder();
        htmlString.append(kopf);

        htmlString.append("<br></br><table  align='center' width='100%' style=\"border: 2px solid black; border-collapse: collapse;\">");
        htmlString.append("<tr><td width='25%' style=\"padding:5px;font-size: 14;border: 1px solid black;\"><b>Name</b></td>");
        htmlString.append("<td style=\"padding:5px;border: 1px solid black;\">" + mo.getData(1, 0) + "</td>");
        htmlString.append("<td style=\"padding:5px;border: 1px solid black;\">" + mo.getData(2, 0) + "</td>");
        htmlString.append("<td style=\"padding:5px;border: 1px solid black;\">" + mo.getData(3, 0) + "</td>");
        htmlString.append("<td style=\"padding:5px;border: 1px solid black;\">" + mo.getData(4, 0) + "</td>");
        htmlString.append("<td style=\"padding:5px;border: 1px solid black;\">" + mo.getData(5, 0) + "</td>");
        htmlString.append("</tr>");

        for (int y = 1; y < mo.getRows(); y++) {
            htmlString.append("<tr>");
            htmlString.append("<td style=\"padding:5px;border: 1px solid black;\">" + mo.getData(0, y) + "</td>");
            for (int x = 1; x < mo.getCols(); x++) {
                htmlString.append("<td style=\"font-size: 10;padding:5px;border: 1px solid black;\">" + mo.getData(x, y) + "</td>");
            }
            htmlString.append("</tr>");
        }

        htmlString.append("</table>");
        document.open();
        // Dokument erzeugen
        InputStream is = new ByteArrayInputStream(htmlString.toString().getBytes());
        // Bild einfügen
        String url = "http://www.mmbbs.de/fileadmin/template/mmbbs/gfx/mmbbs_logo_druck.gif";
        Image image = Image.getInstance(url);
        image.setAbsolutePosition(45f, 720f);
        image.scalePercent(50f);
        document.add(image);
        XMLWorkerHelper.getInstance().parseXHtml(writer, document, is);
        document.close();
        return document;
    }

    private Document createNotenliste(MyTableDataModel mo, String kopf, OutputStream out, String schuljahrName) throws ParseException, IOException, DocumentException {

        Document document = new Document();
        /* Basic PDF Creation inside servlet */
        PdfWriter writer = PdfWriter.getInstance(document, out);
        StringBuilder htmlString = new StringBuilder();
        htmlString.append(kopf);
        htmlString.append("<h3 align=\"center\">" + schuljahrName + "</h3>");
        htmlString.append("<table  align='center' width='100%' style=\"border: 2px solid black; border-collapse: collapse;\">");
        htmlString.append("<tr><td width='25%' style=\"padding:5px;font-size: 14;border: 1px solid black;\"><b>Name</b></td>");

        for (int x = 1; x < mo.getCols(); x++) {
            htmlString.append("<td style=\"padding:5px;border: 1px solid black;\">" + mo.getData(x, 0) + "</td>");
        }
        htmlString.append("</tr>");

        for (int y = 1; y < mo.getRows(); y++) {
            htmlString.append("<tr>");
            htmlString.append("<td style=\"padding:5px;border: 1px solid black;\">" + mo.getData(0, y) + "</td>");

            for (int x = 1; x < mo.getCols(); x++) {
                htmlString.append("<td style=\"padding:5px;border: 1px solid black;\">" + mo.getData(x, y) + "</td>");
            }

            htmlString.append("</tr>");
        }

        htmlString.append("</table>");
        document.open();
        // Dokument erzeugen
        InputStream is = new ByteArrayInputStream(htmlString.toString().getBytes());
        // Bild einfügen
        String url = "http://www.mmbbs.de/fileadmin/template/mmbbs/gfx/mmbbs_logo_druck.gif";
        Image image = Image.getInstance(url);
        image.setAbsolutePosition(45f, 720f);
        image.scalePercent(50f);
        document.add(image);
        XMLWorkerHelper.getInstance().parseXHtml(writer, document, is);

        document.close();
        return document;
    }

    private Document createStundenplan(Klasse kl, String kopf, Date parsedFrom, Date parsedTo, OutputStream out) throws ParseException, IOException, DocumentException {
        Document document = new Document();
        /* Basic PDF Creation inside servlet */
        PdfWriter writer = PdfWriter.getInstance(document, out);
        StringBuilder htmlString = new StringBuilder();
        htmlString.append(kopf);
        htmlString.append(StundenplanUtil.getInstance().getPlan(kl.getKNAME(), PlanType.STDPlanSchueler));
        document.open();
        // Dokument erzeugen
        InputStream is = new ByteArrayInputStream(htmlString.toString().getBytes());
        // Bild einfügen
        String url = "http://www.mmbbs.de/fileadmin/template/mmbbs/gfx/mmbbs_logo_druck.gif";
        Image image = Image.getInstance(url);
        image.setAbsolutePosition(45f, 720f);
        image.scalePercent(50f);
        document.add(image);
        XMLWorkerHelper.getInstance().parseXHtml(writer, document, is);

        document.close();
        return document;
    }

    private Document createVertretungsplan(Klasse kl, String kopf, Date parsedFrom, Date parsedTo, OutputStream out) throws ParseException, IOException, DocumentException {
        Document document = new Document();
        /* Basic PDF Creation inside servlet */
        PdfWriter writer = PdfWriter.getInstance(document, out);
        StringBuilder htmlString = new StringBuilder();
        htmlString.append(kopf);
        htmlString.append(StundenplanUtil.getInstance().getPlan(kl.getKNAME(), PlanType.VERTRPlanSchueler));
        document.open();
        // Dokument erzeugen
        InputStream is = new ByteArrayInputStream(htmlString.toString().getBytes());
        // Bild einfügen
        String url = "http://www.mmbbs.de/fileadmin/template/mmbbs/gfx/mmbbs_logo_druck.gif";
        Image image = Image.getInstance(url);
        image.setAbsolutePosition(45f, 720f);
        image.scalePercent(50f);
        document.add(image);
        XMLWorkerHelper.getInstance().parseXHtml(writer, document, is);

        document.close();
        return document;
    }

    private MyTableDataModel getModelFehlzeiten(Klasse kl, Date parsedFrom, Date parsedTo) {
        Query q = em.createNamedQuery("findSchuelerEinerBenanntenKlasse");
        q.setParameter("paramNameKlasse", kl.getKNAME());
        List<Schueler> schueler = q.getResultList();

        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbyKlasse", AnwesenheitEintrag.class);
        query.setParameter("paramKName", kl.getKNAME());
        query.setParameter("paramFromDate", new java.sql.Date(parsedFrom.getTime()));
        query.setParameter("paramToDate", new java.sql.Date(parsedTo.getTime()));
        Log.d("setze From auf " + new java.sql.Date(parsedFrom.getTime()));
        List<AnwesenheitObjekt> anwesenheit = getData(query);
        int rows = 0;
        for (AnwesenheitObjekt ao : anwesenheit) {
            VerspaetungsUtil.parse(ao);
            if (ao.getAnzahlVerspaetungen() != 0 || ao.getSummeFehltage() != 0) {
                rows++;
            }
        }
        MyTableDataModel mo = new MyTableDataModel(rows, new String[]{"Name", "Fehltage gesamt", "Fehltage entschuldigt", "Verspätungen", "Verspätungen [min]", "Verspätungen [min] entschuldigt"});

        int y = 0;
        for (AnwesenheitObjekt ao : anwesenheit) {
            if (ao.getAnzahlVerspaetungen() != 0 || ao.getSummeFehltage() != 0) {
                mo.setData(0, y, getSchulerName(ao.getId_Schueler(), schueler));
                mo.setData(1, y, "" + ao.getSummeFehltage());
                mo.setData(2, y, "" + ao.getSummeFehltageEntschuldigt());
                mo.setData(3, y, "" + ao.getAnzahlVerspaetungen());
                mo.setData(4, y, "" + ao.getSummeMinutenVerspaetungen());
                mo.setData(5, y, "" + ao.getSummeMinutenVerspaetungenEntschuldigt());
                y++;
            }
        }
        return mo;
    }

    private Document createFehlzeiten(Klasse kl, String kopf, Date parsedFrom, Date parsedTo, OutputStream out) throws ParseException, IOException, DocumentException {
        Document document = new Document();
        /* Basic PDF Creation inside servlet */
        PdfWriter writer = PdfWriter.getInstance(document, out);
        StringBuilder htmlString = new StringBuilder();
        htmlString.append(kopf);
        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbyKlasse", AnwesenheitEintrag.class);
        query.setParameter("paramKName", kl.getKNAME());
        query.setParameter("paramFromDate", new java.sql.Date(parsedFrom.getTime()));
        query.setParameter("paramToDate", new java.sql.Date(parsedTo.getTime()));
        Log.d("setze From auf " + new java.sql.Date(parsedFrom.getTime()));
        List<AnwesenheitObjekt> anwesenheit = getData(query);

        Log.d("Result List:" + anwesenheit);
        document.open();
        String tagZeile = "";
        tagZeile += "<table  align='center' width='100%' style=\"border: 2px solid black; border-collapse: collapse;\">\n";
        tagZeile += AnwesenheitObjekt.getTRHead();

        for (AnwesenheitObjekt ao : anwesenheit) {
            VerspaetungsUtil.parse(ao);
            if (ao.getAnzahlVerspaetungen() != 0 || ao.getSummeFehltage() != 0) {
                Schueler s = em.find(Schueler.class, ao.getId_Schueler());
                Log.d("Fehltage für Schuler " + s);
                tagZeile += ao.toHTML(s.getVNAME() + " " + s.getNNAME());
            }
        }
        tagZeile += "</table>";
        htmlString.append(tagZeile);

        // Dokument erzeugen
        InputStream is = new ByteArrayInputStream(htmlString.toString().getBytes());
        // Bild einfügen
        String url = "http://www.mmbbs.de/fileadmin/template/mmbbs/gfx/mmbbs_logo_druck.gif";
        Image image = Image.getInstance(url);
        image.setAbsolutePosition(45f, 720f);
        image.scalePercent(50f);
        document.add(image);
        XMLWorkerHelper.getInstance().parseXHtml(writer, document, is);

        document.close();
        return document;
    }

    private MyTableDataModel getModelAnwesenheit(Klasse kl, Date parsedFrom, Date parsedTo, int filter1Id, int filter2Id) {
        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbyKlasse", AnwesenheitEintrag.class);
        query.setParameter("paramKName", kl.getKNAME());
        query.setParameter("paramFromDate", new java.sql.Date(parsedFrom.getTime()));
        query.setParameter("paramToDate", new java.sql.Date(parsedTo.getTime()));
        Log.d("setze From auf " + new java.sql.Date(parsedFrom.getTime()));
        List<AnwesenheitObjekt> anwesenheit = getData(query);

        Query q = em.createNamedQuery("findSchuelerEinerBenanntenKlasse");
        q.setParameter("paramNameKlasse", kl.getKNAME());
        List<Schueler> schueler = q.getResultList();

        /**
         * Termindaten holen
         */
        Termine t1 = null;
        Termine t2 = null;
        if (filter1Id != -1) {
            t1 = em.find(Termine.class, filter1Id);

        }
        if (filter2Id != -1) {
            t2 = em.find(Termine.class, filter2Id);
        }
        List<Termin> termine = null;
        TypedQuery<Termin> tquery = null;
        if (filter1Id != 0) {
            // zwei Filter
            if (filter2Id != 0) {
                tquery = em.createNamedQuery("findAllTermineTwoFilters", Termin.class);
                tquery.setParameter("filter1", t1.getId());
                tquery.setParameter("filter2", t2.getId());
                tquery.setParameter("fromDate", new java.sql.Date(parsedFrom.getTime()));
                tquery.setParameter("toDate", new java.sql.Date(parsedTo.getTime()));
                termine = tquery.getResultList();
            } // nur Filter1
            else {
                tquery = em.createNamedQuery("findAllTermineOneFilter", Termin.class);
                tquery.setParameter("filter1", t1.getId());
                tquery.setParameter("fromDate", new java.sql.Date(parsedFrom.getTime()));
                tquery.setParameter("toDate", new java.sql.Date(parsedTo.getTime()));
                termine = tquery.getResultList();
            }
        } else {
            // nur Filter2
            if (filter2Id != 0) {
                tquery = em.createNamedQuery("findAllTermineOneFilter", Termin.class);
                tquery.setParameter("filter1", t2.getId());
                tquery.setParameter("fromDate", new java.sql.Date(parsedFrom.getTime()));
                tquery.setParameter("toDate", new java.sql.Date(parsedTo.getTime()));
                termine = tquery.getResultList();
            } // kein Filter, Termine so generieren
            else {
                termine = new ArrayList<>();
                Date current = new Date(parsedFrom.getTime());
                parsedTo.setTime(parsedTo.getTime() + 1000);
                while (current.before(parsedTo)) {
                    termine.add(new Termin(new Timestamp(current.getTime())));
                    Log.d("!Erzeuge neuen Termin:" + new Termin(new Timestamp(current.getTime())));
                    //current.setTime(current.getTime() + 24 * 60 * 60 * 1000);
                    Calendar c = Calendar.getInstance(TimeZone.getTimeZone("CET"));
                    c.setTime(current);
                    c.add(Calendar.DATE, 1);
                    c.set(Calendar.HOUR, 0);
                    c.set(Calendar.MINUTE, 0);
                    c.set(Calendar.SECOND, 0);
                    Log.d("Calendar is "+c);
                    current=c.getTime();
                    
                    //current.setTime(current.getTime() + 24 * 60 * 60 * 1000);
                    
                }
            }
        }

        Log.d("Result List:" + anwesenheit);

        List<String> sb = new ArrayList<>();
        GregorianCalendar c = (GregorianCalendar) GregorianCalendar.getInstance();

        for (Termin t : termine) {
            c.setTime(new Date(t.getDate().getTime()));
            sb.add("" + DatumUtil.getWochentag(c.get(GregorianCalendar.DAY_OF_WEEK)) + ":" + c.get(GregorianCalendar.DATE) + "." + (c.get(GregorianCalendar.MONTH) + 1) + "." + c.get(GregorianCalendar.YEAR));
        }
        Log.d("Es werden " + sb.size() + " Tage dargestellt");
        sb.add(0, "Name");
        String[] cols = new String[sb.size()];
        for (int i = 0; i < cols.length; i++) {
            cols[i] = sb.get(i);
        }
        MyTableDataModel mo = new MyTableDataModel(schueler.size(), cols);
        Schueler s;
        for (int y = 0; y < schueler.size(); y++) {
            s = schueler.get(y);
            mo.setData(0, y, s.getVNAME() + " " + s.getNNAME());
            int x = 1;
            for (Termin t : termine) {
                mo.setData(x, y, findVermerk(s.getId(), t.getDate(), anwesenheit));
                x++;
            }
        }
        return mo;
    }

    private Document createAnwesenheit(Klasse kl, String kopf, Date parsedFrom, Date parsedTo, OutputStream out, int filter1Id, int filter2Id) throws ParseException, IOException, DocumentException {
        Document document = new Document();
        /* Basic PDF Creation inside servlet */
        PdfWriter writer = PdfWriter.getInstance(document, out);
        StringBuilder htmlString = new StringBuilder();
        htmlString.append(kopf);
        /* Anwesenheit einfügen */
        TypedQuery<AnwesenheitEintrag> query = em.createNamedQuery("findAnwesenheitbyKlasse", AnwesenheitEintrag.class);
        query.setParameter("paramKName", kl.getKNAME());
        query.setParameter("paramFromDate", new java.sql.Date(parsedFrom.getTime()));
        query.setParameter("paramToDate", new java.sql.Date(parsedTo.getTime()));

        Log.d("setze From auf " + new java.sql.Date(parsedFrom.getTime()));
        List<AnwesenheitObjekt> anwesenheit = getData(query);

        /**
         * Termindaten holen
         */
        Termine t1 = null;
        Termine t2 = null;
        if (filter1Id != -1) {
            t1 = em.find(Termine.class, filter1Id);

        }
        if (filter2Id != -1) {
            t2 = em.find(Termine.class, filter2Id);
        }
        List<Termin> termine = null;
        TypedQuery<Termin> tquery = null;
        if (filter1Id != 0) {
            // zwei Filter
            if (filter2Id != 0) {
                tquery = em.createNamedQuery("findAllTermineTwoFilters", Termin.class);
                tquery.setParameter("filter1", t1.getId());
                tquery.setParameter("filter2", t2.getId());
                tquery.setParameter("fromDate", new java.sql.Date(parsedFrom.getTime()));
                tquery.setParameter("toDate", new java.sql.Date(parsedTo.getTime()));
                termine = tquery.getResultList();
            } // nur Filter1
            else {
                tquery = em.createNamedQuery("findAllTermineOneFilter", Termin.class);
                tquery.setParameter("filter1", t1.getId());
                tquery.setParameter("fromDate", new java.sql.Date(parsedFrom.getTime()));
                tquery.setParameter("toDate", new java.sql.Date(parsedTo.getTime()));
                termine = tquery.getResultList();
            }
        } else {
            // nur Filter2
            if (filter2Id != 0) {
                tquery = em.createNamedQuery("findAllTermineOneFilter", Termin.class);
                tquery.setParameter("filter1", t2.getId());
                tquery.setParameter("fromDate", new java.sql.Date(parsedFrom.getTime()));
                tquery.setParameter("toDate", new java.sql.Date(parsedTo.getTime()));
                termine = tquery.getResultList();
            } // kein Filter, Termine so generieren
            else {
                termine = new ArrayList<>();
                Date current = new Date(parsedFrom.getTime());
                parsedTo.setTime(parsedTo.getTime() + 1000);
                while (current.before(parsedTo)) {
                    termine.add(new Termin(new Timestamp(current.getTime())));
                    Log.d("Erzeuge neuen Termin:" + new Termin(new Timestamp(current.getTime())));
                    current.setTime(current.getTime() + 24 * 60 * 60 * 1000);                    
                }
            }
        }

        Log.d("Result List:" + anwesenheit);
        GregorianCalendar c = (GregorianCalendar) GregorianCalendar.getInstance();
        c.setTime(parsedFrom);

        String tagZeile = "";
        document.open();
        Query q = em.createNamedQuery("findSchuelerEinerBenanntenKlasse");
        q.setParameter("paramNameKlasse", kl.getKNAME());
        List<Schueler> schueler = q.getResultList();
        Date current = new Date(parsedFrom.getTime());
        Log.d("Current=" + current + " TO=" + parsedTo + " From=" + parsedFrom + " Termine=" + termine.size());
        int spalte = 0;

        for (spalte = 0; spalte < termine.size(); spalte++) {
            tagZeile += "<table  align='center' width='100%' style=\"border: 2px solid black; border-collapse: collapse;\">\n";
            tagZeile += ("<tr >\n");
            tagZeile += ("<td width='25%' style=\"font-size: 14;border: 1px solid black;\"><b>Name</b></td>\n");
            // Zeile f.  Tage (Headline)
            Log.d("Spalte ist nun " + spalte);
            int i = 0;
            for (i = 0; i < 7 && spalte + i < termine.size(); i++) {
                current = new Date(termine.get(spalte + i).getDate().getTime());
                c.setTime(current);
                if (c.get(GregorianCalendar.DAY_OF_WEEK) == 1 || c.get(GregorianCalendar.DAY_OF_WEEK) == 7) {
                    tagZeile += ("<td align=\"center\" style=\"padding:5px; background-color: #cccccc; font-size: 12;border: 1px solid black;\">" + DatumUtil.getWochentag(c.get(GregorianCalendar.DAY_OF_WEEK)) + "<br></br>" + c.get(GregorianCalendar.DATE) + "." + (c.get(GregorianCalendar.MONTH) + 1) + "." + c.get(GregorianCalendar.YEAR) + "</td>\n");
                } else {
                    tagZeile += ("<td align=\"center\" style=\"padding: 5px; font-size: 12;border: 1px solid black;\">" + DatumUtil.getWochentag(c.get(GregorianCalendar.DAY_OF_WEEK)) + "<br></br>" + c.get(GregorianCalendar.DATE) + "." + (c.get(GregorianCalendar.MONTH) + 1) + "." + c.get(GregorianCalendar.YEAR) + "</td>\n");
                }
                Log.d("Spalte " + (i + spalte) + " Datum=" + current);
            }
            Log.d("Head aufgebaut");
            tagZeile += "</tr>\n";

            // Zeile pro Name
            for (Schueler s : schueler) {
                tagZeile += "<tr>\n";
                tagZeile += ("<td width='20%' style=\"padding: 5px;font-size: 12;border: 1px solid black;\"><b>" + s.getVNAME() + " " + s.getNNAME() + "</b></td>\n");
                // Zeile f.  Tage
                //Log.d("Zeile f. Schüler " + s.getNNAME());
                for (i = 0; i < 7 && spalte + i < termine.size(); i++) {
                    current = new Date(termine.get(spalte + i).getDate().getTime());
                    c.setTime(current);
                    if (c.get(GregorianCalendar.DAY_OF_WEEK) == 1 || c.get(GregorianCalendar.DAY_OF_WEEK) == 7) {
                        tagZeile += ("<td style=\"background-color:#cccccc;font-size: 11;border: 1px solid black;\">" + findVermerk(s.getId(), current, anwesenheit) + "</td>\n");
                    } else {
                        tagZeile += ("<td style=\"font-size: 11;border: 1px solid black;\">" + findVermerk(s.getId(), current, anwesenheit) + "</td>\n");
                    }
                    Log.d("Zeile f. Schüler " + s.getNNAME() + " Datum " + current);
                }
                tagZeile += "</tr>\n";
            }
            Log.d("Rumpf aufgebaut");

            spalte = spalte + i - 1;

            // neue Seite bei 7 Terminen
            if (i == 7) {
                tagZeile += "</table>\n";
                htmlString.append(tagZeile);
                InputStream is = new ByteArrayInputStream(htmlString.toString().getBytes());
                // Bild einfügen
                String url = "http://www.mmbbs.de/fileadmin/template/mmbbs/gfx/mmbbs_logo_druck.gif";
                Image image = Image.getInstance(url);
                image.setAbsolutePosition(45f, 720f);
                image.scalePercent(50f);
                document.add(image);
                XMLWorkerHelper.getInstance().parseXHtml(writer, document, is);
                document.newPage();
                Log.d("neue Seite");
                htmlString = new StringBuilder();
                tagZeile = "";
                htmlString.append(kopf);
            }
            Log.d("SPalte ist " + spalte + " Termine=" + termine.size());

        }
        Log.d("Ende der ForSchleife spalte=" + spalte);
        // den Rest der Seite noch drucken
        if (spalte % 7 != 0) {
            tagZeile += "</table>\n";
            htmlString.append(tagZeile);
            Log.d("Rest Seite erzeugen");
            //Log.d("html String =" + htmlString.toString());
            //document.add(new Paragraph("Tutorial to Generate PDF using Servlet"));

            InputStream is = new ByteArrayInputStream(htmlString.toString().getBytes());
            // Bild einfügen
            String url = "http://www.mmbbs.de/fileadmin/template/mmbbs/gfx/mmbbs_logo_druck.gif";
            Image image = Image.getInstance(url);
            image.setAbsolutePosition(45f, 720f);
            image.scalePercent(50f);
            document.add(image);
            Log.d("writer=" + writer + " document=" + document + " is=" + is);
            XMLWorkerHelper.getInstance().parseXHtml(writer, document, is);

        }

        document.close();
        return document;
    }

    /**
     * Umfrage Modell erzeugen
     *
     * @param anwFilter1 ID Umfrage
     * @param filter1 Filter (Klassen) z.B. FISI%
     * @return
     */
    private MyTableDataModel getModelUmfrageAuswertung(List<UmfrageResult> res1) {
        
        Log.d("res1=" + res1);
        String[] headlines;
        if (res1.size() > 0) {
            headlines = new String[res1.get(0).getSkalen().size() + 1];
            headlines[0] = "Fragen";
            int i = 1;
            Iterator it = res1.get(0).getSkalen().iterator();
            while (it.hasNext()) {
                AntwortSkalaObjekt as = (AntwortSkalaObjekt) it.next();
                Log.d("Seatze headline auf " + as.getName());
                headlines[i++] = as.getName();
            }
        } else {
            headlines = new String[1];
            headlines[0] = "Die Umfrage enthält keine Fragen";
        }
        MyTableDataModel mo = new MyTableDataModel(res1.size(), headlines);
        int x = 0;
        int y = 0;
        Log.d("Table Data has " + mo.getRows() + " Rows und " + mo.getCols() + " Cols");
        Iterator results = res1.iterator();
        while (results.hasNext()) {
            UmfrageResult ur = (UmfrageResult) results.next();
            mo.setData(x, y, ur.getFrage());
            Iterator antworten = ur.getSkalen().iterator();
            x++;
            while (antworten.hasNext()) {
                AntwortSkalaObjekt as = (AntwortSkalaObjekt) antworten.next();
                //Log.d("x="+x+" y="+y);
                mo.setData(x, y, "" + as.getAnzahl());
                x++;
            }
            x = 0;
            y++;
        }
        return mo;
    }

    private MyTableDataModel getModelVerlauf(Klasse kl, Date parsedFrom, Date parsedTo, String filter1, String filter2, String me) {
        Query query = em.createNamedQuery("findVerlaufbyKlasse");
        query.setParameter("paramKName", kl.getKNAME());
        query.setParameter("paramFromDate", new java.sql.Date(parsedFrom.getTime()));
        query.setParameter("paramToDate", new java.sql.Date(parsedTo.getTime()));
        List<Verlauf> overlauf = query.getResultList();
        List<Verlauf> verlauf = new ArrayList<>();
        /**
         * Filtern der oVerlauf Liste
         */
        for (Verlauf v : overlauf) {
            if (filter1.equals("eigeneEintraege")) {
                if (v.getID_LEHRER().equals(me)) {
                    if (filter2.equals("alle") || filter2.equals(v.getID_LERNFELD())) {
                        verlauf.add(v);
                    }
                }
            } else {
                if (filter2.equals("alle") || filter2.equals(v.getID_LERNFELD())) {
                    verlauf.add(v);
                }
            }
        }

        MyTableDataModel mo = new MyTableDataModel(verlauf.size(), new String[]{"Datum", "Stunde", "LF", "LK", "Inhalt", "Bemerkung", "Lernsituation"});
        Verlauf v;
        GregorianCalendar c = (GregorianCalendar) GregorianCalendar.getInstance();
        Log.d("Verlaufsmodel erzeugen filter1=(" + filter1 + ") filter2=(" + filter2 + ")");
        for (int y = 0; y < verlauf.size(); y++) {
            v = verlauf.get(y);
            c.setTime(v.getDATUM());
            mo.setData(0, y, DatumUtil.getWochentag(c.get(GregorianCalendar.DAY_OF_WEEK)) + ":" + c.get(GregorianCalendar.DATE) + "." + (c.get(GregorianCalendar.MONTH) + 1) + "." + c.get(GregorianCalendar.YEAR));
            mo.setData(1, y, v.getSTUNDE());
            mo.setData(2, y, v.getID_LERNFELD());
            mo.setData(3, y, v.getID_LEHRER());
            mo.setData(4, y, v.getINHALT());
            mo.setData(5, y, v.getBEMERKUNG());
            mo.setData(6, y, v.getAUFGABE());
        }
        return mo;
    }

    private Document createPortfolio(Klasse kl, OutputStream out) throws DocumentException, IOException {
        Document document = new Document();

        /* Basic PDF Creation inside servlet */
        PdfWriter writer = PdfWriter.getInstance(document, out);
        StringBuilder htmlString = new StringBuilder();
        document.open();

        Query q = em.createNamedQuery("findSchuelerEinerBenanntenKlasse");
        q.setParameter("paramNameKlasse", kl.getKNAME());
        List<Schueler> schueler = q.getResultList();

        Query q2 = em.createNamedQuery("findPortfolio");
        q2.setParameter("paramIdKlasse", kl.getId());
        List<Noten_all> portfolio = q2.getResultList();

        Query q3 = em.createNamedQuery("getLatestSchuljahr").setMaxResults(1);
        List<Schuljahr> schuljahr = q3.getResultList();

        Log.d("Schuljahr = " + schuljahr.get(0).getNAME() + " Zeugnisdatum=" + schuljahr.get(0).getZEUGNISDATUM());
        Log.d("Noten_all=" + portfolio);
        for (Schueler s : schueler) {

            htmlString.append("<h2 align=\"center\">Multi Media Berufsbildende Schulen</h2>");
            htmlString.append("<h2 align=\"center\">der Region Hannover</h2>");
            htmlString.append("<hr></hr>");
            htmlString.append("<h1 align=\"center\">Portfolio</h1>");
            htmlString.append("<h3 align=\"center\">über besuchte Zusatzkurse</h3>");
            htmlString.append("<p align=\"center\">für " + s.getVNAME() + " " + s.getNNAME() + " geb. am " + toReadable(s.getGEBDAT()) + "</p>");
            htmlString.append("<br></br>");
            htmlString.append("<hr></hr>");
            htmlString.append("<br></br>");
            int oldSchuljahr = -1;
            for (Noten_all p : portfolio) {
                Log.d("Suche für Schüler ID=" + s.getId() + " einen Portfolioeintrag, found ID=" + p.getID_SCHUELER());
                if (p.getID_SCHUELER().intValue() == s.getId().intValue()) {

                    Log.d("gefunden!");
                    Schuljahr sj = em.find(Schuljahr.class, p.getID_SCHULJAHR());
                    Klasse_all ka = em.find(Klasse_all.class, p.getID_KLASSEN_ALL());
                    Log.d(" Schüler gefunden sj=" + sj.getNAME() + " ka=" + ka.getTitel());
                    if (oldSchuljahr != sj.getID()) {
                        htmlString.append("<h3>Schuljahr " + sj.getNAME() + "</h3>");
                        oldSchuljahr = sj.getID();
                    }
                    htmlString.append("<table>");
                    htmlString.append("<tr>");
                    htmlString.append("<td width=\"70%\"><b>" + ka.getTitel() + "</b><p>" + ka.getNotiz() + "</p></td>");
                    htmlString.append("<td>" + NotenUtil.getNote(p.getWERT()) + "</td>");
                    htmlString.append("</tr>");
                    htmlString.append("</table>");
                    htmlString.append("<p>&nbsp;</p>");
                }
            }
            htmlString.append("<br></br>");
            htmlString.append("<br></br>");
            htmlString.append("<b>Hannover, " + toReadable(schuljahr.get(0).getZEUGNISDATUM()) + "</b>");
            htmlString.append("<br></br>");
            htmlString.append("<br></br>");
            htmlString.append("<br></br>");
            htmlString.append("<br></br>");
            htmlString.append("<table width=\"100%\" >");
            htmlString.append("<tr>");
            htmlString.append("<td style=\"font-size: 10;border-bottom: 0.5px solid #888888\" width=\"40%\" align=\"center\">&nbsp;</td>");
            htmlString.append("<td></td>");
            htmlString.append("</tr>");
            htmlString.append("<tr>");
            htmlString.append("<td style=\"font-size: 10;\" width=\"40%\" align=\"center\">Klassenlehrerin/Klassenlehrer</td>");
            htmlString.append("<td>&nbsp;</td>");
            htmlString.append("</tr>");
            htmlString.append("<tr>");
            htmlString.append("<td style=\"font-size: 9;border-top: 0.5px solid #888888\" colspan=\"2\">Noten: sehr gut (1), gut (2), befriedigend (3), ausreichend (4), mangelhaft (5), ungenügend (6)<br></br>*) Angegeben ist die durchschnittliche Unterrichtsstundenzahl pro Schuljahr.<br></br>*) In Kursen mit insgesamt 12 Unterrichtsstunden findet keine Bewertung statt.</td>");
            htmlString.append("</tr>");

            htmlString.append("</table>");

            InputStream is = new ByteArrayInputStream(htmlString.toString().getBytes());
            // Bild einfügen
            String url = "http://www.mmbbs.de/fileadmin/template/mmbbs/gfx/mmbbs_logo_druck.gif";
            Image image = Image.getInstance(url);
            image.setAbsolutePosition(480f, 730f);
            image.scalePercent(40f);
            Log.d("Image=" + image);
            document.add(image);
            XMLWorkerHelper.getInstance().parseXHtml(writer, document, is);
            htmlString = new StringBuilder();
            document.newPage();
        }

        document.close();
        return document;
    }

    private Document createVertretungsliste(Date parsedFrom, Date parsedTo, OutputStream out) throws DocumentException, BadElementException, IOException {
        Document document = new Document();
        Log.d("create Vertretungsliste von " + parsedFrom.toString() + " bis" + parsedTo.toString());
        GregorianCalendar cf = (GregorianCalendar) GregorianCalendar.getInstance();
        cf.setTime(parsedFrom);
        GregorianCalendar ct = (GregorianCalendar) GregorianCalendar.getInstance();
        ct.setTime(parsedTo);
        /* Basic PDF Creation inside servlet */
        PdfWriter writer = PdfWriter.getInstance(document, out);
        StringBuilder htmlString = new StringBuilder();
        String kopf = "";
        kopf += ("<table border='1' align='center' width='100%'>");
        kopf += ("<tr>");
        kopf += ("<td rowspan=\"3\" width='150px'></td>");
        kopf += ("<td align='center'><h2>Multi Media Berufsbildende Schulen Hannover</h2></td>");

        kopf += ("<td colspan=\"2\" align='center'><b>Digitales Klassenbuch Vertretungsliste</b></td>");
        kopf += ("</tr>");
        kopf += ("<tr>");
        kopf += ("<td  align='center' rowspan=\"2\"><h3>von " + toReadableDate(cf) + " bis " + toReadableDate(ct) + "</h3></td>");
        kopf += ("<td  style=\"font-size: 11;padding:4px;height:30px;\">Verantwortlicher: BO&nbsp;</td>");
        kopf += ("<td  style=\"font-size: 11;padding:4px;\">geprüft</td>");
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
        htmlString.append(kopf);
        document.open();

        Query qb = em.createNamedQuery("findVertretungbyDate");
        qb.setParameter("paramFromDate", parsedFrom);
        qb.setParameter("paramToDate", parsedTo);
        List<Vertretung> vl = qb.getResultList();
        Log.d("Result Liste = " + vl);

        for (Vertretung v : vl) {
            htmlString.append("<h3>Absenz von " + v.getAbsenzVon() + " am " + toReadableFromat(v.getAbsenzAm()) + " eingereicht von " + v.getEingereichtVon() + " am " + toReadableFromat(v.getEingereichtAm()) + "</h3>");
            htmlString.append("<h4>" + v.getKommentar() + "</h4>");
            htmlString.append("<p> </p>");
            htmlString.append("<table border='0.5' align='center' width='100%'>");
            htmlString.append("<tr>");
            htmlString.append("<td width='10%' style=\"padding:4px;\">Stunde</td><td width='15%' style=\"padding:4px;\">Klasse</td><td width='15%' style=\"padding:4px;\">Aktion</td><td width='10%' style=\"padding:4px;\">Vertreter</td><td style=\"padding:4px;\">Kommentar</td>");
            htmlString.append("</tr>");
            JSONParser jsonParser = new JSONParser();
            try {
                JSONArray ja = (JSONArray) jsonParser.parse(v.getJsonString());

                for (int i = 0; i < ja.size(); i++) {
                    JSONObject jo = (JSONObject) ja.get(i);
                    htmlString.append("<tr>");
                    htmlString.append("<td style=\"font-size: 11;padding:4px;\" width='10%'>" + jo.get("stunde") + "</td>");
                    htmlString.append("<td style=\"font-size: 11;padding:4px;\" width='15%'>" + jo.get("Klasse") + "</td>");
                    htmlString.append("<td style=\"font-size: 11;padding:4px;\" width='15%'>" + jo.get("Aktion") + "</td>");
                    htmlString.append("<td style=\"font-size: 11;padding:4px;\" width='10%'>" + jo.get("Vertreter") + "</td>");
                    htmlString.append("<td style=\"font-size: 11;padding:4px;\">" + jo.get("Kommentar") + "</td>");
                    htmlString.append("</tr>");
                }

            } catch (org.json.simple.parser.ParseException ex) {
                ex.printStackTrace();
                Logger.getLogger(DokuServlet.class.getName()).log(Level.SEVERE, null, ex);
            }
            htmlString.append("</table>");
            htmlString.append("<p></p>");
        }

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
        return document;
    }

    private Document createVerlauf(Klasse kl, String kopf, Date parsedFrom, Date parsedTo, OutputStream out, String filter1, String filter2, String me) throws ParseException, IOException, DocumentException {
        Document document = new Document();
        /* Basic PDF Creation inside servlet */
        PdfWriter writer = PdfWriter.getInstance(document, out);
        StringBuilder htmlString = new StringBuilder();
        htmlString.append(kopf);
        /* Verlauf einfügen */
        Query query = em.createNamedQuery("findVerlaufbyKlasse");
        query.setParameter("paramKName", kl.getKNAME());
        query.setParameter("paramFromDate", new java.sql.Date(parsedFrom.getTime()));
        query.setParameter("paramToDate", new java.sql.Date(parsedTo.getTime()));
        List<Verlauf> overlauf = query.getResultList();
        List<Verlauf> verlauf = new ArrayList<>();

        /**
         * Filtern der oVerlauf Liste
         */
        for (Verlauf v : overlauf) {
            if (filter1.equals("eigeneEintraege")) {
                if (v.getID_LEHRER().equals(me)) {
                    if (filter2.equals("alle") || filter2.equals(v.getID_LERNFELD())) {
                        verlauf.add(v);
                    }
                }
            } else {
                if (filter2.equals("alle") || filter2.equals(v.getID_LERNFELD())) {
                    verlauf.add(v);
                }
            }
        }

        Log.d("Result List:" + verlauf);
        htmlString.append("<table  align='center' width='100%' style=\"border: 2px solid black; border-collapse: collapse;\">");
        String tagZeile = Verlauf.getTRHead();
        htmlString.append(tagZeile);
        String tag = " ";
        int kw = -1;
        document.open();
        boolean firstPage = true;
        for (Verlauf v : verlauf) {
            String str = v.getDATUM().toString();
            if (str.compareTo(tag) == 0) {
                htmlString.append(v.toHTML());
            } // ein neuer Tag
            else {
                if (kw == -1) {
                    kw = v.getKw();
                }
                // Jede Woche eine neue Seite!
                if (!firstPage && kw != v.getKw()) {
                    kw = v.getKw();
                    htmlString.append("</table>");
                    Log.d("html String=" + htmlString.toString());
                    //document.add(new Paragraph("Tutorial to Generate PDF using Servlet"));
                    InputStream is = new ByteArrayInputStream(htmlString.toString().getBytes());
                    // Bild einfügen
                    String url = "http://www.mmbbs.de/fileadmin/template/mmbbs/gfx/mmbbs_logo_druck.gif";
                    Image image = Image.getInstance(url);
                    image.setAbsolutePosition(45f, 720f);
                    image.scalePercent(50f);
                    document.add(image);
                    XMLWorkerHelper.getInstance().parseXHtml(writer, document, is);
                    document.newPage();
                    htmlString = new StringBuilder();
                    htmlString.append(kopf);
                    htmlString.append("<table  align='center' width='100%' style=\"border: 2px solid black; border-collapse: collapse;\">");
                    htmlString.append(tagZeile);
                    Log.d("weiter mit neuer Seite");
                }
                htmlString.append("<tr>");
                htmlString.append("<td colspan=\"6\" align=\"center\" style=\"background-color: #cccccc; padding:4px;border: 1px solid black;\">KW " + v.getKw() + " / " + v.getWochentag() + " " + str.substring(0, str.indexOf(" ")) + "</td>");
                htmlString.append("</tr>");
                htmlString.append(v.toHTML());
                firstPage = false;
                tag = str;
            }
        }
        htmlString.append("</table>");
        Log.d("html String Rest=" + htmlString.toString());
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
        return document;
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

    private String findVermerk(Integer id, Date current, List<AnwesenheitObjekt> anwesenheit) {
        for (AnwesenheitObjekt ao : anwesenheit) {
            if (ao.getId_Schueler() == id) {
                //Log.d("Schuler mit id= " + id + " gefunden!");
                for (AnwesenheitEintrag a : ao.getEintraege()) {
                    if (a.getDATUM().compareTo(current) == 0) {
                        return a.getVERMERK();
                    }
                }
                return "";
            }
        }
        return "";
    }

    private List<AnwesenheitObjekt> getData(TypedQuery query) {
        List<AnwesenheitEintrag> anwesenheit = query.getResultList();
        //Log.d("Results:="+anwesenheit);
        List<AnwesenheitObjekt> anw = new ArrayList();
        int id = 0;
        AnwesenheitObjekt ao = new AnwesenheitObjekt();
        for (int i = 0; i < anwesenheit.size(); i++) {
            if (anwesenheit.get(i).getID_SCHUELER() != id) {
                id = anwesenheit.get(i).getID_SCHUELER();
                ao = new AnwesenheitObjekt(id);
                anw.add(ao);
            }
            ao.getEintraege().add(anwesenheit.get(i));
        }
        return anw;
    }

    private String getNoteSchueler(int sid, String lfid, List<NotenObjekt> lno) {
        Log.d("GetNotenSchueler sid=" + sid + " lfid=" + lfid + " lno=" + lno);
        for (NotenObjekt no : lno) {
            if (no.getSchuelerID() == sid) {
                for (Noten_all n : no.getNoten()) {
                    if (n.getID_LERNFELD().compareTo(lfid) == 0) {
                        return n.getWERT();
                    }
                }
                return "";
            }
        }

        return "";
    }

    private AusbilderObject getAusbilder(Integer id, List<AusbilderObject> ausbilder) {
        for (AusbilderObject ao : ausbilder) {
            if (ao.getId_schueler() == id.intValue()) {
                return ao;
            }
        }
        return null;
    }

    private String getSchulerName(int id_Schueler, List<Schueler> schueler) {
        for (Schueler s : schueler) {
            if (s.getId() == id_Schueler) {
                return s.getVNAME() + " " + s.getNNAME();
            }
        }
        return null;
    }

    private String toReadable(java.sql.Date gebdat) {
        Calendar c = GregorianCalendar.getInstance();
        c.setTime(gebdat);
        return "" + c.get(Calendar.DAY_OF_MONTH) + "." + (c.get(Calendar.MONTH) + 1) + "." + c.get(Calendar.YEAR);
    }

    private String toReadableDate(Calendar cf) {

        return cf.get(GregorianCalendar.DAY_OF_MONTH) + "." + (cf.get(GregorianCalendar.MONTH) + 1) + "." + cf.get(GregorianCalendar.YEAR);
    }

    private String toReadableFromat(Timestamp absenzAm) {
        Calendar gc = GregorianCalendar.getInstance();
        gc.setTime(new Date(absenzAm.getTime()));
        return toReadableDate(gc);
    }

    private Document printHead(PdfWriter writer,Document document, StringBuilder htmlString, OutputStream out, Image image) throws DocumentException, BadElementException, IOException {
        // Dokument erzeugen
        InputStream is = new ByteArrayInputStream(htmlString.toString().getBytes());
        
        Log.d("document="+document+" image="+image);
        document.add(image);
        XMLWorkerHelper.getInstance().parseXHtml(writer, document, is);
        return document;
    }

}
