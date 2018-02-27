# Quelques remarques et réflexions personnelles

Ne pas hésiter à supprimer les profils itinérants avant de migrer ou réinstaller un nouveau serveur :
Cette commande crée un dossier EMPTY qui doit être vide et utilise rsync plutot que rm car c'est plus rapide.
```sh
mkdir -p "empty"
rsync -a --delete empty/ /home/profiles/
rm -rf "empty"
```
Commandes pour conversion en utf8, ne pas hésiter à lancer une session [screen](https://linux.developpez.com/formation_debian/screen.html "Lien vers la doc screen") pour la deuxième ligne

```sh
fichier_logh="encodageUTF8_home.log"
fichier_logvs3="encodageUTF8_varse3.log"
/usr/bin/convmv --notest -f iso-8859-15 -t utf-8 -r /home 2&>1 | grep -v Skipping >> $fichier_logh
/usr/bin/convmv --notest -f iso-8859-15 -t utf-8 -r /var/se3 2&>1 | grep -v Skipping >> $fichier_logvs3
```

Problème que j'ai déjà rencontré 3 fois lors d'une migration d'un sambaedu de squeeze vers wheezy :
apt-get ne télécharge plus les paquets après 150-200 paquets environ.
L'erreur est "Erreur de somme de contrôle".
J'ai appliqué cette solution et la migration se passe bien :
https://askubuntu.com/questions/41605/trouble-downloading-packages-list-due-to-a-hash-sum-mismatch-error
```sh
echo "Acquire::http::Pipeline-Depth 0; Acquire::http::No-Cache true; Acquire::BrokenProxy true;" > /etc/apt/apt.conf.d/99fixbadproxy
```
Pour la version wheezy pas de problème par contre.
