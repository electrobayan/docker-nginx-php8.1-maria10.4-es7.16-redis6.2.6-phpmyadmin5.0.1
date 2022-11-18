FROM php:8.1-fpm

RUN apt-get update && apt-get install -y \
  libzip-dev \
  libonig-dev \
  cron \
  libfreetype6-dev \
  libicu-dev \
  libjpeg62-turbo-dev \
  libmcrypt-dev \
  libxslt1-dev \
  zip \
  libpng-dev \
  libxml2-dev \
  libxslt-dev \
  libsodium-dev \
  git

RUN docker-php-ext-install \
  pdo \
  pdo_mysql \
  mysqli \
  sockets \
  bcmath \
  gd \
  intl \
  mbstring \
  opcache \
  pdo_mysql \
  soap \
  xsl \
  zip

ARG INSTALL_XDEBUG=false
RUN if [ ${INSTALL_XDEBUG} = true ]; \
    then \
      pecl install xdebug && docker-php-ext-enable xdebug; \
    fi;

RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd

RUN curl -sS https://getcomposer.org/installer | \
  php -- --install-dir=/usr/local/bin --filename=composer --version=2.1.6

ARG PUID=1000
ARG PGID=1000
RUN groupmod -o -g ${PGID} www-data && \
    usermod -o -u ${PUID} -g www-data www-data

RUN chown www-data:www-data /var/www
WORKDIR /var/www

USER www-data

CMD ["php-fpm"]