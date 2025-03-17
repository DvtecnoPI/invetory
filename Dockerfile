# Etapa 1: Construcción del frontend (Vite)
FROM node:16 AS frontend

# Establecer el directorio de trabajo para el frontend
WORKDIR /app

# Copiar el package.json y el package-lock.json
COPY package.json package-lock.json ./

# Instalar dependencias de Node.js
RUN npm install

# Copiar el resto de los archivos del frontend
COPY resources/ .

# Ejecutar el build de Vite
RUN npm run build

# Etapa 2: Construcción del backend (Laravel)
FROM php:8.1-fpm AS backend

# Instalar dependencias necesarias para Laravel
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev zip git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql

# Establecer el directorio de trabajo
WORKDIR /var/www

# Copiar los archivos de la aplicación Laravel
COPY . .

# Instalar las dependencias de PHP con Composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer install --no-dev --optimize-autoloader

# Copiar los archivos del frontend (generados por Vite)
COPY --from=frontend /app/public /var/www/public

# Copiar el archivo .env para la configuración
COPY .env.example .env

# Configurar permisos
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Exponer el puerto del servidor
EXPOSE 8080

# Comando para iniciar el servidor PHP-FPM
CMD ["php-fpm"]
