FROM php:8.2-fpm

WORKDIR /var/www/app

# Install dependencies
RUN apt-get update \
    && apt-get install -y \
        nginx \
        git \
        zip \
        unzip \
        libonig-dev \
        libxml2-dev \
        libzip-dev \
    && docker-php-ext-install \
        pdo_mysql \
        mbstring \
        xml \
        zip

# Copy app files
COPY . /var/www/app/


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install app dependencies
RUN composer install --no-dev

# Setup Nginx
RUN rm /etc/nginx/sites-enabled/default
COPY /nginx/app.conf /etc/nginx/conf.d/

COPY .env /var/www/app/

RUN chown -R www-data:www-data /var/www/app/storage/logs && chmod -R 775 /var/www/app/storage

# Expose ports
EXPOSE 80

# Start Nginx and PHP-FPM
CMD service nginx start && php-fpm
