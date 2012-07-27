#ENCODING: UTF-8

u1 = User.create name: "Konstantin Schuler", email: "konstantin.schuler@mni.thm.de"
Authorization.create provider: "github", uid: "1998180", user: u1

java = Language.create title: "java", user: u1
css = Language.create title: "css", user: u1

ror = Library.create title: "Java", user: u1
pis = Library.create title: "RubyCode", user: u1

p1 = Project.create title: "Tutorials", description: "Hier finden Sie meine Java-Tutorials'", library: pis, user: u1
bootstrap = Project.create title: "Bootstrap", library: ror, user: u1

s1 = Package.create title: "Beispiel", description: "Einfache Beispiele", project: p1, user: u1
s2 = Package.create title: "RubyCode", description: "Neue CSS-Datei für die Darstellung", project: bootstrap, user: u1

Snippet.create user: u1, package: s1, title: "Deadlock.java", description: "http://docs.oracle.com/javase/tutorial/essential/concurrency/deadlock.html", language: java, source: <<SOURCE
public class Deadlock {
    static class Friend {
        private final String name;
        public Friend(String name) {
            this.name = name;
        }
        public String getName() {
            return this.name;
        }
        public synchronized void bow(Friend bower) {
            System.out.format("%s: %s"
                + "  has bowed to me!%n",
                this.name, bower.getName());
            bower.bowBack(this);
        }
        public synchronized void bowBack(Friend bower) {
            System.out.format("%s: %s"
                + " has bowed back to me!%n",
                this.name, bower.getName());
        }
    }

    public static void main(String[] args) {
        final Friend alphonse =
            new Friend("Alphonse");
        final Friend gaston =
            new Friend("Gaston");
        new Thread(new Runnable() {
            public void run() { alphonse.bow(gaston); }
        }).start();
        new Thread(new Runnable() {
            public void run() { gaston.bow(alphonse); }
        }).start();
    }
}
SOURCE

snip1 = Snippet.create user: u1, package: s1, title: "SimpleThreads.java", description: "http://docs.oracle.com/javase/tutorial/essential/concurrency/simple.html", language: java, source: <<SOURCE
public class SimpleThreads {

    // Display a message, preceded by
    // the name of the current thread
    static void threadMessage(String message) {
        String threadName =
            Thread.currentThread().getName();
        System.out.format("%s: %s%n",
                          threadName,
                          message);
    }

    private static class MessageLoop
        implements Runnable {
        public void run() {
            String importantInfo[] = {
                "Mares eat oats",
                "Does eat oats",
                "Little lambs eat ivy",
                "A kid will eat ivy too"
            };
            try {
                for (int i = 0;
                     i < importantInfo.length;
                     i++) {
                    // Pause for 4 seconds
                    Thread.sleep(4000);
                    // Print a message
                    threadMessage(importantInfo[i]);
                }
            } catch (InterruptedException e) {
                threadMessage("I wasn't done!");
            }
        }
    }

    public static void main(String args[])
        throws InterruptedException {

        // Delay, in milliseconds before
        // we interrupt MessageLoop
        // thread (default one hour).
        long patience = 1000 * 60 * 60;

        // If command line argument
        // present, gives patience
        // in seconds.
        if (args.length > 0) {
            try {
                patience = Long.parseLong(args[0]) * 1000;
            } catch (NumberFormatException e) {
                System.err.println("Argument must be an integer.");
                System.exit(1);
            }
        }

        threadMessage("Starting MessageLoop thread");
        long startTime = System.currentTimeMillis();
        Thread t = new Thread(new MessageLoop());
        t.start();

        threadMessage("Waiting for MessageLoop thread to finish");
        // loop until MessageLoop
        // thread exits
        while (t.isAlive()) {
            threadMessage("Still waiting...");
            // Wait maximum of 1 second
            // for MessageLoop thread
            // to finish.
            t.join(1000);
            if (((System.currentTimeMillis() - startTime) > patience)
                  && t.isAlive()) {
                threadMessage("Tired of waiting!");
                t.interrupt();
                // Shouldn't be long now
                // -- wait indefinitely
                t.join();
            }
        }
        threadMessage("Finally!");
    }
}
SOURCE

Snippet.create user: u1, package: s2, title: "coderay.css.scss", description: "Neue CSS-Datei für RubyCode", language: css, source: <<SOURCE
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