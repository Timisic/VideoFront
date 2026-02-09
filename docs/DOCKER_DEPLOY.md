# Docker 部署文档

## 🐳 Docker 快速部署指南

### 前置要求

- Docker 20.10+
- Docker Compose 2.0+ (可选)

### 检查 Docker 安装

```bash
docker --version
docker-compose --version
```

---

## ⚠️ 重要: Docker 权限问题解决

### 错误信息

如果遇到以下错误:
```
PermissionError(13, 'Permission denied')
docker.errors.DockerException: Error while fetching server API version
```

### 原因

当前用户没有权限访问 Docker daemon。

### 解决方法

#### 方法 1: 将用户添加到 docker 组 (推荐)

```bash
# 1. 将当前用户添加到 docker 组
sudo usermod -aG docker $USER

# 2. 刷新组权限 (或重新登录)
newgrp docker

# 3. 验证权限
docker ps
```

**注意**: 如果 `newgrp docker` 不生效,需要完全退出并重新登录:

```bash
# 退出当前会话
exit

# 重新 SSH 登录
ssh user@server
```

#### 方法 2: 使用 sudo (临时方案)

```bash
# 使用 sudo 运行 docker 命令
sudo docker-compose up -d --build

# 或
sudo docker ps
```

**不推荐长期使用 sudo**,建议使用方法 1。

#### 方法 3: 修改 Docker socket 权限 (不推荐,有安全风险)

```bash
# 仅用于测试环境
sudo chmod 666 /var/run/docker.sock
```

### 验证权限配置

```bash
# 应该能正常运行,不需要 sudo
docker ps
docker-compose --version
```

---

## 🚀 方法一: 使用 Docker Compose (推荐)

### 1. 构建并启动

```bash
# 在项目根目录执行
docker-compose up -d --build
```

### 2. 查看日志

```bash
docker-compose logs -f
```

### 3. 访问应用

```
http://localhost:20053/
或
http://服务器IP:20053/
```

### 4. 停止服务

```bash
docker-compose down
```

### 5. 重启服务

```bash
docker-compose restart
```

---

## 🔧 方法二: 使用 Docker 命令

### 1. 构建镜像

```bash
docker build -t psychological-assessment:latest .
```

### 2. 运行容器

```bash
docker run -d \
  --name psychological-assessment \
  -p 20053:20053 \
  --restart unless-stopped \
  --add-host host.docker.internal:host-gateway \
  psychological-assessment:latest
```

### 3. 查看日志

```bash
docker logs -f psychological-assessment
```

### 4. 停止容器

```bash
docker stop psychological-assessment
docker rm psychological-assessment
```

---

## 📦 部署到远程服务器

### 方法 A: 直接在服务器上构建

```bash
# 1. 上传项目到服务器
scp -r /Users/hong/Downloads/Gemini/VideoFront user@159.226.113.201:/home/user/

# 2. SSH 登录服务器
ssh user@159.226.113.201

# 3. 进入项目目录
cd /home/user/VideoFront

# 4. 构建并启动
docker-compose up -d --build

# 5. 查看状态
docker-compose ps
docker-compose logs -f
```

### 方法 B: 本地构建镜像后上传

```bash
# 1. 本地构建镜像
docker build -t psychological-assessment:latest .

# 2. 保存镜像为文件
docker save psychological-assessment:latest > psychological-assessment.tar

# 3. 上传到服务器
scp psychological-assessment.tar user@159.226.113.201:/tmp/

# 4. SSH 登录服务器
ssh user@159.226.113.201

# 5. 加载镜像
docker load < /tmp/psychological-assessment.tar

# 6. 运行容器
docker run -d \
  --name psychological-assessment \
  -p 20053:20053 \
  --restart unless-stopped \
  --add-host host.docker.internal:host-gateway \
  psychological-assessment:latest

# 7. 清理临时文件
rm /tmp/psychological-assessment.tar
```

---

## 🔍 验证部署

### 1. 检查容器状态

```bash
docker ps | grep psychological-assessment
```

**期望输出**:
```
CONTAINER ID   IMAGE                              STATUS         PORTS
abc123def456   psychological-assessment:latest    Up 2 minutes   0.0.0.0:20053->20053/tcp
```

### 2. 检查健康状态

```bash
docker inspect psychological-assessment | grep -A 5 Health
```

### 3. 测试访问

```bash
# 测试首页
curl http://localhost:20053/

# 测试 API 代理 (需要有视频文件)
curl -X POST http://localhost:20053/api/v1/analysis/face_video \
  -F "video=@test.mp4"
```

### 4. 浏览器访问

打开浏览器访问: `http://服务器IP:20053/`

---

## 📝 配置说明

### 1. Mock 模式已自动关闭

Dockerfile 中已自动关闭 Mock 模式:

```dockerfile
RUN sed -i 's/const USE_MOCK = true/const USE_MOCK = false/' src/api/index.js
```

### 2. 跨域问题已解决

`nginx-docker.conf` 中已配置 CORS 支持:

```nginx
# CORS 支持
add_header Access-Control-Allow-Origin * always;
add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;

# 处理 OPTIONS 预检请求
if ($request_method = 'OPTIONS') {
    return 204;
}
```

