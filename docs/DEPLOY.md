# Linux 快速部署指南

## 🚀 最简单的部署方法

### 方法一: 使用 Nginx (推荐)

#### 1. 本地构建

```bash
# 在本地 Mac 上执行
cd /Users/hong/Downloads/Gemini/VideoFront

# 关闭 Mock 模式
sed -i '' 's/const USE_MOCK = true/const USE_MOCK = false/' src/api/index.js

# 构建
npm run build

# 打包 dist 目录
tar -czf dist.tar.gz dist/
```

#### 2. 上传到服务器

```bash
# 上传到服务器
scp dist.tar.gz user@159.226.113.201:/tmp/
```

#### 3. 服务器端部署

```bash
# SSH 登录服务器
ssh user@159.226.113.201

# 解压
cd /var/www/
sudo tar -xzf /tmp/dist.tar.gz
sudo mv dist psychological-assessment

# 安装 Nginx (如果未安装)
sudo apt update
sudo apt install nginx -y

# 创建 Nginx 配置
sudo nano /etc/nginx/sites-available/psychological-assessment
```

**Nginx 配置内容**:

```nginx
server {
    listen 20053;
    server_name 159.226.113.201;
    
    root /var/www/psychological-assessment;
    index index.html;
    
    # 前端路由支持
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # API 代理到后端
    location /api/ {
        proxy_pass http://192.168.8.167:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }
    
    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### 4. 启用配置并重启

```bash
# 启用站点
sudo ln -s /etc/nginx/sites-available/psychological-assessment /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx

# 设置开机自启
sudo systemctl enable nginx
```

#### 5. 验证部署

```bash
# 访问
curl http://159.226.113.201:20053/

# 或在浏览器打开
# http://159.226.113.201:20053/
```

---

### 方法二: 使用 Node.js + PM2 (备选)

如果服务器上已有 Node.js 环境,可以直接运行:

#### 1. 上传整个项目

```bash
# 本地打包
cd /Users/hong/Downloads/Gemini/VideoFront
tar -czf VideoFront.tar.gz --exclude=node_modules .

# 上传
scp VideoFront.tar.gz user@159.226.113.201:/home/user/
```

#### 2. 服务器端运行

```bash
# SSH 登录
ssh user@159.226.113.201

# 解压
cd /home/user/
tar -xzf VideoFront.tar.gz
cd VideoFront

# 安装依赖
npm install

# 关闭 Mock 模式
sed -i 's/const USE_MOCK = true/const USE_MOCK = false/' src/api/index.js

# 构建
npm run build

# 安装 PM2
npm install -g pm2

# 安装静态服务器
npm install -g serve

# 使用 PM2 运行
pm2 serve dist 20053 --name psychological-assessment

# 保存 PM2 配置
pm2 save
pm2 startup
```

---

### 方法三: Docker 部署 (最简单)

#### 1. 创建 Dockerfile

在项目根目录创建 `Dockerfile`:

```dockerfile
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# 关闭 Mock 模式
RUN sed -i 's/const USE_MOCK = true/const USE_MOCK = false/' src/api/index.js

RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 20053
CMD ["nginx", "-g", "daemon off;"]
```

#### 2. 创建 nginx.conf

```nginx
server {
    listen 20053;
    root /usr/share/nginx/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://192.168.8.167:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_connect_timeout 300s;
        proxy_read_timeout 300s;
    }
}
```

#### 3. 构建和运行

```bash
# 本地构建镜像
docker build -t psychological-assessment .

# 保存镜像
docker save psychological-assessment > psychological-assessment.tar

# 上传到服务器
scp psychological-assessment.tar user@159.226.113.201:/tmp/

# 服务器端加载并运行
ssh user@159.226.113.201
docker load < /tmp/psychological-assessment.tar
docker run -d -p 20053:20053 --name psychological-assessment psychological-assessment

# 查看日志
docker logs -f psychological-assessment
```

---

## 🔧 一键部署脚本

创建 `deploy.sh`:

```bash
#!/bin/bash
set -e

echo "🚀 开始部署心理测评系统..."

# 配置
SERVER="user@159.226.113.201"
DEPLOY_PATH="/var/www/psychological-assessment"

# 1. 关闭 Mock 模式
echo "📝 关闭 Mock 模式..."
sed -i '' 's/const USE_MOCK = true/const USE_MOCK = false/' src/api/index.js

# 2. 构建
echo "🔨 构建项目..."
npm run build

# 3. 打包
echo "📦 打包文件..."
tar -czf dist.tar.gz dist/

# 4. 上传
echo "📤 上传到服务器..."
scp dist.tar.gz $SERVER:/tmp/

# 5. 部署
echo "🚢 服务器端部署..."
ssh $SERVER << 'EOF'
  sudo rm -rf /var/www/psychological-assessment
  sudo mkdir -p /var/www/psychological-assessment
  sudo tar -xzf /tmp/dist.tar.gz -C /var/www/psychological-assessment --strip-components=1
  sudo systemctl restart nginx
  rm /tmp/dist.tar.gz
EOF

# 6. 清理
echo "🧹 清理本地文件..."
rm dist.tar.gz

# 7. 恢复 Mock 模式 (可选)
sed -i '' 's/const USE_MOCK = false/const USE_MOCK = true/' src/api/index.js

echo "✅ 部署完成!"
echo "🌐 访问地址: http://159.226.113.201:20053/"
```

**使用方法**:

```bash
chmod +x deploy.sh
./deploy.sh
```

---

## 📋 部署前检查清单

- [ ] 已关闭 Mock 模式 (`USE_MOCK = false`)
- [ ] 后端服务运行正常 (`http://192.168.8.167:8080`)
- [ ] 服务器防火墙开放 20053 端口
- [ ] 服务器有足够磁盘空间 (至少 100MB)
- [ ] 已安装 Nginx 或 Docker

---

## 🔍 常见问题

### Q1: 访问 404

**原因**: Nginx 配置错误或路径不对

**解决**:
```bash
# 检查文件是否存在
ls -la /var/www/psychological-assessment/

# 检查 Nginx 配置
sudo nginx -t

# 查看 Nginx 日志
sudo tail -f /var/log/nginx/error.log
```

### Q2: API 请求失败

**原因**: 后端服务未启动或代理配置错误

**解决**:
```bash
# 测试后端连接
curl http://192.168.8.167:8080/api/v1/analysis/face_video

# 检查 Nginx 代理配置
sudo nano /etc/nginx/sites-available/psychological-assessment
```

### Q3: 端口被占用

**原因**: 20053 端口已被其他服务占用

**解决**:
```bash
# 查看端口占用
sudo netstat -tlnp | grep 20053

# 停止占用的服务或修改配置使用其他端口
```

---

## 🔄 更新部署

```bash
# 重新运行部署脚本即可
./deploy.sh
```

---

## 📊 性能优化建议

### 1. 启用 Gzip 压缩

在 Nginx 配置中添加:

```nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
gzip_min_length 1000;
```

### 2. 调整超时时间

如果视频处理时间很长,增加超时:

```nginx
proxy_connect_timeout 600s;
proxy_send_timeout 600s;
proxy_read_timeout 600s;
```

### 3. 启用 HTTP/2

```nginx
listen 20053 http2;
```

---

## 🎯 推荐方案

**生产环境推荐**: 方法一 (Nginx) + 一键部署脚本

**优点**:
- ✅ 性能最好
- ✅ 配置简单
- ✅ 易于维护
- ✅ 资源占用少
