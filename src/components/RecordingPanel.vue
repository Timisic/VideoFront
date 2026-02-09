<template>
  <div class="recording-container">
    <div class="material-section">
      <div class="material-content">
        <h2>阅读材料</h2>
        <div class="material-text">{{ materialText }}</div>
      </div>
    </div>
    
    <div class="camera-section">
      <video ref="videoElement" autoplay playsinline class="camera-preview"></video>
      <div class="recording-indicator">
        <span class="rec-dot"></span>
        录制中
      </div>
    </div>
    
    <div class="progress-bar">
      <div class="time-display">已录制 {{ recordedTime }} 秒</div>
      <el-button 
        type="danger" 
        size="large" 
        @click="handleStop"
        :disabled="recordedTime < 3"
      >
        {{ recordedTime < 3 ? `请至少录制 ${3 - recordedTime} 秒` : '停止录制并上传' }}
      </el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { MATERIAL_TEXT } from '../assets/material'

const props = defineProps({
  stream: MediaStream
})

const emit = defineEmits(['recorded'])

const videoElement = ref(null)
const recordedTime = ref(0)
const materialText = ref(MATERIAL_TEXT)

let mediaRecorder = null
let recordedChunks = []
let timeUpdateTimer = null
let startTime = null

onMounted(() => {
  if (videoElement.value && props.stream) {
    videoElement.value.srcObject = props.stream
  }
  
  startRecording()
})

onUnmounted(() => {
  if (timeUpdateTimer) {
    clearInterval(timeUpdateTimer)
  }
  if (mediaRecorder && mediaRecorder.state !== 'inactive') {
    mediaRecorder.stop()
  }
})

function startRecording() {
  try {
    // 检测浏览器支持的视频格式，优先使用 MP4
    const mimeTypes = [
      'video/mp4',
      'video/mp4;codecs=h264',
      'video/webm;codecs=h264',
      'video/webm;codecs=vp9',
      'video/webm'
    ]
    
    let selectedMimeType = 'video/webm' // 默认降级方案
    for (const mimeType of mimeTypes) {
      if (MediaRecorder.isTypeSupported(mimeType)) {
        selectedMimeType = mimeType
        console.log('✅ 选择录制格式:', mimeType)
        break
      }
    }
    
    if (selectedMimeType === 'video/webm') {
      console.warn('⚠️ 浏览器不支持 MP4 录制，使用 WebM 格式')
    }
    
    mediaRecorder = new MediaRecorder(props.stream, {
      mimeType: selectedMimeType
    })
    
    mediaRecorder.ondataavailable = (event) => {
      if (event.data && event.data.size > 0) {
        recordedChunks.push(event.data)
      }
    }
    
    mediaRecorder.onstop = () => {
      // 使用实际录制的格式创建 Blob
      const blob = new Blob(recordedChunks, { type: selectedMimeType })
      console.log('📹 录制完成，格式:', selectedMimeType, '大小:', (blob.size / 1024 / 1024).toFixed(2), 'MB')
      emit('recorded', blob)
    }
    
    mediaRecorder.start()
    startTime = Date.now()
    
    // Update time display
    timeUpdateTimer = setInterval(() => {
      const elapsed = Date.now() - startTime
      recordedTime.value = Math.floor(elapsed / 1000)
    }, 100)
    
  } catch (error) {
    console.error('❌ 录制启动失败:', error)
  }
}

function handleStop() {
  if (mediaRecorder && mediaRecorder.state !== 'inactive') {
    if (timeUpdateTimer) {
      clearInterval(timeUpdateTimer)
    }
    mediaRecorder.stop()
  }
}
</script>

<style scoped>
.recording-container {
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #fff;
}

.material-section {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
  background: #fafafa;
  border-bottom: 1px solid #e4e7ed;
}

.material-content {
  max-width: 800px;
  width: 100%;
}

.material-content h2 {
  font-size: 24px;
  font-weight: 600;
  margin-bottom: 24px;
  color: #303133;
}

.material-text {
  font-size: 16px;
  line-height: 1.8;
  color: #606266;
  white-space: pre-wrap;
}

.camera-section {
  position: relative;
  height: 300px;
  background: #000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.camera-preview {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.recording-indicator {
  position: absolute;
  top: 20px;
  right: 20px;
  background: rgba(0, 0, 0, 0.7);
  color: #fff;
  padding: 8px 16px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}

.rec-dot {
  width: 8px;
  height: 8px;
  background: #f56c6c;
  border-radius: 50%;
  animation: blink 1.5s ease-in-out infinite;
}

@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.3; }
}

.progress-bar {
  padding: 20px 40px;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
}

.time-display {
  font-size: 18px;
  font-weight: 600;
  color: #409eff;
  min-width: 120px;
}
</style>
