#! /usr/bin/env python
# -*- coding: UTF-8 -*-

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

import shutil, os, sys, subprocess, datetime, plistlib, urllib, time, json
import xml.etree.ElementTree as ET
from xml.dom import minidom

#-------------------- Version ElCanari
VERSION_CANARI = "0.3.0"

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

#--- Get script absolute path
scriptDir = os.path.dirname (os.path.abspath (sys.argv [0]))
#-------------------- Supprimer une distribution existante
TEMP_DIR = scriptDir + "/../DISTRIBUTION_EL_CANARI_" + VERSION_CANARI
os.chdir (scriptDir + "/..")
while os.path.isdir (TEMP_DIR):
  shutil.rmtree (TEMP_DIR)
#-------------------- Creer le repertoire contenant la distribution
os.mkdir (TEMP_DIR)
os.chdir (TEMP_DIR)
#-------------------- Construire le fichier xml - rss
versionDictionary = dictionaryFromJsonFile (scriptDir + "/versions.json")
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
  xmlString += '    </item>\n'
xmlString += '  </channel>\n'
xmlString += '</rss>\n'
f = open (scriptDir + "/rss.xml", "w")
f.write (xmlString)
f.close ()
#-------------------- Vérifier si l'application est signée
# runCommand (["xattr", "-r", "-d", "com.apple.quarantine", "ElCanari.app])
# runCommand (["spctl", "-a", "-vv", "ElCanari.app"])
#-------------------- Créer l'archive de Cocoa canari
nomArchive = "ElCanari-" + VERSION_CANARI
runCommand (["mkdir", nomArchive])
runCommand (["mv", "ElCanari.app", nomArchive + "/ElCanari.app"])
runCommand (["ln", "-s", "/Applications", nomArchive + "/Applications"])
runCommand (["hdiutil", "create", "-srcfolder", nomArchive, nomArchive + ".dmg"])
runCommand (["mv", nomArchive + ".dmg", "../" + nomArchive + ".dmg"])
#--- Supprimer les répertoires intermédiaires
while os.path.isdir (TEMP_DIR + "/COCOA-CANARI"):
  shutil.rmtree (TEMP_DIR + "/COCOA-CANARI")
while os.path.isdir (TEMP_DIR + "/ElCanari-dev-master"):
  shutil.rmtree (TEMP_DIR + "/ElCanari-dev-master")

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*
