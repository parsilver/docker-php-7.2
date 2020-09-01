FROM php:7.2-apache

WORKDIR /var/www/project/public

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*


# # Enable redis
RUN pecl install redis && docker-php-ext-enable redis

# # Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl xml iconv intl opcache mysqli
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd


# Install cacert pem
RUN curl --remote-name --time-cond cacert.pem https://curl.haxx.se/ca/cacert.pem \
    && mkdir -p /etc/ssl/certs/ \
    && cp cacert.pem /etc/ssl/certs/ \
    && chown -R www-data:www-data /etc/ssl/certs/cacert.pem

# Setup php
RUN echo "curl.cainfo=\"/etc/ssl/certs/cacert.pem\"" >> /usr/local/etc/php/php.ini \
    && echo "openssl.cafile=\"/etc/ssl/certs/cacert.pem\"" >> /usr/local/etc/php/php.ini \
    && echo "openssl.capath=\"/etc/ssl/certs/cacert.pem\"" >> /usr/local/etc/php/php.ini

RUN a2enmod rewrite session session_cookie session_dbd request echo buffer ext_filter mime_magic alias actions

