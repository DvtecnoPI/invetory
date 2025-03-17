# Usar PHP-FPM como base
FROM php:8.2-fpm AS backend

# Instalar dependencias necesarias
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

# Configuración de Nginx directamente en el Dockerfile
RUN echo "\
server {\
    listen 80;\
    server_name _;\
    root /var/www/public;\
    index index.php index.html index.htm;\
    location / {\
        try_files \$uri \$uri/ /index.php?\$query_string;\
    }\
    location ~ \\.php\$ {\
        fastcgi_pass 127.0.0.1:9000;\
        fastcgi_index index.php;\
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\
        include fastcgi_params;\
    }\
    location ~ \\/\\.ht {\
        deny all;\
    }\
}" > /etc/nginx/sites-available/default

# Exponer el puerto 80 para Nginx
EXPOSE 80

# Comando para iniciar PHP-FPM y Nginx
CMD service php8.2-fpm start && nginx -g 'daemon off;'
