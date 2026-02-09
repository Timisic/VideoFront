#!/bin/bash
# Docker 镜像本地构建并上传到服务器脚本

set -e

echo "🚀 开始构建并部署 Docker 镜像到服务器..."

# 配置 (请根据实际情况修改)
SERVER="user@159.226.113.201"
IMAGE_NAME="psychological-assessment"
IMAGE_TAG="latest"
REMOTE_PATH="/home/user"

# 1. 本地构建镜像
echo "📦 步骤 1/5: 本地构建 Docker 镜像..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

# 2. 保存镜像为 tar 文件
echo "💾 步骤 2/5: 保存镜像为文件..."
docker save ${IMAGE_NAME}:${IMAGE_TAG} > ${IMAGE_NAME}.tar
echo "   镜像大小: $(du -h ${IMAGE_NAME}.tar | cut -f1)"

# 3. 压缩镜像文件
echo "🗜️  步骤 3/5: 压缩镜像文件..."
gzip ${IMAGE_NAME}.tar
echo "   压缩后大小: $(du -h ${IMAGE_NAME}.tar.gz | cut -f1)"

# 4. 上传到服务器
echo "📤 步骤 4/5: 上传镜像到服务器..."
scp ${IMAGE_NAME}.tar.gz ${SERVER}:${REMOTE_PATH}/

# 5. 在服务器上加载并运行
echo "🚢 步骤 5/5: 在服务器上部署..."
ssh ${SERVER} << EOF
  cd ${REMOTE_PATH}
  
  # 解压镜像
  echo "解压镜像文件..."
  gunzip -f ${IMAGE_NAME}.tar.gz
  
  # 加载镜像
  echo "加载 Docker 镜像..."
  docker load < ${IMAGE_NAME}.tar
  
  # 停止旧容器
  echo "停止旧容器..."
  docker stop ${IMAGE_NAME} 2>/dev/null || true
  docker rm ${IMAGE_NAME} 2>/dev/null || true
  
  # 运行新容器
  echo "启动新容器..."
  docker run -d \
    --name ${IMAGE_NAME} \
    -p 20053:20053 \
    --restart unless-stopped \
    --add-host host.docker.internal:host-gateway \
    ${IMAGE_NAME}:${IMAGE_TAG}
  
  # 清理临时文件
  echo "清理临时文件..."
  rm ${IMAGE_NAME}.tar
  
  # 查看容器状态
  echo ""
  echo "容器状态:"
  docker ps | grep ${IMAGE_NAME}
  
  echo ""
  echo "查看日志 (最后 20 行):"
  docker logs ${IMAGE_NAME} --tail 20
EOF

# 6. 清理本地文件
echo "🧹 清理本地文件..."
rm ${IMAGE_NAME}.tar.gz

echo ""
echo "✅ 部署完成!"
echo "🌐 访问地址: http://159.226.113.201:20053/"
echo ""
echo "📝 查看日志: ssh ${SERVER} 'docker logs -f ${IMAGE_NAME}'"
echo "🔄 重启容器: ssh ${SERVER} 'docker restart ${IMAGE_NAME}'"
echo "🛑 停止容器: ssh ${SERVER} 'docker stop ${IMAGE_NAME}'"
