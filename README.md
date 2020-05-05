# laravel-base-image
Docker image for Laravel projects

## Credits:
[https://github.com/FramgiaDockerTeam/laravel-nginx-php-fpm](https://github.com/FramgiaDockerTeam/laravel-nginx-php-fpm)
[https://medium.com/@c.harrison/speedy-composer-installs-in-docker-builds-41eea6d0172b](https://medium.com/@c.harrison/speedy-composer-installs-in-docker-builds-41eea6d0172b)
[https://github.com/TrafeX/docker-php-nginx](https://github.com/TrafeX/docker-php-nginx)
[https://laravel-news.com/multi-stage-docker-builds-for-laravel](https://laravel-news.com/multi-stage-docker-builds-for-laravel)

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
# FRONTEND ARTIFACTS
FROM node:11 as frontend

RUN mkdir -p /app/public

WORKDIR /app

COPY semantic /app/semantic/
COPY gulpfile.js package.json package-lock.json npm-shrinkwrap.json /app/

RUN npm install && npm run prod


# VENDOR ARTIFACTS
FROM composer:1.7 as vendor

COPY database/ database/

COPY tests tests
COPY composer.json composer.json
COPY composer.lock composer.lock

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist

# APP
FROM mariocoski/laravel-base-image:latest

WORKDIR /var/www

COPY . /var/www/

COPY --from=vendor /app/vendor/ /var/www/vendor/
COPY --from=frontend /app/public/js /var/www/public/js/
COPY --from=frontend /app/public/css /var/www/public/css/

RUN chown -R $USER:www-data \
        /var/www/storage \
        /var/www/bootstrap/cache

RUN chmod 775 -R storage \ 
       /var/www/bootstrap/cache

# nginx ports
EXPOSE 80

# Default command
CMD ["/usr/bin/supervisord"]

```
