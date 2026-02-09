# Windows Docker 部署指南

## 🪟 Windows 环境部署

### 前置要求

1. **Docker Desktop for Windows**
   - 下载: https://www.docker.com/products/docker-desktop
   - 确保 Docker 正在运行

2. **SSH 客户端**
   - Windows 10+ 自带 OpenSSH
   - 或使用 PuTTY、Git Bash

3. **检查环境**

```powershell
# 检查 Docker
docker --version

# 检查 SSH
ssh -V

# 检查 tar (Windows 10+ 自带)
tar --version
```

---

## 🚀 部署方法

### 方法 1: 使用 PowerShell 脚本 (推荐)

#### 步骤 1: 配置脚本

打开 `deploy-docker.ps1`,修改配置:

```powershell
$SERVER = "ubuntu@192.168.8.167"      # 服务器地址
$REMOTE_PATH = "/home/ubuntu/hwj/"    # 远程路径
```

#### 步骤 2: 设置执行策略

```powershell
# 以管理员身份运行 PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### 步骤 3: 运行脚本

```powershell
# 在项目目录执行
cd C:\path\to\VideoFront
.\deploy-docker.ps1
```

---

### 方法 2: 使用批处理脚本

#### 步骤 1: 配置脚本

打开 `deploy-docker.bat`,修改配置:

```batch
set SERVER=ubuntu@192.168.8.167
set REMOTE_PATH=/home/ubuntu/hwj/
```

#### 步骤 2: 双击运行

直接双击 `deploy-docker.bat` 文件即可。

---

### 方法 3: 手动步骤

#### 1. 构建镜像

```powershell
docker build -t psychological-assessment:latest .
```

#### 2. 保存镜像

```powershell
docker save psychological-assessment:latest -o psychological-assessment.tar
```

#### 3. 压缩文件

```powershell
# 使用 tar 压缩
tar -czf psychological-assessment.tar.gz psychological-assessment.tar

# 删除未压缩文件
del psychological-assessment.tar
```

#### 4. 上传到服务器

```powershell
scp psychological-assessment.tar.gz ubuntu@192.168.8.167:/home/ubuntu/hwj/
```

#### 5. SSH 登录服务器

```powershell
ssh ubuntu@192.168.8.167
```

#### 6. 在服务器上部署

```bash
cd /home/ubuntu/hwj/

# 解压
gunzip psychological-assessment.tar.gz

# 加载镜像
docker load < psychological-assessment.tar

# 停止旧容器
docker stop psychological-assessment
docker rm psychological-assessment

# 运行新容器
docker run -d \
  --name psychological-assessment \
  -p 20053:20053 \
  --restart unless-stopped \
  --add-host host.docker.internal:host-gateway \
  psychological-assessment:latest

# 查看状态
docker ps
docker logs psychological-assessment

# 清理
rm psychological-assessment.tar
```

---

## 🔧 常见问题

### Q1: PowerShell 脚本无法运行

**错误**: "无法加载,因为在此系统上禁止运行脚本"

**解决**:

```powershell
# 以管理员身份运行 PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Q2: Docker 命令找不到

**错误**: "docker: 无法将"docker"项识别为 cmdlet"

**解决**:
1. 确保 Docker Desktop 正在运行
2. 重启 PowerShell
3. 检查环境变量中是否有 Docker 路径

### Q3: SSH 连接失败

**错误**: "ssh: connect to host ... port 22: Connection refused"

**解决**:
1. 检查服务器 IP 地址是否正确
2. 确认服务器 SSH 服务运行正常
3. 检查防火墙设置

### Q4: scp 上传失败

**错误**: "Permission denied"

**解决**:
1. 检查服务器用户名和密码
2. 确认远程路径有写入权限
3. 使用绝对路径

### Q5: tar 命令不存在

**解决**:

Windows 10 1803+ 自带 tar,如果没有:

**方案 A**: 升级 Windows

**方案 B**: 使用 7-Zip

```powershell
# 下载 7-Zip: https://www.7-zip.org/
# 使用 7z 压缩
7z a psychological-assessment.tar.gz psychological-assessment.tar
```

**方案 C**: 不压缩直接上传

修改脚本,跳过压缩步骤。

---

## 💡 优化建议

### 1. 使用 SSH 密钥认证

避免每次输入密码:

```powershell
# 生成 SSH 密钥
ssh-keygen -t rsa -b 4096

# 复制公钥到服务器
type $env:USERPROFILE\.ssh\id_rsa.pub | ssh ubuntu@192.168.8.167 "cat >> ~/.ssh/authorized_keys"
```

### 2. 配置 Git Bash

如果使用 Git Bash,可以直接使用 Linux 脚本:

```bash
# 在 Git Bash 中运行
./deploy-docker.sh
```

### 3. 使用 WSL2

Windows Subsystem for Linux 2 提供完整 Linux 环境:

```powershell
# 安装 WSL2
wsl --install

# 在 WSL2 中运行
wsl
cd /mnt/c/path/to/VideoFront
./deploy-docker.sh
```

---

## 📊 性能对比

| 方法 | 优点 | 缺点 |
|------|------|------|
| PowerShell 脚本 | 原生支持,功能完整 | 需要设置执行策略 |
| 批处理脚本 | 双击即用,简单 | 功能有限,错误处理弱 |
| Git Bash | 与 Linux 一致 | 需要安装 Git |
| WSL2 | 完整 Linux 环境 | 需要额外配置 |

---

## 🎯 推荐配置

### 开发环境
- ✅ PowerShell 脚本 + SSH 密钥
- ✅ Docker Desktop
- ✅ Windows Terminal (更好的终端体验)

### 快速部署
- ✅ 批处理脚本 (双击运行)

### 高级用户
- ✅ WSL2 + Linux 脚本

---

## 📝 脚本对比

| 脚本 | 语言 | 适用场景 |
|------|------|----------|
| deploy-docker.sh | Bash | Mac/Linux/WSL2/Git Bash |
| deploy-docker.bat | Batch | Windows CMD |
| deploy-docker.ps1 | PowerShell | Windows PowerShell |

---

## 🔍 验证部署

```powershell
# 浏览器访问
Start-Process "http://192.168.8.167:20053/"

# 或使用 curl
curl http://192.168.8.167:20053/
```

---

## 📞 需要帮助?

如果遇到问题,请提供:

1. Windows 版本: `winver`
2. PowerShell 版本: `$PSVersionTable.PSVersion`
3. Docker 版本: `docker --version`
4. 错误截图或日志
