'use client'

import { motion } from 'framer-motion'
import { User, Palette, Heart, Share2, Clock } from 'lucide-react'

interface Activity {
  id: string
  type: 'user_register' | 'creation_complete' | 'share' | 'like'
  user: string
  description: string
  time: string
  avatar?: string
}

const activities: Activity[] = [
  {
    id: '1',
    type: 'creation_complete',
    user: '小明',
    description: '完成了一幅"星空下的小猫"创作',
    time: '2分钟前'
  },
  {
    id: '2',
    type: 'user_register',
    user: '小红',
    description: '注册成为新用户',
    time: '5分钟前'
  },
  {
    id: '3',
    type: 'share',
    user: '小李',
    description: '分享了作品"梦幻花园"',
    time: '8分钟前'
  },
  {
    id: '4',
    type: 'like',
    user: '小王',
    description: '点赞了"可爱小狗"作品',
    time: '12分钟前'
  },
  {
    id: '5',
    type: 'creation_complete',
    user: '小张',
    description: '完成了一幅"未来城市"创作',
    time: '15分钟前'
  }
]

const getActivityIcon = (type: Activity['type']) => {
  switch (type) {
    case 'user_register':
      return { icon: User, color: 'text-green-400 bg-green-400/20' }
    case 'creation_complete':
      return { icon: Palette, color: 'text-cute-purple bg-cute-purple/20' }
    case 'share':
      return { icon: Share2, color: 'text-cute-blue bg-cute-blue/20' }
    case 'like':
      return { icon: Heart, color: 'text-cute-pink bg-cute-pink/20' }
    default:
      return { icon: Clock, color: 'text-white/60 bg-white/10' }
  }
}

export function RecentActivity() {
  return (
    <div className="space-y-4">
      {activities.map((activity, index) => {
        const { icon: Icon, color } = getActivityIcon(activity.type)
        
        return (
          <motion.div
            key={activity.id}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.4, delay: index * 0.1 }}
            className="flex items-center gap-4 p-4 rounded-lg bg-white/5 hover:bg-white/10 transition-colors duration-200"
          >
            {/* 活动图标 */}
            <div className={`w-10 h-10 rounded-full ${color} flex items-center justify-center flex-shrink-0`}>
              <Icon className="w-5 h-5" />
            </div>
            
            {/* 用户头像 */}
            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-cute-blue to-cute-purple flex items-center justify-center text-white text-sm font-semibold flex-shrink-0">
              {activity.user.charAt(0)}
            </div>
            
            {/* 活动内容 */}
            <div className="flex-1 min-w-0">
              <p className="text-white text-sm">
                <span className="font-semibold text-cute-blue">{activity.user}</span>
                {' '}
                <span className="text-white/80">{activity.description}</span>
              </p>
            </div>
            
            {/* 时间 */}
            <div className="text-white/50 text-xs flex-shrink-0">
              {activity.time}
            </div>
          </motion.div>
        )
      })}
      
      {/* 查看更多 */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.4, delay: 0.6 }}
        className="text-center pt-4"
      >
        <button className="text-cute-blue hover:text-cute-purple transition-colors duration-200 text-sm font-medium">
          查看更多活动 →
        </button>
      </motion.div>
    </div>
  )
}
