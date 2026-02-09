<template>
  <div class="countdown-container">
    <video ref="videoPreview" autoplay playsinline class="video-preview"></video>
    <div class="countdown-overlay">
      <div class="countdown-number">{{ count }}</div>
      <div class="countdown-text">准备开始录制</div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  stream: MediaStream
})

const emit = defineEmits(['done'])
const count = ref(3)
const videoPreview = ref(null)
let timer = null

onMounted(() => {
  // Show camera preview
  if (videoPreview.value && props.stream) {
    videoPreview.value.srcObject = props.stream
  }
  
  // Start countdown
  timer = setInterval(() => {
    count.value--
    if (count.value === 0) {
      clearInterval(timer)
      setTimeout(() => {
        emit('done')
      }, 500)
    }
  }, 1000)
})

onUnmounted(() => {
  if (timer) {
    clearInterval(timer)
  }
})
</script>

<style scoped>
.countdown-container {
  position: relative;
  width: 100vw;
  height: 100vh;
  background: #000;
  display: flex;
  align-items: center;
  justify-content: center;
}

.video-preview {
  width: 100%;
  height: 100%;
  object-fit: cover;
  opacity: 0.3;
}

.countdown-overlay {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  text-align: center;
}

.countdown-number {
  font-size: 120px;
  font-weight: 700;
  color: #fff;
  text-shadow: 0 4px 12px rgba(0, 0, 0, 0.5);
  animation: pulse 1s ease-in-out infinite;
}

.countdown-text {
  font-size: 24px;
  color: #fff;
  margin-top: 20px;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.5);
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
    opacity: 1;
  }
  50% {
    transform: scale(1.1);
    opacity: 0.8;
  }
}
</style>
