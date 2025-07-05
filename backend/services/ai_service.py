"""
华图儿AI创意绘画应用 - AI服务集成
集成阿里云百炼API，提供涂鸦作画和图生视频功能
"""

import os
import json
import time
import base64
import requests
from typing import Optional, Dict, Any
from dataclasses import dataclass
from enum import Enum


class TaskStatus(Enum):
    """任务状态枚举"""
    PENDING = "PENDING"
    RUNNING = "RUNNING"
    SUCCESS = "SUCCESS"
    FAILED = "FAILED"


@dataclass
class AIGenerationResult:
    """AI生成结果"""
    success: bool
    task_id: Optional[str] = None
    image_url: Optional[str] = None
    video_url: Optional[str] = None
    progress: int = 0
    error_message: Optional[str] = None


class DashScopeAIService:
    """阿里云百炼AI服务"""
    
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://dashscope.aliyuncs.com/api/v1"
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
    
    def sketch_to_image(self, sketch_base64: str, prompt: str = "", style: str = "anime") -> AIGenerationResult:
        """
        涂鸦作画 - 将用户涂鸦转换为精美图片
        
        Args:
            sketch_base64: Base64编码的涂鸦图片
            prompt: 文字描述
            style: 艺术风格
        
        Returns:
            AIGenerationResult: 生成结果
        """
        try:
            # 构建请求参数
            payload = {
                "model": "wanx-sketch-to-image-lite",
                "input": {
                    "sketch": f"data:image/png;base64,{sketch_base64}",
                    "prompt": prompt or "一幅精美的艺术作品",
                    "style": style
                },
                "parameters": {
                    "size": "1024*1024",
                    "n": 1,
                    "seed": int(time.time())
                }
            }
            
            # 发送请求
            response = requests.post(
                f"{self.base_url}/services/aigc/text2image/image-synthesis",
                headers=self.headers,
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                
                if result.get("output") and result["output"].get("results"):
                    # 同步返回结果
                    image_url = result["output"]["results"][0]["url"]
                    return AIGenerationResult(
                        success=True,
                        image_url=image_url
                    )
                elif result.get("output") and result["output"].get("task_id"):
                    # 异步任务
                    task_id = result["output"]["task_id"]
                    return AIGenerationResult(
                        success=True,
                        task_id=task_id
                    )
                else:
                    return AIGenerationResult(
                        success=False,
                        error_message=f"API返回格式错误: {result}"
                    )
            else:
                return AIGenerationResult(
                    success=False,
                    error_message=f"API请求失败: {response.status_code} - {response.text}"
                )
                
        except Exception as e:
            return AIGenerationResult(
                success=False,
                error_message=f"涂鸦作画失败: {str(e)}"
            )
    
    def image_to_video(self, image_url: str, duration: int = 10) -> AIGenerationResult:
        """
        图生视频 - 将图片转换为创作过程视频
        
        Args:
            image_url: 图片URL
            duration: 视频时长（秒）
        
        Returns:
            AIGenerationResult: 生成结果
        """
        try:
            # 构建请求参数
            payload = {
                "model": "wanx2.1-i2v-turbo",
                "input": {
                    "image_url": image_url
                },
                "parameters": {
                    "duration": min(duration, 10),  # 最大10秒
                    "fps": 24,
                    "resolution": "1024x1024"
                }
            }
            
            # 发送请求
            response = requests.post(
                f"{self.base_url}/services/aigc/image2video/generation",
                headers=self.headers,
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                
                if result.get("output") and result["output"].get("results"):
                    # 同步返回结果
                    video_url = result["output"]["results"][0]["url"]
                    return AIGenerationResult(
                        success=True,
                        video_url=video_url
                    )
                elif result.get("output") and result["output"].get("task_id"):
                    # 异步任务
                    task_id = result["output"]["task_id"]
                    return AIGenerationResult(
                        success=True,
                        task_id=task_id
                    )
                else:
                    return AIGenerationResult(
                        success=False,
                        error_message=f"API返回格式错误: {result}"
                    )
            else:
                return AIGenerationResult(
                    success=False,
                    error_message=f"API请求失败: {response.status_code} - {response.text}"
                )
                
        except Exception as e:
            return AIGenerationResult(
                success=False,
                error_message=f"图生视频失败: {str(e)}"
            )
    
    def get_task_status(self, task_id: str) -> AIGenerationResult:
        """
        获取异步任务状态
        
        Args:
            task_id: 任务ID
        
        Returns:
            AIGenerationResult: 任务状态和结果
        """
        try:
            # 发送状态查询请求
            response = requests.get(
                f"{self.base_url}/tasks/{task_id}",
                headers=self.headers,
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                
                task_status = result.get("task_status", "UNKNOWN")
                
                if task_status == "SUCCEEDED":
                    # 任务成功完成
                    output = result.get("output", {})
                    
                    if "results" in output and output["results"]:
                        # 图片生成结果
                        image_url = output["results"][0].get("url")
                        return AIGenerationResult(
                            success=True,
                            image_url=image_url,
                            progress=100
                        )
                    elif "video_url" in output:
                        # 视频生成结果
                        video_url = output["video_url"]
                        return AIGenerationResult(
                            success=True,
                            video_url=video_url,
                            progress=100
                        )
                    else:
                        return AIGenerationResult(
                            success=False,
                            error_message="任务完成但未找到结果"
                        )
                        
                elif task_status == "RUNNING":
                    # 任务进行中
                    progress = result.get("task_metrics", {}).get("progress", 0)
                    return AIGenerationResult(
                        success=True,
                        progress=progress
                    )
                    
                elif task_status == "FAILED":
                    # 任务失败
                    error_msg = result.get("message", "任务执行失败")
                    return AIGenerationResult(
                        success=False,
                        error_message=error_msg
                    )
                    
                else:
                    # 任务等待中
                    return AIGenerationResult(
                        success=True,
                        progress=0
                    )
                    
            else:
                return AIGenerationResult(
                    success=False,
                    error_message=f"状态查询失败: {response.status_code}"
                )
                
        except Exception as e:
            return AIGenerationResult(
                success=False,
                error_message=f"状态查询异常: {str(e)}"
            )


class MockAIService:
    """模拟AI服务 - 用于开发和测试"""
    
    def sketch_to_image(self, sketch_base64: str, prompt: str = "", style: str = "anime") -> AIGenerationResult:
        """模拟涂鸦作画"""
        # 模拟处理时间
        time.sleep(1)
        
        # 返回模拟结果
        return AIGenerationResult(
            success=True,
            image_url="https://example.com/generated_image.jpg"
        )
    
    def image_to_video(self, image_url: str, duration: int = 10) -> AIGenerationResult:
        """模拟图生视频"""
        # 模拟处理时间
        time.sleep(2)
        
        # 返回模拟结果
        return AIGenerationResult(
            success=True,
            video_url="https://example.com/generated_video.mp4"
        )
    
    def get_task_status(self, task_id: str) -> AIGenerationResult:
        """模拟任务状态查询"""
        return AIGenerationResult(
            success=True,
            progress=100,
            image_url="https://example.com/generated_image.jpg"
        )


def get_ai_service() -> DashScopeAIService:
    """
    获取AI服务实例
    
    Returns:
        AI服务实例
    """
    api_key = os.getenv('DASHSCOPE_API_KEY', 'sk-070725ebe68c4c9d9cbb9392f23fbbe5')
    
    if not api_key or api_key.startswith('your_'):
        # 如果没有配置API密钥，返回模拟服务
        print("警告: 未配置DASHSCOPE_API_KEY，使用模拟AI服务")
        return MockAIService()
    
    return DashScopeAIService(api_key)


# 导出主要类和函数
__all__ = [
    'AIGenerationResult',
    'DashScopeAIService', 
    'MockAIService',
    'get_ai_service',
    'TaskStatus'
]
