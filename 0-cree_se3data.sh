#!/bin/bash
#Crée par Samuel GONZALES - samuel.gonzales@ac-strasbourg.fr
# SERVEUR ------------------------------------------
#cat /etc/se3/config_c.cache.sh
# MYSQL ------------------------------------------
# /etc/se3/config_o.cache.sh
# LDAP ------------------------------------------
#cat /etc/se3/config_l.cache.sh 
#SAMBA ------------------------------------------
#cat /etc/se3/config_m.cache.sh
SETUPSE3=/var/se3/save/setup_se3.data
echo "#!/bin/bash" > $SETUPSE3
echo "# Pre config de SambaEdu a copier dans /etc/se3" >> $SETUPSE3
SE3IP=$(mysql se3db -e "select value from params where name='se3ip';" -s -N)
echo -e 'SE3IP="'$SE3IP'"' >> $SETUPSE3
NETMASK=$(mysql se3db -e "select value from params where name='se3mask';" -s -N)
echo -e 'NETMASK="'$NETMASK'"' >> $SETUPSE3
BROADCAST=$(sed -e '/#/d' /etc/network/interfaces |grep broadcast|cut -d" " -f2)
echo -e 'BROADCAST="'$BROADCAST'"' >> $SETUPSE3
NETWORK=$(sed -e '/#/d' /etc/network/interfaces |grep network|cut -d" " -f2)
echo -e 'NETWORK="'$NETWORK'"' >> $SETUPSE3
GATEWAY=$(sed -e '/#/d' /etc/network/interfaces |grep gateway|cut -d" " -f2)
echo -e 'GATEWAY="'$GATEWAY'"' >> $SETUPSE3
PRIMARYDNS=$(cat /etc/resolv.conf |grep nameserver|cut -d" " -f2|sed -n 1p)		# ip du slis ou dns academique
echo -e 'PRIMARYDNS="'$PRIMARYDNS'"' >> $SETUPSE3
SECONDARYDNS=$(cat /etc/resolv.conf |grep nameserver|cut -d" " -f2|sed -n 2p)		# Dns secondaire  si abs de slis)
echo -e 'SECONDARYDNS="'$SECONDARYDNS'"' >> $SETUPSE3
FQHN=$(/bin/hostname -A) #nom du serveur avec le domaine : Fully Qualify HostName
echo -e 'FQHN="'$FQHN'"' >> $SETUPSE3
SERVNAME=$(/bin/hostname -A|cut -d"." -f1 )	# de la 1ere variable on deduit le nom du serveur ici nom_serveur
echo -e 'SERVNAME="'$SERVNAME'"' >> $SETUPSE3
DOMNAME=$(mysql se3db -e "select value from params where name='domain';" -s -N) # ainsi que le nom de domaine ici nom_slis.academie.fr
echo -e 'DOMNAME="'$DOMNAME'"' >> $SETUPSE3
IFACEWEB_AUTOCONF="yes"
echo -e 'IFACEWEB_AUTOCONF="yes"' >> $SETUPSE3
PROXY_AUTOCONF="yes" # en cas d'abs de proxy ou proxy transparent mettre la variable a "no"
echo -e 'PROXY_AUTOCONF="yes"' >> $SETUPSE3
IPPROXY=$(cat /etc/profile|grep http_proxy=|awk -F "//" '{gsub("\"","");print $2}'|cut -d: -f1)
echo -e 'IPPROXY="'$IPPROXY'"' >> $SETUPSE3
PROXYPORT=$(cat /etc/profile|grep http_proxy=|awk -F "//" '{gsub("\"","");print $2}'|cut -d: -f2)
echo -e 'PROXYPORT="'$PROXYPORT'"' >> $SETUPSE3
CONFSE3="yes" # si la variable est a yes les autres variables de cette partie doivent etre renseignees
MYSQLIP="127.0.0.1"
echo -e 'MYSQLIP="'$MYSQLIP'"' >> $SETUPSE3
MYSQLPW=$(cat /etc/se3/config_o.cache.sh|grep dbpass|cut -d'"' -f2)
echo -e 'MYSQLPW="'$MYSQLPW'"' >> $SETUPSE3 #mot de pass root mysql 
SE3PW= # mot de pass admin pour l'interface web et samba
#config de l'annuaire Ldap
LDAPIP=$(mysql se3db -e "select value from params where name='ldap_server';" -s -N)	# ICI il faut entrer l'ip du slis s'il y en a un Sinon ip de se3 ou lcs ##
echo -e 'LDAPIP="'$LDAPIP'"' >> $SETUPSE3
#BASEDN=	$(mysql se3db -e "select value from params where name='ldap_base_dn';" -s -N) # dn de l annuaire#
BASEDN=$(cat /etc/se3/config_l.cache.sh |grep ldap_base_dn|cut -d'"' -f2)
/bin/echo  -e 'BASEDN="'$BASEDN'"' >> $SETUPSE3
ADMINRDN="admin"	# Attention s'il y a un Lcs ou lors d'une migration il faut verifier que c'est bien admin et non pas manager
echo -e 'ADMINRDN="'$ADMINRDN'"' >> $SETUPSE3
ADMINPW=$(mysql se3db -e "select value from params where name='adminPw';" -s -N) ## mot de passe de l'admin ldap 
echo -e 'ADMINPW="'$ADMINPW'"' >> $SETUPSE3
ADMINSE3PW=$(mysql se3db -e "select value from params where name='xppass';" -s -N) # mot de pass adminse3 pour postes windows
echo -e 'ADMINSE3PW="'$ADMINSE3PW'"' >> $SETUPSE3
echo -e '### parametres generaux ldap normalement a ne pas modifier ##
PEOPLERDN="People"
GROUPSRDN="Groups"
COMPUTERSRDN="Computers"
PARCSRDN="Parcs"
RIGHTSRDN="Rights"
PRINTERSRDN="Printers"
TRASHRDN="Trash"

