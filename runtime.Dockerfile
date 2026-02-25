# PHP Runtime Image
ARG PHP_VERSION=8.4

FROM php:${PHP_VERSION}-bookworm

# 設定環境變數，避免安裝過程出現互動視窗
ENV DEBIAN_FRONTEND=noninteractive

# 1. 更新 apt 並安裝基礎工具 (software-properties-common 用於加入 PPA)
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    software-properties-common

# 2. 加入 Ondřej Surý 的 PHP PPA
RUN add-apt-repository ppa:ondrej/php && \
    apt-get update

# 3. 安裝 PHP (或改成你需要版本) 以及 Laravel/Larastan 常用擴充
# 請根據你的專案需求增減 extensions
RUN apt-get install -y \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-xmlrpc \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-dev \
    php${PHP_VERSION}-imap \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-mongodb \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-sqlite3 \
    php${PHP_VERSION}-memcached && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 安裝 Composer
# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'c8b085408188070d5f52bcfe4ecfbee5f727afa458b2573b8eaaf77b3419b0bf2768dc67c86944da1544f06fa544fd47') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('composer-setup.php'); exit(1); }" && \
    php composer-setup.php &&\
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# 驗證安裝
RUN php -v && composer -V

CMD ["php", "-v"]
