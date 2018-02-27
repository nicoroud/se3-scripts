#!/bin/bash

#Version 0.2 du 15 février 2013.

#Crée par Samuel GONZALES - samuel.gonzales@ac-strasbourg.fr

clear
#Couleurs
COLTITRE="\033[1;35m"   # Rose
COLPARTIE="\033[1;34m"  # Bleu

COLTXT="\033[0;37m"     # Gris
COLCHOIX="\033[1;33m"   # Jaune
COLDEFAUT="\033[0;33m"  # Brun-jaune
COLSAISIE="\033[1;32m"  # Vert

COLCMD="\033[1;37m"     # Blanc

COLERREUR="\033[1;31m"  # Rouge
COLINFO="\033[0;36m"    # Cyan
DEPTIME=$(date "+%s")
NOMTAR="SauvegardeSE3-$(date +%Y%m%d).tar.gz"
SAVEDIR="/var/se3/save/$(date +%Y-%m-%d)"
if [ ! -d $SAVEDIR ]
then
	mkdir -p $SAVEDIR
	echo "Création du répertoire de sauvegarde $SAVEDIR"
else
	echo "Le répertoire existe déjà."
fi
echo -e "$COLTITRE"
cat  <<EOF


*****************************************************************
*								*
*		Sauvegarde des paramètres SE3 			*
*	      avant de migrer vers un nouveau serveur.		*
*								*
*****************************************************************

Pour exécuter proprement ce script votre serveur doit être migré en version squeeze ou wheezy.

Ce script permet de sauvegarder les paramètres de votre serveur puis de les exporter vers un support USB formaté en NTFS ou EXT.

ATTENTION : il faut stopper la sauvegarde et démonter le support de sauvegarde!!


EOF
ETAPE=1
echo -e $COLPARTIE
echo "Appuyez sur ENTREE pour continuer." && read

echo -e "Etape $ETAPE : test de version!"
VERSION=$(cut -c1 /etc/debian_version)
if [ $VERSION = "5" ] #Teste le numéro de version 5 = lenny 6 = squeeze 7 = wheezy
then
	echo "Erreur : migrez votre serveur en squeeze avant de lancer la procédure. Le script s'arrète."
	exit 1
else
echo
echo "Vous avez la bonne version, le script continue."
echo
#
#Annuaire LDAP
#

let ETAPE++
echo -e "Etape $ETAPE : sauvegarde de l'annuaire ldap.\n"
slapcat > $SAVEDIR/sauve_annu.ldif
echo -e "$COLTXT Annuaire sauvegardé dans $SAVEDIR/sauve_annu.ldif !\n"
sleep 2

#
#Sauvegarde du setup_se3 s'il existe!
#

let ETAPE++
echo -e $COLPARTIE
echo -e "Etape $ETAPE : sauvegarde du setup_se3.data (s'il existe)\n"
echo -e "$COLTXT"
if [ -e "/etc/se3/setup_se3.data" ]
then 
	echo "Le fichier setup_se3.data existe."
	cp -f /etc/se3/setup_se3.data $SAVEDIR/setup_se3.data
	echo -e "Sauvegarde effectuée!\n\n"
else
	echo -e "Le fichier n'existe pas il ne sera pas sauvegardé.\n\n"
fi
echo -e "Appuyez sur ENTREE pour continuer.\n\n" && read
#
#Sauvegarde de samba
#
let ETAPE++
echo -e $COLPARTIE
echo -e "Etape $ETAPE : sauvegarde des paramètres samba"
echo -e "$COLTXT"
if [ -e "/var/lib/samba/secrets.tdb" ]
then 
        echo "Le fichier existe."
        cp  /var/lib/samba/secrets.tdb "$SAVEDIR"/secrets.tdb
        echo -e "Sauvegarde effectuée.\n\n"
else
        echo -e "Le fichier n'existe pas il faut sauvegarder le SID autrement.\n\n"
