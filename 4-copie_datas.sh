#!/bin/bash
echo "Ce script sert à copier les données d'un serveur à l'autre via le réseau."
SAVEDIR="/var/se3/save"
echo "Installation rsync :"
apt-get install rsync -y
echo "Création des dossiers /var/lib/samba et /etc/se3"
if [ ! -d /var/lib/samba ]
then
	mkdir /var/lib/samba
	echo "/var/lib/samba crée."
else echo "Le dossier /var/lib/samba existe."
fi
if [ ! -d /etc/se3 ]
then
	mkdir /etc/se3 
	echo "/etc/se3  crée."
else echo "Le dossier /etc/se3  existe."
fi
echo "Copie du dossier /var/se3/save depuis l'ancien serveur."
echo "Entrez l'IP de l'ancien serveur :" && read IP
rsync -av --progress root@$IP:$SAVEDIR/ $SAVEDIR/
echo "Copie vers ce serveur terminée, copie des fichiers secrets.tbd et setup_se3"
if [ -e /var/lib/samba/secrets.tdb ]
then
	mv /var/lib/samba/secrets.tdb /var/lib/samba/secrets.tdb.ori
	cp $SAVEDIR/secrets.tdb /var/lib/samba/secrets.tdb 
	echo "/var/lib/samba/secrets.tdb copié"
else 
cp $SAVEDIR/secrets.tdb /var/lib/samba/secrets.tdb 
echo "/var/lib/samba/secrets.tdb copié"
fi
if [ ! -e $SAVEDIR/setup_se3.data.conf ]
then
		echo "Le fichier $SAVEDIR.setup_se3.data n'existe pas, il ne sera pas copié."
else 
	if [  -e /etc/se3/setup_se3.data ]
	then
		mv /etc/se3/setup_se3.data /etc/se3/setup_se3.data.ori
	fi	
cp $SAVEDIR/setup_se3.data.conf /etc/se3/setup_se3.data
echo "/etc/se3/setup_se3.data  copié."
fi
echo "le script install_se3.sh pour la version wheezy va être récupéré pour installer le serveur SE3."
sleep 5
cd /root
echo "http_proxy = http://10.131.254.254:3128/" >> /etc/wgetrc
wget http://dimaker.tice.ac-caen.fr/diSE3/se3scripts/install_phase2.sh
chmod +x install_phase2.sh
echo "Lancez la ligne de commande 'bash /root/install_phase2.sh' pour installer se3!"
exit 0
