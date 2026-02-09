#!/bin/bash
# 测试后端 API 接口
# 用法: ./test_api.sh <video_file_path>

API_URL="http://192.168.8.167:8080/api/v1/analysis/face_video"
VIDEO_FILE="${1:-test_video.mp4}"

echo "测试 API: $API_URL"
echo "视频文件: $VIDEO_FILE"
echo "-----------------------------------"

if [ ! -f "$VIDEO_FILE" ]; then
    echo "错误: 视频文件不存在: $VIDEO_FILE"
    echo "请提供一个有效的视频文件路径"
    echo "用法: $0 <video_file_path>"
    exit 1
fi

echo "发送请求..."
curl -X POST "$API_URL" \
  -H "Content-Type: multipart/form-data" \
  -F "video=@$VIDEO_FILE" \
  -w "\n\nHTTP 状态码: %{http_code}\n响应时间: %{time_total}s\n" \
  | jq '.' 2>/dev/null || cat

echo "-----------------------------------"
echo "完成"