fi
# sauvegarde des partages personnalisés /etc/samba/smb_etab*
    echo "Synchronisation de /etc/samba dans $SAVEDIR"
    rsync -av --del --ignore-errors --force /etc/samba/smb_* $SAVEDIR/etcsamba/ > /root/logrsyncsamba.txt
echo -e "Appuyez sur ENTREE pour continuer.\n\n" && read
#
#Leases du dhcp - pas obligatoire car ils sont dans la base se donnée se3db
#
let ETAPE++
echo -e $COLPARTIE
echo -e "Etape $ETAPE : sauvegarde de /etc/dhcp/dhcpd.conf qui contient les reservations des baux dhcp."
echo -e "$COLTXT"
cp /etc/dhcp/dhcpd.conf "$SAVEDIR"/dhcpd.conf
echo -e "Sauvegarde effectuée!\n"
echo -e "Appuyez sur ENTREE pour continuer.\n\n" && read
#
#Sauvegarde de la base de donnée
#
let ETAPE++
echo -e $COLPARTIE
echo -e "Etape $ETAPE : sauvegarde de la base se3db existante."
echo -e "$COLTXT"
mysqldump se3db > $SAVEDIR/se3db.dump || ( echo "La base se3db n'a pas été exportée. C'est une erreur fatale!" && exit 1  )
echo -e "Sauvegarde de la base se3db existante! Appuyez sur ENTREE pour continuer.\n\n" && read
#
#Sauvergarde des imprimantes
#
let ETAPE++
echo -e $COLPARTIE
echo -e "Etape $ETAPE : les imprimantes."
echo -e "$COLTXT"
    # synchro des drivers imprimantes
    echo "synchronisation des pilotes d'imprimantes dans $SAVEDIR" 
    rsync -av --del --ignore-errors --force /var/lib/samba/printers/ $SAVEDIR/varlibsambaprinters/ > /root/logrsyncprinters.txt
    # archivage des fichiers de configuration des imprimantes
    IMPR=`ls /etc/cups/ | grep printers.`
    if [ -z "$IMPR" ]
    then
        echo "" 
        echo "Attention : il n'y a pas de fichier /etc/cups/printers.*"
        echo "" 
    else
        echo "archivage de fichiers de configuration des imprimantes dans $SAVEDIR" 
        cd /etc/cups > /dev/null
        tar -cz printers.* > $SAVEDIR/printers.tgz
        cd - > /dev/null
    fi

#
#Récupération des données pour la configuration à l'identique du nouveau serveur
#
let ETAPE++
echo -e $COLPARTIE
echo -e "Etape $ETAPE : récupération des données de configuration."
echo -e "$COLTXT"
./0-cree_se3data.sh 
./1-recup_se3data.sh > $SAVEDIR/se3data.txt

echo -e "Données de configuration du nouveau serveur disponible dans le fichier se3data.txt"
echo -e "Les fichiers sont disponibles dans le dossier $SAVEDIR qui a pour contenu\n$(ls $SAVEDIR)\n"
ENDTIME=$(date "+%s")
DELTATIME=$((ENDTIME-DEPTIME))
case $DELTATIME in
        1) echo "Sauvegarde complétée en 1 seconde.";;
        0) echo "Sauvegarde complétée en moins d'1 seconde.";;
        *) echo "Sauvegarde complétée en $DELTATIME secondes!";;
esac
echo "Appuyez sur ENTREE pour continuer." && read

#
#Arret des services
#
let ETAPE++
echo -e $COLPARTIE
echo -e "Etape $ETAPE : Les services samba et DHCP vont être arrétés.$COLTXT\n\nArret du DHCP."
VERSION=$(cut -c1 /etc/debian_version)
if [ $VERSION = "5" ] #Teste le numéro de version 5 = lenny 6 = squeeze
then
	/etc/init.d/dhcp3-server stop || echo "Erreur : le DHCP n'est pas installé chez vous? Désactivez le DHCP via l'interface graphique SVP le cas échéant."
else
	/etc/init.d/isc-dhcp-server stop || echo "Erreur : le DHCP n'est pas installé chez vous? Désactivez le DHCP via l'interface graphique SVP le cas échéant."
