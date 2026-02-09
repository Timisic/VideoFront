# 🐛 FFmpeg 调试日志说明

## 📊 正常流程的控制台输出

如果一切正常，您应该在浏览器控制台看到以下日志：

```
🎬 开始视频转换流程...
📊 输入视频信息: {type: "video/webm", size: "2.34 MB"}
🔄 开始从本地加载 FFmpeg...
📂 FFmpeg 基础 URL: https://159.226.113.201:20443/ffmpeg
⏳ 正在加载 ffmpeg-core.js...
✅ ffmpeg-core.js Blob URL 创建成功
⏳ 正在加载 ffmpeg-core.wasm (31MB，可能需要几秒)...
✅ ffmpeg-core.wasm Blob URL 创建成功
⏳ 正在初始化 FFmpeg 实例...
FFmpeg 内部日志: ... (FFmpeg 内部消息)
✅ FFmpeg 加载成功！
💾 写入输入文件到 FFmpeg...
✅ 输入文件写入成功
🔄 开始转换 WebM → MP4...
FFmpeg 内部日志: ... (转换进度)
✅ 转换完成
📖 读取输出文件...
✅ 输出文件读取成功
📊 输出视频信息: {type: "video/mp4", size: "2.15 MB"}
🧹 清理临时文件...
✅ 清理完成
🎉 视频转换成功！
```

---

## 🔍 诊断卡住的位置

根据最后一条日志，可以判断卡在哪个步骤：

### 1. 卡在 "🔄 开始从本地加载 FFmpeg..."
**可能原因**: 
- Cross-Origin-Isolation 头未生效
- SharedArrayBuffer 不可用

**检查**:
```javascript
console.log('crossOriginIsolated:', crossOriginIsolated)
console.log('SharedArrayBuffer:', typeof SharedArrayBuffer)
```

### 2. 卡在 "⏳ 正在加载 ffmpeg-core.js..."
**可能原因**: 
- 文件 404
- 网络请求被阻止

**检查**: 
- Network 标签页查看 `/ffmpeg/ffmpeg-core.js` 请求状态

### 3. 卡在 "⏳ 正在加载 ffmpeg-core.wasm..."
**可能原因**: 
- WASM 文件太大，加载慢
- MIME 类型错误
- 内存不足

**检查**: 
- Network 标签页查看下载进度
- 等待 10-15 秒（31MB 文件）

### 4. 卡在 "⏳ 正在初始化 FFmpeg 实例..."
**可能原因**: 
- WASM 初始化失败
- SharedArrayBuffer 问题
- 浏览器兼容性问题

**检查**: 
- 查看是否有 JavaScript 错误
- 尝试不同浏览器（Chrome/Edge 推荐）

### 5. 卡在 "🔄 开始转换 WebM → MP4..."
**可能原因**: 
- 视频文件太大
- 转换耗时长
- FFmpeg 内部错误

**检查**: 
- 查看 "FFmpeg 内部日志" 是否有错误
- 等待更长时间（大视频可能需要 30 秒+）

---

## 🛠️ 快速诊断命令

在浏览器控制台执行：

```javascript
// 1. 检查 Cross-Origin-Isolation
console.log('crossOriginIsolated:', crossOriginIsolated)

// 2. 检查 SharedArrayBuffer
console.log('SharedArrayBuffer:', typeof SharedArrayBuffer)

// 3. 测试 FFmpeg 文件访问
fetch('/ffmpeg/ffmpeg-core.js')
  .then(r => console.log('JS 文件:', r.status, r.headers.get('content-type')))
  
fetch('/ffmpeg/ffmpeg-core.wasm')
  .then(r => console.log('WASM 文件:', r.status, r.headers.get('content-type')))

// 4. 检查内存使用
console.log('内存:', performance.memory)
```

---

## 💡 常见解决方案

### 如果 crossOriginIsolated = false
重新检查 Nginx 配置，确保有：
```nginx
add_header Cross-Origin-Embedder-Policy "require-corp" always;
add_header Cross-Origin-Opener-Policy "same-origin" always;
```

### 如果文件 404
检查 Docker 容器内文件是否存在：
```bash
sudo docker exec psychological-assessment ls -la /usr/share/nginx/html/ffmpeg/
```

### 如果加载太慢
- 等待更长时间（首次加载 31MB WASM 文件需要时间）
- 检查网络速度
- 刷新页面重试

---

## 📝 报告问题时请提供

1. **最后一条日志** - 卡在哪个步骤
2. **crossOriginIsolated 值** - true/false
3. **Network 标签截图** - FFmpeg 文件请求状态
4. **Console 错误** - 如果有红色错误信息
