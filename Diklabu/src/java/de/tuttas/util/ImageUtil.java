/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.util;

import java.awt.AlphaComposite;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import javax.imageio.ImageIO;
import sun.misc.BASE64Encoder;

/**
 *
 * @author Jörg
 */
public class ImageUtil {
    
    

    /**
     * Encode image to string
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

public static BufferedImage resizeImage(BufferedImage originalImage, int type, int w, int h){
	BufferedImage resizedImage = new BufferedImage(w, h, type);
	Graphics2D g = resizedImage.createGraphics();
	g.drawImage(originalImage, 0, 0, w, h, null);
	g.dispose();
		
	return resizedImage;
    }

public static BufferedImage cropImage(BufferedImage originalImage, int type, int h){
	BufferedImage resizedImage = new BufferedImage(h, h, type);
	Graphics2D g = resizedImage.createGraphics();
        g.setBackground(new Color(58, 58, 58));
            
            g.clearRect(0,0, h, h);
        int d = h-originalImage.getWidth();
	g.drawImage(originalImage, d/2, 0, originalImage.getWidth(), h, null);
	g.dispose();
		
	return resizedImage;
    }
	
	
}
