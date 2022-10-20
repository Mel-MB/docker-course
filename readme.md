# Docker

## Utilité

Le but de docker c'est d'harmoniser les machines de développement, mais aussi de production : cela nous évite de devoir débugger ou mettre à jour la machine de prod par rapport à celle de dév par exemple.

Avec docker, on peut configurer des environnement de dev très rapidement pour avoir le même fonctionnement partout. Une réplique exacte pour tout le monde. Cela nous évite les machines virtuelles lourdes.

Docker nous permet de créer des conteneurs qui contiennent tout ce qui faut pour faire tourner des applications.

En général l'OS et les bibliothèques nécessaires.

Donc :

    - utile car docker permet de faire tourner notre application sans avoir à configurer chaque machine sur laquelle elle tourne. On configure notre image et hop tout les conteneurs auront le même fonctionnement.
    - les conteneurs sont portables et peuvent être déployés (run) n'importe et c'est rapide et léger
    - l'environnement de travail est contrôlé
    - une étape indispensable pour déployer une application à grande échelle


## Installation (sur la VM déjà fait)

Récap des commandes à faire pour installer et utiliser docker : https://docs.docker.com/engine/install/ubuntu/

Pour éviter le sudo à chaque fois : https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user

```bash
sudo apt-get update

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Pour tester l'installation
sudo service docker start
sudo docker run hello-world

# Utilisation de docker sans sudo
sudo groupadd docker
sudo gpasswd -a $USER docker
```

## L'Utilisation de docker

- `docker run hello-world` : https://hub.docker.com/_/hello-world
- `docker ps` qui permet de visualiser les conteneurs actifs sur notre système, si on exécute un conteneur, après l'exécution il est éteint automatiquement **mais pas supprimé**. Pour afficher tout les conteneurs dont ceux inactifs il faut rajouter l'option `-a`.
- `docker ps -a` pour afficher les conteneurs actifs et inactifs
- `docker rm ID` / `docker rm NAME` pour supprimer un conteneur

On peut supprimer les conteneurs tout de suite après leur exécution grâce à l'option `--rm` ce qui évite de devoir gérer la suppression des inactifs à la main
- `docker run --rm hello-world` cela va lancer le conteneur hello-world, puis après la fin de l'exécution cela va supprimer le conteneur

Il y a des tonnes de conteneurs qui son disponible sur docker hub : https://hub.docker.com/search?q=


On essaye la commande :
- `docker run --rm ubuntu:latest` normalement la première fois il vous dit que il doit faire pull de l'image de ubuntu (normal on l'a pas en local, cela vient de docker hub) et une fois le pull fait il exécute notre conteneur. Rien ne s'affiche car on n'a rien fait faire à notre ubuntu. Il se lance et puis il n'exécute aucune commande et se termine...

- `docker run --rm ubuntu:latest cat /etc/os-release` on utilise la commande `cat` dans notre conteneur pour afficher le contenu du fichier `/etc/release`. Cela va être la seule chose que fait notre conteneur avant de s'arrêter.

On veut travailler sur une version ubuntu bien précise pour des raisons de rétrocompatibilité, par exemple on veut la version 18.04

- `docker run --rm ubuntu:18.04 cat /etc/os-release` on est bien dans notre conteneur avec une version plus ancienne de ubuntu (il télécharge l'image si on ne l'a pas)

On a beaucoup d'options pour pouvoir lancer notre conteneur dans des états un peu différents :
- `-d` pour lancer le conteneur en background, pour ne pas afficher ce qui se passe sur le conteneur et continuer à utiliser le terminal
- `-i` qui veut dire interactif, ici le conteneur attends des commandes en plus de notre part (il ne va pas se fermer tout seul)

Par exemple pour avoir accès au terminal dans notre conteneur on va lancer :
- `docker run --rm -di ubuntu:18.04 /bin/bash` ici on a le flag `d` pour lancer en background et le flag `i` pour pouvoir interagir avec notre conteneur (sinon il tournerait mais on ne pourrait pas faire quelque chose avec)

Pour quitter ensuite on fait exit, mais cela n'arrête pas le conteneur qui continue d'exécuter la commande initiale `/bin/bash` et donc il faut l'arrêter à la main avec la commande `docker stop ID`

