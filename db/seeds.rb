#ENCODING: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

u1 = User.create name: "Konstantin Schuler", email: "konstantin.schuler@mni.thm.de"
u2 = User.create name: "Weiterer Benutzer", email: "konstantinschuler@hotmail.com"

Authorization.create provider: "github", uid: "1998180", user: u1
Authorization.create provider: "github", uid: "2044640", user: u2

java = Language.create title: "java", user: u1
css = Language.create title: "css", user: u1
ruby = Language.create title: "ruby", user: u1

ror = Library.create title: "ROR", user: u1
pis = Library.create title: "PIS", user: u1

hue01 = Project.create title: "Hausübung 1", description: "Doppelwürfel", library: pis, user: u1
hue02 = Project.create title: "Hausübung 2", description: "Client-/Server-Chat", library: pis , user: u1
bootstrap = Project.create title: "Bootstrap", library: ror, user: u1

client = Package.create title: "chatClient", description: "Client", project: hue02, user: u1
server = Package.create title: "chatServer", description: "Server", project: hue02, user: u1
rubycode = Package.create title: "RubyCode", description: "Neue CSS-Datei für die Darstellung", project: bootstrap, user: u1

Snippet.create user: u1, package: client, title: "AutorunClient.java", description: "Startpunkt des Chat-Clients", language: java, source: <<SOURCE
package chatClient;

import java.io.IOException;
import java.net.UnknownHostException;

public class AutorunClient {

  /**
   * Startpunkt des Chat-Clients
   * @param args Programm-Argumente der IDE
   * @throws UnknownHostException IP-Adresse kann nicht ermittelt werden
   * @throws IOException Fehlgeschlagene oder unterbrochenen E/A-Operation
   */
  public static void main(String[] args) throws UnknownHostException, IOException {

    new ClientGUI();
  }
}
SOURCE

Snippet.create user: u1, package: client, title: "Client.java", description: "Logik der Clients", language: java, source: <<SOURCE
package chatClient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.UnknownHostException;
import javax.swing.DefaultListModel;
import javax.swing.JOptionPane;
import javax.swing.JTextArea;


public class Client implements ClientInterface {

  private static Socket socket;
  private static BufferedReader socket_in;
  private static PrintWriter socket_out;
  private boolean isAlive = false;

  private JTextArea textareaMessages  = new JTextArea();
  private PrintWriter log = new PrintWriter(new TextAreaWriter(textareaMessages));
  private DefaultListModel listModel = new DefaultListModel();
  //private PrintWriter list = new PrintWriter(new ListModelWriter(listModel));

  /**
   * Baut Verbindung zum Chat-Server auf
   * @param host String: IP-Adresse des Chat-Servers
   * @param port Integer: Port-Nummer des Chat-Servers für die Kommunikationsaufbau
   * @param user String: Gewählter Benutzername
   * @throws UnknownHostException IP-Adresse kann nicht ermittelt werden
   * @throws IOException Fehlgeschlagene oder unterbrochenen E/A-Operation
   */
  @Override
  public void connect(String host, String port, String user)
      throws UnknownHostException, IOException {
    try {
      int intPort = Integer.parseInt(port);
      socket = new Socket(host, intPort);

      try {
        socket_in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        socket_out = new PrintWriter(socket.getOutputStream(), true);
        socket_out.println("connect:" +user);
        this.isAlive = true;

        new Thread( new Runnable() {
          public void run() {
            String message = "";
            while (message != null)  {
              try {
                message = socket_in.readLine();
                if (message.startsWith("connect:") ||
                    message.startsWith("namelist:") ||
                    message.startsWith("disconnect:") ||
                    message.startsWith("refused")) {
                  if (message.startsWith("namelist:")) updateClientList(message);
                  if (message.matches("connect:OK"))
                    log.println("Client started and connected...");
                  if (message.startsWith("disconnect:")) {
                    if (message.matches("disconnect:OK")) {
                      log.println("You are disconnected...");
                      updateClientList("");
                      setDisconnected();
                      break;
                    }
                    if (message.matches("disconnect:invalid_command")) {
                      log.println("Check your configurations...");
                      break;
                    }
                  }
                  if (message.startsWith("refused:")) {
                    if (message.matches("refused:to_many_users"))
                      log.println("Too many users connected...");
                    if (message.matches("refused:name_in_use"))
                      log.println("Username in use...");
                    if (message.matches("refused:invalid_name"))
                      log.println("Check your username...");
                    setDisconnected();
                    updateClientList(message);
                  }
                } else log.println(message);
              } catch (IOException e) { showException(e.toString());
                try { setDisconnected();
                } catch (InterruptedException e1) {  showException(e1.toString());;
                } catch (IOException e1) { showException(e1.toString()); }
              } catch (InterruptedException e) { showException(e.toString());}
            }
          }

          /**
           * Übergibt die Nachricht an DefaultListModel
           * @param message String: Zeichenfolge der Nachricht vom Server
           */
          private void updateClientList(String message) {
            int position = 0;
            int x = message.indexOf(":");
            String userNames = message.substring(x+1);
            listModel.clear();
            String[] names = userNames.split(":");
            for (String part : names) {
              listModel.add(position, part);
              position++;
            }
          };
          }
        ).start();

      } catch (UnknownHostException e) { showException(e.toString());
      } catch (IOException e) { log.println("Connection interrupted"); }
      if (!isConnected()) log.println("Client closed.");
    } catch (IllegalArgumentException e) { showException(e.toString()); }
  }

