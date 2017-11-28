FROM ubuntu:16.04

MAINTAINER Dragutin Cirkovic <dragonmen@gmail.com>

ENV VERSION php71
ENV FULLVERSION PHP-7.1.12

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive
ENV PHP_EXTENSIONS gd,mysqlnd,mbstring,exif,opcache,sockets,curl,iconv,mcrypt,pthreads

RUN apt update && apt install -y git libfcgi-dev libfcgi0ldbl libjpeg-turbo8-dev libmcrypt-dev libssl-dev libc-client2007e libc-client2007e-dev libxml2-dev libbz2-dev libjpeg8-dev libcurl4-openssl-dev libjpeg-dev libpng12-dev libfreetype6-dev libkrb5-dev libpq-dev libxml2-dev libxslt1-dev build-essential nano autoconf  python-setuptools curl bison libssl-dev libcurl4-openssl-dev pkg-config libssl-dev libsslcommon2-dev libenchant-dev libpspell-dev libreadline-dev git nano sudo \
unzip \
openssl \
supervisor \
ssmtp \
cron \
xz-utils \
apt-utils \
iputils-* \
net-tools \
wget

RUN mkdir /usr/src/php71 && \
mkdir -p /etc/php7 && \
mkdir -p /etc/php7/cli \
mkdir -p /var/www/html

COPY index.php /var/www/html

RUN cd /usr/src/php71 && \
git clone https://github.com/php/php-src.git -b PHP-7.1.12 --depth=1

RUN cd /usr/src/php71/php-src && \
./buildconf --force && \
./configure --prefix=/etc/php7 --with-bz2 --with-zlib --enable-zip --disable-cgi \
   --enable-soap --enable-intl --with-mcrypt --with-openssl --with-readline --with-curl \
   --enable-ftp --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
   --enable-sockets --enable-pcntl --with-pspell --with-enchant --with-gettext \
   --with-gd --enable-exif --with-jpeg-dir --with-png-dir --with-freetype-dir --with-xsl \
   --enable-bcmath --enable-mbstring --enable-calendar --enable-simplexml --enable-json \
   --enable-hash --enable-session --enable-xml --enable-wddx --enable-opcache \
   --with-pcre-regex --with-config-file-path=/etc/php7/cli \
   --with-config-file-scan-dir=/etc/php7/etc --enable-cli --enable-maintainer-zts \
   --with-tsrm-pthreads --enable-debug --enable-fpm \
   --with-fpm-user=www-data --with-fpm-group=www-data

RUN cd /usr/src/php71/php-src && \
make -j"$(nproc)" && make install

RUN cd /usr/src/php71/php-src && \
chmod o+x /etc/php7/bin/phpize && \
chmod o+x /etc/php7/bin/php-config

RUN cd /usr/src/php71/php-src && \
cd ext && \
#git clone https://github.com/krakjoe/pthreads -b master pthreads && \
wget https://github.com/SirSnyder/pthreads/archive/v3.1.7-beta.1.tar.gz && tar xvfz v3.1.7-beta.1.tar.gz && \
cd pthreads* && \
/etc/php7/bin/phpize && \
./configure --prefix=/etc/php7 --with-libdir=/lib/x86_64-linux-gnu --enable-pthreads=shared --with-php-config=/etc/php7/bin/php-config && \
make -j"$(nproc)" && make install

RUN cd /usr/src/php71/php-src && \
cp -r php.ini-development /etc/php7/cli/php.ini && \
cp php.ini-development /etc/php7/cli/php-cli.ini && \
echo "extension=pthreads.so" > /etc/php7/cli/php-cli.ini && \
echo "zend_extension=opcache.so" >> /etc/php7/cli/php.ini && \
ln --symbolic /etc/php7/bin/php /usr/bin/php

RUN rm -rf /usr/src/php71

VOLUME /var/www/html
VOLUME /etc/php7/php
EXPOSE 9000

RUN export USE_ZEND_ALLOC=0