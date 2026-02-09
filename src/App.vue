<template>
  <div class="app-container">
    <GuideDialog v-if="currentStep === 'guide'" @start="handleStart" />
    <CountDown v-if="currentStep === 'countdown'" :stream="cameraStream" @done="handleCountdownDone" />
    <RecordingPanel 
      v-if="currentStep === 'recording'" 
      :stream="cameraStream"
      @recorded="handleRecorded" 
    />
    <UploadLoading v-if="currentStep === 'uploading'" />
    <ReportView 
      v-if="currentStep === 'report'" 
      :data="reportData" 
      @retry="handleRetry"
    />
    <ErrorRetry 
      v-if="currentStep === 'error'" 
      :message="errorMessage"
      @retry="handleRetry" 
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import GuideDialog from './components/GuideDialog.vue'
import CountDown from './components/CountDown.vue'
import RecordingPanel from './components/RecordingPanel.vue'
import UploadLoading from './components/UploadLoading.vue'
import ReportView from './components/ReportView.vue'
import ErrorRetry from './components/ErrorRetry.vue'
import { uploadVideo } from './api'
import { convertToMp4 } from './utils/convertToMp4'

const currentStep = ref('guide')
const cameraStream = ref(null)
const reportData = ref(null)
const errorMessage = ref('')

async function handleStart() {
  try {
    // Request camera permission
    cameraStream.value = await navigator.mediaDevices.getUserMedia({
      video: { width: 640, height: 480, facingMode: 'user' },
      audio: false
    })
    currentStep.value = 'countdown'
  } catch (error) {
    console.error('Camera access denied:', error)
    errorMessage.value = '无法访问摄像头,请检查权限设置'
    currentStep.value = 'error'
  }
}

function handleCountdownDone() {
  currentStep.value = 'recording'
}

async function handleRecorded(webmBlob) {
  currentStep.value = 'uploading'
  
  try {
    // Convert webm to mp4
    const mp4Blob = await convertToMp4(webmBlob)
    
    // Upload video
    const response = await uploadVideo(mp4Blob)
    
    if (response.code === 0) {
      reportData.value = response.data
      currentStep.value = 'report'
    } else {
      throw new Error(response.msg || '分析失败')
    }
  } catch (error) {
    console.error('Upload or processing failed:', error)
    errorMessage.value = error.message || '上传或分析失败,请重试'
    currentStep.value = 'error'
  } finally {
    // Stop camera stream
    if (cameraStream.value) {
      cameraStream.value.getTracks().forEach(track => track.stop())
      cameraStream.value = null
    }
  }
}

function handleRetry() {
  reportData.value = null
  errorMessage.value = ''
  currentStep.value = 'guide'
}
</script>

<style scoped>
.app-container {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
