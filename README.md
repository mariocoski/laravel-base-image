# laravel-base-image
Docker image for Laravel projects

## Credits:
[https://github.com/FramgiaDockerTeam/laravel-nginx-php-fpm](https://github.com/FramgiaDockerTeam/laravel-nginx-php-fpm)

## Build
```sh
docker build -t mariocoski/laravel-base-image:latest .
```

## Push to docker registry
```sh
docker push mariocoski/laravel-base-image:latest
```

## How to use this base image?
1. For laravel project which needs nginx + php-fpm7.2 create a Dockerfile: 

```sh
FROM mariocoski/laravel-base-image:latest

WORKDIR /var/www

# Install dependencies
COPY composer.json composer.json /var/www/
RUN composer install --prefer-dist --no-scripts --no-dev --no-autoloader && rm -rf /root/.composer

# Copy existing application directory permissions
COPY . /var/www/

# Finish composer
RUN composer dump-autoload --no-scripts --no-dev --optimize

RUN chown -R $USER:www-data \
        /var/www/storage \
        /var/www/bootstrap/cache

RUN chmod 775 -R storage \ 
       /var/www/bootstrap/cache

# nginx ports
EXPOSE 80 443

# Default command
CMD ["/usr/bin/supervisord"]

```
