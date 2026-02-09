import { FFmpeg } from '@ffmpeg/ffmpeg'
import { fetchFile, toBlobURL } from '@ffmpeg/util'

let ffmpeg = null
let loaded = false

async function loadFFmpeg() {
  if (loaded) return
  
  ffmpeg = new FFmpeg()
  
  try {
    console.log('从本地加载 FFmpeg...')
    
    // 使用本地打包的 FFmpeg 核心文件
    const baseURL = window.location.origin + '/ffmpeg'
    
    await ffmpeg.load({
      coreURL: await toBlobURL(`${baseURL}/ffmpeg-core.js`, 'text/javascript'),
      wasmURL: await toBlobURL(`${baseURL}/ffmpeg-core.wasm`, 'application/wasm')
    })
    
    console.log('FFmpeg 加载成功')
    loaded = true
  } catch (error) {
    console.error('FFmpeg 加载失败:', error)
    throw new Error('FFmpeg 加载失败: ' + error.message)
  }
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
