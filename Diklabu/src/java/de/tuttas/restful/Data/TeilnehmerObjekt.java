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
public class TeilnehmerObjekt extends ResultObject{
    
    private String key;
    private int idUmfrage;
    private Integer idSchueler;
    private Integer idBetrieb;
    private String idLehrer;
    private int invited;

    public void setInvited(int invited) {
        this.invited = invited;
    }

    public int getInvited() {
        return invited;
    }
    
    

    public void setKey(String key) {
        this.key = key;
    }

    public String getKey() {
        return key;
    }

    
    public int getIdUmfrage() {
        return idUmfrage;
    }

    public void setIdUmfrage(int idUmfrage) {
        this.idUmfrage = idUmfrage;
    }

    public Integer getIdSchueler() {
        return idSchueler;
    }

    public void setIdSchueler(Integer idSchueler) {
        this.idSchueler = idSchueler;
    }

    public Integer getIdBetrieb() {
        return idBetrieb;
    }

    public void setIdBetrieb(Integer idBetrieb) {
        this.idBetrieb = idBetrieb;
    }

    public String getIdLehrer() {
        return idLehrer;
    }

    public void setIdLehrer(String idLehrer) {
        this.idLehrer = idLehrer;
    }

    @Override
    public String toString() {
        return "TeilnehmerBbjekt ID_Umfrage="+idUmfrage+" idSchueler="+idSchueler+" idBetrieb="+idBetrieb+" idLehere="+idLehrer;
    }
    
    
    
    
}
