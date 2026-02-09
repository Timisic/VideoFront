<template>
  <div class="upload-container">
    <div class="loading-content">
      <el-icon class="loading-icon" :size="60">
        <Loading />
      </el-icon>
      <div class="loading-text">AI 正在分析中</div>
      <div class="loading-subtext">请稍候,这可能需要一些时间...</div>
    </div>
  </div>
</template>

<script setup>
import { Loading } from '@element-plus/icons-vue'
</script>

<style scoped>
.upload-container {
  width: 100vw;
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
}

.loading-content {
  text-align: center;
}

.loading-icon {
  color: #409eff;
  animation: rotate 2s linear infinite;
}

@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.loading-text {
  font-size: 20px;
  font-weight: 600;
  color: #303133;
  margin-top: 24px;
}

.loading-subtext {
  font-size: 14px;
  color: #909399;
  margin-top: 12px;
}
</style>
