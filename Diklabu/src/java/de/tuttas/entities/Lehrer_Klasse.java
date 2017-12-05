/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.entities;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;

/**
 *
 * @author jtutt
 */
@Entity
@NamedQueries({
   @NamedQuery(name = "findKlassebyLehrer", query= "select k from Klasse k inner join Lehrer_Klasse lk on lk.ID_KLASSE=k.ID where lk.ID_LEHRER = :paramIDLEHRER "),
   @NamedQuery(name = "findLehrerbyKlasse", query= "select l from Lehrer l inner join Lehrer_Klasse lk on lk.ID_LEHRER=l.id where lk.ID_KLASSE = :paramIDKLASSE "),
})
@IdClass(Lehrer_KlasseId.class)
public class Lehrer_Klasse {
    @Id
    private String ID_LEHRER;
    @Id
    private int ID_KLASSE;
    
    public Lehrer_Klasse() {
        
    }
    
    public Lehrer_Klasse(String l,int k) {
        ID_LEHRER=l;
        ID_KLASSE=k;
    }

    public String getID_LEHRER() {
        return ID_LEHRER;
    }

    public void setID_LEHRER(String ID_LEHRER) {
        this.ID_LEHRER = ID_LEHRER;
    }

    public int getID_KLASSE() {
        return ID_KLASSE;
    }

    public void setID_KLASSE(int ID_KLASSE) {
        this.ID_KLASSE = ID_KLASSE;
    }
    
       
}
