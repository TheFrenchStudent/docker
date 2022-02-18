# Dockerfile pour le REACT JS (FRONTEND)

# Les insctructions sont les mêmes que pour le Dockerfile de l'API REST, sauf pour le port d'écoute qui change.

FROM node:latest-alpine

WORKDIR /usr/src/app

COPY package.json ./package.json

RUN npm install

COPY . .

EXPOSE 3000

CMD [ "npm", "start" ]