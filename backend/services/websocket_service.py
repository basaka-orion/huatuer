"""
华图儿AI创意绘画应用 - WebSocket服务
提供实时协作功能支持
"""

import json
import asyncio
import logging
from typing import Dict, Set, Optional, Any
from datetime import datetime
import websockets
from websockets.server import WebSocketServerProtocol
from dataclasses import dataclass, asdict


@dataclass
class CollaborationRoom:
    """协作房间"""
    code: str
    name: str
    host_id: str
    participants: Set[str]
    created_at: datetime
    max_participants: int = 8
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            'code': self.code,
            'name': self.name,
            'host_id': self.host_id,
            'participants': list(self.participants),
            'created_at': self.created_at.isoformat(),
            'max_participants': self.max_participants,
            'participant_count': len(self.participants)
        }


@dataclass
class WebSocketMessage:
    """WebSocket消息"""
    type: str
    data: Dict[str, Any]
    sender_id: str
    timestamp: datetime
    room_code: Optional[str] = None
    
    def to_json(self) -> str:
        return json.dumps({
            'type': self.type,
            'data': self.data,
            'sender_id': self.sender_id,
            'timestamp': self.timestamp.isoformat(),
            'room_code': self.room_code
        })
    
    @classmethod
    def from_json(cls, json_str: str) -> 'WebSocketMessage':
        data = json.loads(json_str)
        return cls(
            type=data['type'],
            data=data['data'],
            sender_id=data['sender_id'],
            timestamp=datetime.fromisoformat(data['timestamp']),
            room_code=data.get('room_code')
        )


