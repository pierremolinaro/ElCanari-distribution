#! /usr/bin/swift

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   FOR PRINTING IN COLOR
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let BLACK   = "\u{001B}[0;30m"
let RED     = "\u{001B}[0;31m" // "\033[91m"
let GREEN   = "\u{001B}[0;32m" // "\033[92m"
let YELLOW  = "\u{001B}[0;33m"
let BLUE    = "\u{001B}[0;34m" // "\033[94m"
let MAGENTA = "\u{001B}[0;35m" // "\033[95m"
let CYAN    = "\u{001B}[0;36m" // "\033[95m"
let ENDC = "\u{001B}[0;0m" // "\033[0m"
let BOLD = "\u{001B}[0;1m" // "\033[1m"
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

func getListOfReleases (_ listOfFileDictionaries : Any, _ line : Int) -> ([(Int, Int, Int)], [String : Int]) {
  if let array = listOfFileDictionaries as? [NSDictionary] {
    var result = ([(Int, Int, Int)] (), [String : Int] ())
    for entry in array {
      let name = getString (entry, "path", #line)
      let nameElements = name.components (separatedBy: ".")
      if (nameElements.count == 7) && (nameElements [0] == "ElCanari") && (nameElements [1] == "app")
                                   && (nameElements [5] == "tar") && (nameElements [6] == "bz2") {
        if let major = Int (nameElements [2]), let minor = Int (nameElements [3]), let patch = Int (nameElements [4]) {
          let size = getInt (entry, "size", #line)
          result.0.append ((major, minor, patch))
          result.1 ["\(major).\(minor).\(patch)"] = size
        }
      }
    }
    return result
  }else{
    print (RED + "line \(line) : object is not an array of dictionaries" + ENDC)
    exit (1)
  }
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
runCommand (cmd:"/usr/bin/curl", args: [
  "-L",
  "https://api.github.com/repos/pierremolinaro/ElCanari-distribution/branches/master",
  "-o", masterJsonFilePath
])
let masterDictionary = loadJsonFile (filePath: masterJsonFilePath)
//print (masterDictionary)
let commitDict = get (masterDictionary, "commit", #line)
let masterSHA = getString (commitDict, "sha", #line)
print (BOLD_BLUE + "SHA master " + masterSHA + ENDC)
//-------------------- Download the Json file of all files of the master branch
let fileDescriptionJsonFilePath = temporaryDir + "/files.json"
runCommand (cmd:"/usr/bin/curl", args: [
  "-L",
  "https://api.github.com/repos/pierremolinaro/ElCanari-distribution/git/trees/" + masterSHA,
  "-o", fileDescriptionJsonFilePath
])
let fileDictionary = loadJsonFile (filePath: fileDescriptionJsonFilePath)
//--- Get sorted list of releases
let listOfFileDictionaries = get (fileDictionary, "tree", #line)
//print (listOfFileDictionaries)
let (releases, releaseSizeDict) = getListOfReleases (listOfFileDictionaries, #line)
let sortedReleases = releases.sorted (by: {
  ($0.0 > $1.0) || (($0.0 == $1.0) && ($0.1 > $1.1)) || (($0.0 == $1.0) && ($0.1 == $1.1) && ($0.2 > $1.2))
} )
print (sortedReleases)
//-------------------- Download versions.json from repository
//versionJsonFilePath = temporaryDir + "/versions.json"
//runCommand (["curl", "-L",
//             "https://raw.githubusercontent.com/pierremolinaro/ElCanari-distribution/master/versions.json",
//             "-o", versionJsonFilePath])
//-------------------- Construire le fichier xml - rss
let channel = XMLElement (name: "channel")
channel.addChild (XMLElement(name: "title", stringValue:"ElCanari Changelog"))
channel.addChild (XMLElement(name: "description", stringValue:"Most recent changes with links to updates"))
channel.addChild (XMLElement(name: "language", stringValue:"en"))
for (major, minor, patch) in sortedReleases {
  let version = "\(major).\(minor).\(patch)"
  let item = XMLElement (name: "item")
  item.addChild (XMLElement(name: "title", stringValue:"Version \(version)"))
  item.addChild (XMLElement(name: "sparkle:minimumSystemVersion", stringValue:"10.11"))
//--- Find infos of last commit of the file
  let commitJSON = temporaryDir + "/" + version + ".json"
  runCommand (cmd:"/usr/bin/curl", args: [
    "-L",
    "https://api.github.com/repos/pierremolinaro/ElCanari-distribution/commits?path=ElCanari.app.\(version).tar.bz2",
    "-o", commitJSON
  ])
  let commit = loadJsonFile (filePath: commitJSON)
  // print ("\(commit)")
  let lastCommitDict = (commit as! [NSDictionary]) [0]
  let lastCommit = get (lastCommitDict, "commit", #line)
  let lastCommitAuthor = get (lastCommit, "committer", #line)
  let lastCommitDate : String = getString (lastCommitAuthor, "date", #line)
  item.addChild (XMLElement(name: "pubDate", stringValue:lastCommitDate))
//---
  let enclosure = XMLElement (name: "enclosure")
  let url = "https://raw.githubusercontent.com/pierremolinaro/ElCanari-distribution/master/ElCanari.app.\(version).tar.bz2"
  enclosure.addAttribute (XMLNode.attribute (withName: "url", stringValue:url) as! XMLNode)
  enclosure.addAttribute (XMLNode.attribute (withName: "type", stringValue:"application/octet-stream") as! XMLNode)
  let fileSize = releaseSizeDict [version]!
  enclosure.addAttribute (XMLNode.attribute (withName: "length", stringValue:"\(fileSize)") as! XMLNode)
  item.addChild (enclosure)
//---
  channel.addChild (item)
}
let rss = XMLElement (name: "rss")
rss.addChild (channel)
rss.addAttribute (XMLNode.attribute (withName: "version", stringValue: "2.0") as! XMLNode)
rss.addAttribute (XMLNode.attribute (withName: "xmlns:sparkle", stringValue: "http://www.andymatuschak.org/xml-namespaces/sparkle") as! XMLNode)
rss.addAttribute (XMLNode.attribute (withName: "xmlns:dc", stringValue: "http://purl.org/dc/elements/1.1/") as! XMLNode)
let xml = XMLDocument (rootElement: rss)
xml.version = "1.0"
xml.characterEncoding = "utf-8"
print (xml.xmlString (withOptions:Int(XMLNode.Options.nodePrettyPrint.rawValue)))
//print (xml.xmlString)
let data = xml.xmlData (withOptions:Int(XMLNode.Options.nodePrettyPrint.rawValue)) // as NSData
do{
  try data.write (to: scriptDir.appendingPathComponent ("rss.xml"))
}catch let error {
  print (BOLD_RED + "Error \(error) writing rss.xml file" + ENDC)
  exit (1)
}
//versionDictionary = loadJsonFile (versionJsonFilePath)
//xmlString  = '<?xml version="1.0" encoding="utf-8"?>\n'
//xmlString += '<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"'
//xmlString += ' xmlns:dc="http://purl.org/dc/elements/1.1/">\n'
//xmlString += '  <channel>\n'
//xmlString += '    <title>ElCanari Changelog</title>\n'
//xmlString += '    <description>Most recent changes with links to updates.</description>\n'
//xmlString += '    <language>en</language>\n'
//for entry in versionDictionary:
//  version = entry ["VERSION"]
//  print (BOLD_BLUE + version + ENDC)
//  xmlString += '    <item>\n'
//  xmlString += '      <sparkle:minimumSystemVersion>10.11</sparkle:minimumSystemVersion>\n'
//  xmlString += '      <title>Version ' + version + '</title>\n'
//--- Find date of last commit of the file
//  commitJSON = temporaryDir + "/" + version + ".json"
//  runCommand (["curl", "-L",
//               "https://api.github.com/repos/pierremolinaro/ElCanari-distribution/commits?path=ElCanari.app." + version + ".tar.bz2",
//               "-o", commitJSON])
//  commitDictionary = loadJsonFile (commitJSON)
//  lastCommitDict = commitDictionary [0]
//  lastCommit = lastCommitDict ["commit"]
//  lastCommitAuthor = lastCommit ["committer"]
//  lastCommitDate = lastCommitAuthor ["date"]
//  print ("  Last commit date " + lastCommitDate)
//  xmlString += '      <pubDate>' + lastCommitDate + '</pubDate>\n'
//---
//  resultDictionary = findDictionaryForVersion (listOfFileDictionaries, version)
//  size = str (resultDictionary ["size"])
//  print ("  size " + size + " bytes")
//  url = "https://raw.githubusercontent.com/pierremolinaro/ElCanari-distribution/master/ElCanari.app." + version + ".tar.bz2"
//  print ("  File URL " + url)
//  xmlString += '      <enclosure url="' + url + '" sparkle:version="' + version + '" length="' + size + '" type="application/octet-stream" />\n'
//  xmlString += '    </item>\n'
//xmlString += '  </channel>\n'
//xmlString += '</rss>\n'
//f = open (scriptDir + "/rss.xml", "w")
//f.write (xmlString)
//f.close ()

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
