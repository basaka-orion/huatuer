"""
华图儿AI创意绘画应用 - AI艺术导师服务
提供智能绘画分析和个性化指导建议
"""

import json
import base64
import requests
from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from enum import Enum
import cv2
import numpy as np
from PIL import Image
import io


class AdviceType(Enum):
    """建议类型枚举"""
    COMPOSITION = "composition"      # 构图建议
    COLOR = "color"                 # 色彩建议
    TECHNIQUE = "technique"         # 技法建议
    STYLE = "style"                # 风格建议
    IMPROVEMENT = "improvement"     # 改进建议


class SkillLevel(Enum):
    """技能水平枚举"""
    BEGINNER = "beginner"           # 初学者
    INTERMEDIATE = "intermediate"   # 中级
    ADVANCED = "advanced"          # 高级


@dataclass
class DrawingAnalysis:
    """绘画分析结果"""
    complexity_score: float        # 复杂度评分 (0-1)
    color_harmony: float           # 色彩和谐度 (0-1)
    composition_balance: float     # 构图平衡度 (0-1)
    stroke_confidence: float       # 笔触自信度 (0-1)
    style_consistency: float       # 风格一致性 (0-1)
    dominant_colors: List[str]     # 主要颜色
    detected_objects: List[str]    # 识别的物体
    artistic_style: str            # 艺术风格


@dataclass
class MentorAdvice:
    """导师建议"""
    advice_type: AdviceType
    title: str
    content: str
    confidence: float              # 建议可信度 (0-1)
    priority: int                  # 优先级 (1-5)
    visual_example: Optional[str]  # 视觉示例URL


