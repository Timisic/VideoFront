# 多模态心理分析统一接口规范

## 1. 概述

本文档定义了六种模态数据的心理分析统一接口规范，支持的模态包括：

| 模态代码 | 名称 | 支持格式 | 最大文件大小 |
|----------|------|----------|--------------|
| `face_video` | 面部视频 | mp4, mkv | 50 MB |
| `gait_video` | 步态视频 | mp4, mkv | 50 MB |
| `voice` | 语音 | mp3, wav | 10 MB |
| `text_zh_hans` | 简体中文 | txt | 1 MB |
| `text_zh_hant` | 繁体中文 | txt | 1 MB |
| `text_en` | 英文 | txt | 1 MB |

---

## 2. 接口定义

### 2.1 接口地址

```
POST /api/v1/analysis/{modality}
```

**路径参数：**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| modality | string | 是 | 模态类型，可选值见上表模态代码 |

**完整接口列表：**

```
POST /api/v1/analysis/face_video      # 面部视频分析
POST /api/v1/analysis/gait_video      # 步态视频分析
POST /api/v1/analysis/voice           # 语音分析
POST /api/v1/analysis/text_zh_hans    # 简体中文分析
POST /api/v1/analysis/text_zh_hant    # 繁体中文分析
POST /api/v1/analysis/text_en         # 英文分析
```

---

### 2.2 请求参数

#### 方式一：文件上传（multipart/form-data）

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | File | 是 | 待分析的文件对象 |
| dimensions | string | 是 | 指定分析维度列表，JSON 数组格式，如 `["emotion_stability","anxiety_level"]`，不能为空 |

**示例：**

```bash
curl -X POST "https://api.example.com/api/v1/analysis/face_video" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@/path/to/video.mp4" \
  -F 'dimensions=["emotion_stability","anxiety_level"]'
```

#### 方式二：URL 地址（application/json）

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| url | string | 是 | 文件的可访问 URL 地址 |
| dimensions | array | 是 | 指定分析维度列表，如 `["emotion_stability","anxiety_level"]`，不能为空 |

大五人格和抑郁，
["BIG-A","BIG-C","BIG-E","BIG-N","BIG-C","BIG-O","face-yyzp"]

**示例：**

```bash
curl -X POST "https://api.example.com/api/v1/analysis/face_video" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://your-oss.com/path/to/video.mp4",
    "dimensions": ["emotion_stability", "anxiety_level"]
  }'
```

---

### 2.3 响应格式

```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "维度名称": {
      "result": "分析结果",
      "score": 0.00,
      "interpretation": "结果解读"
    }
  }
}
```

**响应字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| code | int | 状态码，0 表示成功，非 0 表示失败 |
| msg | string | 状态描述信息 |
| data | object | 心理分析结果，key 为分析维度，value 为分析详情。若请求时指定了 `dimensions`，则只返回指定的维度 |

**data 中每个维度的字段说明：**

| 字段 | 类型 | 说明 |
|------|------|------|
| result | string | 分析结果 |
| score | float | 分析分数（0-1 或具体评分范围） |
| interpretation | string | 结果解读 |

**dimensions 参数说明：**

- `dimensions` 为必填参数，不能为空数组
- 仅返回 `dimensions` 中指定的分析维度
- 若 `dimensions` 中包含系统未配置的维度，接口返回错误码 `1007`
- 若 `dimensions` 为空数组，接口返回错误码 `1001`

---

## 3. 响应示例

### 3.1 面部视频分析（face_video）

```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "emotion_stability": {
      "result": "中等",
      "score": 0.65,
      "interpretation": "情绪波动处于正常范围，能够较好地控制情绪表达"
    },
    "anxiety_level": {
      "result": "轻度",
      "score": 0.28,
      "interpretation": "存在轻微焦虑迹象，表现为眼部微表情偶有紧张"
    },
    "stress_index": {
      "result": "正常",
      "score": 0.42,
      "interpretation": "压力水平处于可控范围，面部肌肉紧张度适中"
    },
    "confidence_level": {
      "result": "较高",
      "score": 0.78,
      "interpretation": "表现出较强的自信特征，目光稳定、表情自然"
    }
  }
}
```

### 3.2 步态视频分析（gait_video）

```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "gait_stability": {
      "result": "稳定",
      "score": 0.82,
      "interpretation": "步态平稳有节奏，重心转换流畅自然"
    },
    "energy_level": {
      "result": "中等",
      "score": 0.55,
      "interpretation": "行走节奏适中，精力状态处于正常水平"
    },
    "tension_index": {
      "result": "低",
      "score": 0.25,
      "interpretation": "身体较为放松，肢体动作协调舒展"
    },
    "mood_tendency": {
      "result": "积极",
      "score": 0.71,
      "interpretation": "步态特征显示情绪状态偏向积极乐观"
    }
  }
}
```

### 3.3 语音分析（voice）

```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "emotional_tone": {
      "result": "平稳",
      "score": 0.68,
      "interpretation": "语调平和稳定，情绪表达适度"
    },
    "anxiety_indicator": {
      "result": "低",
      "score": 0.22,
      "interpretation": "语音特征未显示明显焦虑信号，语速和音调正常"
    },
    "confidence_score": {
      "result": "较高",
      "score": 0.75,
      "interpretation": "声音有力清晰，表达流畅，显示较强自信"
    },
    "stress_marker": {
      "result": "正常",
      "score": 0.38,
      "interpretation": "语音压力指标正常，未检测到明显压力特征"
    }
  }
}
```

### 3.4 文本分析（text_zh_hans / text_zh_hant / text_en）

