# Installation d'une architecture front/backend via Docker

## Installation de Docker

La première étape sera d'installer Docker sur votre machine hôte. Suivez le tutoriel suivant pour y arriver :

https://docs.docker.com/get-docker/

Une fois l'installation réussie, vous pouvez vérifier la version de Docker qui tourne sur votre machine en faisant 

`docker -v`

## Création du script docker-compose.yml

docker-compose est un outil très puissant permettant à partir d’un fichier de configuration en yaml d’orchestrer plusieurs containers (gestion des ports, de l’environnement et même de dépendances entre plusieurs containers).
Docker-compose est souvent pré-installé au moment de l’installation de docker, dans le cas contraire il faut vous référer à la procédure d’installation disponible sur le lien suivant:

https://docs.docker.com/compose/install/

Veuillez créer au sein de votre dossier racine un fichier *docker-compose.yml*.
En tête de ce dernier se situe la version de docker-compose utilisée nous allons utiliser la version 3 :

`version: "3"`

Nous devons ensuite configurer une partie services comprenant l’ensemble des définitions de nos containers docker.
Rajoutons tout d’abord notre container mongo, qui sera notre base de données qui stockera les informations de nos conteneurs API & REACT (respectivement, la partie backend et la partie frontend).
Nous lui donnons le nom `mongo` pour que la résolution DNS dans le fichier `server.js` de la partie backend puisse faire le lien.

```
services:
  mongo:
    image: mongo:latest
    ports:
      - 5000:5000
    volumes:
      - mongo_db_data:/data/db

```

Nous passons ensuite à la partie API. Puisque la partie backend va intéragir avec la partie base de données, un lien de dépendance doit être créé. Le build dans le dossier cible (ici backend) permet d'indiquer la localisation du Dockerfile nécessaire à la construction du conteneur. 
Le service API REST aura besoin du fichier `server.js`, qui spécifie le port sur lequel doit l'API doit écouter. Il est donc primordial de mettre le port correspondant se trouvant dans le fichier `server.js` (ici `8080`) dans le fichier docker-compose.

```

api_rest:
    build: ./backend
    volumes:
      - backend:/usr/src/app
    ports:
      - 8080:8080
    depends_on:
      - mongo_db

```

Enfin, nous définissons le service frontend (react js), qui sera l'interface avec laquelle les utilisateurs intéragiront. Ce service dépend de l'API REST et doit être lié à ce dernier. Pour la partie `build`, nous mettons l'emplacement de notre Dockerfile nécessaire cette fois-ci à la construction du conteneur REACT JS (pour la partie front).

```

react_js:
    build: ./frontend
    depends_on:
      - api_rest
    volumes:
      - frontend:/usr/src/app
    ports:
      - 3000:3000

```

Nous finissons enfin notre fichier `docker-compose.yml` par lister les volumes, dans un souci de persistance des données :

```

volumes:
  mongo_db_data:
  backend:
  frontend:
 
 ```
 
 ## Création des scripts Dockerfile
 
 ### Pour la partie Backend
 
 Notre Dockerfile se construira de la manière suivante :
 
 Une partie FROM pour spécifier l'image choisie, ici une version de node:alpine.
 
 ```
 
 FROM node:12.9.0-alpine
 
 ```
 
 Nous définissons ensuite l'emplacement dans lequel nous copierons les fichiers nécessaires. Nous indiquons ensuite une commande à exécuter lors de la construction de l'image :
 
 ```
 
WORKDIR /usr/src/app

COPY package.json ./package.json

RUN npm install

COPY . .

```

Nous exposons enfin le port d'écoute et nous lançons le service npm dans le CMD : 

```

EXPOSE 8080

CMD [ "npm", "start" ]

```

### Pour la partie frontend

Ce sera le même format et le même contenu que pour le Dockerfile de la partie backend, mais le port d'exposition sera `3000` :

```

FROM node:12.9.0-alpine

WORKDIR /usr/src/app

COPY package.json ./package.json

RUN npm install

COPY . .

EXPOSE 3000

CMD [ "npm", "start" ]

```

## Construction des conteneurs avec la commande `docker-compose up`

Une fois nos fichiers prêts et dans les bons emplacements (*Dockerfiles* respectivement dans les dossiers back et frontend, *docker-compose.yml* à la racine), nous pouvons lancer la commande `docker-compose up`. Faites bien attention d'être dans votre dossier de travail lorsque vous lancez cette commande. 
L'image mongo est pullée du Docker Hub dans un premier temps, puis les images REACT & API REST sont construites à leur tour via les fichiers de configuration Dockerfile. Les volumes sont également créés et attachés aux conteneurs correspondant.

La base de donnée est ensuite initiée et fait le lien avec les autres conteneurs. Une fois le script fini, vous devriez obtenir la message suivant :

![Docker-compose1](https://user-images.githubusercontent.com/95022398/154681455-51e7287b-ab2c-46f8-a875-28523ac9994e.PNG)

Vous pouvez ensuite vérifiez que votre application REACT JS est bien accessible via le port 3000 de votre machine locale :

![Docker-compose2](https://user-images.githubusercontent.com/95022398/154681869-81232e92-3c33-49a2-9b64-1fefa51bb762.PNG)

Enfin, votre API REST est également accessible via le port 8080 et affiche bien le message mis dans vos fichiers de configuration correspondant :

![Docker-compose3](https://user-images.githubusercontent.com/95022398/154682050-11dc9939-48ed-4b1b-8de4-8345518be560.PNG)
