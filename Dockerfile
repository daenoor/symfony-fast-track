FROM php:8.0-fpm-alpine

RUN apk --no-cache add \
      bash \
      icu-libs \
      icu-dev \
    && docker-php-ext-install \
      intl \
      opcache

COPY docker/app.ini /usr/local/etc/php/conf.d/99_app.ini
COPY docker/xdebug.ini /usr/local/etc/php/conf.d/50_xdebug.ini

ARG INSTALL_XDEBUG=false
ARG INSTALL_XDEBUG_HOST=127.0.0.1
ARG INSTALL_XDEBUG_PORT=9000
ARG INSTALL_XDEBUG_AUTOSTART=1

RUN if [ ${INSTALL_XDEBUG} = true ] && [ ${INSTALL_XDEBUG_V3} = true ]; then \
    pecl install xdebug \
    && docker-php-ext-enable xdebug \
;fi

ARG INSTALL_PCOV=false

RUN if [ ${INSTALL_PCOV} = true ]; then \
      pecl install pcov \
      && docker-php-ext-enable pcov \
;fi

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app

COPY composer.lock composer.json /app/

RUN composer install --prefer-dist --no-progress --no-scripts --no-autoloader

COPY . /var/www/ledger/

RUN composer dump-autoload --optimize
