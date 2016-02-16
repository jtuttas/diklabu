/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.restful;

import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.MetadataException;
import de.tuttas.config.Config;
import de.tuttas.entities.Ausbilder;
import de.tuttas.entities.Bemerkung;
import de.tuttas.entities.Betrieb;
import de.tuttas.entities.Klasse;
import de.tuttas.entities.LoginSchueler;
import de.tuttas.restful.Data.SchuelerObject;
import de.tuttas.entities.Schueler;
import de.tuttas.restful.Data.BildObject;
import de.tuttas.restful.Data.ResultObject;
import de.tuttas.util.ImageUtil;
import java.awt.AlphaComposite;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ejb.Stateless;
import javax.imageio.ImageIO;
import javax.imageio.stream.ImageInputStream;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.ResponseBuilder;
import org.apache.commons.io.IOUtils;
import org.glassfish.jersey.media.multipart.FormDataContentDisposition;
import org.glassfish.jersey.media.multipart.FormDataParam;

/**
 *
 * @author Jörg
 */
@Path("schueler")
@Stateless
public class SchuelerManager {

    /**
     * Injection des EntityManagers
     */
    @PersistenceContext(unitName = "DiklabuPU")
    EntityManager em;

    @GET
    @Path("/{idschueler}")
    public SchuelerObject getPupil(@PathParam("idschueler") int idschueler) {
        System.out.println("Abfrage Schueler mit der ID " + idschueler);
        Schueler s = em.find(Schueler.class, idschueler);

        if (s != null) {
            SchuelerObject so = new SchuelerObject();
            so.setId(idschueler);
            so.setGebDatum(s.getGEBDAT());
            so.setName(s.getNNAME());
            so.setVorname(s.getVNAME());
            so.setEmail(s.getEMAIL());
            Query query = em.createNamedQuery("findKlassenbySchuelerID");
            query.setParameter("paramIDSchueler", so.getId());
            List<Klasse> klassen = query.getResultList();
            System.out.println("Result List:" + klassen);
            so.setKlassen(klassen);

            Ausbilder a = em.find(Ausbilder.class, s.getID_AUSBILDER());
            so.setAusbilder(a);

            if (a != null) {
                Betrieb b = em.find(Betrieb.class, a.getID_BETRIEB());
                so.setBetrieb(b);
            }
            Query squery = em.createNamedQuery("findBemerkungbySchuelerId");
            squery.setParameter("paramSchuelerId", so.getId());
            List<Bemerkung> bemerkungen = squery.getResultList();
            System.out.println("Result List:" + klassen);
            so.setBemerkungen(bemerkungen);
            
            return so;
        }
        return null;
    }

    @GET
    @Path("/bild/{idschueler}")
    @Produces("image/jpg")
    public Response getFile(@PathParam("idschueler") int idschueler) {
        
            String filename = Config.IMAGE_FILE_PATH + idschueler + ".jpg";
            System.out.println("Lade  file " + filename);
            File file = new File(filename);
            if (!file.exists()) {
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            return Response.status(Response.Status.OK).build();       
    }

   

    @GET
    @Path("/bild64/{idschueler}")

    public BildObject getFile64(@PathParam("idschueler") int idschueler) {
        BildObject bo = new BildObject();
        bo.setId(idschueler);
        String filename = Config.IMAGE_FILE_PATH + idschueler + ".jpg";
        System.out.println("Lade file " + filename);
        File file = new File(filename);

        if (!file.exists()) {
            return null;
        }
        BufferedImage img = null;
        try {
            img = ImageIO.read(file);
            bo.setBase64(ImageUtil.encodeToString(img, "jpeg"));
            return bo;

        } catch (IOException e) {
            return bo;
        }
    }

    @POST
    @Path("/bild/{idschueler}")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    public ResultObject uploadFile(
            @PathParam("idschueler") int idschueler,
            @FormDataParam("file") InputStream uploadedInputStream,
            @FormDataParam("file") FormDataContentDisposition fileDetail) {

        ResultObject r = new ResultObject();
        String fileLocation = Config.IMAGE_FILE_PATH + idschueler + ".jpg";
        System.out.println("upload  File for " + idschueler);
        try {
            
            byte[] imageBytes = IOUtils.toByteArray(uploadedInputStream);
            
            int i = uploadedInputStream.read(imageBytes);
            System.out.println("habe "+i+" bytes gelesen!");
            InputStream myInputStream = new ByteArrayInputStream(imageBytes); 
            Image image = ImageIO.read(myInputStream);
            System.out.println("Image gelesen ="+image);
            InputStream myExifInputStream = new ByteArrayInputStream(imageBytes); 
            int orientation = ImageUtil.getImageOrientation(myExifInputStream);
            BufferedImage bImage = ImageUtil.toBufferedImage(image);
            System.out.println("Image hat w="+bImage.getWidth()+" h="+bImage.getHeight());
            bImage = ImageUtil.transformImage(bImage, ImageUtil.getExifTransformation(orientation, image.getWidth(null), image.getHeight(null)));
            System.out.println("Image hat nach Transformation w="+bImage.getWidth()+" h="+bImage.getHeight());            
            if (image != null) {
                int originalWidth = image.getWidth(null);
                int originalHeight = image.getHeight(null);
                int newWidth = 200;
                int newHeight = Math.round(newWidth * ((float) originalHeight / originalWidth));
                BufferedImage bi = this.createResizedCopy(image, newWidth, newHeight, true);
                ImageIO.write(bi, "jpg", new File(Config.IMAGE_FILE_PATH + idschueler + ".jpg"));
                r.setMsg("Bild erfolgreich hochgeladen!");
                r.setSuccess(true);
            } else {
                r.setMsg("Fehler beim Hochladen des Bildes!");
                r.setSuccess(false);

            }
        } catch (IOException e) {
            System.out.println("Error");
            r.setMsg(e.getMessage());
            r.setSuccess(false);
        } catch (MetadataException ex) {
            Logger.getLogger(SchuelerManager.class.getName()).log(Level.SEVERE, null, ex);
        } catch (ImageProcessingException ex) {
            Logger.getLogger(SchuelerManager.class.getName()).log(Level.SEVERE, null, ex);
        } catch (Exception ex) {
            Logger.getLogger(SchuelerManager.class.getName()).log(Level.SEVERE, null, ex);
        }

        return r;
    }

    
    
    private BufferedImage createResizedCopy(Image originalImage, int scaledWidth, int scaledHeight, boolean preserveAlpha) {
        int imageType = preserveAlpha ? BufferedImage.TYPE_INT_RGB : BufferedImage.TYPE_INT_ARGB;
        BufferedImage scaledBI = new BufferedImage(scaledWidth, scaledHeight, imageType);
        Graphics2D g = scaledBI.createGraphics();
        if (preserveAlpha) {
            g.setComposite(AlphaComposite.Src);
        }
        g.drawImage(originalImage, 0, 0, scaledWidth, scaledHeight, null);
        g.dispose();
        return scaledBI;
    }
}
