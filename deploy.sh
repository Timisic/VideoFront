#!/bin/bash
set -e

echo "🚀 开始部署心理测评系统..."

# 配置 (请根据实际情况修改)
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
echo "🔄 恢复 Mock 模式..."
sed -i '' 's/const USE_MOCK = false/const USE_MOCK = true/' src/api/index.js

echo ""
echo "✅ 部署完成!"
echo "🌐 访问地址: http://159.226.113.201:20053/"
echo ""
