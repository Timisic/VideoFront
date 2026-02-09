# 心理测评系统前端

基于 Vue 3 的心理测评系统前端应用,支持视频录制、人格分析和抑郁自评。

## 📋 目录

- [功能特性](#功能特性)
- [技术栈](#技术栈)
- [快速开始](#快速开始)
- [API 配置](#api-配置)
- [Mock 数据模式](#mock-数据模式)
- [项目结构](#项目结构)
- [开发说明](#开发说明)
- [部署](#部署)

## ✨ 功能特性

### 核心功能
- ✅ **引导弹窗** - 测评流程说明和注意事项
- ✅ **3秒倒计时** - 录制前准备时间,显示摄像头预览
- ✅ **视频录制** - 可手动停止(最少3秒),实时显示录制时长
- ✅ **阅读材料** - 录制时展示文字材料供用户阅读
- ✅ **自动上传** - 录制结束后自动上传到后端 API
- ✅ **格式转换** - WebM 自动转换为 MP4 格式
- ✅ **心理报告** - 大五人格雷达图 + 抑郁自评
- ✅ **PDF 导出** - 一键导出完整测评报告

### 测评维度
- **大五人格** (雷达图展示)
  - 宜人性 (BIG_A)
  - 尽责性 (BIG_C)
  - 外倾性 (BIG_E)
  - 神经质 (BIG_N)
  - 开放性 (BIG_O)
- **抑郁自评** (face_yyzp) - 单独高亮展示

## 🛠 技术栈

### 核心框架
- **Vue 3.4** - Composition API
- **Vite 5.0** - 快速构建工具

### UI 组件
- **Element Plus 2.5** - UI 组件库
- **ECharts 5.4** - 数据可视化(雷达图)

### 视频处理
- **MediaRecorder API** - 浏览器原生录制
- **FFmpeg.wasm 0.12** - WebM 转 MP4

### 其他工具
- **Axios 1.6** - HTTP 请求
- **html2canvas 1.4** - 页面截图
- **jsPDF 2.5** - PDF 生成

## 🚀 快速开始

### 安装依赖

```bash
npm install
```

### 启动开发服务器

```bash
npm run dev
```

访问: http://localhost:20053/

### 构建生产版本

```bash
npm run build
```

构建产物在 `dist/` 目录

## 🔌 API 配置

### 后端接口

- **地址**: `http://192.168.8.167:8080/api/v1/analysis/face_video`
- **方法**: POST
- **格式**: multipart/form-data
- **参数**: `video` (MP4 文件)

### 代理配置

开发环境代理配置在 `vite.config.js`:

```javascript
server: {
  port: 20053,
  host: '0.0.0.0',
  proxy: {
    '/api': {
      target: 'http://192.168.8.167:8080',
      changeOrigin: true
    }
  }
}
```

### 响应格式

```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "BIG_A": {
      "dimension_name": "宜人性",
      "score": 0.57,
      "raw_score": 57.0,
      "result": "高宜人性",
      "interpretation": "该个体属于高宜人性..."
    },
    "BIG_C": { ... },
    "BIG_E": { ... },
    "BIG_N": { ... },
    "BIG_O": { ... },
    "face_yyzp": {
      "dimension_name": "抑郁自评",
      "score": 0.1,
      "raw_score": 5.0,
      "result": "低",
      "interpretation": "轻度抑郁可能意味着..."
    }
  }
}
```

## 🎭 Mock 数据模式

### 启用/禁用

在 `src/api/index.js` 中修改:

```javascript
const USE_MOCK = true  // true: 使用 mock 数据, false: 使用真实后端
```

### Mock 数据特点

- ✅ 无需后端即可测试完整流程
- ✅ 模拟 2 秒网络延迟
- ✅ 包含完整的 6 个维度数据
- ✅ 控制台输出提示信息

### 何时使用

- **开发阶段**: 保持 `USE_MOCK = true` 进行前端开发
- **集成测试**: 改为 `USE_MOCK = false` 连接真实后端
- **生产部署**: 必须设置 `USE_MOCK = false`

## 📁 项目结构

```
VideoFront/
├── index.html              # HTML 入口
├── package.json            # 依赖配置
├── vite.config.js          # Vite 配置
├── README.md               # 项目说明
├── docs/                   # 文档目录
│   ├── FrontTech.md       # 技术方案
│   ├── PRD.md             # 产品需求
│   └── test_request.py    # API 测试脚本
└── src/
    ├── main.js             # 应用入口
    ├── App.vue             # 主应用(状态机)
    ├── style.css           # 全局样式
    ├── assets/
    │   └── material.js     # 阅读材料文本
    ├── api/
    │   ├── index.js        # API 接口(支持 mock)
    │   └── mockData.js     # Mock 数据
    ├── components/
    │   ├── GuideDialog.vue     # 引导弹窗
    │   ├── CountDown.vue       # 3秒倒计时
    │   ├── RecordingPanel.vue  # 录制面板
    │   ├── UploadLoading.vue   # 上传等待
    │   ├── ReportView.vue      # 报告展示
    │   └── ErrorRetry.vue      # 错误重试
    └── utils/
        ├── exportPdf.js        # PDF 导出
        └── convertToMp4.js     # WebM 转 MP4
```

## 💻 开发说明

### 状态机流程

```
guide → countdown → recording → uploading → report
                                    ↓ (失败)
                                  error → guide
```

`App.vue` 通过 `currentStep` 状态控制整个流程。

### 录制功能

- **最少录制时间**: 3 秒(防止误操作)
- **停止方式**: 手动点击"停止录制并上传"按钮
- **格式**: 录制 WebM,自动转换为 MP4

### 报告展示

- **雷达图**: 仅显示大五人格 5 个维度
- **抑郁自评**: 单独黄色高亮卡片展示
- **详细分析**: 每个维度的完整解释文字

### 修改阅读材料

编辑 `src/assets/material.js`:

```javascript
export const MATERIAL_TEXT = `
您的文字材料内容...
`.trim()
```

### 浏览器兼容性

- ✅ Chrome/Edge (推荐)
- ✅ Safari
- ⚠️ Firefox (部分功能可能受限)

**注意**: 摄像头 API 需要 HTTPS 或 localhost

## 🚢 部署

### 生产环境配置

1. **关闭 Mock 模式**

```javascript
// src/api/index.js
const USE_MOCK = false
```

2. **构建**

```bash
npm run build
```

3. **部署**

将 `dist/` 目录部署到服务器

### 部署地址

- **前端**: http://159.226.113.201:20053/
- **后端**: http://192.168.8.167:8080 (内网)

## 🔧 常见问题

### 1. 摄像头无法访问

**原因**: 浏览器权限未授予或使用 HTTP 协议

**解决**:
- 确保使用 HTTPS 或 localhost
- 检查浏览器摄像头权限设置

### 2. 视频上传失败

**原因**: 后端服务未启动或网络问题

**解决**:
- 检查后端服务状态
- 验证 API 地址配置
- 使用 Mock 模式进行前端测试

### 3. 报告不显示

**原因**: API 返回数据格式不匹配

**解决**:
- 检查控制台错误信息
- 验证 API 返回的数据结构
- 对比 `mockData.js` 中的数据格式

## 📝 Git 提交历史

```bash
# 查看提交历史
git log --oneline

# 主要提交
0c23d1f feat: 添加抑郁自评(face_yyzp)维度展示
18ead90 feat: 添加模拟数据支持和可手动停止的录制功能
72b3019 Initial commit: 心理测评系统前端完整实现
```