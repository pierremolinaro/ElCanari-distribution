#! /usr/bin/swift

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ElCanari RSS : https://raw.githubusercontent.com/pierremolinaro/ElCanari-distribution/master/rss.xml
// https://fr.wikipedia.org/wiki/RSS
// https://sparkle-project.org
// Example: https://version.cyberduck.io//changelog.rss
// https://htmlpreview.github.com/?https://github.com/pierremolinaro/ElCanari-distribution/master/ElCanari.app.0.3.0.html
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func header () -> [String] {
  return []
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let changeLogURL = "https://pierremolinaro.github.io/ElCanari-distribution/release-notes.html"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   FOR PRINTING IN COLOR
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BLACK   = "\u{1B}[0;30m"
let RED     = "\u{1B}[0;31m"
let GREEN   = "\u{1B}[0;32m"
let YELLOW  = "\u{1B}[0;33m"
let BLUE    = "\u{1B}[0;34m"
let MAGENTA = "\u{1B}[0;35m"
let CYAN    = "\u{1B}[0;36m"
let ENDC    = "\u{1B}[0;0m"
let BOLD    = "\u{1B}[0;1m"
let UNDERLINE = "\u{1B}[4m"
let BOLD_MAGENTA = BOLD + MAGENTA
let BOLD_BLUE = BOLD + BLUE
let BOLD_GREEN = BOLD + GREEN
let BOLD_RED = BOLD + RED

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    Release Notes
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

var releaseNotesHTML = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n"
releaseNotesHTML += "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n"
releaseNotesHTML += "  <head>\n"
releaseNotesHTML += "    <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />\n"
releaseNotesHTML += "    <title>ElCanari Release Notes</title>\n"
releaseNotesHTML += "    <style type=\"text/css\">\n"
releaseNotesHTML += "      body {\n"
releaseNotesHTML += "       font-family: \"Lucida Grande\", sans-serif ;\n"
releaseNotesHTML += "       font-size: 12px ;\n"
releaseNotesHTML += "      }\n"
releaseNotesHTML += "      .version-title {\n"
releaseNotesHTML += "        display: inline;\n"
releaseNotesHTML += "        padding: .2em .6em .3em;\n"
releaseNotesHTML += "        font-weight: bold;\n"
releaseNotesHTML += "        line-height: 1;\n"
releaseNotesHTML += "        text-align: left ;\n"
releaseNotesHTML += "        white-space: nowrap;\n"
releaseNotesHTML += "        vertical-align: baseline;\n"
releaseNotesHTML += "        border-radius: .25em;\n"
releaseNotesHTML += "        padding: .2em .6em .3em;\n"
releaseNotesHTML += "        color: #000000 ;\n"
releaseNotesHTML += "        background-color: #FFFFCC ;\n"
releaseNotesHTML += "      }\n"
releaseNotesHTML += "      .box {\n"
releaseNotesHTML += "        display: inline ;\n"
releaseNotesHTML += "        padding: .2em .6em .3em ;\n"
releaseNotesHTML += "        font-size: 75% ;\n"
releaseNotesHTML += "        font-weight: normal ;\n"
releaseNotesHTML += "        line-height: 1 ;\n"
releaseNotesHTML += "        color: #FFFFFF ;\n"
releaseNotesHTML += "        text-align: center ;\n"
releaseNotesHTML += "        white-space: nowrap ;\n"
releaseNotesHTML += "        vertical-align: baseline ;\n"
releaseNotesHTML += "        border-radius: .5em ;\n"
releaseNotesHTML += "        min-width: 150px ;\n"
releaseNotesHTML += "      }\n"
releaseNotesHTML += "      .bugfix {\n"
releaseNotesHTML += "        background-color: #FFCC00 ;\n"
releaseNotesHTML += "      }\n"
releaseNotesHTML += "      .new {\n"
releaseNotesHTML += "        background-color: #0099FF ;\n"
releaseNotesHTML += "      }\n"
releaseNotesHTML += "      .note {\n"
releaseNotesHTML += "        background-color: #000000 ;\n"
releaseNotesHTML += "      }\n"
releaseNotesHTML += "      .change {\n"
releaseNotesHTML += "        background-color: #993300 ;\n"
releaseNotesHTML += "      }\n"
releaseNotesHTML += "      ul li {\n"
releaseNotesHTML += "        list-style-type: none;\n"
releaseNotesHTML += "        line-height: 1.5em;\n"
releaseNotesHTML += "      }\n"
releaseNotesHTML += "    </style>\n"
releaseNotesHTML += "  </head>\n"
releaseNotesHTML += "    <body>\n"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    getListOfReleases
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func getOrderedListOfReleases (_ scriptDir : String) -> [(Int, Int, Int)] {
  let fm = FileManager ()
  if let fileArray = fm.subpaths (atPath: scriptDir) {
    var releases = [(Int, Int, Int)] ()
    for entry in fileArray { // Search for ElCanari-X.Y.Z.json
      let components = entry.components (separatedBy: "-")
      if components.count == 2, components [0] == "ElCanari" {
         let extensionElements = components [1].components (separatedBy: ".")
         if extensionElements.count == 4,
            extensionElements [3] == "json",
            let major = Int (extensionElements [0]),
            let minor = Int (extensionElements [1]),
            let patch = Int (extensionElements [2]) {
           releases.append ((major, minor, patch))
         }
      }
    }
    let sortedReleases = releases.sorted (by: {
       ($0.0 > $1.0) ||
      (($0.0 == $1.0) && ($0.1  > $1.1)) ||
      (($0.0 == $1.0) && ($0.1 == $1.1) && ($0.2 > $1.2))
    } )
    return sortedReleases
  }else{
    print (RED + "line \(#line) : object is not an array of dictionaries" + ENDC)
    exit (1)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  HTML encode
// https://gist.github.com/SebastianMecklenburg/4f72d0ca1d5bd8638633
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let encoder : [Character:String] = [" ":"&emsp;", " ":"&ensp;", " ":"&nbsp;", " ":"&thinsp;", "‾":"&oline;", "–":"&ndash;", "—":"&mdash;", "¡":"&iexcl;", "¿":"&iquest;", "…":"&hellip;", "·":"&middot;", "'":"&apos;", "‘":"&lsquo;", "’":"&rsquo;", "‚":"&sbquo;", "‹":"&lsaquo;", "›":"&rsaquo;", "‎":"&lrm;", "‏":"&rlm;", "­":"&shy;", "‍":"&zwj;", "‌":"&zwnj;", "\"":"&quot;", "“":"&ldquo;", "”":"&rdquo;", "„":"&bdquo;", "«":"&laquo;", "»":"&raquo;", "⌈":"&lceil;", "⌉":"&rceil;", "⌊":"&lfloor;", "⌋":"&rfloor;", "〈":"&lang;", "〉":"&rang;", "§":"&sect;", "¶":"&para;", "&":"&amp;", "‰":"&permil;", "†":"&dagger;", "‡":"&Dagger;", "•":"&bull;", "′":"&prime;", "″":"&Prime;", "´":"&acute;", "˜":"&tilde;", "¯":"&macr;", "¨":"&uml;", "¸":"&cedil;", "ˆ":"&circ;", "°":"&deg;", "©":"&copy;", "®":"&reg;", "℘":"&weierp;", "←":"&larr;", "→":"&rarr;", "↑":"&uarr;", "↓":"&darr;", "↔":"&harr;", "↵":"&crarr;", "⇐":"&lArr;", "⇑":"&uArr;", "⇒":"&rArr;", "⇓":"&dArr;", "⇔":"&hArr;", "∀":"&forall;", "∂":"&part;", "∃":"&exist;", "∅":"&empty;", "∇":"&nabla;", "∈":"&isin;", "∉":"&notin;", "∋":"&ni;", "∏":"&prod;", "∑":"&sum;", "±":"&plusmn;", "÷":"&divide;", "×":"&times;", "<":"&lt;", "≠":"&ne;", ">":"&gt;", "¬":"&not;", "¦":"&brvbar;", "−":"&minus;", "⁄":"&frasl;", "∗":"&lowast;", "√":"&radic;", "∝":"&prop;", "∞":"&infin;", "∠":"&ang;", "∧":"&and;", "∨":"&or;", "∩":"&cap;", "∪":"&cup;", "∫":"&int;", "∴":"&there4;", "∼":"&sim;", "≅":"&cong;", "≈":"&asymp;", "≡":"&equiv;", "≤":"&le;", "≥":"&ge;", "⊄":"&nsub;", "⊂":"&sub;", "⊃":"&sup;", "⊆":"&sube;", "⊇":"&supe;", "⊕":"&oplus;", "⊗":"&otimes;", "⊥":"&perp;", "⋅":"&sdot;", "◊":"&loz;", "♠":"&spades;", "♣":"&clubs;", "♥":"&hearts;", "♦":"&diams;", "¤":"&curren;", "¢":"&cent;", "£":"&pound;", "¥":"&yen;", "€":"&euro;", "¹":"&sup1;", "½":"&frac12;", "¼":"&frac14;", "²":"&sup2;", "³":"&sup3;", "¾":"&frac34;", "á":"&aacute;", "Á":"&Aacute;", "â":"&acirc;", "Â":"&Acirc;", "à":"&agrave;", "À":"&Agrave;", "å":"&aring;", "Å":"&Aring;", "ã":"&atilde;", "Ã":"&Atilde;", "ä":"&auml;", "Ä":"&Auml;", "ª":"&ordf;", "æ":"&aelig;", "Æ":"&AElig;", "ç":"&ccedil;", "Ç":"&Ccedil;", "ð":"&eth;", "Ð":"&ETH;", "é":"&eacute;", "É":"&Eacute;", "ê":"&ecirc;", "Ê":"&Ecirc;", "è":"&egrave;", "È":"&Egrave;", "ë":"&euml;", "Ë":"&Euml;", "ƒ":"&fnof;", "í":"&iacute;", "Í":"&Iacute;", "î":"&icirc;", "Î":"&Icirc;", "ì":"&igrave;", "Ì":"&Igrave;", "ℑ":"&image;", "ï":"&iuml;", "Ï":"&Iuml;", "ñ":"&ntilde;", "Ñ":"&Ntilde;", "ó":"&oacute;", "Ó":"&Oacute;", "ô":"&ocirc;", "Ô":"&Ocirc;", "ò":"&ograve;", "Ò":"&Ograve;", "º":"&ordm;", "ø":"&oslash;", "Ø":"&Oslash;", "õ":"&otilde;", "Õ":"&Otilde;", "ö":"&ouml;", "Ö":"&Ouml;", "œ":"&oelig;", "Œ":"&OElig;", "ℜ":"&real;", "š":"&scaron;", "Š":"&Scaron;", "ß":"&szlig;", "™":"&trade;", "ú":"&uacute;", "Ú":"&Uacute;", "û":"&ucirc;", "Û":"&Ucirc;", "ù":"&ugrave;", "Ù":"&Ugrave;", "ü":"&uuml;", "Ü":"&Uuml;", "ý":"&yacute;", "Ý":"&Yacute;", "ÿ":"&yuml;", "Ÿ":"&Yuml;", "þ":"&thorn;", "Þ":"&THORN;", "α":"&alpha;", "Α":"&Alpha;", "β":"&beta;", "Β":"&Beta;", "γ":"&gamma;", "Γ":"&Gamma;", "δ":"&delta;", "Δ":"&Delta;", "ε":"&epsilon;", "Ε":"&Epsilon;", "ζ":"&zeta;", "Ζ":"&Zeta;", "η":"&eta;", "Η":"&Eta;", "θ":"&theta;", "Θ":"&Theta;", "ϑ":"&thetasym;", "ι":"&iota;", "Ι":"&Iota;", "κ":"&kappa;", "Κ":"&Kappa;", "λ":"&lambda;", "Λ":"&Lambda;", "µ":"&micro;", "μ":"&mu;", "Μ":"&Mu;", "ν":"&nu;", "Ν":"&Nu;", "ξ":"&xi;", "Ξ":"&Xi;", "ο":"&omicron;", "Ο":"&Omicron;", "π":"&pi;", "Π":"&Pi;", "ϖ":"&piv;", "ρ":"&rho;", "Ρ":"&Rho;", "σ":"&sigma;", "Σ":"&Sigma;", "ς":"&sigmaf;", "τ":"&tau;", "Τ":"&Tau;", "ϒ":"&upsih;", "υ":"&upsilon;", "Υ":"&Upsilon;", "φ":"&phi;", "Φ":"&Phi;", "χ":"&chi;", "Χ":"&Chi;", "ψ":"&psi;", "Ψ":"&Psi;", "ω":"&omega;", "Ω":"&Omega;", "ℵ":"&alefsym;"]

extension String {
    var html: String {
        get {
            var html = ""
            for c in self {
                if let entity = encoder [c] {
                    html.append (entity)
                } else {
                    html.append(c)
                }
            }
            return html
        }
    }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct VersionDescriptor : Codable {
  var bugfixes = [String] ()
  var notes = [String] ()
  var length = ""
  var edSignature = ""
  var news = [String] ()
  var changes = [String] ()
  var date = ""
  var osmin = ""
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//-------------------- Get script absolute path
let scriptURL = URL (fileURLWithPath: CommandLine.arguments [0]).deletingLastPathComponent ()
print ("scriptURL \(scriptURL)")
//-------------------- Make temporary directory
let temporaryDir = NSTemporaryDirectory ()
print ("Temporary dir \(temporaryDir)")
//-------------------- Get sorted list of releases
let sortedReleases = getOrderedListOfReleases (scriptURL.path)
print ("Releases: \(sortedReleases)")
//-------------------- Construire le fichier xml - rss
let channel = XMLElement (name: "channel")
channel.addChild (XMLElement(name: "title", stringValue:"ElCanari Changelog"))
channel.addChild (XMLElement(name: "description", stringValue:"Most recent changes with links to updates"))
channel.addChild (XMLElement(name: "language", stringValue:"en"))
let fm = FileManager ()
for (major, minor, patch) in sortedReleases {
  let version = "\(major).\(minor).\(patch)"
//--- Explore JSON file
  let jsonFilePath = scriptURL.path + "/ElCanari-" + version + ".json"
  let jsonFileContents : Data
  if let data = try? Data (contentsOf: URL (fileURLWithPath: jsonFilePath)) {
    jsonFileContents = data
  }else{
    print (RED + "line \(#line) : cannot read \(jsonFilePath) file" + ENDC)
    exit (1)
  }
  let decoder = JSONDecoder ()
  let versionDescriptor : VersionDescriptor
  if let version = try? decoder.decode (VersionDescriptor.self, from: jsonFileContents) {
    versionDescriptor = version
  }else{
    print (RED + "line \(#line) : cannot decode \(jsonFilePath) file" + ENDC)
    exit (1)
  }
  let item = XMLElement (name: "item")
  item.addChild (XMLElement(name: "title", stringValue:"Version \(version)"))
  item.addChild (XMLElement(name: "sparkle:minimumSystemVersion", stringValue:"\(versionDescriptor.osmin)"))
//--- Check the dmg file exists, and has the good length
  let dmgFilePath = scriptURL.path + "/ElCanari-" + version + ".dmg"
  let dmgFileLength : Int
  if let attributes = try? fm.attributesOfItem (atPath: dmgFilePath) {
    if let lg = attributes [.size] as? Int {
      dmgFileLength = lg
    }else{
      print (RED + "line \(#line) : cannot get size of \(dmgFilePath) file" + ENDC)
      exit (1)
    }
  }else{
    print (RED + "line \(#line) : cannot read \(dmgFilePath) file" + ENDC)
    exit (1)
  }
//--- Check dmg length is equal to version descriptor length
  if dmgFileLength != Int (versionDescriptor.length) {
    print (RED + "line \(#line) : incorrect \(dmgFilePath) file size, \(dmgFileLength), expected \(versionDescriptor.length)" + ENDC)
    exit (1)
  }
//--- Add build date
  item.addChild (XMLElement(name: "pubDate", stringValue: versionDescriptor.date))
//--- sparkle:releaseNotesLink
  item.addChild (XMLElement (name: "sparkle:releaseNotesLink", stringValue: changeLogURL))
//--- enclosure
  let enclosure = XMLElement (name: "enclosure")
  let url = "https://raw.githubusercontent.com/pierremolinaro/ElCanari-distribution/master/ElCanari-\(version).dmg"
  enclosure.addAttribute (XMLNode.attribute (withName: "url", stringValue:url) as! XMLNode)
  enclosure.addAttribute (XMLNode.attribute (withName: "type", stringValue:"application/octet-stream") as! XMLNode)
  enclosure.addAttribute (XMLNode.attribute (withName: "sparkle:edSignature", stringValue:versionDescriptor.edSignature) as! XMLNode)
  enclosure.addAttribute (XMLNode.attribute (withName: "sparkle:version", stringValue:version) as! XMLNode)
  enclosure.addAttribute (XMLNode.attribute (withName: "length", stringValue:"\(dmgFileLength)") as! XMLNode)
  enclosure.addAttribute (XMLNode.attribute (withName: "sparkle:installationType", stringValue:"package") as! XMLNode)
  item.addChild (enclosure)
//---
  channel.addChild (item)
//--- Release notes
  let date = ISO8601DateFormatter ().date(from: versionDescriptor.date)!
  let dateFormatter = DateFormatter()
  dateFormatter.locale = Locale(identifier: "en_US")
  dateFormatter.setLocalizedDateFormatFromTemplate("MMMMdYYYY") // set template after setting locale
  releaseNotesHTML += "\n  <p>\n    <span class=\"version-title\">Version \(version) (\(dateFormatter.string(from: date)))</span>\n  </p>\n"
  releaseNotesHTML += "  <ul>\n"
  for str in versionDescriptor.bugfixes {
    releaseNotesHTML += "    <li><span class=\"box new\">Bug Fix</span> \(str.html)</li>\n"
  }
  for str in versionDescriptor.news {
    releaseNotesHTML += "    <li><span class=\"box new\">New</span> \(str.html)</li>\n"
  }
  for str in versionDescriptor.changes {
    releaseNotesHTML += "    <li><span class=\"box new\">Change</span> \(str.html)</li>\n"
  }
  for str in versionDescriptor.notes {
    releaseNotesHTML += "    <li><span class=\"box new\">Note</span> \(str.html)</li>\n"
  }
  releaseNotesHTML += "  </ul>\n"
}
//--- Build rss file
let rss = XMLElement (name: "rss")
rss.addChild (channel)
rss.addAttribute (XMLNode.attribute (withName: "version", stringValue: "2.0") as! XMLNode)
rss.addAttribute (XMLNode.attribute (withName: "xmlns:sparkle", stringValue: "http://www.andymatuschak.org/xml-namespaces/sparkle") as! XMLNode)
rss.addAttribute (XMLNode.attribute (withName: "xmlns:dc", stringValue: "http://purl.org/dc/elements/1.1/") as! XMLNode)
let xml = XMLDocument (rootElement: rss)
xml.version = "1.0"
xml.characterEncoding = "utf-8"
//print (xml.xmlString (options: [.nodePrettyPrint]))
//print (xml.xmlString)
let data = xml.xmlData (options: [.nodePrettyPrint])
do{
  try data.write (to: scriptURL.appendingPathComponent ("rss.xml"))
}catch let error {
  print (BOLD_RED + "Error \(error) writing rss.xml file" + ENDC)
  exit (1)
}
//--- Terminer le fichier release-notes.html
releaseNotesHTML +=  "  </body>\n"
releaseNotesHTML +=  "</html>\n"
if let releaseNotesData = releaseNotesHTML.data (using: .utf8) {
  do{
    try releaseNotesData.write (to: scriptURL.appendingPathComponent ("docs/release-notes.html"))
  }catch let error {
    print (BOLD_RED + "Error \(error) writing docs/release-notes.html file" + ENDC)
    exit (1)
  }
}else{
  print (BOLD_RED + "Release notes source is not an UTF-8 string" + ENDC)
  exit (1)
}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
