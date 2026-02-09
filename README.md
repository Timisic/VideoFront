# 心理测评系统前端

基于 Vue 3 + Vite + Element Plus 开发的心理测评系统前端应用。

## 功能特性

- 引导说明弹窗
- 3秒倒计时准备
- 40秒视频录制(含文字材料阅读)
- 自动上传视频到后端
- WebM 转 MP4 格式
- 心理测评报告展示(雷达图)
- PDF 报告导出

## 技术栈

- Vue 3 (Composition API)
- Vite
- Element Plus
- ECharts (雷达图)
- FFmpeg.wasm (视频格式转换)
- html2canvas + jsPDF (PDF导出)

## 开发

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build
```

## 配置

后端 API 地址配置在 `vite.config.js` 中:

```javascript
proxy: {
  '/api': {
    target: 'http://192.168.8.167:8080',
    changeOrigin: true
  }
}
```

## 部署

应用将部署在 `http://159.226.113.201:20053/`

## 项目结构

```
src/
├── App.vue                 # 主应用(状态机)
├── main.js                 # 入口文件
├── style.css              # 全局样式
├── assets/
│   └── material.js        # 文字材料
├── components/
│   ├── GuideDialog.vue    # 引导弹窗
│   ├── CountDown.vue      # 倒计时
│   ├── RecordingPanel.vue # 录制面板
│   ├── UploadLoading.vue  # 上传等待
│   ├── ReportView.vue     # 报告展示
│   └── ErrorRetry.vue     # 错误重试
├── utils/
│   ├── exportPdf.js       # PDF导出
│   └── convertToMp4.js    # 视频格式转换
└── api/
    └── index.js           # API接口
```
