#ENCODING: UTF-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

u = User.create name: "KS", email: "konstantin.schuler@mni.thm.de"
Authorization.create provider: "github", uid: "1998180", user: u

oop = Library.create title: "OOP", user: u
pis = Library.create title: "PIS", user: u

java = Language.create title: "java", user: u
css = Language.create title: "css", user: u

Snippet.create user: u, library: oop, title: "Bsp 1", description: "Bla", language: java, source: <<SOURCE
    package test;

    import java.io.*;
    public class Temperatur {

      public Temperatur() {
      }

      public static void main(String[] args) throws Exception {
        BufferedReader in = new BufferedReader(new InputStreamReader( System.in ) );
        System.out.print( "Bitte geben Sie eine Temperatur in °Fahrenheit ein: " );
        String line = in.readLine();
        int temperaturF = Integer.parseInt(line);
        int temperaturC = (int)(5.0/9.0*(temperaturF- 32));
        System.out.println
          ("Ergebnis: " + temperaturF + "°F entspricht "+ temperaturC + "°C.");
      }
    }
SOURCE
Snippet.create user: u, library: pis, title: "Bsp 2", description: "Bla", language: css, source: <<SOURCE
.CodeRay {
  background-color: hsl(0,0%,95%);
  border: 1px solid silver;
  color: black;
}

.CodeRay pre {
  margin: 0px;
}

span.CodeRay { white-space: pre; border: 0px; padding: 2px; }

table.CodeRay { border-collapse: collapse; width: 100%; padding: 2px; }
table.CodeRay td { padding: 2px 4px; vertical-align: top; }

.CodeRay .line-numbers {
  background-color: hsl(180,65%,90%);
  color: gray;
  text-align: right;
  -webkit-user-select: none;
  -moz-user-select: none;
  user-select: none;
}

.CodeRay .line-numbers a {
  background-color: hsl(180,65%,90%) !important;
  color: gray !important;
  text-decoration: none !important;
}

table.CodeRay {
  width: auto;
}

#main .example {
  width: 960px;
  overflow: auto;
}

#main .CodeRay pre {
  font-size: 13px ! important;
  line-height: 15px;
}
SOURCE
Snippet.create user: u, library: pis, title: "Bsp 3", description: "Bla", language: java, source: <<SOURCE
import java.io.*;
class Head {
  public static void main (String args[]){
    String zeile;
    try {
      BufferedReader in = new BufferedReader(new FileReader(args[0]));
      for (int i = 0; i < 10; i++){
        zeile = in.readLine();
        System.out.println(zeile);
      }
    } catch (IOException e){
        System.err.println("Fehler beim Lesen  von " + args[0]);
    }
  }
}
SOURCE
