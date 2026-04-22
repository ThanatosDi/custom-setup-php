# PHP Runtime Image
ARG PHP_VERSION=8.4
ARG NODE_VERSION=lts
ARG PHP_EXTENSIONS=""

# 定義 Node.js 來源 stage（解決 COPY --from 不支援變數展開的問題）
FROM node:${NODE_VERSION}-trixie-slim AS node-source

FROM php:${PHP_VERSION}-cli

# 重新宣告 ARG（FROM 之後 ARG 會失效）
ARG PHP_EXTENSIONS

# 設定環境變數，避免安裝過程出現互動視窗
ENV DEBIAN_FRONTEND=noninteractive

# 安裝系統套件
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# Node.js（從 node-source stage 複製）
COPY --from=node-source /usr/local/bin/node /usr/local/bin/
COPY --from=node-source /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# PHP 設定（適用於 CI/CD 環境）
RUN echo "memory_limit = -1" > /usr/local/etc/php/conf.d/memory-limit.ini

# 基礎擴展
RUN install-php-extensions xml curl gd mbstring opcache zip bcmath @composer exif

# 資料庫相關（中等變動頻率）
# PHP 8.4 使用 mongodb-2.1.1，其他版本使用 1.21.5
RUN PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') && \
    if [ "$PHP_VER" = "8.4" ]; then \
        MONGO_VER="2.1.1"; \
    else \
        MONGO_VER="1.21.5"; \
    fi && \
    install-php-extensions mongodb-${MONGO_VER} redis sqlite3 memcached

# 其他擴展（較少用到）
RUN install-php-extensions xmlrpc imagick imap soap sockets

# 動態擴展（每次可能不同，支援逗號分隔格式如 "pcntl, sockets, mongodb-1.21.0"）
RUN if [ -n "${PHP_EXTENSIONS}" ]; then \
    EXTS=$(echo "${PHP_EXTENSIONS}" | tr ',' ' ' | tr -s ' '); \
    install-php-extensions ${EXTS}; \
fi


# 驗證安裝
RUN php -v && composer -V && node -v && npm -v

CMD ["php", "-v"]
