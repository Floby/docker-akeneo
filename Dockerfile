FROM php:5.6-apache

# Set Default Variables
ENV PIM_VERSION 1.6.4


# setup dependencies
RUN apt-get update
RUN apt-get install -y \
    icu-devtools \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng12-dev \
    libicu-dev \
    curl \
    wget \
    mcrypt \
    zlib1g-dev  \
    libxml2 \
    libxml2-dev \
    php-pear \
    libmcrypt-dev 

RUN pecl install apcu-4.0.10
RUN echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini
RUN docker-php-ext-install mcrypt intl zip mysqli pdo pdo_mysql gd soap 

RUN a2enmod rewrite

RUN curl -s https://getcomposer.org/installer | php

RUN echo "date.timezone = \"Europe/Paris\"" >> /usr/local/etc/php/php.ini
RUN echo "memory_limit = 768M" >> /usr/local/etc/php/php.ini
RUN echo "short_open_tag = off" >> /usr/local/etc/php/php.ini

RUN php --ini

# install akeneo
RUN php /var/www/html/composer.phar self-update
RUN php /var/www/html/composer.phar config -g github-oauth.github.com ed32d7f017a3821be65769eeca54e9b257cb4b4a && \
    php /var/www/html/composer.phar create-project --prefer-dist akeneo/pim-community-standard /src '1.6.4@stable'

WORKDIR /src
ADD ./sites-enabled/akeneo-pim.conf /etc/apache2/sites-enabled/000-default.conf
ADD ./run.sh /run.sh
RUN chmod +x /run.sh

# Clean
RUN rm -rf /src/app/cache/* && \
    rm -fr /src/app/logs/* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find /var/log -type f | while read f; do echo -ne '' > $f; done; \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log


EXPOSE 80
CMD ["/run.sh"]
