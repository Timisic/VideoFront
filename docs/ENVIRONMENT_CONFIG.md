# 环境配置切换指南

## 测试环境 vs 生产环境

### 快速对照表

| 配置项 | 测试环境 | 生产环境 | 文件位置 |
|--------|---------|---------|----------|
| Mock 数据 | ✅ 启用 | ❌ 禁用 | `src/api/index.js` |
| 录制方式 | 手动停止(≥3秒) | 手动停止(≥3秒) | `src/components/RecordingPanel.vue` |
| 后端 API | 代理到内网 | 代理到内网 | `vite.config.js` |

---

## 配置详解

### 1. Mock 数据模式

#### 📍 文件: `src/api/index.js`

**测试环境** (当前):
```javascript
// 第 5 行
const USE_MOCK = true  // 使用模拟数据,无需后端
```

**生产环境**:
```javascript
// 第 5 行
const USE_MOCK = false  // 连接真实后端 API
```

#### 作用说明
- `true`: 使用 `mockData.js` 中的模拟数据,2秒后返回结果
- `false`: 调用真实后端 API `http://192.168.8.167:8080/api/v1/analysis/face_video`

---

### 2. 录制时长控制

#### 📍 文件: `src/components/RecordingPanel.vue`

**当前配置**: 手动停止模式
- 最少录制 3 秒
- 用户点击"停止录制并上传"按钮结束
- 实时显示"已录制 X 秒"

**如需改为固定40秒自动停止**:

需要修改以下部分:

1. **恢复进度条显示** (第 18-22 行):
```vue
<!-- 替换当前的时间显示和按钮 -->
<div class="progress-bar">
  <el-progress 
    :percentage="progress" 
    :show-text="false"
    :stroke-width="8"
  />
  <div class="time-remaining">剩余 {{ remainingTime }} 秒</div>
</div>
```

2. **修改脚本逻辑** (第 44-77 行):
```javascript
const RECORDING_DURATION = 40000 // 40 秒
const progress = ref(0)
const remainingTime = ref(40)

// 在 startRecording() 中添加自动停止逻辑
progressTimer = setInterval(() => {
  const elapsed = Date.now() - startTime
  const progressPercent = Math.min((elapsed / RECORDING_DURATION) * 100, 100)
  progress.value = progressPercent
  remainingTime.value = Math.max(0, Math.ceil((RECORDING_DURATION - elapsed) / 1000))
  
  if (elapsed >= RECORDING_DURATION) {
    clearInterval(progressTimer)
    mediaRecorder.stop()  // 自动停止
  }
}, 100)
```

3. **删除手动停止函数** `handleStop()`

---

### 3. 后端 API 配置

#### 📍 文件: `vite.config.js`

**开发环境代理** (当前):
```javascript
server: {
  port: 20053,
  host: '0.0.0.0',
  proxy: {
    '/api': {
      target: 'http://192.168.8.167:8080',  // 内网后端
      changeOrigin: true
    }
  }
}
```

**生产环境**:
- 构建后部署到 `http://159.226.113.201:20053/`
- 需要配置 Nginx 反向代理到后端

---

## 自动显示报告机制

### 流程说明

```
用户停止录制
    ↓
显示 "AI 正在分析中" Loading
    ↓
等待后端处理 (可能需要较长时间)
    ↓
后端返回数据
    ↓
自动跳转到报告页面 ✅
    ↓
渲染雷达图和维度分析
```

### 代码实现

**文件**: `src/App.vue` (第 60-78 行)

```javascript
async function handleRecorded(webmBlob) {
  currentStep.value = 'uploading'  // 显示 Loading
  
  try {
    // 1. 转换格式
    const mp4Blob = await convertToMp4(webmBlob)
    
    // 2. 上传并等待后端处理 (无超时限制)
    const response = await uploadVideo(mp4Blob)
    
    // 3. 成功后自动显示报告
    if (response.code === 0) {
      reportData.value = response.data
      currentStep.value = 'report'  // 自动切换到报告页面
    } else {
      throw new Error(response.msg || '分析失败')
    }
  } catch (error) {
    // 4. 失败则显示错误页面
    errorMessage.value = error.message || '上传或分析失败,请重试'
    currentStep.value = 'error'
  }
}
```

### 超时设置

**文件**: `src/api/index.js` (第 8 行)

```javascript
const api = axios.create({
  baseURL: '/api',
  timeout: 120000  // 120秒超时,可根据后端处理时间调整
})
```

**建议**:
- 如果后端处理时间超过 2 分钟,增加 `timeout` 值
- 例如: `timeout: 300000` (5分钟)

---

## 快速切换命令

### 切换到生产环境

```bash
# 1. 关闭 Mock 模式
sed -i '' 's/const USE_MOCK = true/const USE_MOCK = false/' src/api/index.js

# 2. 构建
npm run build

# 3. 部署 dist/ 目录
```

### 切换回测试环境

```bash
# 启用 Mock 模式
sed -i '' 's/const USE_MOCK = false/const USE_MOCK = true/' src/api/index.js
```

---

## 常见问题

### Q1: 后端处理时间很长,用户会等待吗?

**A**: 是的,页面会一直显示 Loading 动画,直到:
- 后端返回结果 → 自动显示报告
- 超时 (120秒) → 显示错误页面
- 网络错误 → 显示错误页面

### Q2: 如何调整超时时间?

**A**: 修改 `src/api/index.js` 第 8 行:
```javascript
timeout: 300000  // 改为 5 分钟
```

### Q3: Mock 模式下会调用真实后端吗?

**A**: 不会。`USE_MOCK = true` 时完全使用本地模拟数据,不发送任何网络请求。

### Q4: 如何验证是否在使用 Mock 模式?

**A**: 打开浏览器控制台,上传时会看到:
```
Using mock data (backend not available)
```

---

## 检查清单

部署到生产环境前,请确认:

- [ ] `src/api/index.js` 中 `USE_MOCK = false`
- [ ] 后端服务运行正常
- [ ] 网络连接正常
- [ ] 超时时间设置合理
- [ ] 已测试完整流程
