FROM php:7.2-fpm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libmemcached-dev \
        libzip-dev \
        zip \
        unzip \
        libz-dev \
        libpq-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
        openssh-server \
        libmagickwand-dev \
        git \
        cron \
        libxml2-dev \
        nginx \
        supervisor \
        net-tools \
        nano

# Install the PHP mcrypt extention (from PECL, mcrypt has been removed from PHP 7.2)
RUN pecl install mcrypt-1.0.3 && docker-php-ext-enable mcrypt

# Install the PHP pcntl extention
RUN docker-php-ext-install pcntl

# Install the PHP zip extention
RUN docker-php-ext-configure zip --with-libzip && docker-php-ext-install zip

# Install the PHP pdo_mysql extention
RUN docker-php-ext-install pdo_mysql && docker-php-ext-enable pdo_mysql

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# turn off deamonize for php-fpm as provided by supervisor
RUN sed -i 's/;daemonize = yes/daemonize = no/g' /usr/local/etc/php-fpm.conf

WORKDIR /var/www

COPY php-fpm.conf /usr/local/etc/php-fpm.d/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.nginx.conf /etc/nginx/conf.d/default.conf
COPY laravel.ini /usr/local/etc/php/conf.d

# configure laravel scheduler
RUN echo "* * * * * root /usr/local/bin/php /var/www/artisan schedule:run >> /dev/null 2>&1"  >> /etc/cron.d/laravel-scheduler
RUN chmod 0644 /etc/cron.d/laravel-scheduler

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer