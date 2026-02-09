<template>
  <el-dialog
    v-model="visible"
    title="欢迎使用心理测评系统"
    width="600px"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
    :show-close="false"
  >
    <div class="guide-content">
      <h3>测评流程说明</h3>
      <ol>
        <li>点击「开始测评」后,将进入 3 秒倒计时</li>
        <li>倒计时结束后,屏幕将展示一段文字材料,请您阅读</li>
        <li>录制过程中,摄像头将记录您的面部画面(共 40 秒)</li>
        <li>录制结束后系统自动提交,稍等片刻即可查看报告</li>
      </ol>
      
      <div class="notice">
        <p>请确保:</p>
        <ul>
          <li>面部处于画面中央</li>
          <li>光线充足</li>
          <li>环境安静</li>
        </ul>
      </div>
    </div>
    
    <template #footer>
      <el-button type="primary" @click="handleStart" size="large">
        开始测评
      </el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref } from 'vue'

const emit = defineEmits(['start'])
const visible = ref(true)

function handleStart() {
  visible.value = false
  emit('start')
}
</script>

<style scoped>
.guide-content {
  padding: 20px 0;
}

.guide-content h3 {
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 16px;
  color: #303133;
}

.guide-content ol {
  padding-left: 24px;
  margin-bottom: 24px;
}

.guide-content ol li {
  margin-bottom: 12px;
  line-height: 1.6;
  color: #606266;
}

.notice {
  background: #f4f4f5;
  padding: 16px;
  border-radius: 4px;
  border-left: 3px solid #409eff;
}

.notice p {
  font-weight: 600;
  margin-bottom: 8px;
  color: #303133;
}

.notice ul {
  padding-left: 24px;
  margin: 0;
}

.notice ul li {
  margin-bottom: 6px;
  color: #606266;
}
</style>
