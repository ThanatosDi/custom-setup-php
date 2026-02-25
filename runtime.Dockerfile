# PHP Runtime Image
ARG PHP_VERSION=8.4
ARG PHP_EXTENSIONS=""

FROM php:${PHP_VERSION}-cli-alpine

# 重新宣告 ARG（FROM 之後 ARG 會失效）
ARG PHP_EXTENSIONS

# 設定環境變數，避免安裝過程出現互動視窗
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN install-php-extensions \
    xml \
    xmlrpc \
    curl \
    gd \
    imagick \
    imap \
    mbstring \
    opcache \
    soap \
    zip \
    bcmath \
    mongodb \
    redis \
    sqlite3 \
    memcached \
    @composer \
    ${PHP_EXTENSIONS}


# 驗證安裝
RUN php -v && composer -V

CMD ["php", "-v"]
