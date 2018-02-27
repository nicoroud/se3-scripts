#!/bin/bash

#Version 0.2 du 15 fevrier 2013
#Version 0.3 du 8 mars 2013
#Version 0.4 du 27 octobre 2014

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
ETAPE=1

cat << EOF

*************************************************************************
*									*
*	Script de restauration de la configuration de l'ancien serveur	*
*		à lancer sur le nouveau serveur				*
*									*
*************************************************************************


Script modifié le 8 mars 2013

Bienvenue sur votre nouveau serveur ! Il est l'heure de réintegrer les bonnes données système!

Recherche du dossier de sauvegarde dans /var/se3/save : affichage de la liste des dossier

EOF
ls /var/se3/save
echo -e "Entrez le nom du dossier  : \c" && read  NOM
if [ ! -d /var/se3/save/$NOM ]
then
	echo "ATTENTION ce dossier n'existe pas! Sortie du script!"
	exit 1
fi
echo -e "Le dossier /var/se3/save/$NOM\nSi ce nom n'est pas correct, relancez le script!\nDébut du processus $(date)"
echo "Appuyez sur ENTREE pour continuer." && read

#
#LDAP
#
echo "Arret LDAP"
/etc/init.d/slapd stop
echo "Copie de l'ancienne config LADP : il faut garder quelques fichiers et modifier quelques droits!"
mv /var/lib/ldap /var/lib/ldap.save #Copie de sauvegarde
mkdir /var/lib/ldap #Recréation du dossier
cp /var/lib/ldap.save/DB_CONFIG /var/lib/ldap/DB_CONFIG #Recopie le fichier de configuration LDAP
slapadd -l /var/se3/save/$NOM/sauve_annu.ldif #Réinstallation de l'annuaire sauvegardé
chown -R openldap:openldap /var/lib/ldap #Modification du propriétaire
echo -e "\nCopie terminée, redémarrage du service LDAP.\n"
/etc/init.d/slapd start
echo "Lancement du script de correction ldap"
bash /usr/share/se3/sbin/corrige_ldap_smb44.sh
#
#Samba
#
echo "Arret Samba"
/etc/init.d/samba stop
cp -f /var/se3/save/$NOM/secrets.tdb /var/lib/samba/secrets.tdb
#
#Remarque : ce fichier avait déjà été copié avec le dossier /var/lib/samba/
#
#Mise en place des droits sur tous les fichiers *.tdb
#
chmod 600 /var/lib/samba/*.tdb
rsync -av --ignore-errors --force /var/se3/save/$NOM/etcsamba/ /etc/samba/ > /root/logrsyncsamba.txt
echo -e "\nCopie terminée, redémarrage du service samba.\n"
chmod 755 /etc/samba
/etc/init.d/samba start
#
#restaure_conf_imprimante()
#
echo -e "\nAu tour des imprimantes.\n"
rsync -av --del --ignore-errors --force /var/se3/save/$NOM/varlibsambaprinters/ /var/lib/samba/printers/ > /root/logrsyncprinters.txt
echo "synchronisation des fichiers de conf d'imprimantes depuis $SAVEDIR" 
rsync -av --del --ignore-errors --force /var/se3/save/$NOM/etcsambaprinters_se3/ /etc/samba/printers_se3/ > /root/logrsyncprinters.txt
echo "restauration des fichiers de configuration des imprimantes depuis $SAVEDIR" 
rsync -av --del --ignore-errors --force $SAVEDIR/etccups/ /etc/cups/  > /root/logrsyncprinters.txt

#
#Mysql
#
echo "Au tour de Mysql"
#Base se3db
mysql se3db < /var/se3/save/$NOM/se3db.dump
if [ -e /var/se3/save/$NOM/ocsweb.dump ]
#Base OCS si elle existe
then
	mysql ocsweb < /var/se3/save/$NOM/ocsweb.dump
fi

#
#Restauration ACL
#

echo -e "Souhaitez-vous restaurer des ACL de /home via un fichier du dossier de sauvegarde ou via le script restore_droits.sh ?\n
1) Fichier du dossier\n2) Script restore_droits.sh\n3) Appuyez sur Entrée pour annuler\nVotre choix : \c" && read reponse
case $reponse in
	1) echo -e "Si vous avez lancé le script 3-sauveACL.sh les ACL se trouvent dans /var/se3/save/acl\nRestauration des ACL de /home"
	setfacl --restore=/var/se3/save/acl/home_acl
	echo -e "\nRestauration terminée!\n\nRestauration des ACL de /var/se3"
	setfacl --restore=/var/se3/save/acl/varse3_acl
	echo -e "\nProcédure terminée! Droits restaurés.\n";;
	2) echo -e "Restauration des droits via le script restore_droits.sh\n"
	/usr/share/se3/scripts/restore_droits.sh;;
	*) echo -e "Choix non valide! Les droits ne sont pas restorés."
esac

#
#Création de AdminSE3
#
echo -e "Lancement du script create_adminse3.sh\n"
/usr/share/se3/sbin/create_adminse3.sh

echo -e "Desinstallation du paquet nscd (qui peut gêner l'integration des clients)!"

apt-get remove nscd

echo -e "Ajout de paquets utiles : htop, mc, ncdu\n"
apt-get install htop mc ncdu -y

echo -e "Fin du script. Amusez-vous bien avec votre nouveau serveur!"

exit 0