class AIArtMentorService:
    """AI艺术导师服务"""
    
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://dashscope.aliyuncs.com/api/v1"
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
    
    def analyze_drawing(self, image_data: bytes, drawing_history: List[Dict] = None) -> DrawingAnalysis:
        """
        分析绘画作品
        
        Args:
            image_data: 图片二进制数据
            drawing_history: 绘画历史记录
        
        Returns:
            DrawingAnalysis: 分析结果
        """
        try:
            # 转换图片为PIL Image
            image = Image.open(io.BytesIO(image_data))
            
            # 基础图像分析
            complexity_score = self._analyze_complexity(image)
            color_harmony = self._analyze_color_harmony(image)
            composition_balance = self._analyze_composition(image)
            stroke_confidence = self._analyze_stroke_confidence(image, drawing_history)
            style_consistency = self._analyze_style_consistency(image)
            dominant_colors = self._extract_dominant_colors(image)
            detected_objects = self._detect_objects(image)
            artistic_style = self._classify_artistic_style(image)
            
            return DrawingAnalysis(
                complexity_score=complexity_score,
                color_harmony=color_harmony,
                composition_balance=composition_balance,
                stroke_confidence=stroke_confidence,
                style_consistency=style_consistency,
                dominant_colors=dominant_colors,
                detected_objects=detected_objects,
                artistic_style=artistic_style
            )
            
        except Exception as e:
            # 返回默认分析结果
            return DrawingAnalysis(
                complexity_score=0.5,
                color_harmony=0.6,
                composition_balance=0.5,
                stroke_confidence=0.6,
                style_consistency=0.5,
                dominant_colors=["#000000", "#FFFFFF"],
                detected_objects=["未知物体"],
                artistic_style="混合风格"
            )
    
    def generate_mentor_advice(self, analysis: DrawingAnalysis, skill_level: str = "beginner") -> List[MentorAdvice]:
        """
        生成导师建议
        
        Args:
            analysis: 绘画分析结果
            skill_level: 用户技能水平
        
        Returns:
            List[MentorAdvice]: 建议列表
        """
        advices = []
        
        # 根据分析结果生成建议
        if analysis.composition_balance < 0.6:
            advices.append(MentorAdvice(
                advice_type=AdviceType.COMPOSITION,
                title="构图平衡改进",
                content="你的作品构图略显不平衡。建议尝试使用三分法则，将主要元素放在画面的三分之一处，这样能让画面更加和谐。",
                confidence=0.8,
                priority=2,
                visual_example="/static/examples/composition_balance.jpg"
            ))
        
        if analysis.color_harmony < 0.5:
            advices.append(MentorAdvice(
                advice_type=AdviceType.COLOR,
                title="色彩搭配优化",
                content="色彩搭配可以更加和谐。建议使用相近色或互补色来创造更好的视觉效果。可以尝试限制色彩数量，专注于2-3种主要颜色。",
                confidence=0.9,
                priority=1,
                visual_example="/static/examples/color_harmony.jpg"
            ))
        
        if analysis.stroke_confidence < 0.6:
            advices.append(MentorAdvice(
                advice_type=AdviceType.TECHNIQUE,
                title="笔触技法提升",
                content="笔触可以更加自信和流畅。建议多练习长线条的绘制，不要害怕犯错。大胆的笔触往往能创造出更有表现力的作品。",
                confidence=0.7,
                priority=3,
                visual_example="/static/examples/confident_strokes.jpg"
            ))
        
        if analysis.complexity_score > 0.8 and skill_level == "beginner":
            advices.append(MentorAdvice(
                advice_type=AdviceType.IMPROVEMENT,
                title="简化表达",
                content="作为初学者，建议先从简单的形状和构图开始。复杂的细节可以在掌握基础后再添加。专注于整体效果比细节更重要。",
                confidence=0.8,
                priority=2,
                visual_example="/static/examples/simplification.jpg"
            ))
        
        # 根据艺术风格给出建议
        if analysis.artistic_style == "anime":
            advices.append(MentorAdvice(
                advice_type=AdviceType.STYLE,
                title="动漫风格强化",
                content="你的作品展现了动漫风格的特点。建议加强线条的清晰度和色彩的饱和度，这是动漫风格的核心特征。",
                confidence=0.7,
                priority=4,
                visual_example="/static/examples/anime_style.jpg"
            ))
        
        # 如果没有生成任何建议，添加通用鼓励
        if not advices:
            advices.append(MentorAdvice(
                advice_type=AdviceType.IMPROVEMENT,
                title="继续创作",
                content="你的作品很棒！继续保持创作热情，多尝试不同的风格和技法。每一次创作都是进步的机会。",
                confidence=0.9,
                priority=5,
                visual_example=None
            ))
        
        # 按优先级排序
        advices.sort(key=lambda x: x.priority)
        
        return advices[:5]  # 最多返回5个建议
    
    def _analyze_complexity(self, image: Image.Image) -> float:
        """分析图像复杂度"""
        # 转换为灰度图
        gray = image.convert('L')
        gray_array = np.array(gray)
        
        # 计算边缘密度
        edges = cv2.Canny(gray_array, 50, 150)
        edge_density = np.sum(edges > 0) / edges.size
        
        return min(edge_density * 10, 1.0)  # 归一化到0-1
    
    def _analyze_color_harmony(self, image: Image.Image) -> float:
        """分析色彩和谐度"""
        # 获取主要颜色
        colors = self._extract_dominant_colors(image, num_colors=5)
        
        if len(colors) <= 2:
            return 0.8  # 单色或双色通常比较和谐
        
        # 简单的色彩和谐度计算
        # 这里可以实现更复杂的色彩理论算法
        return 0.6  # 默认中等和谐度
    
    def _analyze_composition(self, image: Image.Image) -> float:
        """分析构图平衡度"""
        # 转换为灰度图
        gray = np.array(image.convert('L'))
        
        # 计算重心
        h, w = gray.shape
        y_indices, x_indices = np.indices((h, w))
        
        total_weight = np.sum(gray)
        if total_weight == 0:
            return 0.5
        
        center_x = np.sum(x_indices * gray) / total_weight
        center_y = np.sum(y_indices * gray) / total_weight
        
        # 计算偏离中心的程度
        deviation_x = abs(center_x - w/2) / (w/2)
        deviation_y = abs(center_y - h/2) / (h/2)
        
        # 轻微偏离中心通常更好看（三分法则）
        optimal_deviation = 0.33
        balance_score = 1 - abs(deviation_x - optimal_deviation) - abs(deviation_y - optimal_deviation)
        
        return max(0, min(1, balance_score))
    
    def _analyze_stroke_confidence(self, image: Image.Image, drawing_history: List[Dict] = None) -> float:
        """分析笔触自信度"""
        if drawing_history:
            # 如果有绘画历史，分析笔触速度和长度
            total_strokes = len(drawing_history)
            if total_strokes == 0:
                return 0.5
            
            # 简化的自信度计算
            return min(0.5 + total_strokes * 0.1, 1.0)
        
        # 基于图像的笔触分析
        gray = np.array(image.convert('L'))
        edges = cv2.Canny(gray, 50, 150)
        
        # 计算连续线条的长度
        contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        
        if not contours:
            return 0.3
        
        avg_contour_length = np.mean([cv2.arcLength(contour, False) for contour in contours])
        confidence = min(avg_contour_length / 100, 1.0)  # 归一化
        
        return confidence
    
    def _analyze_style_consistency(self, image: Image.Image) -> float:
        """分析风格一致性"""
        # 简化的风格一致性分析
        # 实际实现可以使用深度学习模型
        return 0.7  # 默认较高的一致性
    
    def _extract_dominant_colors(self, image: Image.Image, num_colors: int = 5) -> List[str]:
        """提取主要颜色"""
        # 缩小图像以提高处理速度
        image = image.resize((150, 150))
        
        # 转换为RGB数组
        rgb_array = np.array(image.convert('RGB'))
        pixels = rgb_array.reshape(-1, 3)
        
        # 使用K-means聚类找到主要颜色
        from sklearn.cluster import KMeans
        
        kmeans = KMeans(n_clusters=min(num_colors, len(np.unique(pixels, axis=0))), random_state=42)
        kmeans.fit(pixels)
        
        # 转换为十六进制颜色
        colors = []
        for color in kmeans.cluster_centers_:
            hex_color = "#{:02x}{:02x}{:02x}".format(int(color[0]), int(color[1]), int(color[2]))
            colors.append(hex_color)
        
        return colors
    
    def _detect_objects(self, image: Image.Image) -> List[str]:
        """检测图像中的物体"""
        # 简化的物体检测
        # 实际实现可以使用YOLO或其他目标检测模型
        return ["绘画元素", "艺术作品"]
    
    def _classify_artistic_style(self, image: Image.Image) -> str:
        """分类艺术风格"""
        # 简化的风格分类
        # 实际实现可以使用训练好的风格分类模型
        
        # 基于色彩饱和度和对比度的简单分类
        rgb_array = np.array(image.convert('RGB'))
        
        # 计算饱和度
        hsv_array = np.array(image.convert('HSV'))
        avg_saturation = np.mean(hsv_array[:, :, 1])
        
        # 计算对比度
        gray = np.array(image.convert('L'))
        contrast = np.std(gray)
        
        if avg_saturation > 150 and contrast > 50:
            return "anime"
        elif avg_saturation < 100:
            return "sketch"
        elif contrast > 80:
            return "realistic"
        else:
            return "artistic"


# 导出主要类
__all__ = [
    'AIArtMentorService',
    'DrawingAnalysis',
    'MentorAdvice',
    'AdviceType',
    'SkillLevel'
]
