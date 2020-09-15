## **ElCanari**

ElCanari is a free software, distributed under MIT license, for making printed circuit boards.

It is written in Swift and runs only on OSX from ElCapitan (10.11).

**ElCanari is currently on development.** 


ElCanari is an application that can edit seven types of documents:

- symbol (*ElCanariSymbol*): element of schematics, for example *and2* is an 2-input and gate;
- package (*ElCanariPackage*): defines the geometrical characteristic of the pins of a package, as well as the drawing appearing on the screen printing: for example, the library defines the DIL14, TO92, packages;
- device (*ElCanariDevice*): a device groups symbols and packages, and assigns the pins of the packages to the symbol signals; for example,, the component *7400* imports the *DIL14* package, four *nand2* symbols and one *vcc-gnd* symbol (for power) and defines the correspondence between the pins of the package and the symbol signals; it can also contain illustrative images and documentation in PDF format;
- font (*ElCanariFont*): the OSX fonts are not suited to texts of a printed circuit board, this type of document allows you to create your own fonts; 
- artwork (*ElCanariArtwork*): an artwork document defines all the production constraints of a printed circuit board manufacturer;
- project (*ElCanariProject*), that combines the definition of the schematic and the printed circuit board: to do this, it imports components, fonts and an artwork;
- merger (*ElCanariMerger*), that combines several boards to one board.