### 3. API 代理配置

后端地址在 `nginx-docker.conf` 中配置:

```nginx
location /api/ {
    proxy_pass http://192.168.8.167:8080/api/;
    # ...
}
```

**如果后端地址需要修改**:

编辑 `nginx-docker.conf` 第 14 行,然后重新构建镜像。

### 4. 访问宿主机网络

`docker-compose.yml` 中已配置:

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

这允许容器访问宿主机网络上的服务。

---

## 🔄 更新部署

### 代码更新后重新部署

```bash
# 方法 1: 使用 docker-compose
docker-compose down
docker-compose up -d --build

# 方法 2: 使用 docker 命令
docker stop psychological-assessment
docker rm psychological-assessment
docker build -t psychological-assessment:latest .
docker run -d \
  --name psychological-assessment \
  -p 20053:20053 \
  --restart unless-stopped \
  --add-host host.docker.internal:host-gateway \
  psychological-assessment:latest
```

---

## 🛠 常见问题

### Q1: 容器无法启动

**检查日志**:
```bash
docker logs psychological-assessment
```

**常见原因**:
- 端口 20053 被占用
- Nginx 配置错误
- 构建失败

**解决方法**:
```bash
# 检查端口占用
netstat -tlnp | grep 20053

# 停止占用端口的服务
docker stop $(docker ps -q --filter "publish=20053")

# 重新启动
docker-compose up -d
```

### Q2: API 请求失败 (跨域错误)

**原因**: Nginx 配置问题或后端地址错误

**解决方法**:

1. 检查 `nginx-docker.conf` 中的后端地址
2. 确认后端服务运行正常
3. 查看容器日志:
   ```bash
   docker logs -f psychological-assessment
   ```

### Q3: 无法访问后端 API

**原因**: Docker 容器网络隔离

**解决方法**:

如果后端在宿主机上:
```bash
# 使用 --add-host 参数
docker run -d \
  --add-host host.docker.internal:host-gateway \
  ...
```

如果后端也在 Docker 中:
```yaml
# docker-compose.yml
services:
  frontend:
    depends_on:
      - backend
    networks:
      - app-network
  backend:
    networks:
      - app-network
```

### Q4: 视频上传超时

**原因**: 超时时间设置过短

**解决方法**:

编辑 `nginx-docker.conf`:
```nginx
proxy_connect_timeout 600s;  # 增加到 10 分钟
proxy_send_timeout 600s;
proxy_read_timeout 600s;
```

重新构建镜像:
```bash
docker-compose up -d --build
```

### Q5: 容器重启后数据丢失

**原因**: 容器是无状态的

**解决方法**:

如果需要持久化数据,使用 volume:
```yaml
services:
  psychological-assessment:
    volumes:
      - ./logs:/var/log/nginx
```

---

## 📊 监控和维护

### 查看资源使用

```bash
docker stats psychological-assessment
```

### 查看容器详情

```bash
docker inspect psychological-assessment
```

### 进入容器调试

```bash
docker exec -it psychological-assessment sh
```

### 查看 Nginx 配置

```bash
docker exec psychological-assessment cat /etc/nginx/conf.d/default.conf
```

---

## 🔐 生产环境建议

### 1. 使用环境变量

创建 `.env` 文件:
```env
BACKEND_URL=http://192.168.8.167:8080
PORT=20053
```

修改 `docker-compose.yml`:
```yaml
services:
  psychological-assessment:
    environment:
      - BACKEND_URL=${BACKEND_URL}
    ports:
      - "${PORT}:20053"
```

### 2. 启用 HTTPS

使用 Let's Encrypt 或自签名证书:

```yaml
services:
  psychological-assessment:
    ports:
      - "443:443"
    volumes:
      - ./ssl:/etc/nginx/ssl
```

### 3. 限制资源使用

```yaml
services:
  psychological-assessment:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

### 4. 日志管理

```yaml
services:
  psychological-assessment:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

---

## 📋 部署检查清单

部署前确认:

- [ ] Docker 和 Docker Compose 已安装
- [ ] 端口 20053 未被占用
- [ ] 后端服务运行正常 (`http://192.168.8.167:8080`)
- [ ] 防火墙已开放 20053 端口
- [ ] Mock 模式已关闭 (Dockerfile 自动处理)
- [ ] Nginx 配置中的后端地址正确

部署后验证:

- [ ] 容器状态为 `Up`
- [ ] 健康检查通过
- [ ] 可以访问首页
- [ ] API 请求正常
- [ ] 视频上传和分析功能正常

---

## 🎯 快速命令参考

```bash
# 构建并启动
docker-compose up -d --build

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart

# 停止服务
docker-compose down

# 查看状态
docker-compose ps

# 进入容器
docker exec -it psychological-assessment sh

# 查看资源使用
docker stats psychological-assessment

# 清理所有容器和镜像 (谨慎使用)
docker system prune -a
```

---

## 📞 技术支持

如遇问题,请提供以下信息:

1. 容器日志: `docker logs psychological-assessment`
2. 容器状态: `docker ps -a`
3. 系统信息: `docker info`
4. 错误截图或描述
