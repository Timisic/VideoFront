#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Request script for Psychology Analysis API.

Uploads a local face video and requests specific dimensions.

请求示例
"""
import json
from pathlib import Path

import requests


API_BASE = "http://192.168.8.167:8080/api/v1/analysis"
VIDEO_PATH = Path("sample1.mkv")
DIMENSIONS = ["BIG_A", "BIG_C", "BIG_E", "BIG_N", "BIG_O"]


def analyze_face_video(file_path: Path, dimensions: list) -> dict:
    url = f"{API_BASE}/face_video"
    with file_path.open("rb") as f:
        response = requests.post(
            url,
            files={"file": f},
            data={"dimensions": json.dumps(dimensions)},
            timeout=1000,
        )
    return response.json()


def main() -> None:
    if not VIDEO_PATH.exists():
        raise FileNotFoundError(f"Video not found: {VIDEO_PATH}")

    result = analyze_face_video(VIDEO_PATH, DIMENSIONS)
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
