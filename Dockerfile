# 多阶段构建
FROM node:18-alpine AS builder

WORKDIR /app

# 复制依赖文件
COPY package*.json ./

# 安装依赖
RUN npm install

# 复制源代码
COPY . .

# 关闭 Mock 模式 (生产环境)
RUN sed -i 's/const USE_MOCK = true/const USE_MOCK = false/' src/api/index.js

# 构建生产版本
RUN npm run build

# 生产环境镜像
FROM nginx:alpine

# 复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制 Nginx 配置
COPY nginx-docker.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 20053

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:20053/ || exit 1

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]
