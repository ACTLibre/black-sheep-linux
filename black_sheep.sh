#!/bin/bash

INSTALL='sudo install --owner=root --group=root --mode=644'

# Check for permissions errors
if [ `id -u` == 0 ]; then
    echo "[ERROR] Este script no debe ser ejecutado como root."
    exit 1
fi



function desktop {

    # Cambiar el fondo por defecto
    $INSTALL ./conf/usr/share/backgrounds/blacksheep.png /usr/share/backgrounds/blacksheep.png
    $INSTALL ./conf/usr/share/gnome-background-properties/ubuntu-wallpapers.xml /usr/share/gnome-background-properties/ubuntu-wallpapers.xml
    gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/blacksheep.png
    # Nota configuraciones dconf en : ~/.config/dconf/user

    # Establecer la página de la escuela
    sudo apt-get remove xul-ext-ubufox
    $INSTALL ./conf/usr/lib/firefox/defaults/preferences/all-itcr.js /usr/lib/firefox/defaults/preferences/all-itcr.js
    $INSTALL ./conf/etc/firefox/itcr.properties /etc/firefox/itcr.properties

    # Cambiar fondo de LigthDM
    sudo xhost +SI:localuser:lightdm
    sudo sudo -u lightdm gsettings set com.canonical.unity-greeter draw-user-backgrounds 'false'
    sudo sudo -u lightdm gsettings set com.canonical.unity-greeter background '/usr/share/backgrounds/blacksheep.png'
}

function hostname {

    # Cambia el hostname
    $INSTALL ./conf/etc/hostname /etc/hostname

    # Cambia el archivo de hosts
    $INSTALL ./conf/etc/hosts /etc/hosts

    # Instala el script de cambio de nombre de estacion
    $INSTALL ./conf/sbin/changehostname /sbin/changehostname
    sudo chmod 755 /sbin/changehostname

    # Nota: Correr como root el siguiente comando en cada una de las estaciones:
    # /sbin/changehostname cic01
}

function clean {

    # Elimina el cache de paquetes
    sudo rm /var/cache/apt/archives/*

    # Elimina el archivo de MAC Address
    sudo rm /etc/udev/rules.d/70-persistent-net.rules
}
