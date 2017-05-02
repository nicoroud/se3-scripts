# se3-scripts

Samuel GONZALES – Raip de Strasbourg

Ce document est inspiré de la documentation
http://wwdeb.crdp.ac-caen.fr/mediase3/index.php/FaqInstallnewserver
et du script de sauvegarde
https://raw.githubusercontent.com/SambaEdu/se3master/master/usr/share/se3/sbin/sauve_se3.sh

Liste des scripts utilisés
0-cree_se3data.sh
2-sauvegardeConfig.sh
3-sauveACL.sh
4-copie_datas.sh
5-restaureConfig.sh
Etape 1 : sur l'ancien serveur
Stoppez la sauvegarde et démontez le support de sauvegarde (via l'interface).
Notez les modules installés.
Mettez le serveur à jour et à niveau en squeeze ou wheezy 
```sh
# se3_update_system.sh 
```
Créez un dossier scripts :
```sh
# mkdir /root/scripts
```
Copiez les scripts sur l'ancien serveur dans le dossier /root/scripts (par winscp ou en montant une clé usb).
Allez dans le dossier 
```sh
# cd /root/scripts/
```
Rendez les scripts exécutables 
```sh
# chmod +x *
```
Exécutez le script 0-cree_se3data.sh
```sh
# bash 0-cree_se3data.sh
```
Le script crée un fichier /var/se3/save/setup_se3.data.conf pour configurer le nouveau serveur 
Tapez
```sh
#cat /var/se3/save/setup_se3.data.conf
```
pour l'afficher.
Exécutez le script 2-sauvegardeConfig.sh sur l'ancien serveur :
```sh
# bash 2-sauvegardeConfig.sh
```
Ce script crée un répertoire dans /var/se3/save à la date du jour. les paramètres importants du serveur sont exportés :
La configuration samba (SID, conf. des partages personnalisés, imprimantes)
L'annuaire ldap
La base de donnée MySQL se3db
A la fin du script les services samba et dhcp sont stoppés et l'adresse ip est modifiée.
Exécutez le script 3-sauveACL.sh sur l'ancien serveur si vous souhaitez sauvegarder les ACL. CETTE ETAPE EST FACULTATIVE !!
A partir de là vous pouvez installer le nouveau serveur. 
Etape 2 : sur le nouveau serveur
Lancez l'installation de Debian 7 à partir du CD ou d'une clé usb. Documentation ici :
https://github.com/SambaEdu/se3-docs/blob/master/se3-installation/installationmanuelle.md
Pour le partitionnement j'utilise plutôt les valeurs suivantes pour un DD de 1To :
- Partition primaire / : 20 GB 
- Partition primaire swap : 4 GB
- Partition logique /var : 40 GB
- Partition logique /var/se3 : 50 %
- Partition logique /home) : ce qui reste

Générez la clé du serveur et exportez-la vers l'ancien serveur, ce qui évitera la saisie systématique d'un mot de passe :
```sh
# ssh-keygen && ssh-copy-id root@$IP_ANCIEN_SERVEUR
```
Créez un dossier scripts :
```sh
# mkdir /root/scripts
```
Copiez les scripts dans le dossier /root/scripts (par winscp ou en montant une clé usb).
Allez dans le dossier
```sh
# cd /root/scripts/
```
Rendez les scripts exécutables
```sh
# chmod +x *
```
Exécutez le script 4-copie_datas.sh
```sh
# bash 4-copie_datas.sh
```
Ce script effectue les tâches suivantes :
Installation de rsync
Création des dossiers /var/lib/samba et /etc/se3
Copie du dossier /var/se3/save de l'ancien serveur sur le nouveau
Copie des fichiers secrets.tdb et setup_se3.data vers les emplacements qui conviennent
Paramétrage du proxy pour wget et récupération du fichier install_phase2.sh pour wheezy
Il ne vous reste plus qu'à installer sambaedu :
```sh
# bash /root/install_phase2.sh
```
Vous pouvez ensuite lancer la copie des données :
```sh
# rsync -av --progress --exclude='profiles' root@$IP_ANCIEN_SERVEUR:/home/ /home/
# rsync -av --progress --exclude='save' root@$IP_ANCIEN_SERVEUR:/var/se3/ /var/se3/
```
Lancez le script 5-restaureConfig.sh
```sh
# bash 5-restaureConfig.sh
```
Ce script restaure les paramètres samba, les configurations des imprimantes, l'annuaire ldap, la base de données se3db.
Installez ensuite les modules du nouveau serveur. Si le serveur dhcp ne démarre pas, exécutez le script
```sh
# makedhcpdconf
```
Pour terminer vous pouvez exécuter le script se3 create_adminse3.sh
```sh
# create_adminse3.sh
```
qui permet de vérifier la bonne compatibilité de l'annuaire avec samba 4.4

RQ : si l'icône samba de la page de diagnostic est rouge, exécutez :
```sh
# chmod 755 /etc/samba
```

