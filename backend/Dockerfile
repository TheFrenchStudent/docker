# Dockerfile pour l'API REST (BACKEND).

# Image node choisie avec la version.

FROM node:latest-alpine

# On se met dans l'emplacement où se trouve nos données de service.

WORKDIR /usr/src/app

# On copie le fichier package.json dans l'emplacement actuel.

COPY package.json ./package.json

# Lancement du service npm (qui est une dépendance dans l'image node js).

RUN npm install

# Copie du répertoire courant dans le répertoire actuel.

COPY . .

# Exposition du port 8080 de notre service API REST.

EXPOSE 8080

# Exécution dans le CMD de notre conteneur du service npm, que l'on démarre.

CMD [ "npm", "start" ]