  /**
   * Gibt an, ob die Verbindung zum Server aufgebaut ist
   * @return boolean: Gibt Status der Verbindung zum Server an
   */
  @Override
  public boolean isConnected() {
    return this.isAlive;
  }

  /**
   * Trennt die Verbindung zum Server
   * @throws InterruptedException IP-Adresse kann nicht ermittelt werden
   * @throws IOException IP-Adresse kann nicht ermittelt werden
   */
  @Override
  public void setDisconnected() throws InterruptedException, IOException {
    this.isAlive = false;
    socket_out.println("disconnect:");
  }

  /**
   * Sendet die Nachricht an den Chat-Server
   * @param message String: Nachricht an den Server
   * @throws IOException IP-Adresse kann nicht ermittelt werden
   */
  @Override
  public void sendMessage(String message) throws IOException {
    if (isAlive) {
      boolean messageSent = false;
      while (!messageSent) {
        socket_out.println(message);
        messageSent = true;
      }
    }
  }

  /**
   * Override: Gibt eine Fenstermeldung mit der Ausnahme aus
   * @param message String: Inhalt der Nachricht
   */
  @Override
  public void showException(String message) {
    JOptionPane.showMessageDialog(null, message);
  }

  /**
   * Stellt das Objekts JTextArea der GUI bereit
   * @return JTextArea: Übergibt das Objekt an die GUI
   */
  public JTextArea getMessageArea() {
    return this.textareaMessages;
  }

  /**
   * Stellt das Objekts DefaultListModel der GUI bereit
   * @return DefaultListModel: ergibt das Objekt an die GUI
   */
  public DefaultListModel getListModel() {
    return this.listModel;
  }
}
SOURCE

Snippet.create user: u1, package: client, title: "ClientGUI.java", description: "Graphische Oberfläche des Clients", language: java, source: <<SOURCE
package chatClient;

import java.awt.Color;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;
import java.net.UnknownHostException;
import javax.swing.DefaultListModel;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;

@SuppressWarnings("serial")
public class ClientGUI extends JFrame {

  Client client = new Client();
  JTextArea textareaMessages  = client.getMessageArea();
  DefaultListModel listModel = client.getListModel();
  JList listUsers = new JList(listModel);

  /**
   * Grafische Oberfläche
   * @throws UnknownHostException IP-Adresse kann nicht ermittelt werden
   * @throws IOException Fehlgeschlagene oder unterbrochenen E/A-Operation
   */
  ClientGUI() throws UnknownHostException, IOException {

    super("Chat Client");

    JPanel frameOben = new JPanel();

    // Eingabebereich: IP-Adresse bzw. -Hostname des Chat-Servers
    frameOben.add(new JLabel(" Server: "));
    final JTextField textfieldHost = new JTextField();
    textfieldHost.setText("127.0.0.1");
    frameOben.add(textfieldHost);

    // Eingabebereich: Chat-Serverport
    frameOben.add(new JLabel(" Port: "));
        final JTextField textfieldPort = new JTextField();
    textfieldPort.setText("1212");
    frameOben.add(textfieldPort);

    // Eingabebereich: Benutzername
    frameOben.add(new JLabel(" User: "));
    final JTextField textfieldUser = new JTextField("Nickname", 8);
    frameOben.add(textfieldUser);

    // Statusanzeige der Verbindung zum Server
    final JButton connectionState = new JButton("");
    connectionState.setEnabled(false);
    frameOben.add(connectionState);

    // Nachrichten- & Benutzerfenster
    textareaMessages.setText(null);
    textareaMessages.setEditable(false);
    listUsers.setPrototypeCellValue("XXXXXXXXXXXXXXXX");

    // Eingabebereich der Nachrichten
    final JTextField textfieldMessage = new JTextField();
    textfieldMessage.setEnabled(false);
    textfieldMessage.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent a) {
        try {
          client.sendMessage("message:" +textfieldMessage.getText());
          } catch (IOException e) { e.printStackTrace(); }
            textfieldMessage.setText(null);
          }
        });

    // Verbindungsbutton
    final JButton connectionButton = new JButton("Connect");
    connectionButton.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent arg0) throws NumberFormatException {
        if (connectionButton.getText() == "Connect") {
          try {
            client.connect(textfieldHost.getText(),
                textfieldPort.getText(),
                textfieldUser.getText());
            if (client.isConnected()) {
              textfieldMessage.setEnabled(true);
              connectionState.setBackground(Color.green);
              connectionButton.setText("Disconnect");
            }
          } catch (UnknownHostException e) { client.showException(e.toString());
          } catch (IOException e) { client.showException(e.toString()); }
        } else {
          try {
            client.setDisconnected();
            textfieldMessage.setEnabled(false);
            connectionState.setBackground(Color.red);
            connectionButton.setText("Connect");
          }
          catch (InterruptedException e) { e.printStackTrace(); }
          catch (IOException e) {  e.printStackTrace(); }
        }
        new Thread( new Runnable() {
          public void run() {
            while (client.isConnected())  {
              if (!client.isConnected()) {
                try {
                  textfieldMessage.setEnabled(false);
                  connectionState.setBackground(Color.red);
                  connectionButton.setText("Connect");
                  client.setDisconnected();
                } catch (InterruptedException e) { client.showException(e.toString());
                } catch (IOException e) { client.showException(e.toString()); }

              }
            }
          }
        }).start();
      }
    });
    frameOben.add(connectionButton);

    // Hinzufügen der Frames zum Hauptfenster
    getContentPane().add(frameOben, "North");
    getContentPane().add(new JScrollPane(listUsers), "East");
    getContentPane().add(new JScrollPane(textareaMessages), "Center");
    getContentPane().add(textfieldMessage, "South");
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    setSize(600, 400);
    setVisible(true);
  }
}
SOURCE