##################################################################	
#Parametrage auto de certaines valeurs de la Base de donnees     #
#celles ci sont visibles dans l interface web                    #
#                            					 #															                 
##################################################################


MYSQL_AUTOCONF="yes" 
# si ce param est a yes les autres parametres de la meme section devront etre absolument definis -no- desactive la section
' >> $SETUPSE3
URL_IFACEWEB=$(mysql se3db -e "select value from params where name='urlse3';" -s -N)	
echo -e 'URL_IFACEWEB="'$URL_IFACEWEB'"' >> $SETUPSE3
DEFAULTGID=$(mysql se3db -e "select value from params where name='defaultgid';" -s -N)
echo -e 'DEFAULTGID="'$DEFAULTGID'"' >> $SETUPSE3
UIDPOLICY=$(mysql se3db -e "select value from params where name='uidPolicy';" -s -N)
echo -e 'UIDPOLICY="'$UIDPOLICY'"' >> $SETUPSE3
DEFAULTSHELL=$(mysql se3db -e "select value from params where name='defaultshell';" -s -N)
echo -e 'DEFAULTSHELL="'$DEFAULTSHELL'"' >> $SETUPSE3
URL_MAJSE3=$(mysql se3db -e "select value from params where name='urlmaj';" -s -N)
echo -e 'URL_MAJSE3="'$URL_MAJSE3'"' >> $SETUPSE3
FTP_MAJSE3=$(mysql se3db -e "select value from params where name='ftpmaj';" -s -N)
echo -e 'FTP_MAJSE3="'$FTP_MAJSE3'"' >> $SETUPSE3
echo -e '####################
#      		   #
# config de slapd  #
#      		   #
####################
SLAPD_AUTOCONF="yes" 		#remplissage de l annuaire si =yes a ne pas modifier normalement


##################
#      		 #
#config de Samba #
#      		 #
##################
SMB_AUTOCONF="yes" 		# config auto du service samba si cette variables est a  yes, les suivantes doivent etre renseignees'  >> $SETUPSE3
NTDOM=$(mysql se3db -e "select value from params where name='se3_domain';" -s -N)
echo -e 'NTDOM="'$NTDOM'"' >> $SETUPSE3
NETBIOS=$(mysql se3db -e "select value from params where name='netbios_name';" -s -N)
echo -e 'NETBIOS="'$NETBIOS'"' >> $SETUPSE3
SE3MASK=$(mysql se3db -e "select value from params where name='se3mask';" -s -N)
echo -e 'SE3MASK="'$SE3MASK'"' >> $SETUPSE3
echo -e '
##################
#		 #
# iP Slis ou Lcs #
#		 #
##################

LCS_OU_SLIS="no"
SLIS_IP=""
LCS_IP=""' >> $SETUPSE3

echo "Fichier $SETUPSE3 crée."
exit 0
