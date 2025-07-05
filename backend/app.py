"""
华图儿AI创意绘画应用 - 后端API服务
集成阿里云百炼API，提供完整的创作服务
"""

import os
import uuid
import json
import base64
from datetime import datetime, timedelta
from typing import Optional, Dict, Any

from flask import Flask, request, jsonify
from flask_cors import CORS
from celery import Celery
import redis
from supabase import create_client, Client
import requests
from werkzeug.utils import secure_filename

# 配置
class Config:
    # Supabase配置
    SUPABASE_URL = "https://iqmckkfhdhemsixdpesa.supabase.co"
    SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxbWNra2ZoZGhlbXNpeGRwZXNhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE2MTIxMzAsImV4cCI6MjA2NzE4ODEzMH0.ccw6Yz3fdoxQ__NfUR6v4cjl3WV4_h8eG1HNgKwd_RQ"
    SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxbWNra2ZoZGhlbXNpeGRwZXNhIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTYxMjEzMCwiZXhwIjoyMDY3MTg4MTMwfQ.gvHg1rXXhX4eduvoPzEDUcguRgJ3yG2cMndkk7SQCEw"
    
    # 阿里云百炼API配置
    DASHSCOPE_API_KEY = "sk-070725ebe68c4c9d9cbb9392f23fbbe5"
    DASHSCOPE_BASE_URL = "https://dashscope.aliyuncs.com/api/v1"
    
    # Redis配置
    REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379/0')
    
    # Celery配置
    CELERY_BROKER_URL = REDIS_URL
    CELERY_RESULT_BACKEND = REDIS_URL

# 初始化Flask应用
app = Flask(__name__)
app.config.from_object(Config)
CORS(app)

# 初始化Supabase客户端
supabase: Client = create_client(Config.SUPABASE_URL, Config.SUPABASE_SERVICE_KEY)

# 初始化Celery
celery = Celery(app.name, broker=Config.CELERY_BROKER_URL)
celery.conf.update(result_backend=Config.CELERY_RESULT_BACKEND)

# 初始化Redis
redis_client = redis.from_url(Config.REDIS_URL)

class DashScopeAPI:
    """阿里云百炼API封装类"""
    
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = Config.DASHSCOPE_BASE_URL
        self.headers = {
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json'
        }
    
    def sketch_to_image(self, sketch_image_base64: str, prompt: str = "", style: str = "anime") -> Dict[str, Any]:
        """涂鸦作画 - 将手绘草图转换为精美图片"""
        url = f"{self.base_url}/services/aigc/text2image/image-synthesis"
        
        payload = {
            "model": "wanx-sketch-to-image-lite",
            "input": {
                "sketch_image": sketch_image_base64,
                "prompt": prompt,
                "style": style
            },
            "parameters": {
                "size": "1024*1024",
                "n": 1
            }
        }
        
        response = requests.post(url, headers=self.headers, json=payload)
        return response.json()
    
    def image_to_video(self, image_url: str, duration: int = 10) -> Dict[str, Any]:
        """图生视频 - 将生成的图片制作成动态视频"""
        url = f"{self.base_url}/services/aigc/image2video/generation"
        
        payload = {
            "model": "wanx2.1-i2v-turbo",
            "input": {
                "image_url": image_url
            },
            "parameters": {
                "duration": duration,
                "fps": 8
            }
        }
        
        response = requests.post(url, headers=self.headers, json=payload)
        return response.json()
    
    def get_task_status(self, task_id: str) -> Dict[str, Any]:
        """获取任务状态"""
        url = f"{self.base_url}/tasks/{task_id}"
        response = requests.get(url, headers=self.headers)
        return response.json()

# 初始化DashScope API
dashscope_api = DashScopeAPI(Config.DASHSCOPE_API_KEY)

