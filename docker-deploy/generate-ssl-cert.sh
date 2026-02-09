#!/bin/bash
# 生成自签名 SSL 证书脚本

set -e

echo "🔐 生成自签名 SSL 证书..."

# 创建 SSL 目录
mkdir -p ssl

# 生成自签名证书（有效期 365 天）
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/nginx-selfsigned.key \
  -out ssl/nginx-selfsigned.crt \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=PsychAssessment/CN=159.226.113.201"

echo ""
echo "✅ SSL 证书生成成功！"
echo "📁 证书位置:"
echo "   私钥: $(pwd)/ssl/nginx-selfsigned.key"
echo "   证书: $(pwd)/ssl/nginx-selfsigned.crt"
echo ""
echo "⚠️  注意: 这是自签名证书，浏览器会显示安全警告"
echo "   用户需要点击 '高级' → '继续访问' 来信任证书"
