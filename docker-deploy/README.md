# 📦 Docker 部署指南

## 🚀 快速开始

### 1️⃣ 本地构建（Mac）
```bash
cd /Users/hong/Downloads/Gemini/VideoFront
./build-docker.sh
```

生成文件位于 `docker-deploy/` 目录：
- `psychological-assessment.tar.gz` (Docker 镜像)
- `ssl/` (SSL 证书)
- `deploy-on-server.sh` (部署脚本)

### 2️⃣ 上传到服务器
将 `docker-deploy/` 目录中的所有文件上传到服务器：
```
/home/ubuntu/hwj/VideoFront/docker-deploy/
```

### 3️⃣ 服务器部署
```bash
ssh ubuntu@192.168.8.167
cd /home/ubuntu/hwj/VideoFront/docker-deploy/
chmod +x deploy-on-server.sh
./deploy-on-server.sh
```

---

## 🌐 访问地址

- **HTTPS**: `https://159.226.113.201:20443/` ⭐ 推荐
- **HTTP**: `http://159.226.113.201:20053/` (自动重定向到 HTTPS)

---

## ⚠️ 首次访问

浏览器会显示安全警告（自签名证书）：
1. 点击 **"高级"**
2. 点击 **"继续访问"**
3. 摄像头权限正常 ✅

---

## 🔧 常用命令

```bash
# 查看容器状态
sudo docker ps | grep psychological-assessment

# 查看日志
sudo docker logs -f psychological-assessment

# 重启容器
sudo docker restart psychological-assessment

# 停止容器
sudo docker stop psychological-assessment
```

---

## 📝 技术说明

### 端口
- `20053`: HTTP (重定向到 HTTPS)
- `20443`: HTTPS (主要端口)

### 后端连接
- 容器通过 `host.docker.internal:8080` 访问宿主机后端
- 需要后端服务在 `192.168.8.167:8080` 运行

### SSL 证书
- 自签名证书，有效期 365 天
- 位置: `docker-deploy/ssl/`

---

## 🐛 问题排查

### 摄像头无法访问
- 确认使用 HTTPS 访问
- 检查是否已信任证书

### 视频上传失败
- 查看容器日志: `sudo docker logs psychological-assessment`
- 确认后端服务正常: `curl http://192.168.8.167:8080`

### 容器无法启动
- 检查 SSL 证书: `ls -la docker-deploy/ssl/`
- 查看错误日志: `sudo docker logs psychological-assessment`