```json
{
  "code": 0,
  "msg": "success",
  "data": {
    "sentiment_polarity": {
      "result": "正向",
      "score": 0.72,
      "interpretation": "文本整体情感倾向积极，用词偏正面"
    },
    "emotional_intensity": {
      "result": "中等",
      "score": 0.55,
      "interpretation": "情感表达强度适中，既非过于压抑也非过于激烈"
    },
    "cognitive_pattern": {
      "result": "理性",
      "score": 0.81,
      "interpretation": "思维模式偏理性分析，逻辑清晰有条理"
    },
    "psychological_state": {
      "result": "稳定",
      "score": 0.69,
      "interpretation": "文字反映的心理状态较为平稳健康"
    }
  }
}
```

---

## 4. 错误码定义

| code | msg | 说明 |
|------|-----|------|
| 0 | success | 成功 |
| 1001 | invalid parameter | 参数错误 |
| 1002 | unsupported format | 不支持的文件格式 |
| 1003 | file too large | 文件大小超限 |
| 1004 | invalid modality | 无效的模态类型 |
| 1005 | file download failed | URL 文件下载失败 |
| 1006 | file is empty | 文件内容为空 |
| 1007 | invalid dimension | 无效的分析维度 |
| 2001 | unauthorized | 认证失败 |
| 2002 | forbidden | 权限不足 |
| 2003 | rate limit exceeded | 请求频率超限 |
| 3001 | internal error | 服务内部错误 |
| 3002 | model error | 模型调用失败 |
| 3003 | service unavailable | 服务暂时不可用 |

**错误响应示例：**

```json
{
  "code": 1001,
  "msg": "invalid parameter: dimensions is required and cannot be empty",
  "data": null
}
```

```json
{
  "code": 1007,
  "msg": "invalid dimension: unknown_dimension is not supported for face_video",
  "data": null
}
```

```json
{
  "code": 1002,
  "msg": "unsupported format: avi is not allowed for face_video, only mp4 and mkv are supported",
  "data": null
}
```

```json
{
  "code": 1003,
  "msg": "file too large: 65MB exceeds the limit of 50MB for face_video",
  "data": null
}
```

---

## 5. 文件限制汇总

| 模态 | 支持格式 | 最大文件大小 |
|------|----------|--------------|
| face_video | mp4, mkv | 50 MB |
| gait_video | mp4, mkv | 50 MB |
| voice | mp3, wav | 10 MB |
| text_zh_hans | txt | 1 MB |
| text_zh_hant | txt | 1 MB |
| text_en | txt | 1 MB |

---

## 6. SDK 使用示例

### Python

```python
import requests
import json

API_BASE = "https://api.example.com/api/v1/analysis"

def analyze_file(modality: str, file_path: str, token: str, dimensions: list) -> dict:
    """文件上传方式"""
    url = f"{API_BASE}/{modality}"
    headers = {"Authorization": f"Bearer {token}"}
    
    data = {"dimensions": json.dumps(dimensions)}
    
    with open(file_path, "rb") as f:
        response = requests.post(url, headers=headers, files={"file": f}, data=data)
    
    return response.json()

def analyze_url(modality: str, file_url: str, token: str, dimensions: list) -> dict:
    """URL 地址方式"""
    url = f"{API_BASE}/{modality}"
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "url": file_url,
        "dimensions": dimensions
    }
    
    response = requests.post(url, headers=headers, json=payload)
    return response.json()

# 使用示例
result = analyze_file(
    "face_video", 
    "/path/to/video.mp4", 
    "YOUR_TOKEN",
    dimensions=["emotion_stability", "anxiety_level"]
)

if result["code"] == 0:
    for dimension, detail in result["data"].items():
        print(f"【{dimension}】")
        print(f"  结果: {detail['result']}")
        print(f"  分数: {detail['score']}")
        print(f"  解读: {detail['interpretation']}")
else:
    print(f"分析失败: {result['msg']}")
```

### JavaScript

```javascript
const API_BASE = 'https://api.example.com/api/v1/analysis';

// 文件上传方式
async function analyzeFile(modality, file, token, dimensions) {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('dimensions', JSON.stringify(dimensions));

  const response = await fetch(`${API_BASE}/${modality}`, {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${token}` },
    body: formData
  });

  return response.json();
}

// URL 地址方式
async function analyzeUrl(modality, fileUrl, token, dimensions) {
  const payload = {
    url: fileUrl,
    dimensions: dimensions
  };

  const response = await fetch(`${API_BASE}/${modality}`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(payload)
  });

  return response.json();
}

// 使用示例
const result = await analyzeFile('voice', audioFile, 'YOUR_TOKEN', ['emotional_tone', 'anxiety_indicator']);

if (result.code === 0) {
  Object.entries(result.data).forEach(([dimension, detail]) => {
    console.log(`【${dimension}】`);
    console.log(`  结果: ${detail.result}`);
    console.log(`  分数: ${detail.score}`);
    console.log(`  解读: ${detail.interpretation}`);
  });
}
```

---

## 7. 注意事项

1. **认证方式**：所有请求需在 Header 中携带 `Authorization: Bearer {token}`
2. **超时设置**：视频文件分析建议设置较长超时时间（如 60 秒）
3. **URL 有效性**：传入的 URL 必须公网可访问，建议使用带签名的临时访问链接
4. **文本编码**：txt 文件请使用 UTF-8 编码
5. **文件格式**：请严格按照支持的格式上传，其他格式将返回 1002 错误

---

## 8. 待细化事项

- [ ] 各模态 `data` 字段的完整维度定义
- [ ] `score` 字段的评分范围和标准
- [ ] 认证鉴权具体实现方案
- [ ] 异步任务处理机制（如需要）

---

## 版本历史

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| v1.0.0 | 2024-01-15 | 初始版本 |
