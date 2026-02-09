import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  timeout: 120000
})

export async function uploadVideo(videoBlob) {
  const formData = new FormData()
  formData.append('video', videoBlob, 'recording.mp4')
  
  const { data } = await api.post('/v1/analysis/face_video', formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  })
  
  return data
}
