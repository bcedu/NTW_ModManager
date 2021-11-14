# Mod Manager for Napoleon Total War


## Installation

### .deb package


Download the -deb file attached to the last release and install it as any .deb package


### Manual Instalation

You will need the following packages, that can be installed through apt:
- gobject-2.0
- glib-2.0
- gtk+-3.0
- gee-0.8

Download last release (zip file), extract files and enter to the folder where they where extracted.

Install your application with the following commands:
- meson build --prefix=/usr
- cd build
- ninja
- sudo ninja install

DO NOT DELETE FILES AFTER MANUAL INSTALLATION, THEY ARE NEEDED DURING UNINSTALL PROCESS

To uninstall type from de build folder:
- sudo ninja uninstall

