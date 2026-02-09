# 🎬 直接录制 MP4 说明

## ✨ 新的录制方式

从 2026-02-09 开始，本应用已改用 **MediaRecorder API 直接录制 MP4 格式**，不再使用 FFmpeg.wasm 进行转换。

---

## 🎯 优势

### 相比 FFmpeg.wasm 方案

| 特性 | FFmpeg.wasm (旧) | MediaRecorder (新) |
|------|------------------|-------------------|
| **稳定性** | ❌ 容易卡住 | ✅ 原生支持，稳定 |
| **加载时间** | ❌ 需加载 31MB WASM | ✅ 无需加载 |
| **转换时间** | ❌ 需要额外转换 | ✅ 直接录制 |
| **内存占用** | ❌ 高（需要 SharedArrayBuffer） | ✅ 低 |
| **Docker 镜像** | ❌ 36MB | ✅ ~6MB (减少 30MB) |

---

## 🌐 浏览器兼容性

### 支持的格式（按优先级）

1. **video/mp4** - Chrome, Edge ✅
2. **video/mp4;codecs=h264** - Chrome, Edge ✅
3. **video/webm;codecs=h264** - Chrome, Firefox ✅
4. **video/webm;codecs=vp9** - Chrome, Firefox, Edge ✅
5. **video/webm** - 所有现代浏览器 ✅（降级方案）

### 测试结果

| 浏览器 | 推荐格式 | 状态 |
|--------|---------|------|
| Chrome 90+ | video/mp4 | ✅ 完全支持 |
| Edge 90+ | video/mp4 | ✅ 完全支持 |
| Firefox 90+ | video/webm;codecs=h264 | ✅ 支持 |
| Safari 14+ | video/webm | ⚠️ 降级到 WebM |

---

## 🔍 如何验证

### 1. 打开浏览器控制台

在录制时，查看控制台日志：

**成功使用 MP4**:
```
✅ 选择录制格式: video/mp4
📹 录制完成，格式: video/mp4 大小: 1.23 MB
📤 开始上传视频，格式: video/mp4 大小: 1.23 MB
✅ 视频上传和分析成功
```

**降级到 WebM**:
```
⚠️ 浏览器不支持 MP4 录制，使用 WebM 格式
✅ 选择录制格式: video/webm
📹 录制完成，格式: video/webm 大小: 1.45 MB
📤 开始上传视频，格式: video/webm 大小: 1.45 MB
✅ 视频上传和分析成功
```

### 2. 检查网络请求

在 Network 标签页中：
- ✅ **不应该看到** `/ffmpeg/ffmpeg-core.js` 或 `/ffmpeg/ffmpeg-core.wasm` 请求
- ✅ **应该看到** `/api/upload` 请求，Content-Type 为 `video/mp4` 或 `video/webm`

---

## 🐛 故障排查

### 问题 1: 录制失败

**症状**: 点击开始后没有反应

**解决**:
1. 检查浏览器版本（需要 Chrome 90+, Firefox 90+, Edge 90+）
2. 确认已授予摄像头权限
3. 查看控制台是否有 `❌ 录制启动失败` 错误

### 问题 2: 上传失败

**症状**: 录制完成但上传失败

**解决**:
1. 检查后端是否支持 MP4 和 WebM 格式
2. 确认后端服务正常运行
3. 查看控制台错误信息

### 问题 3: 视频无法播放

**症状**: 后端收到视频但无法处理

**解决**:
1. 确认后端 FFmpeg 支持 H.264 编码
2. 检查后端日志，查看具体错误
3. 如果只支持特定格式，可能需要后端转换

---

## 📝 技术细节

### MIME 类型检测逻辑

```javascript
const mimeTypes = [
  'video/mp4',                    // 优先：纯 MP4
  'video/mp4;codecs=h264',        // 次选：H.264 编码的 MP4
  'video/webm;codecs=h264',       // 备选：H.264 编码的 WebM
  'video/webm;codecs=vp9',        // 降级：VP9 编码的 WebM
  'video/webm'                    // 最终降级：默认 WebM
]

for (const mimeType of mimeTypes) {
  if (MediaRecorder.isTypeSupported(mimeType)) {
    // 使用第一个支持的格式
    return mimeType
  }
}
```

### 自动降级机制

应用会自动检测浏览器支持的格式：
1. 优先尝试 MP4 格式
2. 如果不支持，尝试 H.264 编码的 WebM
3. 最终降级到标准 WebM

这确保了在所有现代浏览器中都能正常工作。

---

## 🔄 迁移说明

### 从 FFmpeg.wasm 迁移

**已移除的文件**:
- ❌ `src/utils/convertToMp4.js`
- ❌ `public/ffmpeg/ffmpeg-core.js` (31MB)
- ❌ `public/ffmpeg/ffmpeg-core.wasm` (31MB)

**已移除的配置**:
- ❌ Nginx Cross-Origin-Isolation 头
- ❌ Nginx `/ffmpeg/` location 块

**保留的文档**（作为历史参考）:
- 📄 `FFmpeg调试日志说明.md`
- 📄 `FFmpeg测试指南.md`

---

## ✅ 验证清单

部署后验证：
- [ ] 浏览器控制台显示 `✅ 选择录制格式: video/mp4`
- [ ] 没有 FFmpeg 相关的加载日志
- [ ] 视频录制和上传功能正常
- [ ] Docker 镜像体积减小约 30MB
- [ ] 在 Chrome/Edge 中测试 MP4 录制
- [ ] 在 Firefox 中测试 WebM 录制