Snippet.create user: u1, package: client, title: "ClientInterface.java", description: "Schnittstelle des Clients", language: java, source: <<SOURCE
package chatClient;

import java.io.IOException;
import java.net.UnknownHostException;

public interface ClientInterface {

  /**
   * Baut Verbindung zum Chat-Server auf
   * @param host String: IP-Adresse des Chat-Servers
   * @param port Integer: Port-Nummer des Chat-Servers für die Kommunikationsaufbau
   * @param user String: Gewählter Benutzername
   * @throws UnknownHostException IP-Adresse kann nicht ermittelt werden
   * @throws IOException Fehlgeschlagene oder unterbrochenen E/A-Operation
   */
  public void connect(String host, String port, String user)
      throws UnknownHostException, IOException;

  /**
   * Gibt an, ob die Verbindung zum Server aufgebaut ist
   * @return boolean: Gibt Status der Verbindung zum Server an
   */
  public boolean isConnected();

  /**
   * Trennt die Verbindung zum Server
   * @throws InterruptedException IP-Adresse kann nicht ermittelt werden
   * @throws IOException IP-Adresse kann nicht ermittelt werden
   */
  public void setDisconnected() throws InterruptedException, IOException;

  /**
   * Sendet die Nachricht an den Chat-Server
   * @param message String: Nachricht an den Server
   * @throws IOException IP-Adresse kann nicht ermittelt werden
   */
  public void sendMessage(String message) throws IOException;

  /**
   * Gibt eine Fenstermeldung mit der Ausnahme aus
   * @param message String: Inhalt der Nachricht
   */
  public void showException(String message);
}
SOURCE

Snippet.create user: u1, package: client, title: "ListModelWriter.java", description: "Ein PrintWriter, der ein DefaultListModel als Ausgabe nutzt.", language: java, source: <<SOURCE
package chatClient;

import java.io.IOException;
import java.io.Writer;
import javax.swing.DefaultListModel;

public class ListModelWriter extends Writer {

  private final DefaultListModel listModel;

  /**
   * ListModelWriter: Ein PrintWriter, der ein DefaultListModel als Ausgabe nutzt.
   * (Ein bequemer Weg, um in der GUI die Ausgabe direkt als Text zu schreiben.)
   * @param listModel DefaultListModel: Ein Objekt in das geschrieben wird
   */
  public ListModelWriter(final DefaultListModel listModel) {
    this.listModel = listModel;
  }

    @Override
    public void flush(){ }

    @Override
    public void close(){ }

  @Override
  public void write(char[] cbuf, int off, int len) throws IOException {
    int pos = listModel.getSize();
    listModel.add(pos, listModel);
  }
}
SOURCE

Snippet.create user: u1, package: client, title: "TextAreaWriter.java", description: "Ein PrintWriter, der eine TextArea als Ausgabe nutzt.", language: java, source: <<SOURCE
package chatClient;

import java.io.IOException;
import java.io.Writer;
import javax.swing.JTextArea;

public final class TextAreaWriter extends Writer {

  private final JTextArea textArea;

  /**
   * TextAreaWriter: Ein PrintWriter, der eine TextArea als Ausgabe nutzt.
   * (Ein bequemer Weg, um in der GUI die Ausgabe direkt als Text zu schreiben.)
   * @param textArea JTextArea: Ein Objekt in das geschrieben wird
   */
  public TextAreaWriter(final JTextArea textArea) {
    this.textArea = textArea;
  }

    @Override
    public void flush(){ }

    @Override
    public void close(){ }

  @Override
  public void write(char[] cbuf, int off, int len) throws IOException {
    textArea.append(new String(cbuf, off, len));
  }
}
SOURCE

s1 = Snippet.create user: u1, package: server, title: "AutorunServer.java", description: "Startpunkt des Chat-Servers", language: java, source: <<SOURCE
package chatServer;

public class AutorunServer {

  /**
   * Startpunkt des Chat-Clients
   * @param args String: Programm-Argumente der IDE
   */
  public static void main(String[] args) {

    new ServerGUI(new Server(3)).showWindow();
//    ServerInterface server = new Server(3);  // max 3 users
//    ServerGUI fenster = new ServerGUI(server);
//    fenster.showWindow();
  }
}
SOURCE

Snippet.create user: u1, package: server, title: "Server.java", description: "Logik des Servers", language: java, source: <<SOURCE
package chatServer;

import java.io.IOException;
import java.net.ServerSocket;

public class Server implements ServerInterface  {
  private String port;
  private int maxUsers = 5;
  private ServerSocket serverSocket;
  private ServerThread serverthread;
  private boolean running;
  volatile boolean interrupted;

  Server (int maxUsers) {
    this.maxUsers = maxUsers;
    this.running = false;
    new TeilnehmerListe(this.maxUsers);
  }

  /**
   * Erzeugt einen neune Thread vom Typ ServerThread, der auf neue Clients wartet
   * @param port String: Der Port auf dem der Server lauscht
   * @return Boolean: Liefert Zustand der Verbindung
   * @throws IOException Fehlgeschlagene oder unterbrochenen E/A-Operation
   */
  public boolean startServer(String port) throws IOException {
    if(this.running) {
      ServerGUI.addLog("Server already running");
      return false;
    }
    this.port = port;
    Integer intPort = Integer.parseInt(this.port);
    try {
      this.serverSocket = new ServerSocket(intPort);
      this.running = true;
      this.interrupted = false;
      this.serverthread = new ServerThread(this.serverSocket,this.maxUsers);
      serverthread.start();
      ServerGUI.addLog("Server started. Listening on port " +this.port);
      return true;
    } catch (IOException e) {
      ServerGUI.addLog("Can't start server. Port already in use?");
      return false;
    }
  }

