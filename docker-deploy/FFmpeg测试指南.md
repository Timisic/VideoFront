# FFmpeg 测试指南

## 🧪 部署前测试步骤

### 方法 1: 使用浏览器开发者工具测试

部署到服务器后，在浏览器中访问 `https://159.226.113.201:20443/`：

1. **打开开发者工具** (F12)
2. **切换到 Network 标签页**
3. **点击开始录制按钮**
4. **刷新页面**
5. **查找 FFmpeg 文件请求**:
   - 搜索 `ffmpeg-core.js`
   - 搜索 `ffmpeg-core.wasm`
6. **检查状态码**:
   - ✅ 应该是 `200 OK`
   - ❌ 如果是 `404 Not Found`，说明 Nginx 配置有问题

### 方法 2: 使用 curl 命令测试

SSH 登录服务器后，在容器内测试：

```bash
# 测试 JS 文件
curl -I https://159.226.113.201:20443/ffmpeg/ffmpeg-core.js

# 测试 WASM 文件
curl -I https://159.226.113.201:20443/ffmpeg/ffmpeg-core.wasm
```

**期望输出**:
```
HTTP/2 200
content-type: application/javascript  # 或 application/wasm
```

### 方法 3: 在浏览器控制台测试 FFmpeg 加载

1. 访问 `https://159.226.113.201:20443/`
2. 打开浏览器控制台 (F12 → Console)
3. 粘贴以下代码并执行:

```javascript
// 测试 FFmpeg 文件是否可访问
fetch('/ffmpeg/ffmpeg-core.js')
  .then(r => console.log('ffmpeg-core.js:', r.status, r.ok ? '✅' : '❌'))
  .catch(e => console.error('ffmpeg-core.js 加载失败:', e))

fetch('/ffmpeg/ffmpeg-core.wasm')
  .then(r => console.log('ffmpeg-core.wasm:', r.status, r.ok ? '✅' : '❌'))
  .catch(e => console.error('ffmpeg-core.wasm 加载失败:', e))
```

**期望输出**:
```
ffmpeg-core.js: 200 ✅
ffmpeg-core.wasm: 200 ✅
```

---

## 🔍 查看实际的 FFmpeg 加载日志

在应用中录制视频时，打开浏览器控制台，会看到以下日志：

**成功加载**:
```
开始视频转换...
从本地加载 FFmpeg...
FFmpeg 加载成功
视频转换成功
```

**加载失败**:
```
开始视频转换...
从本地加载 FFmpeg...
FFmpeg 加载失败: Error: failed to import ffmpeg-core.js
视频转换失败，使用原始 WebM 格式: FFmpeg 加载失败: undefined
```

---

## 🐛 常见问题排查

### 问题 1: 404 Not Found
**原因**: Nginx 配置未正确提供 FFmpeg 文件

**解决**: 检查 `nginx-docker.conf` 中的 `/ffmpeg/` location 块是否存在

### 问题 2: MIME 类型错误
**原因**: `.wasm` 文件 MIME 类型不正确

**解决**: 确保 Nginx 配置中设置了 `application/wasm`

### 问题 3: CORS 错误
**原因**: SharedArrayBuffer 需要特定的 CORS 头

**解决**: 确保设置了:
- `Cross-Origin-Embedder-Policy: require-corp`
- `Cross-Origin-Opener-Policy: same-origin`

---

## ✅ 验证清单

部署后验证：
- [ ] `/ffmpeg/ffmpeg-core.js` 返回 200
- [ ] `/ffmpeg/ffmpeg-core.wasm` 返回 200
- [ ] 控制台显示 "FFmpeg 加载成功"
- [ ] 视频录制和转换功能正常
- [ ] 视频上传到后端成功
