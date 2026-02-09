#!/bin/bash
# 服务器快速部署脚本 - 在服务器上执行

set -e

IMAGE_NAME="psychological-assessment"
IMAGE_TAG="latest"

echo "🚀 开始部署 Docker 容器..."

# 1. 解压镜像
echo "📦 步骤 1/5: 解压镜像文件..."
gunzip -f ${IMAGE_NAME}.tar.gz

# 2. 加载镜像
echo "💾 步骤 2/5: 加载 Docker 镜像..."
sudo docker load < ${IMAGE_NAME}.tar

# 3. 停止旧容器
echo "🛑 步骤 3/5: 停止旧容器..."
sudo docker stop ${IMAGE_NAME} 2>/dev/null || true
sudo docker rm ${IMAGE_NAME} 2>/dev/null || true

# 4. 运行新容器
echo "🚢 步骤 4/5: 启动新容器..."
sudo docker run -d \
  --name ${IMAGE_NAME} \
  -p 20053:20053 \
  --restart unless-stopped \
  --add-host host.docker.internal:host-gateway \
  ${IMAGE_NAME}:${IMAGE_TAG}

# 5. 验证部署
echo "✅ 步骤 5/5: 验证部署..."
sleep 2

echo ""
echo "📊 容器状态:"
sudo docker ps | grep ${IMAGE_NAME}

echo ""
echo "📝 容器日志 (最后 20 行):"
sudo docker logs ${IMAGE_NAME} --tail 20

# 6. 清理临时文件
echo ""
echo "🧹 清理临时文件..."
rm ${IMAGE_NAME}.tar

echo ""
echo "✅ 部署完成!"
echo "🌐 访问地址: http://159.226.113.201:20053/"
echo ""
echo "💡 常用命令:"
echo "   查看日志: sudo docker logs -f ${IMAGE_NAME}"
echo "   重启容器: sudo docker restart ${IMAGE_NAME}"
echo "   停止容器: sudo docker stop ${IMAGE_NAME}"
