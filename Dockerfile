# ---------------------------------------------------------------
# 階段 1: 設定基底映像檔
# 使用 Node.js 20 作為執行環境
# ---------------------------------------------------------------
FROM node:20

# 設定環境變數
# 確保 Puppeteer 下載 Chromium (或是使用系統 Chrome，這邊採用 Puppeteer 內建版本比較簡單，但需補齊系統依賴)
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=false

# ---------------------------------------------------------------
# 階段 2: 安裝系統層級依賴 (System Dependencies)
# 包含：
# 1. 執行 Chrome 瀏覽器所需的數十個 Linux 函式庫 (libdrm, libnss3 等)
# 2. 官方 Google Noto CJK 繁體中文標準字型 (fonts-noto-cjk)
# ---------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libgbm1 \
    libasound2 \
    libpangocairo-1.0-0 \
    libxss1 \
    libgtk-3-0 \
    libxshmfence1 \
    libglu1 \
    libdrm2 \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libnspr4 \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxfixes3 \
    libxi6 \
    libxtst6 \
    xdg-utils \
    wget \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------
# 階段 3: 安裝您的「自訂字型」 (Custom Fonts)
# 將專案根目錄下 fonts/ 資料夾內的檔案複製到 Linux 系統字型庫
# ---------------------------------------------------------------

# 切換工作目錄到系統字型資料夾
WORKDIR /usr/share/fonts/custom

# 將您電腦 fonts 資料夾內的所有檔案複製進去
# 注意：您的專案根目錄必須要有 fonts 資料夾
COPY ./fonts/* ./

# 執行指令刷新 Linux 字型快取，讓系統認得新字型
RUN fc-cache -fv

# ---------------------------------------------------------------
# 階段 4: 安裝 Node.js 專案依賴 (App Setup)
# ---------------------------------------------------------------

# 切換回應用程式工作目錄
WORKDIR /app

# 複製 package.json (先做這步是為了利用 Docker 快取機制加速)
COPY package*.json ./

# 安裝 npm 套件 (包含 puppeteer, express 等)
RUN npm install

# 複製剩餘的所有程式碼 (server.js 等)
COPY . .

# ---------------------------------------------------------------
# 階段 5: 啟動設定
# ---------------------------------------------------------------

# 開放 Port (Zeabur 預設通常會注入 PORT=8080)
EXPOSE 8080

# 啟動伺服器
CMD ["node", "server.js"]