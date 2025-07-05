#!/usr/bin/env python3
"""
华图儿AI创意绘画应用 - AI服务测试脚本
测试阿里云百炼API集成和AI导师功能
"""

import os
import sys
import base64
import json
import time
from PIL import Image, ImageDraw
import io

# 添加项目根目录到Python路径
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.services.ai_service import get_ai_service, AIGenerationResult
from backend.services.ai_mentor_service import AIArtMentorService


def create_test_sketch() -> str:
    """创建测试涂鸦图片"""
    # 创建一个简单的测试图片
    img = Image.new('RGB', (512, 512), color='white')
    draw = ImageDraw.Draw(img)
    
    # 画一个简单的房子
    # 房子主体
    draw.rectangle([150, 250, 350, 400], outline='black', width=3)
    
    # 屋顶
    draw.polygon([(125, 250), (250, 150), (375, 250)], outline='black', width=3)
    
    # 门
    draw.rectangle([220, 320, 280, 400], outline='black', width=2)
    
    # 窗户
    draw.rectangle([170, 280, 210, 320], outline='black', width=2)
    draw.rectangle([290, 280, 330, 320], outline='black', width=2)
    
    # 太阳
    draw.ellipse([400, 50, 450, 100], outline='black', width=2)
    
    # 转换为base64
    buffer = io.BytesIO()
    img.save(buffer, format='PNG')
    img_data = buffer.getvalue()
    
    return base64.b64encode(img_data).decode('utf-8')


def test_ai_service():
    """测试AI服务"""
    print("🎨 测试AI服务...")
    
    # 获取AI服务实例
    ai_service = get_ai_service()
    
    # 创建测试涂鸦
    sketch_base64 = create_test_sketch()
    print("✅ 创建测试涂鸦完成")
    
    # 测试涂鸦作画
    print("\n🖼️ 测试涂鸦作画功能...")
    image_result = ai_service.sketch_to_image(
        sketch_base64=sketch_base64,
        prompt="一座美丽的房子，动漫风格，色彩鲜艳",
        style="anime"
    )
    
    if image_result.success:
        print(f"✅ 涂鸦作画成功!")
        if image_result.image_url:
            print(f"   图片URL: {image_result.image_url}")
        elif image_result.task_id:
            print(f"   异步任务ID: {image_result.task_id}")
            
            # 测试任务状态查询
            print("   等待任务完成...")
            for i in range(10):  # 最多等待50秒
                time.sleep(5)
                status_result = ai_service.get_task_status(image_result.task_id)
                
                if status_result.success:
                    print(f"   进度: {status_result.progress}%")
                    if status_result.image_url:
                        print(f"✅ 异步任务完成! 图片URL: {status_result.image_url}")
                        image_result = status_result
                        break
                else:
                    print(f"❌ 任务状态查询失败: {status_result.error_message}")
                    break
    else:
        print(f"❌ 涂鸦作画失败: {image_result.error_message}")
        return False
    
    # 测试图生视频
    if image_result.image_url:
        print("\n🎬 测试图生视频功能...")
        video_result = ai_service.image_to_video(
            image_url=image_result.image_url,
            duration=5
        )
        
        if video_result.success:
            print("✅ 图生视频成功!")
            if video_result.video_url:
                print(f"   视频URL: {video_result.video_url}")
            elif video_result.task_id:
                print(f"   异步任务ID: {video_result.task_id}")
                
                # 等待视频生成完成
                print("   等待视频生成...")
                for i in range(20):  # 最多等待200秒
                    time.sleep(10)
                    status_result = ai_service.get_task_status(video_result.task_id)
                    
                    if status_result.success:
                        print(f"   进度: {status_result.progress}%")
                        if status_result.video_url:
                            print(f"✅ 视频生成完成! 视频URL: {status_result.video_url}")
                            break
                    else:
                        print(f"❌ 视频生成失败: {status_result.error_message}")
                        break
        else:
            print(f"❌ 图生视频失败: {video_result.error_message}")
    
    return True


