#!/bin/bash

INSTALL='sudo install --owner=root --group=root --mode=644'

# Check for permissions errors
if [ `id -u` == 0 ]; then
    echo "[ERROR] Este script no debe ser ejecutado como root. Debe ser ejecutado como usuario sudoer."
    exit 1
fi

function depends {
    # Dependencias para ejecutar este script
    sudo apt-get install devscripts gdebi
}

function repos {
    # Skype
    sudo sh -c 'echo "deb http://archive.canonical.com/ $(lsb_release -sc) partner" >> /etc/apt/sources.list.d/skype.list'

    # VirtualBox
    wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
    sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" >> /etc/apt/sources.list.d/virtualbox.list'

    # Google Talk Plugin
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb http://dl.google.com/linux/talkplugin/deb/ stable main" >> /etc/apt/sources.list.d/google.list'

    # Dropbox
    sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 5044912E
    sudo sh -c 'echo "deb http://linux.dropbox.com/ubuntu $(lsb_release -sc) main" >> /etc/apt/sources.list.d/dropbox.list'

    # Gummi
    sudo add-apt-repository ppa:gummi/gummi

    # Cinnamon
    sudo add-apt-repository ppa:gwendal-lebihan-dev/cinnamon-nightly

    sudo apt-get update
}

function packages {
    # Instalar todos los paquetes de Black Sheep
    ./package_builder build
    sudo gdebi --n `./package_builder version`

    # Instalar aplicaciones al inicio
    $INSTALL ./conf/etc/xdg/autostart/*.desktop /etc/xdg/autostart/
}

function updates {
    # Desactiva actualizaciones
    sudo apt-get remove update-notifier
    $INSTALL ./conf/etc/apt/apt.conf.d/10periodic /etc/apt/apt.conf.d/10periodic
}

function environments {
    sudo apt-get install cinnamon
}

function ldap {

    # Instalación de paquetes para autenticar vía LDAP
    # FIXME

    # Configurar LigthDM para ingreso vía LDAP
    sudo cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.original
    $INSTALL ./conf/etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf
}

function branding {

    # Elimina las barras overlay de Ubuntu
    sudo apt-get remove overlay-scrollbar*

    # Establecer la página de la escuela
    sudo apt-get remove xul-ext-ubufox
    $INSTALL ./conf/usr/lib/firefox/defaults/preferences/all-itcr.js /usr/lib/firefox/defaults/preferences/all-itcr.js
    $INSTALL ./conf/etc/firefox/itcr.properties /etc/firefox/itcr.properties

    # Adaptar el escritorio
    $INSTALL ./conf/usr/share/backgrounds/blacksheep.png /usr/share/backgrounds/blacksheep.png
    $INSTALL ./conf/usr/share/gnome-background-properties/blacksheep-wallpapers.xml /usr/share/gnome-background-properties/blacksheep-wallpapers.xml
    $INSTALL ./conf/usr/share/glib-2.0/schemas/20_blacksheep_settings.gschema.override /usr/share/glib-2.0/schemas/20_blacksheep_settings.gschema.gschema.override
    glib-compile-schemas /usr/share/glib-2.0/schemas

    # Cambiar fondo de LigthDM
    sudo xhost +SI:localuser:lightdm
    sudo sudo -u lightdm gsettings set com.canonical.unity-greeter draw-user-backgrounds 'false'
    sudo sudo -u lightdm gsettings set com.canonical.unity-greeter background '/usr/share/backgrounds/blacksheep.png'

    # Cambiar el splash screen
    sudo cp -R ./conf/lib/plymouth/themes/blacksheep /lib/plymouth/themes/
    sudo update-alternatives --install /lib/plymouth/themes/default.plymouth default.plymouth /lib/plymouth/themes/blacksheep/blacksheep.plymouth 100
    sudo update-alternatives --set default.plymouth /lib/plymouth/themes/blacksheep/blacksheep.plymouth
    sudo update-initramfs -u

    # Eliminar las configuraciones actuales del usuario
    rm ~/.config/dconf/user
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

#packages
#environments
#branding
#ldap
#hostname
#clean
