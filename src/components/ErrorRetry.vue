<template>
  <div class="error-container">
    <div class="error-content">
      <el-icon class="error-icon" :size="60" color="#f56c6c">
        <CircleClose />
      </el-icon>
      <div class="error-title">操作失败</div>
      <div class="error-message">{{ message }}</div>
      <el-button type="primary" size="large" @click="handleRetry">
        重新测评
      </el-button>
    </div>
  </div>
</template>

<script setup>
import { CircleClose } from '@element-plus/icons-vue'

defineProps({
  message: {
    type: String,
    default: '发生错误,请重试'
  }
})

const emit = defineEmits(['retry'])

function handleRetry() {
  emit('retry')
}
</script>

<style scoped>
.error-container {
  width: 100vw;
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fff;
}

.error-content {
  text-align: center;
}

.error-icon {
  margin-bottom: 24px;
}

.error-title {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 12px;
}

.error-message {
  font-size: 16px;
  color: #606266;
  margin-bottom: 32px;
}
</style>
