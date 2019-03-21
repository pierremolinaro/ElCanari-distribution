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
  return [] // ["-H", "\"Accept: application/vnd.github.v3+json\""]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let changeLogURL = "https://pierremolinaro.github.io/ElCanari-distribution/release-notes.html"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   FOR PRINTING IN COLOR
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BLACK   = "\u{001B}[0;30m"
let RED     = "\u{001B}[0;31m"
let GREEN   = "\u{001B}[0;32m"
let YELLOW  = "\u{001B}[0;33m"
let BLUE    = "\u{001B}[0;34m"
let MAGENTA = "\u{001B}[0;35m"
let CYAN    = "\u{001B}[0;36m"
let ENDC    = "\u{001B}[0;0m"
let BOLD    = "\u{001B}[0;1m"
//let UNDERLINE = "\033[4m"
let BOLD_MAGENTA = BOLD + MAGENTA
let BOLD_BLUE = BOLD + BLUE
let BOLD_GREEN = BOLD + GREEN
let BOLD_RED = BOLD + RED

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   runCommand
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func runCommand (cmd : String, args : [String]) {
  var str = "+ " + cmd
  for s in args {
    str += " " + s
  }
  print (BOLD_MAGENTA + str + ENDC)
  let task = Process.launchedProcess (launchPath:cmd, arguments:args)
  task.waitUntilExit ()
  let status = task.terminationStatus
  if status != 0 {
    print (BOLD_RED + "Error \(status)" + ENDC)
    exit (status)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   loadJsonFile
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func loadJsonFile (filePath : String) -> Any {
  do{
    let data = try Data (contentsOf: URL (fileURLWithPath:filePath))
    return try JSONSerialization.jsonObject (with:data)
  }catch let error {
    print (RED + "Error \(error) while processing \(filePath) file" + ENDC)
    exit (1)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   get fromDictionary
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func get (_ inObject: Any, _ key : String, _ line : Int) -> Any {
  if let dictionary = inObject as? NSDictionary {
    if let r = dictionary [key] {
      return r
    }else{
      print (RED + "line \(line) : no \(key) key in dictionary" + ENDC)
      exit (1)
    }
  }else{
    print (RED + "line \(line) : object is not a dictionary" + ENDC)
    exit (1)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   getString fromDictionary
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func getString (_ inObject: Any, _ key : String, _ line : Int) -> String {
  if let dictionary = inObject as? NSDictionary {
    let r = dictionary [key]
    if r == nil {
      print (RED + "line \(line) : no \(key) key in dictionary" + ENDC)
      exit (1)
    }else if let s = r as? String {
      return s
    }else{
      print (RED + "line \(line) : \(key) key value is not a string" + ENDC)
      exit (1)
    }
  }else{
    print (RED + "line \(line) : object is not a dictionary" + ENDC)
    exit (1)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   getInt fromDictionary
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func getInt (_ inObject: Any, _ key : String, _ line : Int) -> Int {
  if let dictionary = inObject as? NSDictionary {
    let r = dictionary [key]
    if r == nil {
      print (RED + "line \(line) : no \(key) key in dictionary" + ENDC)
      exit (1)
    }else if let s = r as? Int {
      return s
    }else{
      print (RED + "line \(line) : \(key) key value is not an int" + ENDC)
      exit (1)
    }
  }else{
    print (RED + "line \(line) : object is not a dictionary" + ENDC)
    exit (1)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   getStringArray fromDictionary
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func getStringArray (_ inObject: Any, _ key : String, _ line : Int) -> [String] {
  if let dictionary = inObject as? NSDictionary {
    let r = dictionary [key]
    if r == nil {
      print (RED + "line \(line) : no \(key) key in dictionary" + ENDC)
      exit (1)
    }else if let s = r as? [String] {
      return s
    }else{
      print (RED + "line \(line) : \(key) key value is not a string array" + ENDC)
      exit (1)
    }
  }else{
    print (RED + "line \(line) : object is not a dictionary" + ENDC)
    exit (1)
  }
}

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
//
//enum ReleaseType {
//  case bz2
//  case pkg
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func getListOfReleases (_ listOfFileDictionaries : Any, _ line : Int) -> ([(Int, Int, Int)], [String : Int]) {
  if let array = listOfFileDictionaries as? [NSDictionary] {
    var result = ([(Int, Int, Int)] (), [String : Int] ())
    for entry in array {
      let name = getString (entry, "path", #line)
//      let bz2NameElements = name.components (separatedBy: ".")
 //     if (bz2NameElements.count == 7)
//         && (bz2NameElements [0] == "ElCanari") && (bz2NameElements [1] == "app")
//         && (bz2NameElements [5] == "tar") && (bz2NameElements [6] == "bz2"),
//         let major = Int (bz2NameElements [2]),
//         let minor = Int (bz2NameElements [3]),
//         let patch = Int (bz2NameElements [4]) {
//        let size = getInt (entry, "size", #line)
//        result.0.append ((major, minor, patch, .bz2))
//        result.1 ["\(major).\(minor).\(patch)"] = size
//      }else{
       let pkgNameElements = name.components (separatedBy: "-")
       if pkgNameElements.count == 2, pkgNameElements [0] == "ElCanari" {
         let extensionElements = pkgNameElements [1].components (separatedBy: ".")
         if extensionElements.count == 4,
            extensionElements [3] == "dmg",
            let major = Int (extensionElements [0]),
            let minor = Int (extensionElements [1]),
            let patch = Int (extensionElements [2]) {
           let size = getInt (entry, "size", #line)
           result.0.append ((major, minor, patch))
           result.1 ["\(major).\(minor).\(patch)"] = size
         }
 //      }
      }
    }
    return result
  }else{
    print (RED + "line \(line) : object is not an array of dictionaries" + ENDC)
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

func analyzeInfos (_ dictionary : Any) -> String {
  var s = "  <ul>\n"
  let bugFixes = getStringArray (dictionary, "BUGFIX", #line)
  let news = getStringArray (dictionary, "NEW", #line)
  for str in news {
    s += "    <li><span class=\"box new\">New</span> \(str.html)</li>\n"
  }
  for str in bugFixes {
    s += "    <li><span class=\"box bugfix\">Bugfix</span> \(str.html)</li>\n"
  }
  let changes = getStringArray (dictionary, "CHANGE", #line)
  for str in changes {
    s += "    <li><span class=\"box change\">Changed</span> \(str.html)</li>\n"
  }
  let notes = getStringArray (dictionary, "NOTE", #line)
  for str in notes {
    s += "    <li><span class=\"box note\">Note</span> \(str.html)</li>\n"
  }
  s += "  </ul>\n"
  return s
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//-------------------- Get script absolute path
let scriptDir = URL (fileURLWithPath:CommandLine.arguments [0]).deletingLastPathComponent ()
print ("scriptDir \(scriptDir)")
//-------------------- Make temporary directory
let temporaryDir = NSTemporaryDirectory ()
print ("Temporary dir \(temporaryDir)")
//-------------------- Download the Json file of master branch
let masterJsonFilePath = temporaryDir + "master.json"
runCommand (cmd:"/usr/bin/curl", args: header () + [
  "-L",
  "https://api.github.com/repos/pierremolinaro/ElCanari-distribution/branches/master",
  "-o", masterJsonFilePath
])
let masterDictionary = loadJsonFile (filePath: masterJsonFilePath)
//print ("masterDictionary : \(masterDictionary)")
let commitDict = get (masterDictionary, "commit", #line)
let masterSHA = getString (commitDict, "sha", #line)
print (BOLD_BLUE + "SHA master " + masterSHA + ENDC)
//-------------------- Download the Json file of all files of the master branch
let fileDescriptionJsonFilePath = temporaryDir + "/files.json"
runCommand (cmd:"/usr/bin/curl", args: header () + [
  "-L",
  "https://api.github.com/repos/pierremolinaro/ElCanari-distribution/git/trees/" + masterSHA,
  "-o", fileDescriptionJsonFilePath
])
let fileDictionary = loadJsonFile (filePath: fileDescriptionJsonFilePath)
//--- Get sorted list of releases
let listOfFileDictionaries = get (fileDictionary, "tree", #line)
//print ("listOfFileDictionaries : \(listOfFileDictionaries)")
let (releases, releaseSizeDict) = getListOfReleases (listOfFileDictionaries, #line)
let sortedReleases = releases.sorted (by: {
  ($0.0 > $1.0) || (($0.0 == $1.0) && ($0.1 > $1.1)) || (($0.0 == $1.0) && ($0.1 == $1.1) && ($0.2 > $1.2))
} )
print (sortedReleases)
//-------------------- Construire le fichier xml - rss
let channel = XMLElement (name: "channel")
channel.addChild (XMLElement(name: "title", stringValue:"ElCanari Changelog"))
channel.addChild (XMLElement(name: "description", stringValue:"Most recent changes with links to updates"))
channel.addChild (XMLElement(name: "language", stringValue:"en"))
for (major, minor, patch, kind) in sortedReleases {
  let version = "\(major).\(minor).\(patch)"
  let item = XMLElement (name: "item")
  item.addChild (XMLElement(name: "title", stringValue:"Version \(version)"))
  item.addChild (XMLElement(name: "sparkle:minimumSystemVersion", stringValue:"10.9"))
//--- Find infos of last commit of the file
  let commitJSON = temporaryDir + "/app-" + version + ".json"
//  switch kind {
//  case .bz2 :
//    runCommand (cmd:"/usr/bin/curl", args:header () + [
//      "-L",
//      "https://api.github.com/repos/pierremolinaro/ElCanari-distribution/commits?path=ElCanari.app.\(version).tar.bz2",
//      "-o", commitJSON
//    ])
//  case .pkg :
    runCommand (cmd:"/usr/bin/curl", args:header () + [
      "-L",
      "https://api.github.com/repos/pierremolinaro/ElCanari-distribution/commits?path=ElCanari-\(version).dmg",
      "-o", commitJSON
    ])
//  }
  let commit = loadJsonFile (filePath: commitJSON)
  // print ("commit \(commit)")
  let lastCommitDict = (commit as! [NSDictionary]) [0]
  let lastCommit = get (lastCommitDict, "commit", #line)
  let lastCommitAuthor = get (lastCommit, "committer", #line)
  let lastCommitDate : String = getString (lastCommitAuthor, "date", #line)
  item.addChild (XMLElement(name: "pubDate", stringValue:lastCommitDate))
//--- Find infos of last commit of the file
  let infoJSON = temporaryDir + "/info-" + version + ".json"
  runCommand (cmd:"/usr/bin/curl", args: header () + [
    "-L",
    "https://raw.githubusercontent.com/pierremolinaro/ElCanari-distribution/master/ElCanari.app.\(version).json",
    "-o", infoJSON
  ])
  let infos = loadJsonFile (filePath: infoJSON)
//--- sparkle:releaseNotesLink
  item.addChild (XMLElement (name: "sparkle:releaseNotesLink", stringValue: changeLogURL))
//--- enclosure
  // print ("-- ENCLOSURE --")
  let enclosure = XMLElement (name: "enclosure")
//  let url : String
//  switch kind {
//  case .bz2 :
//    url = "https://raw.githubusercontent.com/pierremolinaro/ElCanari-distribution/master/ElCanari.app.\(version).tar.bz2"
//  case .pkg :
    url = "https://raw.githubusercontent.com/pierremolinaro/ElCanari-distribution/master/ElCanari-\(version).dmg"
//  }
  enclosure.addAttribute (XMLNode.attribute (withName: "url", stringValue:url) as! XMLNode)
  enclosure.addAttribute (XMLNode.attribute (withName: "type", stringValue:"application/octet-stream") as! XMLNode)
  let archiveSum = getString (infos, "archive-sum", #line)
  enclosure.addAttribute (XMLNode.attribute (withName: "sparkle:dsaSignature", stringValue:archiveSum) as! XMLNode)
  enclosure.addAttribute (XMLNode.attribute (withName: "sparkle:version", stringValue:version) as! XMLNode)
  let fileSize = releaseSizeDict [version]!
  enclosure.addAttribute (XMLNode.attribute (withName: "length", stringValue:"\(fileSize)") as! XMLNode)
  item.addChild (enclosure)
//---
  channel.addChild (item)
//--- Release notes
  let buildString = getString (infos, "build", #line)
  releaseNotesHTML += "\n  <p>\n    <span class=\"version-title\">Version \(version) (build \(buildString))</span>\n  </p>\n"
  let infoHTMLString = analyzeInfos (infos)
  releaseNotesHTML += infoHTMLString
}
let rss = XMLElement (name: "rss")
rss.addChild (channel)
rss.addAttribute (XMLNode.attribute (withName: "version", stringValue: "2.0") as! XMLNode)
rss.addAttribute (XMLNode.attribute (withName: "xmlns:sparkle", stringValue: "http://www.andymatuschak.org/xml-namespaces/sparkle") as! XMLNode)
rss.addAttribute (XMLNode.attribute (withName: "xmlns:dc", stringValue: "http://purl.org/dc/elements/1.1/") as! XMLNode)
let xml = XMLDocument (rootElement: rss)
xml.version = "1.0"
xml.characterEncoding = "utf-8"
print (xml.xmlString (options: [.nodePrettyPrint]))
//print (xml.xmlString)
let data = xml.xmlData (options: [.nodePrettyPrint])
do{
  try data.write (to: scriptDir.appendingPathComponent ("rss.xml"))
}catch let error {
  print (BOLD_RED + "Error \(error) writing rss.xml file" + ENDC)
  exit (1)
}
//--- Terminer le fichier release-notes.html
releaseNotesHTML +=  "  </body>\n"
releaseNotesHTML +=  "</html>\n"
if let releaseNotesData = releaseNotesHTML.data (using: .utf8) {
  do{
    try releaseNotesData.write (to: scriptDir.appendingPathComponent ("docs/release-notes.html"))
  }catch let error {
    print (BOLD_RED + "Error \(error) writing docs/release-notes.html file" + ENDC)
    exit (1)
  }
}else{
  print (BOLD_RED + "Release notes source is not an UTF-8 string" + ENDC)
  exit (1)
}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
