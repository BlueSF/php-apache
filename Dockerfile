FROM php:7.1-apache

# Install PHP extensions and PECL modules.
RUN buildDeps=" \
    default-libmysqlclient-dev \
    " \
    runtimeDeps=" \
    vim \
    locales \
    libmcrypt-dev \
    libicu-dev \
    " \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $buildDeps $runtimeDeps \
    && docker-php-ext-install iconv intl mbstring mcrypt mysqli zip \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/* \
    && a2enmod rewrite actions headers

ENV TZ Asia/Seoul
RUN echo $TZ > /etc/timezone && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

EXPOSE 80 443
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
