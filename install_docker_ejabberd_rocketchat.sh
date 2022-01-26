#!/bin/bash

############################### Installation de Docker, Ejabberd (Version 18.04), Rocket.Chat, d'un serveur Minecraft et Hamachi sur une VM Debian 10 avec un utilisateur root. ###############################

############## Installation de Docker ##############

# Suppression des containers existants et du répertoire d'installation RocketChat si le script a déjà été exécuté. De manière à repartir sur une installation propre.

rm -fr ./Rocket.Chat/
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

# Mise à jour des paquets existants de la VM et installation des paquets nécessaires à la suite du programme.

apt-get update && apt-get upgrade -y

apt-get install curl wget net-tools vim python3 git docker.io docker-compose -y

# Pour désinstaller les paquets ci-dessus, faites la commande suivante :
# apt-get purge curl wget net-tools vim python3 git docker.io docker-compose -y
# Vérification du status de Docker et obtention de l'image portainer via Docker sur le port 9000 de notre machine locale.

systemctl start docker 

docker pull portainer/portainer-ce
docker run --restart=always --name=portainer -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce

############## Installation d'Ejabberd (Version 18.04) ##############

# Création du domaine et des comptes utilisateurs et administrateurs d'Ejabberd.

read -p "Rentrez un nom de domaine : " domain

echo "Votre domaine est $domain."

echo "############################ ENTREZ DES CHIFFRES COMPRIS SUPERIEURS A 0 UNIQUEMENT ! ############################"

# Création du/des compte(s) administrateur(s).

read -p "Nombre de compte(s) administrateur(s) à créer : " numadmin

until [[ $numadmin =~ ^[+]?[1-9]+$ ]]
do
    echo "Veuillez rentrer des chiffres supérieurs à 0 !"
    echo
    read -p "Nombre de compte(s) administrateur(s) à créer : " numadmin
done

# Confirmation du nombre de compte(s) administrateur(s) créé(s).

echo "Vous avez créé $numadmin compte(s) administrateur(s)."

# Création du/de(s) compte(s) utilisateur(s).

read -p "Nombre de compte(s) utilisateur(s) à créer : " numuser

until [[ $numuser =~ ^[+]?[1-9]+$ ]]
do
    echo "Veuillez rentrer des chiffres supérieurs à 0 !"
    echo
    read -p "Nombre de compte(s) utilisateur(s) à créer : " numuser
done

# Confirmation du nombre de compte(s) utilisateur(s) créé(s).

echo "Vous avez créé $numuser compte(s) utilisateur(s)."

# Informations d'identification des comptes administrateur(s) et utilisateur(s) à rentrer.

if [ $numadmin -eq 0 ];then
        echo "Attention, aucun compte administrateur n'a été créé."
else
        for i in $( seq 1 $numadmin);do
                read -p "Nom du compte administrateur n°$i : " login_admin
                read -p "Mot de passe du compte administrateur n°$i : " password_admin
                echo "Votre compte administrateur est ${login_admin}@${domain} avec le mot de passe : ${password_admin}"
                admin_users="${login_admin}@${domain}"
                list_admin+="${admin_users} "
                list_admin_password+="${admin_users}:${password_admin} "
        done

fi

if [ $numuser -eq 0 ];then
        echo "Attention, aucun compte utilisateur n'a été créé."
else
        for i in $( seq 1 $numuser);do
                read -p "Nom du compte utilisateur n°$i : " login_user
                read -p "Mot de passe du compte utilisateur n°$i : " password_user
                echo "Votre compte utilisateur est ${login_user}@${domain} avec le mot de passe : ${password_user}"
                users="${login_user}@${domain}:${password_user}"
                list_users+="${users}"
        done

fi

# Création et paramétrage du container Ejabberd (Version 18.04) via Docker.

docker run -d \
        --name "ejabberd" \
        -p 5222:5222 \
        -p 5269:5269 \
        -p 5280:5280 \
        -h 'xmpp.$domain' \
        -e "XMPP_DOMAIN=$domain" \
        -e "EJABBERD_ADMINS=$list_admin" \
        -e "EJABBERD_USERS=${list_admin_password} ${list_users}" \
        -e "TZ=Europe/Paris" \
        rroemhild/ejabberd:18.04


############## Installation de Rocket.Chat ##############

# Clonage d'un répertoire GitHub pour installer RocketChat sur notre répertoire courant.

git clone https://github.com/RocketChat/Rocket.Chat.git

# Exécution dans le répertoire cloné de la commande docker-compose pour construire le container RocketChat.

cd Rocket.Chat/ && docker-compose up --build -d

echo "Rendez-vous sur la page web http://localhost:9000 pour orchestrer vos containers Docker via Portainer"
echo "Pour se rendre sur RocketChat, allez sur http://localhost:3000"

############## Installation du serveur Minecraft et du service VPN Hamachi ##############

# Installation du serveur Minecraft.

docker pull itzg/minecraft-server
docker run -e EULA=TRUE -p 25565:25565 itzg/minecraft-server:latest

# Installation du service VPN Hamachi.

wget https://www.vpn.net/installers/logmein-hamachi_2.1.0.203-1_amd64.deb
dpkg -i logmein-hamachi_2.1.0.203-1_i386.deb

# Démarrage du service.

/etc/init.d/logmein-hamachi start

# Se connecter à Hamachi en CLI.

hamachi login

# Création d'un nom de réseau et d'un mot de passe pour permettre aux autres persones détentrice de ces informations de se connecter à un serveur via le VPN Hamachi.

hamachi create hadrien-vpn 

# Pour rejoindre un réseau déjà existant :

hamachi join hadrien-vpn 

# Possibilité de mettre un mot de passe pour le réseau que l'on vient de créer :

hamachi set-pass password

# Pour se connecter à un réseau privé, il faut posséder les informations d'identification du VPN auquel on veut se connecter, à savoir le network ID et le mot de passe, s'il y en a un :
# hamachi join <networkID> <password>

# Pour voir les personnes connectés à votre VPN :

hamachi list

# Pour arrêter le service hamachi :

/etc/init.d/logmein-hamachi stop

# Pour se déconnecter uniquement du VPN :

hamachi logout

############################### Fin du script ###############################