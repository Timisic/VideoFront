import { FFmpeg } from '@ffmpeg/ffmpeg'
import { fetchFile, toBlobURL } from '@ffmpeg/util'

let ffmpeg = null
let loaded = false

async function loadFFmpeg() {
  if (loaded) return
  
  ffmpeg = new FFmpeg()
  
  const baseURL = 'https://unpkg.com/@ffmpeg/core@0.12.6/dist/umd'
  await ffmpeg.load({
    coreURL: await toBlobURL(`${baseURL}/ffmpeg-core.js`, 'text/javascript'),
    wasmURL: await toBlobURL(`${baseURL}/ffmpeg-core.wasm`, 'application/wasm')
  })
  
  loaded = true
}

export async function convertToMp4(webmBlob) {
  try {
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
    
    return mp4Blob
  } catch (error) {
    console.error('Failed to convert video:', error)
    // If conversion fails, return original blob
    // Backend might accept webm format
    return webmBlob
  }
}
