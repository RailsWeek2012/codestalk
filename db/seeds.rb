#ENCODING: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

u = User.create name: "Konstantin Schuler", email: "konstantin.schuler@mni.thm.de"
Authorization.create provider: "github", uid: "1998180", user: u
java = Language.create title: "java", user: u
css = Language.create title: "css", user: u
ruby = Language.create title: "ruby", user: u

#ror = Library.create title: "ROR", user: u
pis = Library.create title: "PIS", user: u

hue01 = Project.create title: "Hausübung 1", description: "Doppelwürfel", library: pis, user: u
hue02 = Project.create title: "Hausübung 2", description: "Client-/Server-Chat", library: pis , user: u
#rubycode = Project.create title: "RubyCode", user: u

client = Package.create title: "chatClient", description: "Client", project: hue02, user: u
server = Package.create title: "chatServer", description: "Server", project: hue02, user: u

Snippet.create user: u, package: client, title: "AutorunClient.java", description: "Startpunkt des Chat-Clients", language: java, source: <<SOURCE
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
Snippet.create user: u, package: server, title: "TextAreaWriter.java", description: "Ein PrintWriter, der eine TextArea als Ausgabe nutzt.", language: java, source: <<SOURCE
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



