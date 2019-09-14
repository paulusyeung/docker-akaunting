FROM php:7.3-fpm-alpine3.10

LABEL maintainer="docker@kevin.oakaged.io"

# Add Production Dependencies
RUN apk add --update --no-cache \
    bash \
    bzip2-dev \
    freetype-dev \
    gettext \
    icu-dev \
    jpegoptim \
    libjpeg-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libzip \
    libzip-dev \
    mysql-client \
    nano \
    optipng \
    php7-mysqli \
    php7-pdo_mysql \
    php7-gd \
    php7-zip \
    php7-xml \
    php7-mbstring \
    pngquant \
    sudo \
    unzip \
    wget \
    zlib-dev

# Configure & Install Extension
RUN docker-php-ext-configure \
    opcache --enable-opcache &&\
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ &&\
    docker-php-ext-install \
    opcache \
    mysqli \
    pdo \
    pdo_mysql \
    sockets \
    json \
    intl \
    gd \
    xml \
    zip \
    bz2 \
    pcntl \
    bcmath

# Add Composer
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="./vendor/bin:$PATH"

ENV AKAUNTING_VERSION=1.3.17 \
    AKAUNTING_USER=www-data \
    AKAUNTING_INSTALL_DIR=/var/www/akaunting \
    AKAUNTING_DATA_DIR=/var/local/akaunting \
    AKAUNTING_RUNTIME_DIR=/usr/local/akaunting \
    AKAUNTING_BUILD_DIR=/tmp

VOLUME [ "/sock" "${AKAUNTING_INSTALL_DIR}" "${AKAUNTING_DATA_DIR}" ]

WORKDIR ${AKAUNTING_INSTALL_DIR}

COPY assets/runtime/ ${AKAUNTING_RUNTIME_DIR}/

COPY assets/tools/ /usr/local/bin/

RUN sed -i 's,^listen = .*,listen = /sock/docker.sock,' /usr/local/etc/php-fpm.d/zz-docker.conf \
 && sed -i 's/^;listen.group = .*/listen.group = www-data/' /usr/local/etc/php-fpm.d/www.conf \
 && sed -i 's/^;env\[PATH\]/env\[PATH\]/' /usr/local/etc/php-fpm.d/www.conf

ENTRYPOINT ["docker-entrypoint"]

CMD ["app:akaunting"]
