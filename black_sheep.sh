#!/bin/bash


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
