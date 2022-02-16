FROM php:8.0-apache

RUN apt update -y \
    && rm -f /var/www/html/index.html

COPY index.php /var/www/html/index.php

WORKDIR /var/www/html