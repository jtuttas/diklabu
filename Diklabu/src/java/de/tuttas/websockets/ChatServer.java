/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package de.tuttas.websockets;

import de.tuttas.util.StringUtil;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

/**
 *
 * @author Jörg
 */
@ServerEndpoint("/chat")
public class ChatServer {

    private static ArrayList<Session> sessions = new ArrayList<>();
    Session mySession;
    private static HashMap users = new HashMap();

    @OnOpen
    public void onOpen(Session session) {
        System.out.println(session.getId() + " has opened a connection");
        sessions.add(session);

        mySession = session;
        ChatLine l = new ChatLine("System", "");
        users.put(session.getId(), "NN");
        try {
            session.getBasicRemote().sendText(l.toJson());
        } catch (IOException ex) {
            Logger.getLogger(ChatServer.class.getName()).log(Level.SEVERE, null, ex);
        }
        System.out.println("Total Number of Clients =" + sessions.size());
    }

    @OnMessage
    public String onMessage(String jsonMessage) {
        System.out.println("ChatServer receive:" + jsonMessage);
        JSONParser parser = new JSONParser();
        JSONObject jo;
        try {
            jo = (JSONObject) parser.parse(jsonMessage);
            String from = (String) jo.get("from");
            String msg = (String) jo.get("msg");
            if (from.compareTo("System") == 0) {
                users.put(mySession.getId(), msg);
                System.out.println("Session " + mySession.getId() + " user " + msg + " zugeordnet");
                jo.put("from", msg);
                jo.put("msg", "beigetreten!");
                jo.put("notoast", true);
            }
            ChatServer.send(jo, mySession);
        } catch (ParseException ex) {
            Logger.getLogger(ChatServer.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    @OnClose
    public void onClose(Session session) {
        System.out.println("Session " + session.getId() + " has ended user is " + users.get(session.getId()));
        JSONObject jo = new JSONObject();
        jo.put("from", users.get(session.getId()));
        jo.put("msg", "hat das System verlassen!");
        jo.put("notoast", true);
        send(jo, session);
        users.remove(session.getId());
        sessions.remove(session);
    }

    public static void send(JSONObject msg, Session myself) {
        System.out.println("Sende " + msg.toJSONString());
        msg.put("msg", StringUtil.escapeHtml((String) msg.get("msg")));
        for (Session s : sessions) {
            if (s != myself) {
                try {
                    s.getBasicRemote().sendText(msg.toJSONString());
                } catch (IOException ex) {
                    Logger.getLogger(ChatServer.class.getName()).log(Level.SEVERE, null, ex);
                    ex.printStackTrace();
                }
           }
        }
    }
}