Pour faire plus rapide on fait tout d'un coup
- `docker run --rm -ti ubuntu:20.04 /bin/bash` si on enlève le flag `d` le conteneur n'est plus en background, il s'arrête quand on tape exit et avec --rm il est en plus supprimé. On peut vérifier avec `docker ps -a`.

## DockerFile

On créé un fichier nommé Dockerfile, le but de ce fichier est de fournir à docker les instruction pour construire un conteneur customisé pour nous.

Après la pause repas

On va faire créer un conteneur qui fait tourner `json-server` et qui nous mettra à disposition une API REST à partir d'un fichier JSON -> pratique pour simuler un backend et une base de donnée quand on en a pas.

[json-server](https://www.npmjs.com/package/json-server)

Exo cas pratique sur les commandes vues le matin
> Créer une instance de conteneur node la dernière version
> On le lance en interactif
> Bonus : Exécuter ensuite le code js `console.log('Hello world')`
> Solution `docker run --rm -ti node:current-alpine3.16`

On créé un fichier `Dockerfile` dedans un part d'une image déjà existante à l'aide de `FROM`.  
Maintenant on veut installer _json-server_ donc on va faire toutes ces étapes dans l'ordre du fichier :
- dire à docker le dossier dans lequel on est en train de travailler dans le conteneur avec `WORKDIR`
- exécuter la commande pour installer json-server avec `RUN`
- donner un fichier db.json à json-server, pour cela on va utiliser la commande `COPY` (voire `ADD` pour des urls mais dezip automatiquement)
- Finalement on fait tourner notre serveur avec `ENTRYPOINT` et on lance `json-server` qui a été installé précédemment

Une fois le fichier [Dockerfile](image/Dockerfile) écrit vous pouvez créer l'image correspondante en faisante la commande depuis le dossier où se trouve le Dockerfile
- `docker build .` ça vous dit que tout est bon et à la fin votre image prête mais sans tage ni nom
- `docker images` ou `docker image list` pour afficher les images et ainsi voir l'image que vous venez de créer (<none> ... <none> ... ID)

Même si elle n'a pas de nom et pas de tag, cela n'empêche de faire une instance à partir de cette dernière :

- `docker run --rm <imageID>` cela lance notre serveur json-server, tout à l'air ok. Par contre on est bloqué car on ne peut pas quitter depuis notre terminal (car pas interactif) il faut donc passer par un autre terminal
  - avec `docker ps` on affiche les conteneurs actifs, on repère l'ID du conteneur (pas de l'image) de celui du json-server
  - avec `docker stop <containerID>` on arrête le conteneur et on est libre !

**Problème:** notre conteneur n'a pas accès aux ports de notre machine hôte, et ne peut donc pas exposer notre application sur un port.
- Par défaut json-server il tourne sur localhost, et pour pouvoir accéder aux réseau de la machine hôte c'est `0.0.0.0` l'ip. Et en plus préciser le port à exposer avec `EXPOSE` (dans le Dockerfile).

## Mémo

### Images

- `docker images` liste toutes les images locales
- `docker rmi nomImage` efface une image
- `docker run nomImage` créé une instance de conteneur à partir d'une image, si elle existe c'est bon, sinon il essaye de télécharger sur docker hub
- `docker run --rm nomImage` pour supprimer automatiquement le conteneur dès qu'on le stoppe.

### Conteneurs

- `docker ps` liste les conteneurs en cours d'exécution
- `docker ps -a` pour lister aussi ceux inactifs
- `docker ps -aq` pour lister les IDs de tous les conteneurs
- `docker rm nomConteneur` supprimer un conteneur
- `docker rm -f nomConteneur` suppression forcée même s'il tourne
- `docker rm -f $(docker ps -aq)` supprimer tous les conteneurs
- `docker run --rm -di nomConteneur COMMANDE` pour lancer le conteneur en mode interactif (COMMANDE : /bin/bash par exemple) 
- `docker run --rm -it nomConteneur /bin/bash` - traduction c'est un peu l'équivalent d'une commande ssh (si besoin d'info google)
- `docker stop nomConteneur`
- `docker start nomConteneur` lancer ou relancer un conteneur (si pas l'option --rm)

### Générales

- `docker system prune` efface tous les conteneurs non utilisés et les images sans noms
- `docker system prune -a` efface tout

### Dockerhub

... Incoming