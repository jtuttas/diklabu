/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

/**
 *
 * @author Jörg
 */
public class KlasseShort {
    private String ID_LEHRER;
    private String KNAME;
    private Integer id;

    public KlasseShort() {
    }

    public KlasseShort(Integer id, String ID_LEHRER, String KNAME) {
        this.ID_LEHRER = ID_LEHRER;
        this.KNAME = KNAME;
        this.id = id;
    }
    
    
    public String getID_LEHRER() {
        return ID_LEHRER;
    }

    public void setID_LEHRER(String ID_LEHRER) {
        this.ID_LEHRER = ID_LEHRER;
    }

    public String getKNAME() {
        return KNAME;
    }

    public void setKNAME(String KNAME) {
        this.KNAME = KNAME;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }
    
    
}
