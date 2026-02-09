#!/bin/bash
# Docker 镜像本地构建并打包脚本（用于手动上传）

set -e

echo "🚀 开始本地构建 Docker 镜像..."

# 配置
IMAGE_NAME="psychological-assessment"
IMAGE_TAG="latest"
OUTPUT_DIR="./docker-deploy"

# 创建输出目录
mkdir -p ${OUTPUT_DIR}

# 1. 本地构建镜像
echo "📦 步骤 1/3: 本地构建 Docker 镜像..."
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

# 2. 保存镜像为 tar 文件
echo "💾 步骤 2/3: 保存镜像为文件..."
docker save ${IMAGE_NAME}:${IMAGE_TAG} > ${OUTPUT_DIR}/${IMAGE_NAME}.tar
echo "   镜像大小: $(du -h ${OUTPUT_DIR}/${IMAGE_NAME}.tar | cut -f1)"

# 3. 压缩镜像文件
echo "🗜️  步骤 3/3: 压缩镜像文件..."
gzip ${OUTPUT_DIR}/${IMAGE_NAME}.tar
echo "   压缩后大小: $(du -h ${OUTPUT_DIR}/${IMAGE_NAME}.tar.gz | cut -f1)"

echo ""
echo "✅ 构建完成!"
echo "📁 输出文件: ${OUTPUT_DIR}/${IMAGE_NAME}.tar.gz"
echo ""
echo "📤 请手动将以下文件上传到服务器:"
echo "   文件: ${OUTPUT_DIR}/${IMAGE_NAME}.tar.gz"
echo "   目标路径: /home/ubuntu/hwj/"
echo ""
echo "📝 上传后在服务器上执行以下命令:"
echo "   cd /home/ubuntu/hwj/"
echo "   gunzip -f ${IMAGE_NAME}.tar.gz"
echo "   docker load < ${IMAGE_NAME}.tar"
echo "   docker stop ${IMAGE_NAME} 2>/dev/null || true"
echo "   docker rm ${IMAGE_NAME} 2>/dev/null || true"
echo "   docker run -d --name ${IMAGE_NAME} -p 20053:20053 --restart unless-stopped --add-host host.docker.internal:host-gateway ${IMAGE_NAME}:${IMAGE_TAG}"
echo "   rm ${IMAGE_NAME}.tar"
echo ""