  /**
   * Schließt die Verbindungen zu allen Teilnehmern in der Teilnehmerliste
   * und stopt den Server Thread
   * @return Boolean: Gibt an, ob der Server erfolgreich gestoppt wurde
   */
  public boolean stopServer() throws IOException {
    if(!this.running) {
      ServerGUI.addLog("Server not running");
      return false;
    }
    for(Teilnehmer curr : TeilnehmerListe.userlist) {
      if(curr != null) curr.interrupted = true;
    }
    this.serverthread.stop = true;
    serverSocket.close();
    this.running = false;
    this.interrupted = true;
    ServerGUI.addLog("Server stopped");
    return true;
  }

  /**
   * Fügt den Logs einen Eintrag hinzu, der zeigt, dass ein Benutzer den Chat betreten hat
   * @param username String: Der Name des neuen Benutzer
   * @return Boolean: Gibt an, dass der Eintrag erfolgreich durchgeführt wurde
   */
  public boolean userJoined(String username) {
    ServerGUI.addLog("User '"+username+"' joined");
    return true;
  }

  /**
   * Fügt den Logs einen Eintrag hinzu, der zeigt, dass ein Benutzer den Chat verlassen ha
   * @param username String: Der Name des Teilnehmers, der den Chat verlassen hat
   * @return Boolean: Gibt an, dass der Eintrag erfolgreich durchgeführt wurde
   */
  public boolean userLeaved(String username) {
    ServerGUI.addLog("User '"+username+"' has left");
    return true;
  }

  /**
   * Trennt die Verbindung zu einem Teilnehmer und fügt einen Log hinzu
   * @param username String: Der Name des Teilnehmers, der getrennt werden soll
   * @return Boolean: Gibt an, dass die Verbindung erfolgreich getrennt wurde
   */
  public boolean kickUser(String username) {
    TeilnehmerListe.removeUser(username);
    ServerGUI.addLog("User '"+username+"' has been kicked");
    return true;
  }
}
SOURCE

Snippet.create user: u1, package: server, title: "ServerGUI.java", description: "Graphische Oberfläche des Servers", language: java, source: <<SOURCE
package chatServer;

