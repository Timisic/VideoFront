# 后端 API 测试指南

## API 信息

- **地址**: `http://192.168.8.167:8080/api/v1/analysis/face_video`
- **方法**: POST
- **Content-Type**: multipart/form-data
- **参数**: video (视频文件)
- **期望维度**: BIG_A, BIG_C, BIG_E, BIG_N, BIG_O, face_yyzp

## 测试方法

### 方法 1: 使用 curl (简单快速)

```bash
# 基本用法
curl -X POST http://192.168.8.167:8080/api/v1/analysis/face_video \
  -F "video=@/path/to/your/video.mp4"

# 带格式化输出 (需要 jq)
curl -X POST http://192.168.8.167:8080/api/v1/analysis/face_video \
  -F "video=@/path/to/your/video.mp4" | jq '.'

# 显示详细信息
curl -X POST http://192.168.8.167:8080/api/v1/analysis/face_video \
  -F "video=@/path/to/your/video.mp4" \
  -w "\nHTTP状态码: %{http_code}\n响应时间: %{time_total}s\n"
```

### 方法 2: 使用 Bash 脚本

```bash
# 添加执行权限
chmod +x test_api.sh

# 运行测试
./test_api.sh /path/to/your/video.mp4
```

### 方法 3: 使用 Python 脚本 (推荐)

```bash
# 安装依赖
pip install requests

# 运行测试
python test_api.py /path/to/your/video.mp4
```

**Python 脚本优势**:
- ✅ 自动检查文件是否存在
- ✅ 格式化 JSON 输出
- ✅ 检查返回的维度是否完整
- ✅ 显示每个维度的详细信息
- ✅ 更好的错误处理

## 在 Linux 服务器上测试

### 一行命令测试

```bash
# 使用 curl (最简单)
curl -X POST http://192.168.8.167:8080/api/v1/analysis/face_video \
  -F "video=@test.mp4" \
  2>/dev/null | python3 -m json.tool

# 或者使用 Python (如果有 requests 库)
python3 -c "
import requests
r = requests.post('http://192.168.8.167:8080/api/v1/analysis/face_video', 
                  files={'video': open('test.mp4', 'rb')})
print(r.json())
"
```

### 创建测试视频 (如果没有视频文件)

```bash
# 使用 ffmpeg 创建一个简单的测试视频 (5秒黑屏)
ffmpeg -f lavfi -i color=black:s=640x480:d=5 -c:v libx264 test.mp4

# 或者从摄像头录制 5 秒
ffmpeg -f v4l2 -i /dev/video0 -t 5 test.mp4
```

## 期望的响应格式

```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "BIG_A": {
      "result": "高宜人性",
      "score": 0.57,
      "interpretation": "该个体属于高宜人性...",
      "raw_score": 57.0,
      "dimension_name": "宜人性"
    },
    "BIG_C": {
      "result": "高尽责性",
      "score": 0.6,
      "interpretation": "该个体的得分属于高尽责性...",
      "raw_score": 60.0,
      "dimension_name": "尽责性"
    },
    "BIG_E": {
      "result": "高外倾性",
      "score": 0.54,
      "interpretation": "该个体属于高外倾性...",
      "raw_score": 54.0,
      "dimension_name": "外倾性"
    },
    "BIG_N": {
      "result": "高神经质",
      "score": 0.4,
      "interpretation": "该个体属于高神经质...",
      "raw_score": 40.0,
      "dimension_name": "神经质"
    },
    "BIG_O": {
      "result": "较高开放性",
      "score": 0.4,
      "interpretation": "该个体属于较高开放性...",
      "raw_score": 40,
      "dimension_name": "开放性"
    },
    "face_yyzp": {
      "result": "...",
      "score": 0.0,
      "interpretation": "...",
      "raw_score": 0.0,
      "dimension_name": "..."
    }
  }
}
```

## 常见问题

### 1. 连接被拒绝

```
curl: (7) Failed to connect to 192.168.8.167 port 8080: Connection refused
```

**解决方案**:
- 检查后端服务是否运行
- 检查防火墙设置
- 确认 IP 地址和端口正确

### 2. 超时

```
curl: (28) Operation timed out
```

**解决方案**:
- 增加超时时间: `curl --max-time 120 ...`
- 检查网络连接
- 视频文件可能太大

### 3. 文件格式错误

```
{"code": 400, "msg": "Invalid video format"}
```

**解决方案**:
- 确保视频是 MP4 格式
- 检查视频是否损坏
- 尝试重新编码: `ffmpeg -i input.webm -c:v libx264 output.mp4`

## 快速测试命令汇总

```bash
# 1. 最简单的测试 (curl)
curl -X POST http://192.168.8.167:8080/api/v1/analysis/face_video -F "video=@test.mp4"

# 2. 带格式化的测试 (curl + jq)
curl -X POST http://192.168.8.167:8080/api/v1/analysis/face_video -F "video=@test.mp4" | jq '.'

# 3. 带详细信息的测试 (curl)
curl -X POST http://192.168.8.167:8080/api/v1/analysis/face_video \
  -F "video=@test.mp4" \
  -w "\nStatus: %{http_code}\nTime: %{time_total}s\n"

# 4. 使用 Python 脚本 (推荐)
python3 test_api.py test.mp4

# 5. 使用 Bash 脚本
./test_api.sh test.mp4
```

## 检查维度完整性

使用 Python 脚本会自动检查返回的维度是否包含所有期望的维度:
- BIG_A (宜人性)
- BIG_C (尽责性)
- BIG_E (外倾性)
- BIG_N (神经质)
- BIG_O (开放性)
- face_yyzp (面部...)

如果缺少某些维度，脚本会显示警告信息。
