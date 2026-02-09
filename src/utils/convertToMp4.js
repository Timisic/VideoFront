import { FFmpeg } from '@ffmpeg/ffmpeg'
import { fetchFile, toBlobURL } from '@ffmpeg/util'

let ffmpeg = null
let loaded = false

// 多个 CDN 源作为备选
const CDN_SOURCES = [
  'https://unpkg.com/@ffmpeg/core@0.12.6/dist/umd',
  'https://cdn.jsdelivr.net/npm/@ffmpeg/core@0.12.6/dist/umd'
]

async function loadFFmpeg() {
  if (loaded) return
  
  ffmpeg = new FFmpeg()
  
  // 尝试从多个 CDN 源加载
  for (const baseURL of CDN_SOURCES) {
    try {
      console.log(`尝试从 ${baseURL} 加载 FFmpeg...`)
      await ffmpeg.load({
        coreURL: await toBlobURL(`${baseURL}/ffmpeg-core.js`, 'text/javascript'),
        wasmURL: await toBlobURL(`${baseURL}/ffmpeg-core.wasm`, 'application/wasm')
      })
      console.log('FFmpeg 加载成功')
      loaded = true
      return
    } catch (error) {
      console.warn(`从 ${baseURL} 加载失败:`, error.message)
      // 继续尝试下一个源
    }
  }
  
  throw new Error('所有 CDN 源均加载失败')
}

export async function convertToMp4(webmBlob) {
  try {
    console.log('开始视频转换...')
    await loadFFmpeg()
    
    // Write input file
    await ffmpeg.writeFile('input.webm', await fetchFile(webmBlob))
    
    // Convert to MP4
    await ffmpeg.exec(['-i', 'input.webm', '-c:v', 'libx264', '-preset', 'fast', 'output.mp4'])
    
    // Read output file
    const data = await ffmpeg.readFile('output.mp4')
    
    // Create blob
    const mp4Blob = new Blob([data.buffer], { type: 'video/mp4' })
    
    // Clean up
    await ffmpeg.deleteFile('input.webm')
    await ffmpeg.deleteFile('output.mp4')
    
    console.log('视频转换成功')
    return mp4Blob
  } catch (error) {
    console.warn('视频转换失败，使用原始 WebM 格式:', error.message)
    // 如果转换失败，直接返回原始 WebM blob
    // 后端应该能够处理 WebM 格式
    return webmBlob
  }
}