import java.awt.*;
import javax.swing.*;
import java.awt.event.*;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ServerGUI extends JFrame {
  private static final long serialVersionUID = 1L;
  private int width = 800,height = 600;
  private String title = "Chat-Server";
  private ServerInterface server;
  private JTextField port = new JTextField(10);
  private static DefaultListModel listmodel = new DefaultListModel();
  private static JList userlist = new JList(listmodel);
  private static JTextArea loglist = new JTextArea("");
  public ServerGUI(ServerInterface myServer) {
    // Frame Optionen
    this.server = myServer;
    this.setTitle(this.title);
    this.setSize(this.width,this.height);
    GridLayout layout_gui = new GridLayout(1,2,10,5);// 1 Zeilen, 2 Spalten, 10 Padding
    this.setLayout(layout_gui);
    this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

    // Container Optionen
    Container c;
    c = this.getContentPane();

    // Panel: options
    JPanel panel_options = new JPanel();
    FlowLayout layout_options = new FlowLayout();
    layout_options.setAlignment(FlowLayout.LEFT);
    layout_options.setHgap(5);
    layout_options.setVgap(5);
    panel_options.setLayout(layout_options);
    c.add(panel_options);

    // Panel: options: Port
    JLabel label_port = new JLabel("Port:");
    panel_options.add(label_port,BorderLayout.WEST);
    this.port.setBackground(Color.WHITE);
    panel_options.add(this.port,BorderLayout.WEST);

    // Panel: options: start
    JButton btn_start = new JButton("start server");
    btn_start.setFont(new Font("sansSerif",Font.BOLD,12));
    panel_options.add(btn_start,BorderLayout.WEST);
    btn_start.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        try {
          server.startServer(port.getText());
        } catch (Exception error) {
          addLog("EXCEPTION: start server. Wrong port?");
        }
      }
    });

    // Panel: options: stop
    JButton btn_stop = new JButton("stop server");
    btn_stop.setFont(new Font("sansSerif",Font.BOLD,12));
    panel_options.add(btn_stop,BorderLayout.WEST);
    btn_stop.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        try {
          if(server.stopServer()) listmodel.clear();
        } catch (Exception error) {
          addLog("EXCEPTION: stop server");
        }
      }
    });

    // Panel: Userlist
    JPanel panel_userlist = new JPanel();
    BorderLayout layout_userlist = new BorderLayout();
    panel_userlist.setLayout(layout_userlist);
    c.add(panel_userlist);

    // Panel: Userlist: Title
    JLabel label_userlist_title = new JLabel("Userlist");
    panel_userlist.add(label_userlist_title,BorderLayout.NORTH);

    // Panel: Userlist: Textfeld
    JScrollPane scrollPaneUserlist = new JScrollPane(ServerGUI.userlist);
    panel_userlist.add(scrollPaneUserlist);

    // Panel: Userlist: Button
    JButton btn_kick = new JButton("kick user");
    btn_kick.setFont(new Font("sansSerif",Font.BOLD,12));
    panel_userlist.add(btn_kick,BorderLayout.SOUTH);
    btn_kick.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        try {
          int pos = userlist.getSelectedIndex();
          Object obj = listmodel.getElementAt(pos);
          String username = obj.toString();
          if(server.kickUser(username)) removeUser(username);
        } catch (Exception error) {
          addLog("Choose an user to kick");
        }
      }
    });

    // Panel: logs
    JPanel panel_logs = new JPanel();
    BorderLayout layout_logs = new BorderLayout();
    panel_logs.setLayout(layout_logs);
    c.add(panel_logs);

    // Panel: logs: Title
    JLabel label_logs_title = new JLabel("Logs");
      panel_logs.add(label_logs_title,BorderLayout.NORTH);

    // Panel: logs: Textfeld
    ServerGUI.loglist.setLineWrap(true);
    ServerGUI.loglist.setWrapStyleWord(true);
    ServerGUI.loglist.setEnabled(false);
    JScrollPane scrollPaneEncode = new JScrollPane(loglist);
    panel_logs.add(scrollPaneEncode);

    // Panel: logs: Button
    JButton btn_clear = new JButton("clear logs");
    btn_clear.setFont(new Font("sansSerif",Font.BOLD,12));
    panel_logs.add(btn_clear,BorderLayout.SOUTH);
    btn_clear.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent e) {
        try {
          clearLogs();
        } catch (Exception error) {
          addLog("EXCEPTION: clear logs");
        }
      }
    });
  }
  /**
   * F�gt den Logs einen Eintrag hinzu
   * @param log : Der Text, der hinzugef�gt werden soll
   * @return true
   **/
  public static boolean addLog(String log) {
    Date now = new Date();
    DateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");
    String str = dateFormat.format(now)+"> "+log+"\n";
    loglist.append(str);
    return true;
  }
  /**
   * L�scht alle Logs und f�gt einen Clear-Log hinzu
   * @post : loglist wurde geloescht
   * @return true
   **/
  public boolean clearLogs() {
    loglist.setText("*** Server Version 1.0 ***\n");
    addLog("logs cleared");
    return true;
  }
  /**
   * Gibt die Server-Logs zur�ck
   * @return : Server-Logs
   **/
  public String getLogs() {
    return loglist.getText();
  }
  /**
   * F�gt einen Teilneher zur Liste hinzu
   * @param username : Der Name des Teilnehmers, der hinzugef�gt werden soll
   * @post : Die Teilnehmerlsite enthaelt einen neune Eintrag
   * @return true
   **/
  public static boolean addUser(String username) {
    int pos = userlist.getModel().getSize();
    listmodel.add(pos, username);
    return true;
  }
  /**
   * Entfernt einen Teilnehmer von der Liste
   * @param username : Der Name des zu entfernende Teilnehmers
   * @post : Der Teilnehmer wurde aus der Liste entfernt
   * @return : true, wenn Teilnehmer erfolgreich entfernt
   * @return : false, wenn Benutzername nicht vorhanden
   **/
  public static boolean removeUser(String username) {
    int pos = userlist.getFirstVisibleIndex();
    int max = userlist.getModel().getSize();
    Object obj;
    String currUsername;
    for(int i=pos;i<=max;i++) {
       obj = listmodel.elementAt(i);
      currUsername = obj.toString();
      if(username == currUsername) {
        listmodel.remove(i);
        return true;
      }
    }
    return false;
  }
  /**
   * Blendet das Fenster ein
   * @post : das Fenster ist sichtbar
   **/
  public void showWindow() {
    this.setVisible(true);
  }
  /**
   * Blendet das Fenster aus
   * @post : das Fenster ist nicht sichtbar
   **/
  public void hideWindow() {
    this.setVisible(false);
  }
}
SOURCE

Snippet.create user: u1, package: server, title: "ServerInterface.java", description: "Schnittstelle des Servers", language: java, source: <<SOURCE
package chatServer;

import java.io.IOException;

interface ServerInterface {

  /**
   * Erzeugt einen neune Thread vom Typ ServerThread, der auf neue Clients wartet
   * @param port String: Der Port auf dem der Server lauscht
   * @return Boolean: Liefert Zustand der Verbindung
   * @throws IOException Fehlgeschlagene oder unterbrochenen E/A-Operation
   */
  boolean startServer(String port) throws IOException;

  /**
   * Schließt die Verbindungen zu allen Teilnehmern in der Teilnehmerliste
   * und stopt den Server Thread
   * @return Boolean: Gibt an, ob der Server erfolgreich gestoppt wurde
   */
  boolean stopServer() throws IOException;

  /**
   * Fügt den Logs einen Eintrag hinzu, der zeigt, dass ein Benutzer den Chat betreten hat
   * @param username String: Der Name des neuen Benutzer
   * @return Boolean: Gibt an, dass der Eintrag erfolgreich durchgeführt wurde
   */
  boolean userJoined(String username);

  /**
   * Fügt den Logs einen Eintrag hinzu, der zeigt, dass ein Benutzer den Chat verlassen ha
   * @param username String: Der Name des Teilnehmers, der den Chat verlassen hat
   * @return Boolean: Gibt an, dass der Eintrag erfolgreich durchgeführt wurde
   */
  boolean userLeaved(String username);

  /**
   * Trennt die Verbindung zu einem Teilnehmer und fügt einen Log hinzu
   * @param username String: Der Name des Teilnehmers, der getrennt werden soll
   * @return Boolean: Gibt an, dass die Verbindung erfolgreich getrennt wurde
   */
  boolean kickUser(String username);
}
SOURCE

Snippet.create user: u1, package: server, title: "ServerThread.java", description: "Abgeleitete Thread-Klasse für die Verwaltung der Benutzerlisten", language: java, source: <<SOURCE
package chatServer;
import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;

