#!/bin/bash


function desktop {

    # Cambiar el fondo por defecto
    cp ./conf/usr/share/backgrounds/blacksheep.png /usr/share/backgrounds/blacksheep.png
    cp ./conf/usr/share/gnome-background-properties/ubuntu-wallpapers.xml /usr/share/gnome-background-properties/ubuntu-wallpapers.xml
    gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/blacksheep.png

    # Establecer la página de la escuela
    apt-get remove xul-ext-ubufox
    cp ./conf/usr/lib/firefox/defaults/preferences/all-itcr.js /usr/lib/firefox/defaults/preferences/all-itcr.js
    cp ./conf/etc/firefox/itcr.properties /etc/firefox/itcr.properties
}

function hostname {

    # Cambia el hostname
    cp ./conf/etc/hostname /etc/hostname

    # Cambia el archivo de hosts
    cp ./conf/etc/hosts /etc/hosts

    # Instala el script de cambio de nombre de estacion
    cp ./conf/sbin/changehostname /sbin/changehostname

    # Nota: Correr como root el siguiente comando en cada una de las estaciones:
    # /sbin/changehostname cic01
}

function clean {

    # Elimina el cache de paquetes
    rm /var/cache/apt/archives/*

    # Elimina el archivo de MAC Address
    rm /etc/udev/rules.d/70-persistent-net.rules
}
