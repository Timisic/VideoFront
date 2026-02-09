#!/bin/bash
# 服务器 HTTPS 部署脚本 - 在服务器上执行

set -e

# 自动切换到脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

IMAGE_NAME="psychological-assessment"
IMAGE_TAG="latest"
SSL_DIR="$SCRIPT_DIR/ssl"

echo "🚀 开始部署 HTTPS Docker 容器..."
echo "📂 工作目录: $SCRIPT_DIR"

# 0. 检查 SSL 证书
echo "🔐 步骤 0/6: 检查 SSL 证书..."
if [ ! -f "$SSL_DIR/nginx-selfsigned.key" ] || [ ! -f "$SSL_DIR/nginx-selfsigned.crt" ]; then
    echo "❌ 错误: SSL 证书文件不存在！"
    echo "   请确保已上传 ssl/ 目录到服务器"
    exit 1
fi
echo "   ✅ SSL 证书文件存在"

# 1. 解压镜像
echo "📦 步骤 1/6: 解压镜像文件..."
gunzip -f ${IMAGE_NAME}.tar.gz

# 2. 加载镜像
echo "💾 步骤 2/6: 加载 Docker 镜像..."
sudo docker load < ${IMAGE_NAME}.tar

# 3. 停止旧容器
echo "🛑 步骤 3/6: 停止旧容器..."
sudo docker stop ${IMAGE_NAME} 2>/dev/null || true
sudo docker rm ${IMAGE_NAME} 2>/dev/null || true

# 4. 运行新容器（挂载 SSL 证书）
echo "🚢 步骤 4/6: 启动新容器（HTTPS）..."
sudo docker run -d \
  --name ${IMAGE_NAME} \
  -p 20053:20053 \
  -p 20443:20443 \
  -v ${SSL_DIR}:/etc/nginx/ssl:ro \
  --restart unless-stopped \
  --add-host host.docker.internal:host-gateway \
  ${IMAGE_NAME}:${IMAGE_TAG}

# 5. 验证部署
echo "✅ 步骤 5/6: 验证部署..."
sleep 3

echo ""
echo "📊 容器状态:"
sudo docker ps | grep ${IMAGE_NAME}

echo ""
echo "📝 容器日志 (最后 20 行):"
sudo docker logs ${IMAGE_NAME} --tail 20

# 6. 清理临时文件
echo ""
echo "🧹 步骤 6/6: 清理临时文件..."
rm ${IMAGE_NAME}.tar

echo ""
echo "✅ HTTPS 部署完成!"
echo ""
echo "🌐 访问地址:"
echo "   HTTP:  http://159.226.113.201:20053/  (自动重定向到 HTTPS)"
echo "   HTTPS: https://159.226.113.201:20443/ (推荐)"
echo ""
echo "⚠️  首次访问提示:"
echo "   1. 浏览器会显示 '您的连接不是私密连接' 警告"
echo "   2. 点击 '高级' → '继续访问 159.226.113.201 (不安全)'"
echo "   3. 之后摄像头权限将正常工作"
echo ""
echo "💡 常用命令:"
echo "   查看日志: sudo docker logs -f ${IMAGE_NAME}"
echo "   重启容器: sudo docker restart ${IMAGE_NAME}"
echo "   停止容器: sudo docker stop ${IMAGE_NAME}"
echo ""
echo "🔒 SSL 证书信息:"
echo "   证书位置: ${SSL_DIR}/nginx-selfsigned.crt"
echo "   私钥位置: ${SSL_DIR}/nginx-selfsigned.key"
echo "   有效期: 365 天"
