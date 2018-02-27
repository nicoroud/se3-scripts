#!/bin/bash
#
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
clear
#
#Sauvegarde ACL
#
echo -e "La sauvegarde des ACL de /var/se3 n'est nécessaire que si vous avez créé des partages samba personnalisés dans /var/se3 avec des droits spéciaux ou des dossiers dans /var/se3/Docs dont vous souhaiteriez conserver les ACL. Dans le cas contraire, vous pouvez vous en dispenser. La sauvegarde des ACL sur /home est inutile, il existe un script qui les restaure, mais on vous le proposera quand même.\n\n"
echo -e "$COLPARTIE\nSouhaitez-vous sauvegarder les ACL de /var/se3 ? (ce n'est pas une obligation) (o/n)" && echo -e "$COLSAISIE\nVotre réponse : \c" && read ACL
echo
case $ACL in 
	o|O) 	echo -e "$COLPARTIE\nSauvegarde des  ACL de /var/se3 dans le dossier /var/se3/save/acl/ $COLTXT\nDébut du processus $(date)" #Ce dossier est celui prévu dans le script restore_droits.sh
		getfacl -R --absolute-names /var/se3 > /var/se3/save/acl/varse3_acl
		cp /var/se3/save/acl/varse3_acl /var/se3/save/acl/varse3_acl2
		bzip2 -f /var/se3/save/acl/varse3_acl #Compression pour être en phase avec le script restore_droits.sh du serveur
		mv /var/se3/save/acl/varse3_acl2 /var/se3/save/acl/varse3_acl
		chmod 700 /var/se3/save/acl/varse3_acl.bz2
		echo -e "ACL sauvegardées localement.\nFin du processus $(date)";;
	n|N) 	echo "Pas de sauvegarde des ACL de /var/se3, vous avez gagné du temps, on passe à la suite.";;
	*) 	echo "Commande non valide. les ACL de /var/se3 ne seront pas sauvegardées."
esac
echo 
echo
echo -e "$COLPARTIE\nSouhaitez-vous sauvegarder les ACL de /home ? (ce n'est VRAIMENT pas une obligation car les droits sont restaurés par défaut avec l'annuaire ldap) (o/n)" && echo -e "$COLSAISIE\nVotre réponse : \c" && read ACL
echo
case $ACL in 
	o|O) 	echo -e "$COLPARTIE\nSauvegarde des  ACL de /home dans le dossier /var/se3/save/acl/ $COLTXT\nDébut du processus $(date)" #Ce dossier est celui prévu dans le script restore_droits.sh
		getfacl -R --absolute-names /home > /var/se3/save/acl/home_acl
		echo -e "ACL sauvegardées localement.\nFin du processus $(date)";;
	n|N) 	echo "Pas de sauvegarde des ACL de /home, vous avez à nouveau gagné du temps, on passe à la suite.";;
	*) 	echo "Commande non valide. les ACL de /home ne seront pas sauvegardées."
esac

echo -e "$COLTITRE \nFin de sauvegarde des ACL dans le dossier /var/se3/save/acl . Liste des fichiers :\n$COLTXT" && ls /var/se3/save/acl

exit 0