@celery.task(bind=True)
def process_creation_task(self, task_id: str):
    """异步处理创作任务"""
    try:
        # 更新任务状态为处理中
        supabase.table('creation_tasks').update({
            'status': 'processing',
            'progress': 10
        }).eq('id', task_id).execute()
        
        # 获取任务详情
        task_result = supabase.table('creation_tasks').select('*').eq('id', task_id).execute()
        if not task_result.data:
            raise Exception("任务不存在")
        
        task = task_result.data[0]
        
        # 步骤1: 涂鸦作画
        self.update_state(state='PROGRESS', meta={'progress': 30, 'step': '正在生成图片...'})
        
        # 从Supabase Storage获取草图
        sketch_response = supabase.storage.from_('sketches').download(task['sketch_image_url'])
        sketch_base64 = base64.b64encode(sketch_response).decode('utf-8')
        
        # 调用涂鸦作画API
        image_result = dashscope_api.sketch_to_image(
            sketch_base64, 
            task.get('voice_description', ''), 
            task.get('style_preference', 'anime')
        )
        
        if image_result.get('output', {}).get('task_status') != 'SUCCEEDED':
            raise Exception(f"图片生成失败: {image_result}")
        
        generated_image_url = image_result['output']['results'][0]['url']
        
        # 更新进度
        self.update_state(state='PROGRESS', meta={'progress': 60, 'step': '图片生成完成，正在生成视频...'})
        
        # 步骤2: 图生视频
        video_result = dashscope_api.image_to_video(
            generated_image_url, 
            task.get('process_duration', 10)
        )
        
        if video_result.get('output', {}).get('task_status') != 'SUCCEEDED':
            raise Exception(f"视频生成失败: {video_result}")
        
        generated_video_url = video_result['output']['results'][0]['url']
        
        # 更新任务完成状态
        supabase.table('creation_tasks').update({
            'status': 'completed',
            'progress': 100,
            'generated_image_url': generated_image_url,
            'generated_video_url': generated_video_url,
            'completed_at': datetime.utcnow().isoformat()
        }).eq('id', task_id).execute()
        
        # 记录创作步骤
        steps = [
            {'task_id': task_id, 'step_type': 'ai_generation', 'step_name': '图片生成完成'},
            {'task_id': task_id, 'step_type': 'video_generation', 'step_name': '视频生成完成'}
        ]
        supabase.table('creation_steps').insert(steps).execute()
        
        # 扣除用户画笔
        user_id = task['user_id']
        supabase.rpc('consume_user_brush', {'user_id': user_id, 'count': task.get('brush_consumed', 1)}).execute()
        
        return {
            'status': 'completed',
            'generated_image_url': generated_image_url,
            'generated_video_url': generated_video_url
        }
        
    except Exception as e:
        # 更新任务失败状态
        supabase.table('creation_tasks').update({
            'status': 'failed',
            'error_message': str(e)
        }).eq('id', task_id).execute()
        
        raise self.retry(exc=e, countdown=60, max_retries=3)

@app.route('/api/health', methods=['GET'])
def health_check():
    """健康检查"""
    return jsonify({'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()})

@app.route('/api/auth/profile', methods=['GET'])
def get_user_profile():
    """获取用户资料"""
    auth_header = request.headers.get('Authorization')
    if not auth_header:
        return jsonify({'error': '未提供认证信息'}), 401
    
    try:
        # 验证JWT token
        token = auth_header.replace('Bearer ', '')
        user = supabase.auth.get_user(token)
        
        # 获取用户详细信息
        result = supabase.table('users').select('*').eq('id', user.user.id).execute()
        
        if result.data:
            return jsonify(result.data[0])
        else:
            return jsonify({'error': '用户不存在'}), 404
            
    except Exception as e:
        return jsonify({'error': str(e)}), 401

@app.route('/api/creation/start', methods=['POST'])
def start_creation():
    """开始创作任务"""
    try:
        data = request.get_json()
        
        # 创建新的创作任务
        task_data = {
            'id': str(uuid.uuid4()),
            'user_id': data['user_id'],
            'title': data.get('title', ''),
            'description': data.get('description', ''),
            'voice_description': data.get('voice_description', ''),
            'style_preference': data.get('style_preference', 'anime'),
            'process_duration': data.get('process_duration', 10),
            'status': 'pending'
        }
        
        # 插入任务记录
        result = supabase.table('creation_tasks').insert(task_data).execute()
        task_id = result.data[0]['id']
        
        # 启动异步处理任务
        celery_task = process_creation_task.delay(task_id)
        
        # 存储Celery任务ID
        redis_client.set(f"task:{task_id}", celery_task.id, ex=3600)
        
        return jsonify({
            'task_id': task_id,
            'celery_task_id': celery_task.id,
            'status': 'started'
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/creation/status/<task_id>', methods=['GET'])
def get_creation_status(task_id: str):
    """获取创作任务状态"""
    try:
        # 从数据库获取任务状态
        result = supabase.table('creation_tasks').select('*').eq('id', task_id).execute()
        
        if not result.data:
            return jsonify({'error': '任务不存在'}), 404
        
        task = result.data[0]
        
        # 如果任务还在处理中，获取Celery任务进度
        if task['status'] == 'processing':
            celery_task_id = redis_client.get(f"task:{task_id}")
            if celery_task_id:
                celery_task = celery.AsyncResult(celery_task_id.decode())
                if celery_task.state == 'PROGRESS':
                    task['progress'] = celery_task.info.get('progress', task['progress'])
                    task['current_step'] = celery_task.info.get('step', '')
        
        return jsonify(task)
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/creation/history/<user_id>', methods=['GET'])
def get_creation_history(user_id: str):
    """获取用户创作历史"""
    try:
        page = request.args.get('page', 1, type=int)
        limit = request.args.get('limit', 20, type=int)
        
        # 计算偏移量
        offset = (page - 1) * limit
        
        # 获取创作历史
        result = supabase.table('creation_tasks')\
            .select('*, creation_steps(*)')\
            .eq('user_id', user_id)\
            .order('created_at', desc=True)\
            .range(offset, offset + limit - 1)\
            .execute()
        
        return jsonify({
            'tasks': result.data,
            'page': page,
            'limit': limit
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
