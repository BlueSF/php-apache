FROM php:7.0-apache

# Install PHP extensions and PECL modules.
RUN buildDeps=" \
    libbz2-dev \
    libmemcached-dev \
    libmysqlclient-dev \
    libsasl2-dev \
    " \
    runtimeDeps=" \
    vim \
    curl \
    ssmtp \
    git \
    locales \
    libfreetype6-dev \
    libicu-dev \
    libjpeg-dev \
    libmcrypt-dev \
    libmemcachedutil2 \
    libpng12-dev \
    libpq-dev \
    libxml2-dev \
    " \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $buildDeps $runtimeDeps \
    && docker-php-ext-install bcmath bz2 calendar iconv intl mbstring mcrypt mysqli zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/* \
    && a2enmod rewrite actions headers

EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
