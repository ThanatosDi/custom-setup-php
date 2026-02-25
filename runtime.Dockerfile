# PHP Runtime Image
ARG PHP_VERSION=8.4
ARG PHP_EXTENSIONS=""

FROM php:${PHP_VERSION}-cli-alpine

# 重新宣告 ARG（FROM 之後 ARG 會失效）
ARG PHP_EXTENSIONS

# 設定環境變數，避免安裝過程出現互動視窗
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

# 基礎擴展
RUN install-php-extensions xml curl gd mbstring opcache zip bcmath @composer

# 資料庫相關（中等變動頻率）
RUN install-php-extensions mongodb redis sqlite3 memcached

# 其他擴展（較少用到）
RUN install-php-extensions xmlrpc imagick imap soap

# 動態擴展（每次可能不同）
RUN if [ -n "${PHP_EXTENSIONS}" ]; then install-php-extensions ${PHP_EXTENSIONS}; fi


# 驗證安裝
RUN php -v && composer -V

CMD ["php", "-v"]
