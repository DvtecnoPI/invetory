# Etapa 1: Construcción del backend (Laravel con PHP-FPM)
FROM php:8.2-fpm AS backend

# Instalar dependencias necesarias para Laravel
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libfreetype6-dev zip git nginx \
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

# Copiar el archivo .env para la configuración
COPY .env.example .env

# Configurar permisos
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Copiar la configuración de Nginx
COPY ./nginx/default.conf /etc/nginx/sites-available/default

# Exponer los puertos 80 para HTTP
EXPOSE 80

# Comando para iniciar Nginx y PHP-FPM
CMD service php8.2-fpm start && nginx -g 'daemon off;'

