#! /usr/bin/env python
# -*- coding: UTF-8 -*-

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

import shutil, os, sys, subprocess, datetime, time, json, tempfile
import xml.etree.ElementTree as ET
from xml.dom import minidom

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*
#   FOR PRINTING IN COLOR                                                                                              *
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

MAGENTA = '\033[95m'
BLUE = '\033[94m'
GREEN = '\033[92m'
RED = '\033[91m'
ENDC = '\033[0m'
BOLD = '\033[1m'
UNDERLINE = '\033[4m'
BOLD_MAGENTA = BOLD + MAGENTA
BOLD_BLUE = BOLD + BLUE
BOLD_GREEN = BOLD + GREEN
BOLD_RED = BOLD + RED

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*
#   runCommand                                                                                                         *
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

def runCommand (cmd) :
  str = "+"
  for s in cmd:
    str += " " + s
  print BOLD_MAGENTA + str + ENDC
  childProcess = subprocess.Popen (cmd)
  childProcess.wait ()
  if childProcess.returncode != 0 :
    sys.exit (childProcess.returncode)

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*
#   runHiddenCommand                                                                                                   *
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

def runHiddenCommand (cmd) :
  str = "+"
  for s in cmd:
    str += " " + s
  print (BOLD_MAGENTA + str + ENDC)
  result = ""
  compteur = 0
  childProcess = subprocess.Popen (cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  while True:
    line = childProcess.stdout.readline ()
    if line != "":
      compteur = compteur + 1
      result += line
      if compteur == 10:
        compteur = 0
        sys.stdout.write (".") # Print without newline
    else:
      print ""
      childProcess.wait ()
      if childProcess.returncode != 0 :
        # print (BOLD_RED + "*** Error " + str (childProcess.returncode) + " ***" + ENDC)
        sys.exit (childProcess.returncode)
      return result

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*
#   dictionaryFromJsonFile                                                                                             *
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

def dictionaryFromJsonFile (file) :
  result = {}
  if not os.path.exists (os.path.abspath (file)):
    print (BOLD_RED + "The '" + file + "' file does not exist" + ENDC)
    sys.exit (1)
  try:
    f = open (file, "r")
    result = json.loads (f.read ())
    f.close ()
  except:
    print (BOLD_RED + "Syntax error in " + file + ENDC)
    sys.exit (1)
  return result

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

def findDictionaryForVersion (listOfFileDictionaries, version) :
  resultDictionary = {}
  archiveName = "ElCanari.app." + version + ".tar.bz2"
  print ("archiveName " + archiveName)
  for entry in listOfFileDictionaries :
    print ("PATH " + entry ["path"])
    if entry ["path"] == archiveName:
      resultDictionary = entry
      break
  return resultDictionary

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

#-------------------- Get script absolute path
scriptDir = os.path.dirname (os.path.abspath (sys.argv [0]))
#-------------------- Make temporary directory
temporaryDir = tempfile.mkdtemp ()
#-------------------- Download the Json file of master branch
masterJsonFilePath = temporaryDir + "/master.json"
runCommand (["curl", "-L",
             "https://api.github.com/repos/pierremolinaro/ElCanari-distribution/branches/master",
             "-o", masterJsonFilePath])
masterDictionary = dictionaryFromJsonFile (masterJsonFilePath)
commitDict = masterDictionary ["commit"]
masterSHA = commitDict ["sha"]
print (BOLD_BLUE + "SHA master " + masterSHA + ENDC)
#-------------------- Download the Json file of all files of the master branch
fileDescriptionJsonFilePath = temporaryDir + "/files.json"
runCommand (["curl", "-L",
             "https://api.github.com/repos/pierremolinaro/ElCanari-distribution/git/trees/" + masterSHA,
             "-o", fileDescriptionJsonFilePath])
fileDictionary = dictionaryFromJsonFile (fileDescriptionJsonFilePath)
listOfFileDictionaries = fileDictionary ["tree"]
#-------------------- Download versions.json from repository
versionJsonFilePath = temporaryDir + "/versions.json"
runCommand (["curl", "-L",
             "https://raw.githubusercontent.com/pierremolinaro/ElCanari-distribution/master/versions.json",
             "-o", versionJsonFilePath])
#-------------------- Construire le fichier xml - rss
versionDictionary = dictionaryFromJsonFile (versionJsonFilePath)
xmlString  = '<?xml version="1.0" encoding="utf-8"?>\n'
xmlString += '<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"'
xmlString += ' xmlns:dc="http://purl.org/dc/elements/1.1/">\n'
xmlString += '  <channel>\n'
xmlString += '    <title>ElCanari Changelog</title>\n'
xmlString += '    <description>Most recent changes with links to updates.</description>\n'
xmlString += '    <language>en</language>\n'
for entry in versionDictionary:
  version = entry ["VERSION"]
  xmlString += '    <item>\n'
  xmlString += '      <title>Version ' + version + '</title>\n'
  xmlString += '      <sparkle:minimumSystemVersion>10.11</sparkle:minimumSystemVersion>\n'
  resultDictionary = findDictionaryForVersion (listOfFileDictionaries, version)
  print ("Version " + version + ", length " + str (resultDictionary ["size"]))
  xmlString += '    </item>\n'
xmlString += '  </channel>\n'
xmlString += '</rss>\n'
f = open (scriptDir + "/rss.xml", "w")
f.write (xmlString)
f.close ()

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*