class CollaborationWebSocketService:
    """协作WebSocket服务"""
    
    def __init__(self):
        self.rooms: Dict[str, CollaborationRoom] = {}
        self.connections: Dict[str, WebSocketServerProtocol] = {}  # user_id -> websocket
        self.user_rooms: Dict[str, str] = {}  # user_id -> room_code
        self.logger = logging.getLogger(__name__)
    
    async def handle_connection(self, websocket: WebSocketServerProtocol, path: str):
        """处理WebSocket连接"""
        user_id = None
        room_code = None
        
        try:
            # 从路径中提取房间代码
            if path.startswith('/ws/room/'):
                room_code = path.split('/')[-1]
            
            self.logger.info(f"新的WebSocket连接: {websocket.remote_address}")
            
            async for message in websocket:
                try:
                    ws_message = WebSocketMessage.from_json(message)
                    user_id = ws_message.sender_id
                    
                    # 注册连接
                    if user_id not in self.connections:
                        self.connections[user_id] = websocket
                        self.logger.info(f"用户 {user_id} 已连接")
                    
                    # 处理消息
                    await self.handle_message(ws_message, room_code)
                    
                except json.JSONDecodeError:
                    self.logger.error(f"无效的JSON消息: {message}")
                except Exception as e:
                    self.logger.error(f"处理消息时出错: {e}")
                    
        except websockets.exceptions.ConnectionClosed:
            self.logger.info(f"WebSocket连接已关闭: {websocket.remote_address}")
        except Exception as e:
            self.logger.error(f"WebSocket连接错误: {e}")
        finally:
            # 清理连接
            if user_id:
                await self.handle_user_disconnect(user_id)
    
    async def handle_message(self, message: WebSocketMessage, room_code: str):
        """处理WebSocket消息"""
        message.room_code = room_code
        
        if message.type == 'join':
            await self.handle_join_room(message)
        elif message.type == 'leave':
            await self.handle_leave_room(message)
        elif message.type == 'stroke':
            await self.handle_stroke_message(message)
        elif message.type == 'cursor':
            await self.handle_cursor_message(message)
        elif message.type == 'chat':
            await self.handle_chat_message(message)
        elif message.type == 'sync':
            await self.handle_sync_request(message)
        else:
            self.logger.warning(f"未知消息类型: {message.type}")
    
    async def handle_join_room(self, message: WebSocketMessage):
        """处理加入房间"""
        room_code = message.room_code
        user_id = message.sender_id
        user_data = message.data
        
        # 创建房间（如果不存在）
        if room_code not in self.rooms:
            self.rooms[room_code] = CollaborationRoom(
                code=room_code,
                name=user_data.get('room_name', f'房间 {room_code}'),
                host_id=user_id,
                participants=set(),
                created_at=datetime.now()
            )
            self.logger.info(f"创建新房间: {room_code}")
        
        room = self.rooms[room_code]
        
        # 检查房间是否已满
        if len(room.participants) >= room.max_participants:
            await self.send_error(user_id, "房间已满")
            return
        
        # 添加用户到房间
        room.participants.add(user_id)
        self.user_rooms[user_id] = room_code
        
        # 通知房间内其他用户
        join_notification = WebSocketMessage(
            type='user_joined',
            data={
                'user_id': user_id,
                'user_name': user_data.get('user_name', f'用户{user_id[:8]}'),
                'room_info': room.to_dict()
            },
            sender_id='system',
            timestamp=datetime.now(),
            room_code=room_code
        )
        
        await self.broadcast_to_room(room_code, join_notification, exclude_user=user_id)
        
        # 发送房间同步信息给新用户
        sync_message = WebSocketMessage(
            type='room_sync',
            data={
                'room_info': room.to_dict(),
                'participants': list(room.participants)
            },
            sender_id='system',
            timestamp=datetime.now(),
            room_code=room_code
        )
        
        await self.send_to_user(user_id, sync_message)
        
        self.logger.info(f"用户 {user_id} 加入房间 {room_code}")
    
    async def handle_leave_room(self, message: WebSocketMessage):
        """处理离开房间"""
        user_id = message.sender_id
        room_code = message.room_code
        
        if room_code in self.rooms and user_id in self.rooms[room_code].participants:
            room = self.rooms[room_code]
            room.participants.remove(user_id)
            
            if user_id in self.user_rooms:
                del self.user_rooms[user_id]
            
            # 通知房间内其他用户
            leave_notification = WebSocketMessage(
                type='user_left',
                data={
                    'user_id': user_id,
                    'user_name': message.data.get('user_name', f'用户{user_id[:8]}'),
                    'room_info': room.to_dict()
                },
                sender_id='system',
                timestamp=datetime.now(),
                room_code=room_code
            )
            
            await self.broadcast_to_room(room_code, leave_notification)
            
            # 如果房间为空，删除房间
            if not room.participants:
                del self.rooms[room_code]
                self.logger.info(f"删除空房间: {room_code}")
            
            self.logger.info(f"用户 {user_id} 离开房间 {room_code}")
    
    async def handle_stroke_message(self, message: WebSocketMessage):
        """处理笔画消息"""
        # 转发给房间内其他用户
        await self.broadcast_to_room(
            message.room_code, 
            message, 
            exclude_user=message.sender_id
        )
    
    async def handle_cursor_message(self, message: WebSocketMessage):
        """处理光标消息"""
        # 转发给房间内其他用户
        await self.broadcast_to_room(
            message.room_code, 
            message, 
            exclude_user=message.sender_id
        )
    
    async def handle_chat_message(self, message: WebSocketMessage):
        """处理聊天消息"""
        # 转发给房间内所有用户（包括发送者）
        await self.broadcast_to_room(message.room_code, message)
    
    async def handle_sync_request(self, message: WebSocketMessage):
        """处理同步请求"""
        room_code = message.room_code
        user_id = message.sender_id
        
        if room_code in self.rooms:
            room = self.rooms[room_code]
            
            sync_response = WebSocketMessage(
                type='sync_response',
                data={
                    'room_info': room.to_dict(),
                    'participants': list(room.participants)
                },
                sender_id='system',
                timestamp=datetime.now(),
                room_code=room_code
            )
            
            await self.send_to_user(user_id, sync_response)
    
    async def handle_user_disconnect(self, user_id: str):
        """处理用户断开连接"""
        if user_id in self.connections:
            del self.connections[user_id]
        
        if user_id in self.user_rooms:
            room_code = self.user_rooms[user_id]
            
            # 创建离开消息
            leave_message = WebSocketMessage(
                type='leave',
                data={'user_name': f'用户{user_id[:8]}'},
                sender_id=user_id,
                timestamp=datetime.now(),
                room_code=room_code
            )
            
            await self.handle_leave_room(leave_message)
        
        self.logger.info(f"用户 {user_id} 已断开连接")
    
    async def broadcast_to_room(self, room_code: str, message: WebSocketMessage, exclude_user: str = None):
        """向房间内所有用户广播消息"""
        if room_code not in self.rooms:
            return
        
        room = self.rooms[room_code]
        
        for user_id in room.participants:
            if exclude_user and user_id == exclude_user:
                continue
            
            await self.send_to_user(user_id, message)
    
    async def send_to_user(self, user_id: str, message: WebSocketMessage):
        """发送消息给特定用户"""
        if user_id in self.connections:
            try:
                websocket = self.connections[user_id]
                await websocket.send(message.to_json())
            except websockets.exceptions.ConnectionClosed:
                # 连接已关闭，清理
                await self.handle_user_disconnect(user_id)
            except Exception as e:
                self.logger.error(f"发送消息给用户 {user_id} 时出错: {e}")
    
    async def send_error(self, user_id: str, error_message: str):
        """发送错误消息"""
        error_msg = WebSocketMessage(
            type='error',
            data={'message': error_message},
            sender_id='system',
            timestamp=datetime.now()
        )
        
        await self.send_to_user(user_id, error_msg)
    
    def get_room_info(self, room_code: str) -> Optional[Dict[str, Any]]:
        """获取房间信息"""
        if room_code in self.rooms:
            return self.rooms[room_code].to_dict()
        return None
    
    def get_active_rooms(self) -> Dict[str, Dict[str, Any]]:
        """获取所有活跃房间"""
        return {code: room.to_dict() for code, room in self.rooms.items()}


# 全局WebSocket服务实例
websocket_service = CollaborationWebSocketService()


async def start_websocket_server(host: str = "localhost", port: int = 8080):
    """启动WebSocket服务器"""
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)
    
    logger.info(f"启动WebSocket服务器: ws://{host}:{port}")
    
    async with websockets.serve(
        websocket_service.handle_connection,
        host,
        port,
        ping_interval=20,
        ping_timeout=10
    ):
        logger.info("WebSocket服务器已启动")
        await asyncio.Future()  # 保持服务器运行


if __name__ == "__main__":
    # 直接运行WebSocket服务器
    asyncio.run(start_websocket_server())


# 导出主要类和函数
__all__ = [
    'CollaborationWebSocketService',
    'WebSocketMessage',
    'CollaborationRoom',
    'websocket_service',
    'start_websocket_server'
]