def test_ai_mentor_service():
    """测试AI导师服务"""
    print("\n🧠 测试AI导师服务...")
    
    # 初始化AI导师服务
    api_key = os.getenv('DASHSCOPE_API_KEY', 'sk-070725ebe68c4c9d9cbb9392f23fbbe5')
    mentor_service = AIArtMentorService(api_key)
    
    # 创建测试图片
    img = Image.new('RGB', (400, 400), color='white')
    draw = ImageDraw.Draw(img)
    
    # 画一个不平衡的构图
    draw.ellipse([50, 50, 150, 150], fill='red', outline='black', width=2)
    draw.rectangle([300, 300, 380, 380], fill='blue', outline='black', width=2)
    draw.polygon([(200, 100), (250, 50), (300, 100)], fill='green', outline='black', width=2)
    
    # 转换为字节数据
    buffer = io.BytesIO()
    img.save(buffer, format='PNG')
    img_data = buffer.getvalue()
    
    print("✅ 创建测试绘画完成")
    
    # 分析绘画
    print("\n📊 分析绘画...")
    analysis = mentor_service.analyze_drawing(img_data)
    
    print(f"   复杂度评分: {analysis.complexity_score:.2f}")
    print(f"   色彩和谐度: {analysis.color_harmony:.2f}")
    print(f"   构图平衡度: {analysis.composition_balance:.2f}")
    print(f"   笔触自信度: {analysis.stroke_confidence:.2f}")
    print(f"   风格一致性: {analysis.style_consistency:.2f}")
    print(f"   主要颜色: {analysis.dominant_colors}")
    print(f"   识别物体: {analysis.detected_objects}")
    print(f"   艺术风格: {analysis.artistic_style}")
    
    # 生成导师建议
    print("\n💡 生成导师建议...")
    advices = mentor_service.generate_mentor_advice(analysis, "beginner")
    
    for i, advice in enumerate(advices, 1):
        print(f"\n   建议 {i}: {advice.title}")
        print(f"   类型: {advice.advice_type.value}")
        print(f"   内容: {advice.content}")
        print(f"   可信度: {advice.confidence:.2f}")
        print(f"   优先级: {advice.priority}")
        if advice.visual_example:
            print(f"   示例: {advice.visual_example}")
    
    print("✅ AI导师服务测试完成")
    return True


def test_api_endpoints():
    """测试API端点"""
    print("\n🌐 测试API端点...")
    
    import requests
    
    # 测试健康检查
    try:
        response = requests.get("http://localhost:5000/api/health", timeout=5)
        if response.status_code == 200:
            print("✅ 健康检查端点正常")
        else:
            print(f"❌ 健康检查失败: {response.status_code}")
    except requests.exceptions.RequestException as e:
        print(f"❌ 无法连接到API服务器: {e}")
        print("   请确保后端服务器正在运行 (python backend/app.py)")
        return False
    
    # 测试AI导师分析端点
    try:
        # 创建测试数据
        sketch_base64 = create_test_sketch()
        
        payload = {
            "image_data": sketch_base64,
            "user_skill_level": "beginner"
        }
        
        response = requests.post(
            "http://localhost:5000/api/ai-mentor/analyze",
            json=payload,
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                print("✅ AI导师分析端点正常")
                print(f"   分析结果: {len(result.get('advices', []))} 条建议")
            else:
                print(f"❌ AI导师分析失败: {result.get('error_message')}")
        else:
            print(f"❌ AI导师分析端点错误: {response.status_code}")
            print(f"   响应: {response.text}")
    except requests.exceptions.RequestException as e:
        print(f"❌ AI导师分析请求失败: {e}")
    
    return True


def main():
    """主测试函数"""
    print("🚀 华图儿AI服务集成测试")
    print("=" * 50)
    
    # 检查环境变量
    api_key = os.getenv('DASHSCOPE_API_KEY')
    if not api_key or api_key.startswith('your_'):
        print("⚠️  警告: 未配置DASHSCOPE_API_KEY环境变量")
        print("   将使用模拟AI服务进行测试")
    else:
        print(f"✅ 已配置API密钥: {api_key[:20]}...")
    
    print()
    
    # 运行测试
    tests = [
        ("AI服务基础功能", test_ai_service),
        ("AI导师服务", test_ai_mentor_service),
        ("API端点", test_api_endpoints)
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n{'='*20} {test_name} {'='*20}")
        try:
            if test_func():
                passed += 1
                print(f"✅ {test_name} 测试通过")
            else:
                print(f"❌ {test_name} 测试失败")
        except Exception as e:
            print(f"❌ {test_name} 测试异常: {e}")
            import traceback
            traceback.print_exc()
    
    # 输出测试结果
    print("\n" + "="*50)
    print(f"🎯 测试完成: {passed}/{total} 通过")
    
    if passed == total:
        print("🎉 所有测试通过! AI服务集成成功!")
        return True
    else:
        print("⚠️  部分测试失败，请检查配置和服务状态")
        return False


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