public class ServerThread extends Thread {
  private ServerSocket serverSocket = null;
  private Socket clientSocket = null;
  public boolean stop = false;
  public ServerThread (ServerSocket serverSocket, int maxUsers) {
    super("ServerThread");
    this.serverSocket = serverSocket;
  }
  @Override
  /**
   * Wartet auf einen neune Client
   * throws IOException
   */
  public void run() {
    while (!this.stop) {
      try {
        clientSocket = this.serverSocket.accept();
        Teilnehmer user = new Teilnehmer(clientSocket);
        new Thread(user).start();
      } catch (IOException e) {
      }
    }

  }
}
SOURCE

Snippet.create user: u1, package: server, title: "Teilnehmer.java", description: "Verwaltungslogik der Kommunikation der Benutzer", language: java, source: <<SOURCE
package chatServer;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.SocketTimeoutException;

public class Teilnehmer extends Thread {
  private Socket socket = null;
  private String name;
  private PrintWriter out;
  private BufferedReader in;
  volatile boolean interrupted = false;
  private boolean connected = false;
  Teilnehmer(Socket socket) {
    this.socket = socket;
  }

  /**
   * Gibt den Benutzernamen des aktuellen Teilnehmers zurück
   * @return String: Benutzername des Teilnehmers
   **/
  public String getUsername() {
    return this.name;
  }

  /**
   * F�hrt das Server-Client-Prtokoll aus und verarbeitet Kommandos vom CLient
   * @throws IOException
   */
  public void run() {
    try {
      this.socket.setSoTimeout(100);
      this.in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
      this.out = new PrintWriter(socket.getOutputStream(), true);
      String inputString = null,command = null, param = null;
      int pos = 0;
      while (!this.interrupted) {
        try {
          inputString = in.readLine();
          System.out.println(inputString); //REMOVE
          pos = inputString.indexOf(":");
          if(pos < 1) {
            ServerGUI.addLog("recieved wrong command from user");
            out.println("disconnect:invalid_command");
            if(this.name != null) {
              ServerGUI.removeUser(this.name);
              TeilnehmerListe.removeUser(this);
            }
            break;
          }
          command = inputString.substring(0,pos);
          param = inputString.substring((pos+1),inputString.length());
          if(!this.connected && command.equals("connect")) {
            int free_slots = 0;
            for(Teilnehmer curr : TeilnehmerListe.userlist) {
              if(curr == null) free_slots++;// free slot
            }
            // wrong username
            if(param.length()> 30 || param.indexOf(" ") > -1 || param.indexOf(":") > -1) {
              ServerGUI.addLog("user tried to join with invalid name: "+param);
              out.println("refused:invalid_name");
              break;
            }
            // server full
            if(free_slots < 1) {
              ServerGUI.addLog("user "+param+" tried to join. server full");
              out.println("refused:too_many_users");
              break;
            }
            // name already taken
            for(Teilnehmer curr : TeilnehmerListe.userlist) {
              if(curr != null) {
                if(param == curr.name) {
                  ServerGUI.addLog(param+" tried to join. name already exists");
                  out.println("refused:name_in_use");
                  break;
                }
              }
            }
            this.connected = true;
            this.name = param;
            TeilnehmerListe.addUser(this);
            ServerGUI.addLog(this.name+" joined");
            ServerGUI.addUser(this.name);
            out.println("connect:OK");
            // send new namelist to all users
            String namelist = "namelist";
            for(Teilnehmer curr : TeilnehmerListe.userlist)
              if (curr != null) namelist += ":"+curr.name;
            for(Teilnehmer curr : TeilnehmerListe.userlist)
              if (curr != null) curr.out.println(namelist);
            continue;
          }
          if(this.connected && command.equals("message")) {
            if(param.indexOf(":") > -1) {
              ServerGUI.addLog("User"+this.name+
                  "tried to send message '"+param+"'. disconnected");
              ServerGUI.removeUser(this.name);
              out.println("disconnect:invalid_command");
              TeilnehmerListe.removeUser(this);
              break;
            }
            // Send message to all clients
            ServerGUI.addLog(this.name+": "+param);
            for(Teilnehmer curr : TeilnehmerListe.userlist)
              if (curr != null) curr.out.println(this.name+":"+param);
            continue;
          }
          if(this.connected && command.equals("disconnect")) {
            ServerGUI.removeUser(this.name);
            ServerGUI.addLog(this.name+" has left.");
            out.println("disconnect:OK");
            TeilnehmerListe.removeUser(this);
            // send new namelist to all users
            String namelist = "namelist";
            for(Teilnehmer curr : TeilnehmerListe.userlist)
              if (curr != null && curr.name != this.name) namelist += ":"+curr.name;
            for(Teilnehmer curr : TeilnehmerListe.userlist)
              if (curr != null && curr.name != this.name) curr.out.println(namelist);
            break;
          }
          out.println("disconnect:invalid_command");
          ServerGUI.addLog("recieved wrong command from user");
          if(this.name != null) {
            ServerGUI.removeUser(this.name);
            this.name = null;
          }
          String namelist = "namelist";
          for(Teilnehmer curr : TeilnehmerListe.userlist) {
            if(curr != null && curr.name != null) {
              namelist += ":"+curr.name;
            }
          }
          for(Teilnehmer curr : TeilnehmerListe.userlist) {
            if(curr != null && curr.name != null) {
              curr.out.println(namelist);
            }
          }
          ServerGUI.addLog("recieved wrong command from user");
          out.println("disconnect:invalid_command");
          if(this.name != null) {
            ServerGUI.removeUser(this.name);
            TeilnehmerListe.removeUser(this);
            // send new namelist to all users
            String namelist2 = "namelist";
            for(Teilnehmer curr : TeilnehmerListe.userlist)
              if (curr != null && curr.name != this.name) namelist2 += ":"+curr.name;
            for(Teilnehmer curr : TeilnehmerListe.userlist)
              if (curr != null && curr.name != this.name) curr.out.println(namelist2);
          }
          break;
        } catch (SocketTimeoutException e) {
          //ServerGUI.addLog("Exception 1 in class Teilnehmer");
        }
      }
      // this code executes when user gets kicked
      out.println("disconnect:OK");
      if(this.name != null) {
        ServerGUI.removeUser(this.name);
        // send new namelist to all users
        String namelist = "namelist";
        for(Teilnehmer curr : TeilnehmerListe.userlist)
          if (curr != null && curr.name != this.name) namelist += ":"+curr.name;
        for(Teilnehmer curr : TeilnehmerListe.userlist)
          if (curr != null && curr.name != this.name) curr.out.println(namelist);
      }
      socket.close();
      TeilnehmerListe.removeUser(this);
    } catch (IOException e) {
      ServerGUI.addLog("Exception 2 in class Teilnehmer");
    }
  }
}
SOURCE

