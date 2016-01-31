/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import de.tuttas.config.Config;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.Schueler;
import de.tuttas.restful.Data.BildObject;
import de.tuttas.util.ImageUtil;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import javax.ejb.Stateless;
import javax.imageio.ImageIO;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;

/**
 *
 * @author Jörg
 */
@Path("klasse")
@Stateless
public class KlassenManager {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    @GET
    @Path("/{klasse}")
    public List<Schueler> getPupil(@PathParam("klasse") String kl) {
        System.out.println("Webservice klasse GET: klasse=" + kl);

        Query query = em.createNamedQuery("findSchuelerEinerBenanntenKlasse");
        query.setParameter("paramNameKlasse", kl);
        List<Schueler> schueler = query.getResultList();
        System.out.println("Result List:" + schueler);
        return schueler;
    }

    @GET
    @Path("/{klasse}/bilder64/{width}")
    public List<BildObject> getBilder(@PathParam("klasse") String kl, @PathParam("width") int width) {
        System.out.println("Webservice klasse GET bilder64: klasse=" + kl + " scale=" + width);
        Query query = em.createNamedQuery("findSchuelerEinerBenanntenKlasse");
        query.setParameter("paramNameKlasse", kl);
        List<Schueler> schueler = query.getResultList();
        System.out.println("Result List:" + schueler);
        List<BildObject> bilder = new ArrayList<>();
        for (Schueler s : schueler) {
            BildObject bo = new BildObject();
            bo.setId(s.getId());
            String filename = Config.IMAGE_FILE_PATH + s.getId() + ".jpg";
            System.out.println("Lade file " + filename);
            File file = new File(filename);
            if (!file.exists()) {
            } else {
                BufferedImage img = null;
                try {
                    img = ImageIO.read(file);
                    
                    System.out.println("Original Width = "+img.getWidth()+" Height = "+img.getHeight());
                    double ow = img.getWidth();
                    double oh=img.getHeight();
                    double ratio = ow/oh;
                    System.out.println("ratio="+ratio);
                    int type = img.getType() == 0? BufferedImage.TYPE_INT_ARGB : img.getType();
                    img = ImageUtil.resizeImage(img, type, width, (int) (width/ratio));
                    System.out.println("Resized Width = "+img.getWidth()+" Height = "+img.getHeight());
                    img = ImageUtil.cropImage(img, type, width);
                    System.out.println("Cropped Width = "+img.getWidth()+" Height = "+img.getHeight());
                    bo.setBase64(ImageUtil.encodeToString(img, "jpeg"));

                } catch (IOException e) {
                }
            }
            bilder.add(bo);            
        }
        return bilder;
    }
}
