import axios from 'axios'
import { MOCK_REPORT_DATA } from './mockData'

// Set to true to use mock data (for testing without backend)
const USE_MOCK = true

const api = axios.create({
  baseURL: '/api',
  timeout: 120000
})

export async function uploadVideo(videoBlob) {
  // Use mock data if enabled
  if (USE_MOCK) {
    console.log('Using mock data (backend not available)')
    // Simulate network delay
    await new Promise(resolve => setTimeout(resolve, 2000))
    return {
      code: 0,
      msg: 'success',
      data: MOCK_REPORT_DATA
    }
  }
  
  // Real API call
  const formData = new FormData()
  formData.append('video', videoBlob, 'recording.mp4')
  
  const { data } = await api.post('/v1/analysis/face_video', formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
  
  return data
}