fi
echo "Si une erreur est survenue, le DHCP n'est peut-être pas installé chez vous? Désactivez le DHCP via l'interface graphique SVP le cas échéant."
echo "Arret de Samba."
/etc/init.d/samba stop
echo "Appuyez sur ENTREE pour continuer." && read
#
#Copie des fichiers de sauvegarde vers l'usb (si on le veut!)
#
let ETAPE++
echo -e $COLPARTIE
echo "Etape $ETAPE : Détection du périphérique USB"
echo -e "$COLTXT"
cat <<EOF
Branchez dès à présent un périphérique USB formaté en NTFS ou EXT ou FAT sur votre serveur si vous souhaitez sauvegarder vers un support USB.
Si vous utilisez un périphérique NTFS, n'oubliez pas d'installer avant le paquet ntfs-3g
apt-get install ntfs-3g
Il est l'heure de brancher un périphérique USB si vous le souhaitez pour une copie du dossier de sauvegarde.

EOF

echo "Appuyez sur ENTREE pour continuer." && read
mkdir -p /mnt/usb 2> $SAVEDIR/error.log
#On démonte (on ne sait jamais) de façon brutale!
echo "Démontage."
umount -f /mnt/usb 2>> $SAVEDIR/error.log
sleep 2
#On se place dans le répertoire utile à la recherche des périphérique
cd /dev/disk/by-id
#On monte le seul périphérique-disque USB qui existe (sinon on est éjecté).
echo "Détection puis montage."
sleep 2
SAVEDIRUSB="/mnt/usb/SaveConfig$(date +%Y-%m-%d)"
if mount /dev/disk/by-id/$(ls |grep usb*-part1)  /mnt/usb 2>> $SAVEDIR/error.log
then
	cd /mnt/usb
	mkdir -p $SAVEDIRUSB && echo "Dossier de sauvegarde $SAVEDIRUSB créé."
	echo "Suite de la procédure : copie sur le périphérique USB"
	rsync -a "$SAVEDIR/" $SAVEDIRUSB
	echo "Copie terminée sur le périphérique USB. Démontage en cours."
	cd /root
	umount -f /mnt/usb 2>> error.log
	echo "Démontage du périphérique usb effectué. Vous pouvez le retirer."
else
	echo "Aucun périphérique USB détecté. Le script continue son chemin."
fi
#
#Modification de l'adresse IP
#
let ETAPE++
echo -e $COLPARTIE
echo -e "Etape  $ETAPE : maintenant vous allez changer l'adresse IP du serveur ! Si vous opérez en ssh, vous allez perdre la connexion!\nRécupération des valeurs actuelles de l'IP.\n\n"
echo -e "$COLTXT"
#Copie du fichier d'origine
cp -f /etc/network/interfaces /etc/network/interfaces.ori
OLD_IP=$(cat /etc/network/interfaces.ori | grep address | sed -e "s/address//g" | tr "\t" " " |sed -e "s/ //g")

echo "Configuration IP actuelle:"
echo "IP :         $OLD_IP"

echo -e "Entrez la nouvelle IP (par exemple 10.131.253.1) : " && read NEW_IP

#
# Mise a jour de /etc/network/interfaces
#
echo "Mise à jour de /etc/network/interfaces"
echo "$(sed -e "s/address $OLD_IP/address $NEW_IP/g" /etc/network/interfaces.ori)" > /etc/network/interfaces
chmod 644 /etc/network/interfaces
#
# Redémarrage de l'interface réseau
#
echo "Redémarrage de l'interface réseau..."
ifdown $(cat /etc/network/interfaces |grep allow-hotplug | sed "s/allow-hotplug //g") && ifup $(cat /etc/network/interfaces |grep allow-hotplug | sed "s/allow-hotplug //g")
echo "Adresse IP modifiée en $NEW_IP"

echo
echo "Vous pouvez lancer le script 3-sauveACL.sh qui sauvegarde les ACL.
Quand le nouveau serveur sera prêt, lancez le script 4-copie_datas.sh"
#Fin et Happy end!
fi
exit 0
