/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.util;

import de.tuttas.servlets.MyTableDataModel;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFChartSheet;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 *
 * @author Jörg
 */
public class ExcelUtil {

    /*
     public static void main(String[] args) {
     try {
     XSSFWorkbook wb = readExcel("C:\\Temp\\Template.xlsx");
     XSSFSheet sh = wb.getSheetAt(0);
     XSSFRow r=sh.getRow(0);
     XSSFCell c= r.getCell(0);
     c.setCellValue("Hallo Welt");
     writeExcel(wb,"c:\\Temp\\umfrage.xlsx");
            
     Log.d("alles geladen");
     } catch (IOException ex) {
     Logger.getLogger(ExcelUtil.class.getName()).log(Level.SEVERE, null, ex);
     }
     }
     */
    public static XSSFWorkbook readExcel(String name, String[] sheetNames, int rows, int cols) throws IOException {
        FileInputStream file = null;
        try {
            file = new FileInputStream(new File(name));
            Log.d("Template " + name + " gefunden!");
            XSSFWorkbook wb = new XSSFWorkbook(file);            
            return wb;
        } catch (FileNotFoundException ex) {
            Log.d("Template " + name + " nicht gefunden erzeuge leeres Workbook");
            XSSFWorkbook wb = new XSSFWorkbook();
            XSSFSheet[] sheets = new XSSFSheet[sheetNames.length];
            for (int k = 0; k < sheetNames.length; k++) {
                sheets[k] = wb.createSheet(sheetNames[k]);
                for (int i = 0; i < rows; i++) {
                    XSSFRow hr = sheets[k].createRow(i);
                    for (int j = 0; j < cols; j++) {
                        hr.createCell(j);
                    }
                }
            }
            return wb;
        } finally {
            try {
                if (file != null) {
                    file.close();
                }
            } catch (IOException ex) {
                Logger.getLogger(ExcelUtil.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    private static void writeExcel(XSSFWorkbook wb, String name) throws FileNotFoundException, IOException {
        FileOutputStream out = new FileOutputStream(new File(name));
        wb.write(out);
        out.close();
    }

}
