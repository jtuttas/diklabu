/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.servlets;

import de.tuttas.util.ExcelUtil;
import static de.tuttas.util.ExcelUtil.readExcel;
import de.tuttas.util.Log;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 *
 * @author Jörg
 */
public class MyTableDataModel {

    private String[][] data;
    private int rows;
    private int cols;

    public MyTableDataModel(int rows, String[] headlines) {
        this.rows = rows + 1;
        this.cols = headlines.length;
        data = new String[rows + 1][headlines.length];
        for (int i = 0; i < headlines.length; i++) {
            data[0][i] = headlines[i];
        }
    }

    public String getData(int x, int y) {
        return data[y][x];
    }

    public void setData(int x, int y, String value) {
        data[y + 1][x] = value;
    }

    public int getRows() {
        return rows;
    }

    public String[] getRow(int ro) {
        return data[ro];
    }

    public int getCols() {
        return cols;
    }

    public String toCsv() {
        String out = "";
        for (int y = 0; y < rows; y++) {
            for (int x = 0; x < cols; x++) {
                String d = data[y][x];
                if (d == null) {
                    d = "";
                }
                out += "\"" + d + "\";";
            }
            out = out.substring(0, out.length() - 1);
            out += "\n";
        }
        return out;
    }

    public XSSFWorkbook toExcel(XSSFWorkbook wb, int sheetNumer) {
        XSSFSheet sh = wb.getSheetAt(sheetNumer);
        for (int y = 0; y < rows; y++) {
            XSSFRow r = sh.getRow(y);
            for (int x = 0; x < cols; x++) {
                XSSFCell c = r.getCell(x);
                String d = data[y][x];
                Log.d("Write to Cell " + d);
                if (d != null) {
                    try {
                        double value = Double.parseDouble(d);
                        c.setCellValue(value);
                    } catch (NumberFormatException nux) {
                        c.setCellValue(d);
                    }
                }

            }
        }
        return wb;
    }

    public static void main(String[] args) {
        MyTableDataModel m = new MyTableDataModel(10, new String[]{"col1", "col2", "col3"});
        m.setData(0, 1, "0 und 1");
        System.out.println(m.toCsv());
    }

}
