/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful.Data;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Jörg
 */
public class AnwesenheitObjekt {
    private int id_Schueler;
    private List<AnwesenheitEintrag> eintraege = new ArrayList();

    public AnwesenheitObjekt() {
    }

    public AnwesenheitObjekt(int id_Schueler) {
        this.id_Schueler = id_Schueler;
    }

    public List<AnwesenheitEintrag> getEintraege() {
        return eintraege;
    }

    public void setEintraege(List<AnwesenheitEintrag> eintraege) {
        this.eintraege = eintraege;
    }

    public int getId_Schueler() {
        return id_Schueler;
    }

    public void setId_Schueler(int id_Schueler) {
        this.id_Schueler = id_Schueler;
    }
    
    
}
