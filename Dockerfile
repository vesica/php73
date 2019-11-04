FROM php:7.3-apache

# Setup Debian
RUN apt-get upgrade && apt-get update && ACCEPT_EULA=Y && apt-get install -y \
        unzip \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libmemcached-dev \
        libzip-dev \
        libgeoip-dev \
        libxml2-dev \
        libxslt-dev \
        libtidy-dev \
        libssl-dev \
        zlib1g-dev \
        libpng-dev \
        libwebp-dev \
        libgmp-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libaio1 \
        libldap2-dev \
        apt-file \
        wget \
        vim \
        gnupg \
        gnupg2 \
        zip \
        git \
        gcc \
        g++ \
        autoconf \
        libc-dev \
        pkg-config \ 
    && pecl install redis \
    && pecl install geoip-1.1.1 \
    && pecl install apcu \
    && pecl install memcached \
    && pecl install timezonedb \
    && pecl install grpc \
    && docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-webp-dir=/usr/include/ --with-jpeg-dir=/usr/include/  \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-install gd calendar gmp ldap sysvmsg pcntl iconv bcmath xml mbstring pdo tidy gettext intl pdo_mysql mysqli simplexml xml xsl xmlwriter zip opcache exif sockets \
    && docker-php-ext-enable redis geoip apcu memcached timezonedb grpc \
    && printf "log_errors = On \nerror_log = /dev/stderr\n" > /usr/local/etc/php/conf.d/php-logs.ini

# Apache settings
COPY etc/apache2/conf-enabled/host.conf /etc/apache2/conf-enabled/host.conf
COPY etc/apache2/apache2.conf /etc/apache2/apache2.conf
COPY etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf

# PHP settings
COPY etc/php/production.ini /usr/local/etc/php/conf.d/production.ini

# Composer
RUN mkdir -p /usr/local/ssh
COPY etc/ssh/* /usr/local/ssh/
RUN sh /usr/local/ssh/install-composer.sh && \
    mv composer.phar /usr/local/bin/composer && \
    a2enmod proxy && \
    a2enmod proxy_http && \
    a2enmod proxy_ajp && \
    a2enmod rewrite && \
    a2enmod deflate && \
    a2enmod headers && \
    a2enmod proxy_balancer && \
    a2enmod proxy_connect && \
    a2enmod ssl && \
    a2enmod cache && \
    a2enmod expires && \
# Run apache on port 8080 instead of 80 due. On linux, ports under 1024 require admin privileges and we run apache as www-data.
    sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf && \
    chmod g+w /var/log/apache2 && \
    chmod 777 /var/lock/apache2 && \
    chmod 777 /var/run/apache2 && \
    echo "<?php echo phpinfo(); ?>" > /var/www/html/phpinfo.php

COPY var/www/html/index.php /var/www/html/index.php

EXPOSE 8080

## Add script to deal with Docker Secrets before starting apache
COPY secrets.sh /usr/local/bin/secrets
COPY startup.sh /usr/local/bin/startup
RUN chmod 755 /usr/local/bin/secrets && chmod 755 /usr/local/bin/startup

### PROD ENVIRONMENT SPECIFIC ###
################################

ENV PROVISION_CONTEXT "production"

################################
CMD ["startup"]