Snippet.create user: u1, package: server, title: "TeilnehmerListe.java", description: "Teilnehmerliste", language: java, source: <<SOURCE
package chatServer;

public class TeilnehmerListe {
  static Teilnehmer[] userlist;
  TeilnehmerListe(int maxClients) {
    userlist = new Teilnehmer[maxClients];
  }
  /**
   * Fügt einen Teilneher zur TeilnehmerListe hinzu
   * @param user : Der Teilnehmer, der hinzugefügt werden soll
   * @post : Der Teilnehmer zur Teilnehmerliste hinzugefügt
   * @return true, wenn Teilnehmer hinzugefügt wurde
   * @return false, wenn TeilnehmerListe bereits voll
   **/
  synchronized public static boolean addUser(Teilnehmer user) {
    for(int i=0;i<userlist.length;i++) {
      if(userlist[i] == null) {
        userlist[i] = user;
        return true;
      }
    }
    return false;
  }
  /**
   * Entfernt einen Teilnehmer aus der TeilnehmerListe
   * @param username : Der Name des zu entfernende Teilnehmers
   * @post : Der Teilnehmer wurde aus der Liste entfernt
   * @return : true, wenn Teilnehmer erfolgreich entfernt wurde
   * @return : false, wenn Benutzername nicht vorhanden
   **/
  synchronized public static boolean removeUser(String username) {
    for(int i=0;i<userlist.length;i++) {
      if(userlist[i] != null && userlist[i].getUsername() == username) {
        userlist[i].interrupted = true;
        userlist[i] = null;
        return true;
      }
    }
    return false;
  }
  /**
   * Entfernt einen Teilnehmer aus der TeilnehmerListe
   * @param username : Der zu entfernende Teilnehmer
   * @post : Der Teilnehmer wurde aus der Liste entfernt
   * @return : true, wenn Teilnehmer erfolgreich entfernt wurde
   * @return : false, wenn Benutzername nicht vorhanden
   **/
  synchronized public static boolean removeUser(Teilnehmer user) {
    for(int i=0;i<userlist.length;i++) {
      if(userlist[i] != null && userlist[i] == user) {
        userlist[i].interrupted = true;
        userlist[i] = null;
        return true;
      }
    }
    return false;
  }
}
SOURCE

Snippet.create user: u1, package: server, title: "TextAreaWriter.java", description: "Ein PrintWriter, der eine TextArea als Ausgabe nutzt.", language: java, source: <<SOURCE
package chatClient;

import java.io.IOException;
import java.io.Writer;
import javax.swing.JTextArea;

public final class TextAreaWriter extends Writer {

  private final JTextArea textArea;

  /**
   * TextAreaWriter: Ein PrintWriter, der eine TextArea als Ausgabe nutzt.
   * (Ein bequemer Weg, um in der GUI die Ausgabe direkt als Text zu schreiben.)
   * @param textArea JTextArea: Ein Objekt in das geschrieben wird
   */
  public TextAreaWriter(final JTextArea textArea) {
    this.textArea = textArea;
  }

    @Override
    public void flush(){ }

    @Override
    public void close(){ }

  @Override
  public void write(char[] cbuf, int off, int len) throws IOException {
    textArea.append(new String(cbuf, off, len));
  }
}
SOURCE

Snippet.create user: u1, package: rubycode, title: "coderay.css.scss", description: "Neue CSS-Datei für RubyCode", language: css, source: <<SOURCE
.CodeRay {
  #background-color: hsl(100,100%,90%);
  border: 0px solid silver;
  color: black;
}

.CodeRay pre {
  margin: 0px;
}

span.CodeRay { white-space: pre; border: 0px; padding: 2px; }

table.CodeRay { border-collapse: collapse; width: 100%; padding: 2px; }
table.CodeRay td { padding: 0px 4px; vertical-align: top; }

.CodeRay .line-numbers {
  #background-color: hsl(100,100%,100%);
  color: gray;
  text-align: right;
  -webkit-user-select: none;
  -moz-user-select: none;
  user-select: none;
}

.CodeRay .line-numbers a {
  background-color: hsl(0,0%,95%) !important;
  color: black !important;
  text-decoration: none !important;
}

