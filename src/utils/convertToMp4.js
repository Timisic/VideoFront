import { FFmpeg } from '@ffmpeg/ffmpeg'
import { fetchFile, toBlobURL } from '@ffmpeg/util'

let ffmpeg = null
let loaded = false

async function loadFFmpeg() {
  if (loaded) {
    console.log('✅ FFmpeg 已加载，跳过')
    return
  }
  
  ffmpeg = new FFmpeg()
  
  // 启用 FFmpeg 日志
  ffmpeg.on('log', ({ message }) => {
    console.log('FFmpeg 内部日志:', message)
  })
  
  try {
    console.log('🔄 开始从本地加载 FFmpeg...')
    
    // 使用本地打包的 FFmpeg 核心文件
    const baseURL = window.location.origin + '/ffmpeg'
    console.log('📂 FFmpeg 基础 URL:', baseURL)
    
    // 加载 JS 文件
    console.log('⏳ 正在加载 ffmpeg-core.js...')
    const coreURL = await toBlobURL(`${baseURL}/ffmpeg-core.js`, 'text/javascript')
    console.log('✅ ffmpeg-core.js Blob URL 创建成功')
    
    // 加载 WASM 文件
    console.log('⏳ 正在加载 ffmpeg-core.wasm (31MB，可能需要几秒)...')
    const wasmURL = await toBlobURL(`${baseURL}/ffmpeg-core.wasm`, 'application/wasm')
    console.log('✅ ffmpeg-core.wasm Blob URL 创建成功')
    
    // 初始化 FFmpeg
    console.log('⏳ 正在初始化 FFmpeg 实例...')
    await ffmpeg.load({
      coreURL,
      wasmURL
    })
    
    console.log('✅ FFmpeg 加载成功！')
    loaded = true
  } catch (error) {
    console.error('❌ FFmpeg 加载失败:', error)
    console.error('错误详情:', {
      name: error.name,
      message: error.message,
      stack: error.stack
    })
    throw new Error('FFmpeg 加载失败: ' + error.message)
  }
}

export async function convertToMp4(webmBlob) {
  try {
    console.log('🎬 开始视频转换流程...')
    console.log('📊 输入视频信息:', {
      type: webmBlob.type,
      size: (webmBlob.size / 1024 / 1024).toFixed(2) + ' MB'
    })
    
    await loadFFmpeg()
    
    // Write input file
    console.log('💾 写入输入文件到 FFmpeg...')
    await ffmpeg.writeFile('input.webm', await fetchFile(webmBlob))
    console.log('✅ 输入文件写入成功')
    
    // Convert to MP4
    console.log('🔄 开始转换 WebM → MP4...')
    await ffmpeg.exec(['-i', 'input.webm', '-c:v', 'libx264', '-preset', 'fast', 'output.mp4'])
    console.log('✅ 转换完成')
    
    // Read output file
    console.log('📖 读取输出文件...')
    const data = await ffmpeg.readFile('output.mp4')
    console.log('✅ 输出文件读取成功')
    
    // Create blob
    const mp4Blob = new Blob([data.buffer], { type: 'video/mp4' })
    console.log('📊 输出视频信息:', {
      type: mp4Blob.type,
      size: (mp4Blob.size / 1024 / 1024).toFixed(2) + ' MB'
    })
    
    // Clean up
    console.log('🧹 清理临时文件...')
    await ffmpeg.deleteFile('input.webm')
    await ffmpeg.deleteFile('output.mp4')
    console.log('✅ 清理完成')
    
    console.log('🎉 视频转换成功！')
    return mp4Blob
  } catch (error) {
    console.warn('⚠️ 视频转换失败，使用原始 WebM 格式:', error.message)
    console.warn('错误详情:', {
      name: error.name,
      message: error.message,
      stack: error.stack
    })
    // 如果转换失败，直接返回原始 WebM blob
    // 后端应该能够处理 WebM 格式
    return webmBlob
  }
}
