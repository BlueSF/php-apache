FROM php:7.0-apache

# Install PHP extensions and PECL modules.
RUN buildDeps=" \
    libbz2-dev \
    libmemcached-dev \
    libmysqlclient-dev \
    libsasl2-dev \
    " \
    runtimeDeps=" \
    curl \
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
    && pecl install redis xdebug \
    && docker-php-ext-enable redis.so xdebug.so \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/* \
    && a2enmod rewrite actions headers

# Enable Remote xdebug
echo "xdebug.idekey = PHPSTORM" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
echo "xdebug.default_enable = 0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
echo "xdebug.remote_autostart = 0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
echo "xdebug.remote_connect_back = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
echo "xdebug.profiler_enable = 0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
echo "xdebug.profiler_enable_trigger = 1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
echo "xdebug.max_nesting_level = 700" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
echo "xdebug.profiler_output_name = cachegrind.out.%t.%p" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
echo "xdebug.profiler_output_dir = /workspace/docker/service-storage" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Set the locale
RUN sed -i -e 's/# en_US en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && dpkg-reconfigure locales
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV TZ Asia/Seoul
RUN echo $TZ > /etc/timezone && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

# Install Composer.
ENV COMPOSER_HOME /root/composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV PATH $COMPOSER_HOME/vendor/bin:$PATH

EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
