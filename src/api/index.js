import axios from 'axios'
import { MOCK_REPORT_DATA } from './mockData'

// Set to true to use mock data (for testing without backend)
const USE_MOCK = false

const api = axios.create({
  baseURL: '/api',
  timeout: 120000
})

export async function uploadVideo(videoBlob) {
  // Use mock data if enabled
  if (USE_MOCK) {
    console.log('🧪 Using mock data (backend not available)')
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 2000))
    return {
      code: 0,
      msg: 'success',
      data: MOCK_REPORT_DATA
    }
  }
  
  // Real API call
  console.log('📦 准备上传视频...')
  console.log('  - Blob 大小:', (videoBlob.size / 1024 / 1024).toFixed(2), 'MB')
  console.log('  - Blob 类型:', videoBlob.type)
  
  const formData = new FormData()
  
  // 根据视频格式设置正确的文件扩展名
  const fileExtension = videoBlob.type.includes('mp4') ? 'mp4' : 'webm'
  const fileName = `recording.${fileExtension}`
  
  // 后端 API 期望字段名为 'file' (参考 docs/test_request.py)
  formData.append('file', videoBlob, fileName)
  
  // 添加分析维度参数 (参考 docs/test_request.py 第 27 行)
  const dimensions = ["BIG_A", "BIG_C", "BIG_E", "BIG_N", "BIG_O", "face_yyzp"]
  formData.append('dimensions', JSON.stringify(dimensions))
  
  console.log('📤 上传文件信息:')
  console.log('  - 字段名: file')
  console.log('  - 文件名:', fileName)
  console.log('  - Content-Type:', videoBlob.type)
  console.log('  - 分析维度:', dimensions)
  console.log('  - 目标 URL: /api/v1/analysis/face_video')
  
  try {
    const { data } = await api.post('/v1/analysis/face_video', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
    
    console.log('✅ 上传成功，后端响应:')
    console.log('  - Response code:', data.code)
    console.log('  - Response msg:', data.msg)
    console.log('  - Response data:', data.data ? '✅ 有数据' : '❌ 无数据')
    
    if (data.data) {
      console.log('📊 分析结果预览:')
      console.log('  - 数据类型:', typeof data.data)
      console.log('  - 数据键:', Object.keys(data.data))
    }
    
    return data
  } catch (error) {
    console.error('❌ 上传失败，详细错误信息:')
    console.error('  - 错误类型:', error.name)
    console.error('  - 错误消息:', error.message)
    
    if (error.response) {
      console.error('  - HTTP 状态码:', error.response.status)
      console.error('  - 状态文本:', error.response.statusText)
      console.error('  - 响应头:', error.response.headers)
      console.error('  - 响应数据:', error.response.data)
      
      // 尝试解析后端错误消息
      if (error.response.data) {
        console.error('📋 后端错误详情:')
        if (typeof error.response.data === 'string') {
          console.error('  - 错误信息:', error.response.data)
        } else {
          console.error('  - 错误对象:', JSON.stringify(error.response.data, null, 2))
        }
      }
    } else if (error.request) {
      console.error('  - 请求已发送但无响应')
      console.error('  - Request:', error.request)
    } else {
      console.error('  - 请求配置错误:', error.message)
    }
    
    console.error('  - 完整错误栈:', error.stack)
    
    // 重新抛出错误，让上层处理
    throw error
  }
}
