# Docker 镜像拉取问题解决方案

## 问题描述

Linux 服务器无法从 Docker Hub 拉取镜像,错误信息:
```
Get "https://registry-1.docker.io/v2/": net/http: request canceled while waiting for connection
```

## 原因

- 网络连接问题
- Docker Hub 访问受限
- 防火墙或代理配置问题

---

## 🎯 推荐方案: 本地构建后上传

### 优点
- ✅ 不依赖服务器网络
- ✅ 构建速度快(本地网络好)
- ✅ 可重复使用镜像文件
- ✅ 适合内网服务器

### 使用方法

#### 方法 1: 使用自动化脚本 (最简单)

```bash
# 1. 修改脚本中的服务器地址
nano deploy-docker.sh
# 修改: SERVER="user@159.226.113.201"

# 2. 添加执行权限
chmod +x deploy-docker.sh

# 3. 运行部署
./deploy-docker.sh
```

**脚本会自动完成**:
1. 本地构建 Docker 镜像
2. 保存并压缩镜像文件
3. 上传到服务器
4. 在服务器上加载并运行
5. 清理临时文件

---

#### 方法 2: 手动步骤

##### 步骤 1: 本地构建镜像

```bash
# 在 Mac 上构建
cd /Users/hong/Downloads/Gemini/VideoFront
docker build -t psychological-assessment:latest .
```

##### 步骤 2: 保存镜像为文件

```bash
# 保存镜像
docker save psychological-assessment:latest > psychological-assessment.tar

# 查看文件大小
ls -lh psychological-assessment.tar

# 压缩以加快传输
gzip psychological-assessment.tar
```

##### 步骤 3: 上传到服务器

```bash
# 上传镜像文件
scp psychological-assessment.tar.gz user@159.226.113.201:/tmp/
```

##### 步骤 4: 服务器端加载并运行

```bash
# SSH 登录服务器
ssh user@159.226.113.201

# 解压
cd /tmp
gunzip psychological-assessment.tar.gz

# 加载镜像
docker load < psychological-assessment.tar

# 验证镜像已加载
docker images | grep psychological

# 运行容器
docker run -d \
  --name psychological-assessment \
  -p 20053:20053 \
  --restart unless-stopped \
  --add-host host.docker.internal:host-gateway \
  psychological-assessment:latest

# 查看状态
docker ps
docker logs psychological-assessment

# 清理临时文件
rm /tmp/psychological-assessment.tar
```

---

## 🔧 其他解决方案

### 方案 2: 配置 Docker 镜像加速器

如果服务器可以访问国内镜像源,可以配置加速器:

```bash
# 创建或编辑 Docker 配置
sudo mkdir -p /etc/docker
sudo nano /etc/docker/daemon.json
```

添加以下内容:

```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
```

重启 Docker:

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

验证配置:

```bash
docker info | grep -A 10 "Registry Mirrors"
```

---

### 方案 3: 使用代理

如果服务器有 HTTP 代理:

```bash
# 创建 Docker 服务配置目录
sudo mkdir -p /etc/systemd/system/docker.service.d

# 创建代理配置文件
sudo nano /etc/systemd/system/docker.service.d/http-proxy.conf
```

添加:

```ini
[Service]
Environment="HTTP_PROXY=http://proxy.example.com:8080"
Environment="HTTPS_PROXY=http://proxy.example.com:8080"
Environment="NO_PROXY=localhost,127.0.0.1"
```

重启 Docker:

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

---

### 方案 4: 使用国内基础镜像

修改 `Dockerfile`,使用国内镜像源:

```dockerfile
# 使用阿里云镜像
FROM registry.cn-hangzhou.aliyuncs.com/library/node:18-alpine AS builder

# 或使用腾讯云镜像
FROM ccr.ccs.tencentyun.com/library/node:18-alpine AS builder
```

**注意**: 这需要在服务器上重新构建,可能还是会遇到网络问题。

---

## 📊 方案对比

| 方案 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| 本地构建上传 | 不依赖服务器网络,速度快 | 需要上传大文件 | ⭐⭐⭐⭐⭐ |
| 镜像加速器 | 配置简单 | 可能仍然不稳定 | ⭐⭐⭐ |
| 配置代理 | 一次配置长期有效 | 需要有可用代理 | ⭐⭐⭐ |
| 国内镜像 | 访问速度快 | 镜像可能不是最新 | ⭐⭐ |

---

## 🎯 推荐流程

### 首次部署

```bash
# 1. 使用本地构建上传方案
./deploy-docker.sh
```

### 后续更新

```bash
# 代码更新后,重新运行部署脚本
./deploy-docker.sh
```

---

## 🔍 验证部署

```bash
# SSH 登录服务器
ssh user@159.226.113.201

# 检查容器状态
docker ps | grep psychological

# 查看日志
docker logs -f psychological-assessment

# 测试访问
curl http://localhost:20053/

# 浏览器访问
# http://159.226.113.201:20053/
```

---

## 📝 镜像文件大小参考

- **未压缩**: 约 200-300 MB
- **压缩后**: 约 80-120 MB
- **上传时间**: 取决于网络速度
  - 10 Mbps: 约 1-2 分钟
  - 100 Mbps: 约 10-20 秒

---

## 🆘 常见问题

### Q1: 上传速度太慢怎么办?

**方案 A**: 使用更快的网络连接

**方案 B**: 在服务器本地构建(如果服务器配置了镜像加速器)

```bash
# 上传项目文件而不是镜像
scp -r VideoFront user@server:/home/user/

# 在服务器上构建
ssh user@server
cd /home/user/VideoFront
docker build -t psychological-assessment:latest .
```

### Q2: docker load 失败

**检查磁盘空间**:

```bash
df -h
```

**检查镜像文件完整性**:

```bash
# 对比本地和服务器的文件大小
ls -lh psychological-assessment.tar.gz
```

### Q3: 容器启动失败

**查看详细日志**:

```bash
docker logs psychological-assessment
docker inspect psychological-assessment
```

**检查端口占用**:

```bash
netstat -tlnp | grep 20053
```

---

## 💡 最佳实践

1. **定期清理**: 删除旧的镜像和容器
   ```bash
   docker system prune -a
   ```

2. **版本管理**: 使用标签管理不同版本
   ```bash
   docker build -t psychological-assessment:v1.0.0 .
   docker build -t psychological-assessment:latest .
   ```

3. **自动化**: 使用脚本自动化部署流程

4. **监控**: 设置容器健康检查和日志监控

---

## 📞 需要帮助?

如果遇到问题,请提供:

1. 错误信息截图
2. Docker 版本: `docker --version`
3. 系统信息: `cat /etc/os-release`
4. 网络状态: `ping -c 3 registry-1.docker.io`
