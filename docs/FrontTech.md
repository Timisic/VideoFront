# 二、前端技术方案

## 1. 技术选型

| 类别      | 选择                                      | 理由                                    |
| --------- | ----------------------------------------- | --------------------------------------- |
| 框架      | **Vue 3** + Composition API               | 轻量、开发效率高                        |
| 构建工具  | **Vite**                                  | 快速冷启动                              |
| UI 组件库 | **Element Plus**                          | PC 端成熟方案，弹窗/按钮/进度条开箱即用 |
| 图表库    | **ECharts**                               | 支持雷达图、柱状图、仪表盘等，覆盖面广  |
| PDF 导出  | **html2canvas** + **jsPDF**               | 页面截图转 PDF，最简单可靠              |
| 视频录制  | **MediaRecorder API**（原生）             | 无需第三方库                            |
| 视频格式  | 录制 webm → 前端用 **FFmpeg.wasm** 转 MP4 | 浏览器原生不支持直接录 MP4              |
| HTTP 请求 | **Axios**                                 | 支持上传进度监听                        |
| 样式方案  | **SCSS** + Element Plus 主题              | 快速开发                                |

> **关于 MP4 格式的说明：**
> 浏览器 MediaRecorder 原生输出 webm 格式。后端不可接受webm格式，请使用ffmpeg转mp4格式。

---

## 2. 项目结构

```
src/
├── App.vue                    # 根组件（状态机控制流程）
├── main.js
├── assets/
│   └── material.js            # 写死的文字材料
├── components/
│   ├── GuideDialog.vue        # 引导弹窗
│   ├── CountDown.vue          # 3s 倒计时
│   ├── RecordingPanel.vue     # 录制页面（摄像头 + 文字 + 进度条）
│   ├── UploadLoading.vue      # 上传等待 Loading
│   ├── ReportView.vue         # 报告图表展示
│   └── ErrorRetry.vue         # 异常提示 + 重新录制
├── composables/
│   ├── useCamera.js           # 摄像头开启/关闭
│   ├── useRecorder.js         # MediaRecorder 封装
│   └── useUpload.js           # 视频上传逻辑
├── utils/
│   ├── exportPdf.js           # PDF 导出
│   └── convertToMp4.js        # webm → mp4（如需要）
└── api/
    └── index.js               # 接口定义
```

---

## 3. 核心流程状态机

```
App.vue 通过一个 ref<string> currentStep 控制全局流程：

  'guide'  →  'countdown'  →  'recording'  →  'uploading'  →  'report'
                                                   │
                                                   ↓ (失败)
                                                 'error'  →  回到 'guide'
```

```vue
<!-- App.vue 核心逻辑 -->
<template>
  <GuideDialog    v-if="step === 'guide'"     @start="step = 'countdown'" />
  <CountDown      v-if="step === 'countdown'" @done="step = 'recording'" />
  <RecordingPanel v-if="step === 'recording'" @recorded="onRecorded" />
  <UploadLoading  v-if="step === 'uploading'" />
  <ReportView     v-if="step === 'report'"    :data="reportData" />
  <ErrorRetry     v-if="step === 'error'"     @retry="step = 'guide'" />
</template>
```

---

## 4. 关键模块实现要点

### 4.1 摄像头 & 录制（useRecorder.js）

```js
// 核心流程
const stream = await navigator.mediaDevices.getUserMedia({
  video: { width: 640, height: 480, facingMode: 'user' },
  audio: false   // ❓是否需要录音？默认否
})

const recorder = new MediaRecorder(stream, {
  mimeType: 'video/webm;codecs=vp9'
})

// 40s 后自动停止
setTimeout(() => recorder.stop(), 40000)

recorder.ondataavailable = (e) => {
  // 收集 blob → 转 mp4 → 上传
}
```

### 4.2 录制页面布局（RecordingPanel.vue）

```
┌──────────────────────────────────────────┐
│  ┌─────────────────┐  ┌──────────────┐   │
│  │                 │  │              │   │
│  │   文字材料区域    │  │  摄像头预览   │   │
│  │   (60% 宽度)    │  │  (40% 宽度)  │   │
│  │                 │  │              │   │
│  └─────────────────┘  └──────────────┘   │
│  ┌──────────────────────────────────────┐ │
│  │  ████████████░░░░░  剩余 28 秒       │ │
│  └──────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

### 4.3 上传（useUpload.js）

```js
const formData = new FormData()
formData.append('video', mp4Blob, 'recording.mp4')

const { data } = await axios.post('/api/upload', formData, {
  headers: { 'Content-Type': 'multipart/form-data' },
  timeout: 60000
})

// 如果是轮询方案：
// const taskId = data.taskId
// const report = await pollResult(taskId)
```

### 4.4 报告图表（ReportView.vue）

```
┌──────────────────────────────────────────┐
│              心理测评报告                   │
│  ┌──────────────┐  ┌──────────────────┐  │
│  │   雷达图      │  │  维度得分柱状图   │  │
│  └──────────────┘  └──────────────────┘  │
│  ┌──────────────────────────────────────┐ │
│  │          详细分析文字说明              │ │
│  └──────────────────────────────────────┘ │
│         [导出 PDF]    [重新测评]           │
└──────────────────────────────────────────┘
```

### 4.5 PDF 导出（exportPdf.js）

```js
import html2canvas from 'html2canvas'
import jsPDF from 'jspdf'

export async function exportPdf(elementId) {
  const el = document.getElementById(elementId)
  const canvas = await html2canvas(el, { scale: 2 })
  const pdf = new jsPDF('p', 'mm', 'a4')
  const imgData = canvas.toDataURL('image/png')
  const pdfWidth = pdf.internal.pageSize.getWidth()
  const pdfHeight = (canvas.height * pdfWidth) / canvas.width
  pdf.addImage(imgData, 'PNG', 0, 0, pdfWidth, pdfHeight)
  pdf.save('心理测评报告.pdf')
}
```
