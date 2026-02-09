# Docker 部署快速参考

## 🚀 一键部署

```bash
# 在项目根目录执行
docker-compose up -d --build
```

## 📋 创建的文件

- **Dockerfile** - 多阶段构建,自动关闭 Mock 模式
- **docker-compose.yml** - 容器编排配置
- **nginx-docker.conf** - Nginx 配置(已解决跨域)
- **.dockerignore** - 优化构建上下文
- **docs/DOCKER_DEPLOY.md** - 完整部署文档

## ✅ 已确保

- ✅ Mock 模式自动关闭
- ✅ API 接口正确配置
- ✅ 跨域问题已解决
- ✅ 健康检查已配置
- ✅ 生产环境优化

## 🔗 访问地址

```
http://localhost:20053/
```

## 📖 详细文档

查看 [`docs/DOCKER_DEPLOY.md`](./DOCKER_DEPLOY.md) 获取完整部署指南。
