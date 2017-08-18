FROM smebberson/alpine-consul-base:4.2.0
MAINTAINER Bobby Burden III <bobby@brb3.org>
ARG magento_url

# Setup nginx
RUN apk add --no-cache nginx \
    && mkdir /www \
    && chown nginx:nginx /www

# Setup mysql
RUN apk add --no-cache mysql mysql-client \
    && mysql_install_db --user=mysql

# Setup php5
RUN apk add --no-cache php5 php5-fpm php5-phar php5-iconv \
    php5-curl php5-gd php5-intl php5-mcrypt php5-openssl php5-pdo_mysql \
    php5-xml php5-soap php5-xsl php5-zip php5-json php5-ctype php5-zlib \
    && wget -O /usr/bin/composer http://getcomposer.org/download/1.4.2/composer.phar \
    && chmod +x /usr/bin/composer

# Put files in place
COPY fs /

# Needed for consul management of nginx
RUN mkdir /etc/services.d/nginx/supervise/ \
    && mkfifo /etc/services.d/nginx/supervise/control \
    && chown -R root:s6 /etc/services.d/nginx/ \
    && chmod g+w /etc/services.d/nginx/supervise/control

# Install Magento
ENV MAGEDIR=/www
ENV MAGEURL=$magento_url
RUN apk add --no-cache sudo bash
RUN apk add --update openssl
RUN install-magento

# Expose the ports for nginx
EXPOSE 80 443