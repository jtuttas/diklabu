/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.util;

import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.Directory;
import com.drew.metadata.Metadata;
import com.drew.metadata.MetadataException;
import com.drew.metadata.Tag;
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.jpeg.JpegDirectory;
import java.awt.AlphaComposite;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.awt.image.RenderedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.imageio.ImageIO;
import sun.misc.BASE64Encoder;

/**
 * Hilfsmethoden zur Bildbearbeitung
 * @author Jörg
 */
public class ImageUtil {

    /*
     public static void main(String[] args) {
     try {
     readImageInformation(new File("c:\\\\Temp\\handy.jpg"));
     } catch (IOException ex) {
     Logger.getLogger(ImageUtil.class.getName()).log(Level.SEVERE, null, ex);
     } catch (MetadataException ex) {
     Logger.getLogger(ImageUtil.class.getName()).log(Level.SEVERE, null, ex);
     } catch (ImageProcessingException ex) {
     Logger.getLogger(ImageUtil.class.getName()).log(Level.SEVERE, null, ex);
     }
     }
     */
    /**
     * Encode image to string
     *
     * @param image The image to encode
     * @param type jpeg, bmp, ...
     * @return encoded string
     */
    public static String encodeToString(BufferedImage image, String type) {
        String imageString = null;
        ByteArrayOutputStream bos = new ByteArrayOutputStream();

        try {
            ImageIO.write(image, type, bos);
            byte[] imageBytes = bos.toByteArray();

            BASE64Encoder encoder = new BASE64Encoder();
            imageString = encoder.encode(imageBytes);

            bos.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return imageString;
    }

    /**
     * Image resize
     * @param originalImage Orininal Image
     * @param type Type
     * @param w Breite
     * @param h Höhe
     * @return  Das rezized Image
     */
    public static BufferedImage resizeImage(BufferedImage originalImage, int type, int w, int h) {
        BufferedImage resizedImage = new BufferedImage(w, h, type);
        Graphics2D g = resizedImage.createGraphics();
        g.drawImage(originalImage, 0, 0, w, h, null);
        g.dispose();

        return resizedImage;
    }

    /**
     * Ein Bild beschneiden
     * @param originalImage das Original
     * @param type der Type
     * @param h die Höhe
     * @return das Beschnittene Bild
     */
    public static BufferedImage cropImage(BufferedImage originalImage, int type, int h) {
        BufferedImage resizedImage = new BufferedImage(h, h, type);
        Graphics2D g = resizedImage.createGraphics();
        g.setBackground(new Color(58, 58, 58));

        g.clearRect(0, 0, h, h);
        int d = h - originalImage.getWidth();
        g.drawImage(originalImage, d / 2, 0, originalImage.getWidth(), h, null);
        g.dispose();

        return resizedImage;
    }

    /**
     * Abfrage der Bild Orientierung
     * @param is Input Stream
     * @return Orientierung
     * @throws IOException
     * @throws MetadataException
     * @throws ImageProcessingException 
     */
    public static int getImageOrientation(InputStream is) throws IOException, MetadataException, ImageProcessingException {
        int orientation = 1;
        try {
            Metadata metadata = ImageMetadataReader.readMetadata(is);
            Collection<ExifIFD0Directory> col = metadata.getDirectoriesOfType(com.drew.metadata.exif.ExifIFD0Directory.class);
            if (col==null) return orientation;
            try {
                for (ExifIFD0Directory d : col) {
                    orientation = d.getInt(ExifIFD0Directory.TAG_ORIENTATION);
                    Log.d("Orientation =" + orientation);
                    return orientation;
                }
            } catch (MetadataException ex) {
                Log.d("keine Orientation gefunden!");
            }
        } catch (ImageProcessingException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return orientation;

    }

    /**
     * Ein Bild drehen
     * @param image Das Orinignal Bild
     * @param transform Die Art der Drehung
     * @return das gedrehte Bild
     * @throws Exception 
     */
    public static BufferedImage transformImage(BufferedImage image, AffineTransform transform) throws Exception {

        AffineTransformOp op = new AffineTransformOp(transform, AffineTransformOp.TYPE_BICUBIC);

        BufferedImage destinationImage = op.createCompatibleDestImage(image, (image.getType() == BufferedImage.TYPE_BYTE_GRAY) ? image.getColorModel() : null);
        Graphics2D g = destinationImage.createGraphics();
        g.setBackground(Color.WHITE);
        g.clearRect(0, 0, destinationImage.getWidth(), destinationImage.getHeight());
        destinationImage = op.filter(image, destinationImage);;
        return destinationImage;
    }

    /**
     * Converts a given Image into a BufferedImage
     *
     * @param img The Image to be converted
     * @return The converted BufferedImage
     */
    public static BufferedImage toBufferedImage(Image img) {
        if (img instanceof BufferedImage) {
            return (BufferedImage) img;
        }

        // Create a buffered image with transparency
        BufferedImage bimage = new BufferedImage(img.getWidth(null), img.getHeight(null), BufferedImage.TYPE_INT_ARGB);

        // Draw the image on to the buffered image
        Graphics2D bGr = bimage.createGraphics();
        bGr.drawImage(img, 0, 0, null);
        bGr.dispose();

        // Return the buffered image
        return bimage;
    }

    public static AffineTransform getExifTransformation(int orientation, int width, int height) {

        AffineTransform t = new AffineTransform();

        switch (orientation) {
            case 1:
                break;
            case 2: // Flip X
                t.scale(-1.0, 1.0);
                t.translate(-width, 0);
                break;
            case 3: // PI rotation 
                t.translate(width, height);
                t.rotate(Math.PI);
                break;
            case 4: // Flip Y
                t.scale(1.0, -1.0);
                t.translate(0, -height);
                break;
            case 5: // - PI/2 and Flip X
                t.rotate(-Math.PI / 2);
                t.scale(-1.0, 1.0);
                break;
            case 6: // -PI/2 and -width
                t.translate(height, 0);
                t.rotate(Math.PI / 2);
                break;
            case 7: // PI/2 and Flip
                t.scale(-1.0, 1.0);
                t.translate(-height, 0);
                t.translate(0, width);
                t.rotate(3 * Math.PI / 2);
                break;
            case 8: // PI / 2
                t.translate(0, width);
                t.rotate(3 * Math.PI / 2);
                break;
        }

        return t;
    }

   

}
