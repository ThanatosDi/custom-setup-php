# PHP Runtime

輕量化 PHP CLI 容器映像，內建常用擴展與 Node.js，適合在 CI/CD 工作流程中作為 job container 使用。

- **多版本支援**：PHP 8.1、8.2、8.3、8.4、8.5
- **多平台架構**：`linux/amd64`、`linux/arm64`
- **每日自動建置**：每日重新建置以取得最新基底映像與擴展更新
- **雙 Registry 發布**：同時推送至 GitHub Container Registry 與 Docker Hub

## 拉取映像

```bash
# GitHub Container Registry
docker pull ghcr.io/thanatosdi/php-runtime:8.4

# Docker Hub
docker pull thanatosdi/php-runtime:8.4
```

## 可用標籤

| 標籤 | 說明 |
|------|------|
| `8.1`, `8.2`, `8.3`, `8.4`, `8.5` | 各 PHP 版本最新映像 |
| `8.x-YYYYMMDD` | 特定日期版本（例如 `8.4-20260429`，時區 Asia/Taipei）|

## 預裝內容

| 類別 | 套件 |
|------|------|
| 基礎擴展 | xml, curl, gd, mbstring, opcache, zip, bcmath, exif |
| 資料庫 | mongodb, redis, sqlite3, memcached |
| 其他擴展 | xmlrpc, imagick, imap, soap, sockets |
| 工具 | Composer, Node.js (LTS), npm, git |

> [!NOTE]
> 於 PHP8.5 版 opcache 已包含在發行板中, 故不需在額外安裝

> MongoDB 擴展版本會依 PHP 版本自動選擇：PHP 8.1～8.3 安裝 `1.21.5`、PHP 8.4 安裝 `2.1.1`、PHP 8.5+ 安裝最新版。

## 在 GitHub Actions 使用

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/thanatosdi/php-runtime:8.4
    steps:
      - uses: actions/checkout@v4
      - run: composer install
      - run: php artisan test
```

## 本地建置

```bash
# 預設版本 (PHP 8.4)
docker build -f runtime.Dockerfile -t php-runtime .

# 指定 PHP 版本
docker build \
  --build-arg PHP_VERSION=8.3 \
  -f runtime.Dockerfile \
  -t php-runtime:8.3 .

# 額外安裝擴展（逗號分隔）
docker build \
  --build-arg PHP_VERSION=8.4 \
  --build-arg PHP_EXTENSIONS="pcntl,intl" \
  -f runtime.Dockerfile \
  -t php-runtime:8.4-custom .
```

## 自動建置流程

[`.github/workflows/runtime.yml`](.github/workflows/runtime.yml) 負責映像的自動建置與推送：

- **觸發條件**
  - `runtime.Dockerfile` 或 workflow 本身有變動時
  - 手動觸發（`workflow_dispatch`）
  - 每日排程（UTC 00:00）

- **建置策略**
  - 矩陣建置：5 個 PHP 版本 × 2 個平台 = 10 個並行建置
  - 採用 `push-by-digest` 後再透過 [`merge-docker-digests`](https://github.com/ThanatosDi/merge-docker-digests) action 合併 manifest list
  - 建置產出同時推送至 GHCR 與 Docker Hub

- **推送控制**
  - 透過 environment variable `PUSH_IMAGE` 控制是否實際推送
  - environment 依 branch 切換：`main` → `production`、其他 → `stage`

## 專案結構

```
.
├── runtime.Dockerfile           # PHP Runtime 映像定義
├── .github/
│   └── workflows/
│       └── runtime.yml          # 自動建置 workflow
├── LICENSE
└── README.md
```

## 可優化部分
1. node 版本不寫死 LTS, 使用 nvm 來預安裝 LTS 但可依照使用者狀況於 workflow 中調整版本


## 授權條款

[MIT License](LICENSE)
