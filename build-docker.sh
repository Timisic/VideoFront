#!/bin/bash
# Docker 镜像本地构建脚本（HTTPS 版本）

set -e

echo "🚀 开始本地构建 HTTPS Docker 镜像..."

# 配置
IMAGE_NAME="psychological-assessment"
IMAGE_TAG="latest"
OUTPUT_DIR="./docker-deploy"

# 创建输出目录
mkdir -p ${OUTPUT_DIR}

# 1. 生成 SSL 证书
echo "🔐 步骤 1/4: 生成 SSL 证书..."
cd ${OUTPUT_DIR}
bash generate-ssl-cert.sh
cd ..

# 2. 本地构建镜像（使用 HTTPS Dockerfile）
echo "📦 步骤 2/4: 本地构建 Docker 镜像（AMD64 架构）..."
docker buildx build --platform linux/amd64 -f Dockerfile -t ${IMAGE_NAME}:${IMAGE_TAG} .

# 3. 保存镜像为 tar 文件
echo "💾 步骤 3/4: 保存镜像为文件..."
docker save ${IMAGE_NAME}:${IMAGE_TAG} > ${OUTPUT_DIR}/${IMAGE_NAME}.tar
echo "   镜像大小: $(du -h ${OUTPUT_DIR}/${IMAGE_NAME}.tar | cut -f1)"

# 4. 压缩镜像文件
echo "🗜️  步骤 4/4: 压缩镜像文件..."
gzip -f ${OUTPUT_DIR}/${IMAGE_NAME}.tar
echo "   压缩后大小: $(du -h ${OUTPUT_DIR}/${IMAGE_NAME}.tar.gz | cut -f1)"

echo ""
echo "✅ 构建完成!"
echo "📁 输出文件:"
echo "   - ${OUTPUT_DIR}/${IMAGE_NAME}.tar.gz (镜像文件)"
echo "   - ${OUTPUT_DIR}/ssl/nginx-selfsigned.key (SSL 私钥)"
echo "   - ${OUTPUT_DIR}/ssl/nginx-selfsigned.crt (SSL 证书)"
echo "   - ${OUTPUT_DIR}/deploy-on-server-https.sh (部署脚本)"
echo ""
echo "📤 请手动将以下文件上传到服务器 /home/ubuntu/hwj/VideoFront/docker-deploy/ 目录:"
echo "   1. ${IMAGE_NAME}.tar.gz"
echo "   2. ssl/ 目录（包含证书和私钥）"
echo "   3. deploy-on-server-https.sh"
echo ""
echo "📝 上传后在服务器上执行:"
echo "   cd /home/ubuntu/hwj/VideoFront/docker-deploy/"
echo "   chmod +x deploy-on-server-https.sh"
echo "   ./deploy-on-server-https.sh"
echo ""
