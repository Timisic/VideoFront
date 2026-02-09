#!/usr/bin/env python3
"""
测试后端 API 接口
用法: python test_api.py <video_file_path>
"""

import sys
import requests
import json
from pathlib import Path

# API 配置
API_URL = "http://192.168.8.167:8080/api/v1/analysis/face_video"
DIMENSIONS = ["BIG_A", "BIG_C", "BIG_E", "BIG_N", "BIG_O", "face_yyzp"]

def test_api(video_path):
    """测试 API 接口"""
    
    # 检查文件是否存在
    video_file = Path(video_path)
    if not video_file.exists():
        print(f"错误: 视频文件不存在: {video_path}")
        return
    
    print(f"测试 API: {API_URL}")
    print(f"视频文件: {video_path}")
    print(f"期望维度: {', '.join(DIMENSIONS)}")
    print("-" * 60)
    
    try:
        # 准备文件
        with open(video_path, 'rb') as f:
            files = {'video': (video_file.name, f, 'video/mp4')}
            
            print("发送请求...")
            response = requests.post(API_URL, files=files, timeout=120)
        
        print(f"\nHTTP 状态码: {response.status_code}")
        print(f"响应时间: {response.elapsed.total_seconds():.2f}s")
        print("-" * 60)
        
        # 解析响应
        if response.status_code == 200:
            try:
                data = response.json()
                print("\n✅ 请求成功!")
                print("\n完整响应:")
                print(json.dumps(data, indent=2, ensure_ascii=False))
                
                # 检查返回的维度
                if 'data' in data:
                    returned_dims = list(data['data'].keys())
                    print(f"\n返回的维度: {', '.join(returned_dims)}")
                    
                    # 检查是否包含所有期望的维度
                    missing_dims = set(DIMENSIONS) - set(returned_dims)
                    extra_dims = set(returned_dims) - set(DIMENSIONS)
                    
                    if missing_dims:
                        print(f"⚠️  缺少的维度: {', '.join(missing_dims)}")
                    if extra_dims:
                        print(f"ℹ️  额外的维度: {', '.join(extra_dims)}")
                    
                    # 显示每个维度的详细信息
                    print("\n各维度详细信息:")
                    for dim in returned_dims:
                        dim_data = data['data'][dim]
                        print(f"\n  {dim}:")
                        print(f"    - 维度名称: {dim_data.get('dimension_name', 'N/A')}")
                        print(f"    - 得分: {dim_data.get('score', 'N/A')}")
                        print(f"    - 原始分数: {dim_data.get('raw_score', 'N/A')}")
                        print(f"    - 结果: {dim_data.get('result', 'N/A')}")
                        interpretation = dim_data.get('interpretation', '')
                        if interpretation:
                            print(f"    - 解释: {interpretation[:100]}...")
                
            except json.JSONDecodeError:
                print("❌ 响应不是有效的 JSON 格式")
                print(f"原始响应: {response.text}")
        else:
            print(f"\n❌ 请求失败!")
            print(f"响应内容: {response.text}")
    
    except requests.exceptions.Timeout:
        print("\n❌ 请求超时 (120秒)")
    except requests.exceptions.ConnectionError:
        print("\n❌ 连接失败，请检查:")
        print("  1. 后端服务是否运行")
        print("  2. 网络连接是否正常")
        print("  3. API 地址是否正确")
    except Exception as e:
        print(f"\n❌ 发生错误: {e}")
    
    print("-" * 60)

def main():
    if len(sys.argv) < 2:
        print("用法: python test_api.py <video_file_path>")
        print("\n示例:")
        print("  python test_api.py test_video.mp4")
        print("  python test_api.py /path/to/video.mp4")
        sys.exit(1)
    
    video_path = sys.argv[1]
    test_api(video_path)

if __name__ == "__main__":
    main()
