# PHP Runtime Image
ARG PHP_VERSION=8.4
ARG NODE_VERSION=lts
ARG NVM_VERSION=v0.40.1
ARG PHP_EXTENSIONS=""

FROM php:${PHP_VERSION}-cli

# 重新宣告 ARG（FROM 之後 ARG 會失效）
ARG PHP_EXTENSIONS
ARG NODE_VERSION
ARG NVM_VERSION

# 設定環境變數，避免安裝過程出現互動視窗
ENV DEBIAN_FRONTEND=noninteractive

# 安裝系統套件
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# 安裝 fnm 但暫時不使用
ENV FNM_PATH=/usr/local/fnm

RUN curl -fsSL https://fnm.vercel.app/install | bash

# 安裝 nvm 與 Node.js（預設 LTS，可透過 build arg NODE_VERSION 指定特定版本）
ENV NVM_DIR=/usr/local/nvm

RUN mkdir -p "$NVM_DIR" \
    && curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash \
    && . "$NVM_DIR/nvm.sh" \
    && if [ "$NODE_VERSION" = "lts" ]; then \
         nvm install --lts \
         && nvm alias default 'lts/*'; \
       else \
         nvm install "$NODE_VERSION" \
         && nvm alias default "$NODE_VERSION"; \
       fi \
    && nvm use default \
    && DEFAULT_NODE="$(nvm version default)" \
    && ln -sf "$NVM_DIR/versions/node/$DEFAULT_NODE/bin/node" /usr/local/bin/node \
    && ln -sf "$NVM_DIR/versions/node/$DEFAULT_NODE/bin/npm" /usr/local/bin/npm \
    && ln -sf "$NVM_DIR/versions/node/$DEFAULT_NODE/bin/npx" /usr/local/bin/npx \
    && nvm cache clear

# 讓互動 shell（bash login shell）也能直接使用 nvm 指令
RUN printf '%s\n' \
      'export NVM_DIR="/usr/local/nvm"' \
      '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' \
      '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"' \
      > /etc/profile.d/nvm.sh

# PHP 設定（適用於 CI/CD 環境）
RUN echo "memory_limit = -1" > /usr/local/etc/php/conf.d/memory-limit.ini

# 基礎擴展
RUN install-php-extensions xml curl gd mbstring opcache zip bcmath @composer exif

# 資料庫相關（中等變動頻率）
# ext-mongodb
# PHP8.5 安裝最新版
# PHP8.4 安裝 2.1.1
# PHP8.1~8.3 安裝 1.21.5

RUN PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') && \
    case "$PHP_VER" in \
      "8.1" | "8.2" | "8.3") \
        install-php-extensions mongodb-1.21.5 redis sqlite3 memcached \
        ;; \
      "8.4") \
        install-php-extensions mongodb-2.1.1 redis sqlite3 memcached \
        ;; \
      *) \
        install-php-extensions mongodb redis sqlite3 memcached \
        ;; \
    esac

# 其他擴展（較少用到）
RUN install-php-extensions xmlrpc imagick imap soap sockets rdkafka

# 動態擴展（每次可能不同，支援逗號分隔格式如 "pcntl, sockets, mongodb-1.21.0"）
RUN if [ -n "${PHP_EXTENSIONS}" ]; then \
    EXTS=$(echo "${PHP_EXTENSIONS}" | tr ',' ' ' | tr -s ' '); \
    install-php-extensions ${EXTS}; \
fi


# 驗證安裝
RUN php -v && composer -V && node -v && npm -v

CMD ["php", "-v"]
