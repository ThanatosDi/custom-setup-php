# 使用官方 Runner 當作基底
FROM myoung34/github-runner:ubuntu-noble

# 重要：再次宣告 ARG，因為 FROM 之後 ARG 會被重置
ARG PHP_VERSION=8.4
ARG PHP_EXTENSIONS=mongodb redis sqlite3 gd bcmath
ARG RUNNER_VERSION=2.330.0

# 設定環境變數，避免安裝過程出現互動視窗
ENV DEBIAN_FRONTEND=noninteractive

# 1. 更新 apt 並安裝基礎工具 (software-properties-common 用於加入 PPA)
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    git \
    software-properties-common

    
# 2. 加入 Ondřej Surý 的 PHP PPA (這是 Ubuntu 安裝最新 PHP 的標準姿勢)
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
    php${PHP_VERSION}-memcached

# 4. 安裝 Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 5. 清理快取以縮小 Image 大小
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 驗證安裝
RUN php -v && composer -V