.CodeRay .line-numbers a:target { color: blue !important; }
.CodeRay .line-numbers .highlighted { color: red !important; }
.CodeRay .line-numbers .highlighted a { color: red !important; }
.CodeRay span.line-numbers { padding: 0px 4px; }
.CodeRay .line { display: block; float: left; width: 100%; }
.CodeRay .code { width: 100%; }
.CodeRay .debug { color: white !important; background: blue !important; }
.CodeRay .annotation { color:#007 }
.CodeRay .attribute-name { color:#b48 }
.CodeRay .attribute-value { color:#700 }
.CodeRay .binary { color:#509 }
.CodeRay .char .content { color:#D20 }
.CodeRay .char .delimiter { color:#710 }
.CodeRay .char { color:#D20 }
.CodeRay .class { color:#B06; font-weight:bold }
.CodeRay .class-variable { color:#369 }
.CodeRay .color { color:#0A0 }
.CodeRay .comment { color:#777 }
.CodeRay .comment .char { color:#444 }
.CodeRay .comment .delimiter { color:#444 }
.CodeRay .complex { color:#A08 }
.CodeRay .constant { color:#036; font-weight:bold }
.CodeRay .decorator { color:#B0B }
.CodeRay .definition { color:#099; font-weight:bold }
.CodeRay .delimiter { color:black }
.CodeRay .directive { color:#088; font-weight:bold }
.CodeRay .doc { color:#970 }
.CodeRay .doc-string { color:#D42; font-weight:bold }
.CodeRay .doctype { color:#34b }
.CodeRay .entity { color:#800; font-weight:bold }
.CodeRay .error { color:#F00; background-color:#FAA }
.CodeRay .escape  { color:#666 }
.CodeRay .exception { color:#C00; font-weight:bold }
.CodeRay .float { color:#60E }
.CodeRay .function { color:#06B; font-weight:bold }
.CodeRay .global-variable { color:#d70 }
.CodeRay .hex { color:#02b }
.CodeRay .imaginary { color:#f00 }
.CodeRay .include { color:#B44; font-weight:bold }
.CodeRay .inline { background-color: hsla(0,0%,0%,0.07); color: black }
.CodeRay .inline-delimiter { font-weight: bold; color: #666 }
.CodeRay .instance-variable { color:#33B }
.CodeRay .integer  { color:#00D }
.CodeRay .key .char { color: #60f }
.CodeRay .key .delimiter { color: #404 }
.CodeRay .key { color: #606 }
.CodeRay .keyword { color:#080; font-weight:bold }
.CodeRay .label { color:#970; font-weight:bold }
.CodeRay .local-variable { color:#963 }
.CodeRay .namespace { color:#707; font-weight:bold }
.CodeRay .octal { color:#40E }
.CodeRay .operator { }
.CodeRay .predefined { color:#369; font-weight:bold }
.CodeRay .predefined-constant { color:#069 }
.CodeRay .predefined-type { color:#0a5; font-weight:bold }
.CodeRay .preprocessor { color:#579 }
.CodeRay .pseudo-class { color:#00C; font-weight:bold }
.CodeRay .regexp .content { color:#808 }
.CodeRay .regexp .delimiter { color:#404 }
.CodeRay .regexp .modifier { color:#C2C }
.CodeRay .regexp { background-color:hsla(300,100%,50%,0.06); }
.CodeRay .reserved { color:#080; font-weight:bold }
.CodeRay .shell .content { color:#2B2 }
.CodeRay .shell .delimiter { color:#161 }
.CodeRay .shell { background-color:hsla(120,100%,50%,0.06); }
.CodeRay .string .char { color: #b0b }
.CodeRay .string .content { color: #D20 }
.CodeRay .string .delimiter { color: #710 }
.CodeRay .string .modifier { color: #E40 }
.CodeRay .string { background-color:hsla(0,100%,50%,0.05); }
.CodeRay .symbol .content { color:#A60 }
.CodeRay .symbol .delimiter { color:#630 }
.CodeRay .symbol { color:#A60 }
.CodeRay .tag { color:#070 }
.CodeRay .type { color:#339; font-weight:bold }
.CodeRay .value { color: #088; }
.CodeRay .variable  { color:#037 }
.CodeRay .insert { background: hsla(120,100%,50%,0.12) }
.CodeRay .delete { background: hsla(0,100%,50%,0.12) }
.CodeRay .change { color: #bbf; background: #007; }
.CodeRay .head { color: #f8f; background: #505 }
.CodeRay .head .filename { color: white; }
.CodeRay .delete .eyecatcher {
  background-color: hsla(0,100%,50%,0.2);
  border: 1px solid hsla(0,100%,45%,0.5);
  margin: -1px; border-bottom: none;
  border-top-left-radius: 5px;
  border-top-right-radius: 5px;
  }
.CodeRay .insert .eyecatcher {
  background-color: hsla(120,100%,50%,0.2);
  border: 1px solid hsla(120,100%,25%,0.5);
  margin: -1px; border-top: none;
  border-bottom-left-radius: 5px;
  border-bottom-right-radius: 5px;
  }
.CodeRay .insert .insert { color: #0c0; background:transparent; font-weight:bold }
.CodeRay .delete .delete { color: #c00; background:transparent; font-weight:bold }
.CodeRay .change .change { color: #88f }
.CodeRay .head .head { color: #f4f }
SOURCE

Comment.create comment: "Bei mir startet das Programm nicht...", snippet: s1, user: u2
Comment.create comment: "Bei mir funktioniert alles!", snippet: s1, user: u1

#Snippet.create user: u2, package: server, title: ".java", description: "", language: java, source: <<SOURCE
#SOURCE