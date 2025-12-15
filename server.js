const express = require('express');
const puppeteer = require('puppeteer');
const app = express();

// 允許接收較大的 HTML 字串 (設定為 10MB 上限)
app.use(express.json({ limit: '10mb' }));

app.post('/render', async (req, res) => {
    try {
        // 1. 從 Dify 接收 HTML 內容
        const { html } = req.body;

        if (!html) {
            return res.status(400).send('Error: Missing "html" in request body');
        }

        console.log("收到渲染請求，開始啟動瀏覽器...");

        // 2. 啟動 Puppeteer (無頭瀏覽器)
        const browser = await puppeteer.launch({
            args: ['--no-sandbox', '--disable-setuid-sandbox'], // 雲端環境必須加這行
            headless: 'new'
        });

        const page = await browser.newPage();

        // 3. 設定畫布大小 (配合您的模版 1920x1080)
        await page.setViewport({
            width: 1920,
            height: 1080,
            deviceScaleFactor: 1, // 1:1 輸出，若要更清晰可設為 2
        });

        // 4. 載入 HTML
        // waitUntil: 'networkidle0' 確保圖片都載入完才截圖
        await page.setContent(html, { waitUntil: 'networkidle0' });

        // 5. 截圖
        const imageBuffer = await page.screenshot({
            type: 'png',
            fullPage: false // 只截取視窗大小
        });

        await browser.close();

        // 6. 直接回傳圖片檔案給 Dify
        res.set('Content-Type', 'image/png');
        res.send(imageBuffer);
        console.log("渲染完成，圖片已回傳");

    } catch (error) {
        console.error("渲染失敗:", error);
        res.status(500).send('Internal Server Error: ' + error.message);
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Render Service is running on port ${PORT}`);
});