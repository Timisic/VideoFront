# Docker 权限问题修复指南

## 🔴 错误信息

```
PermissionError(13, 'Permission denied')
docker.errors.DockerException: Error while fetching server API version: ('Connection aborted.', PermissionError(13, 'Permission denied'))
```

## 📋 原因

当前用户没有权限访问 Docker daemon (`/var/run/docker.sock`)。

---

## ✅ 解决方案

### 方案 1: 添加用户到 docker 组 (推荐)

这是最标准和安全的解决方案。

```bash
# 1. 将当前用户添加到 docker 组
sudo usermod -aG docker $USER

# 2. 查看用户所属组 (应该包含 docker)
groups $USER

# 3. 刷新组权限
newgrp docker

# 4. 验证 (不需要 sudo)
docker ps
```

**如果第 3 步不生效**:

```bash
# 完全退出当前会话
exit

# 重新登录 (SSH 或本地终端)
ssh user@server

# 再次验证
docker ps
```

---

### 方案 2: 使用 sudo (临时方案)

如果无法修改用户组,可以使用 sudo:

```bash
# 所有 docker 命令前加 sudo
sudo docker-compose up -d --build
sudo docker ps
sudo docker logs psychological-assessment
```

**缺点**:
- 每次都需要输入密码
- 不是长期解决方案
- 可能导致文件权限问题

---

### 方案 3: 修改 socket 权限 (仅测试环境)

⚠️ **警告**: 此方法有安全风险,仅用于测试环境!

```bash
# 修改 Docker socket 权限
sudo chmod 666 /var/run/docker.sock

# 验证
docker ps
```

**问题**:
- 任何用户都可以访问 Docker
- 重启后可能失效
- 生产环境不推荐

---

## 🔍 验证配置

### 检查 Docker 服务状态

```bash
# 查看 Docker 服务状态
sudo systemctl status docker

# 如果未运行,启动 Docker
sudo systemctl start docker

# 设置开机自启
sudo systemctl enable docker
```

### 检查用户组

```bash
# 查看当前用户所属组
groups

# 应该包含 docker 组
# 输出示例: user adm cdrom sudo dip plugdev docker
```

### 检查 Docker socket 权限

```bash
# 查看 socket 文件权限
ls -la /var/run/docker.sock

# 正常输出:
# srw-rw---- 1 root docker 0 Feb  9 13:00 /var/run/docker.sock
```

### 测试 Docker 命令

```bash
# 不使用 sudo 运行
docker ps
docker images
docker-compose --version

# 如果都能正常运行,说明权限配置成功
```

---

## 🚀 配置完成后的部署步骤

### 1. 克隆或上传项目

```bash
# 如果是从 Git 克隆
git clone <repository-url>
cd VideoFront

# 或者上传项目文件
scp -r VideoFront user@server:/home/user/
ssh user@server
cd /home/user/VideoFront
```

### 2. 构建并启动

```bash
# 使用 docker-compose (推荐)
docker-compose up -d --build

# 或使用 docker 命令
docker build -t psychological-assessment:latest .
docker run -d \
  --name psychological-assessment \
  -p 20053:20053 \
  --restart unless-stopped \
  --add-host host.docker.internal:host-gateway \
  psychological-assessment:latest
```

### 3. 查看状态

```bash
# 查看容器状态
docker ps

# 查看日志
docker logs -f psychological-assessment

# 或使用 docker-compose
docker-compose logs -f
```

### 4. 访问应用

```
http://服务器IP:20053/
```

---

## 🔧 常见问题

### Q1: newgrp docker 后还是报错

**解决**: 完全退出并重新登录

```bash
exit
ssh user@server
docker ps
```

### Q2: 添加到 docker 组后还是没权限

**检查 Docker 服务**:

```bash
sudo systemctl status docker
sudo systemctl restart docker
```

**重新加载用户组**:

```bash
sudo usermod -aG docker $USER
su - $USER
```

### Q3: docker 组不存在

**创建 docker 组**:

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl restart docker
```

### Q4: 使用 sudo 后文件权限错误

**修复文件权限**:

```bash
# 修改项目文件所有者
sudo chown -R $USER:$USER ~/VideoFront

# 或使用 docker-compose 时指定用户
docker-compose run --user $(id -u):$(id -g) ...
```

---

## 📝 最佳实践

### 1. 生产环境

- ✅ 使用方案 1 (添加用户到 docker 组)
- ✅ 定期更新 Docker 版本
- ✅ 使用非 root 用户运行应用
- ❌ 不要使用 chmod 666 修改 socket 权限

### 2. 开发环境

- ✅ 可以使用 sudo (方便快速测试)
- ✅ 配置用户组 (长期使用)

### 3. 安全建议

- 只将需要使用 Docker 的用户添加到 docker 组
- 定期审查 docker 组成员
- 使用 Docker 的安全特性 (如 user namespace)

---

## 🎯 快速修复命令

```bash
# 一键修复脚本
sudo usermod -aG docker $USER && \
newgrp docker && \
docker ps && \
echo "✅ Docker 权限配置成功!"

# 如果上面不生效,执行:
exit
# 然后重新登录
```

---

## 📞 仍然无法解决?

请提供以下信息:

```bash
# 1. 用户组信息
groups

# 2. Docker 服务状态
sudo systemctl status docker

# 3. Socket 权限
ls -la /var/run/docker.sock

# 4. Docker 版本
docker --version

# 5. 系统信息
cat /etc/os-release
```
