# 🚀 HTTPS 部署快速指南

## 📦 需要上传的文件

将以下文件上传到服务器 `/home/ubuntu/hwj/VideoFront/docker-deploy/` 目录：

```
docker-deploy/
├── psychological-assessment.tar.gz    (25MB - Docker 镜像)
├── ssl/
│   ├── nginx-selfsigned.key          (SSL 私钥)
│   └── nginx-selfsigned.crt          (SSL 证书)
└── deploy-on-server-https.sh         (部署脚本)
```

---

## 🔧 服务器部署命令

```bash
# 1. SSH 登录服务器
ssh ubuntu@192.168.8.167

# 2. 进入部署目录
cd /home/ubuntu/hwj/VideoFront/docker-deploy/

# 3. 添加执行权限
chmod +x deploy-on-server-https.sh

# 4. 执行部署
./deploy-on-server-https.sh
```

---

## 🌐 访问地址

- **HTTPS** (推荐): `https://159.226.113.201:20443/`
- **HTTP** (自动重定向): `http://159.226.113.201:20053/`

---

## ⚠️ 首次访问

浏览器会显示安全警告（自签名证书正常现象）：

1. 点击 **"高级"**
2. 点击 **"继续访问"** 或 **"接受风险"**
3. 摄像头权限将正常工作 ✅

---

## ✅ 验证步骤

```bash
# 查看容器状态
sudo docker ps | grep psychological-assessment

# 查看日志
sudo docker logs psychological-assessment --tail 50

# 测试 HTTPS 访问
curl -k https://localhost:20443/
```

---

## 💡 常用命令

```bash
# 查看实时日志
sudo docker logs -f psychological-assessment

# 重启容器
sudo docker restart psychological-assessment

# 停止容器
sudo docker stop psychological-assessment
```

---

## 🔍 问题排查

### 容器无法启动
```bash
# 检查 SSL 证书文件是否存在
ls -la ssl/

# 查看容器错误日志
sudo docker logs psychological-assessment
```

### 摄像头仍无法访问
1. 确认使用 HTTPS 访问（地址栏有锁图标）
2. 检查浏览器是否已信任证书
3. 清除浏览器缓存后重试

---

完整文档请查看 [walkthrough.md](file:///Users/hong/.gemini/antigravity/brain/28f7559f-01d6-4e6d-94df-9c162de1282b/walkthrough.md)
