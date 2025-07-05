'use client'

import { useState, useEffect } from 'react'
import { Users, Palette, Video, TrendingUp, Activity, Star } from 'lucide-react'
import UserGrowthChart from '../components/dashboard/UserGrowthChart'
import RecentActivity from '../components/dashboard/RecentActivity'

interface DashboardStats {
  totalUsers: number
  totalCreations: number
  totalVideos: number
  activeUsers: number
}

export default function Dashboard() {
  const [stats, setStats] = useState<DashboardStats>({
    totalUsers: 0,
    totalCreations: 0,
    totalVideos: 0,
    activeUsers: 0
  })

  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    // 模拟数据加载
    setTimeout(() => {
      setStats({
        totalUsers: 1248,
        totalCreations: 3567,
        totalVideos: 892,
        activeUsers: 234
      })
      setIsLoading(false)
    }, 1000)
  }, [])

  const StatCard = ({ icon: Icon, title, value, change, color }: {
    icon: any
    title: string
    value: number
    change: string
    color: string
  }) => (
    <div className="glass-card p-6 rounded-2xl backdrop-blur-md bg-white/10 border border-white/20">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-white/70 text-sm font-medium">{title}</p>
          <p className="text-2xl font-bold text-white mt-1">
            {isLoading ? '...' : value.toLocaleString()}
          </p>
          <p className={`text-sm mt-1 ${color}`}>{change}</p>
        </div>
        <div className={`p-3 rounded-xl ${color.includes('green') ? 'bg-green-500/20' : 'bg-blue-500/20'}`}>
          <Icon className="w-6 h-6 text-white" />
        </div>
      </div>
    </div>
  )

  return (
    <div className="min-h-screen p-6">
      <div className="max-w-7xl mx-auto">
        {/* 头部 */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-white mb-2">华图儿管理后台</h1>
          <p className="text-white/70">AI创意绘画应用数据概览</p>
        </div>

        {/* 统计卡片 */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <StatCard
            icon={Users}
            title="总用户数"
            value={stats.totalUsers}
            change="+12.5% 本月"
            color="text-green-400"
          />
          <StatCard
            icon={Palette}
            title="创作总数"
            value={stats.totalCreations}
            change="+8.2% 本月"
            color="text-blue-400"
          />
          <StatCard
            icon={Video}
            title="视频总数"
            value={stats.totalVideos}
            change="+15.3% 本月"
            color="text-purple-400"
          />
          <StatCard
            icon={Activity}
            title="活跃用户"
            value={stats.activeUsers}
            change="+5.7% 今日"
            color="text-yellow-400"
          />
        </div>

        {/* 图表区域 */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
          <div className="glass-card p-6 rounded-2xl backdrop-blur-md bg-white/10 border border-white/20">
            <h3 className="text-xl font-semibold text-white mb-4 flex items-center">
              <TrendingUp className="w-5 h-5 mr-2" />
              用户增长趋势
            </h3>
            <UserGrowthChart />
          </div>

          <div className="glass-card p-6 rounded-2xl backdrop-blur-md bg-white/10 border border-white/20">
            <h3 className="text-xl font-semibold text-white mb-4 flex items-center">
              <Star className="w-5 h-5 mr-2" />
              最近活动
            </h3>
            <RecentActivity />
          </div>
        </div>

        {/* 快速操作 */}
        <div className="glass-card p-6 rounded-2xl backdrop-blur-md bg-white/10 border border-white/20">
          <h3 className="text-xl font-semibold text-white mb-4">快速操作</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <button className="p-4 rounded-xl bg-gradient-to-r from-blue-500/20 to-purple-500/20 border border-white/20 text-white hover:from-blue-500/30 hover:to-purple-500/30 transition-all duration-200">
              <Users className="w-6 h-6 mb-2" />
              <div className="text-sm font-medium">用户管理</div>
            </button>
            <button className="p-4 rounded-xl bg-gradient-to-r from-green-500/20 to-blue-500/20 border border-white/20 text-white hover:from-green-500/30 hover:to-blue-500/30 transition-all duration-200">
              <Palette className="w-6 h-6 mb-2" />
              <div className="text-sm font-medium">创作管理</div>
            </button>
            <button className="p-4 rounded-xl bg-gradient-to-r from-purple-500/20 to-pink-500/20 border border-white/20 text-white hover:from-purple-500/30 hover:to-pink-500/30 transition-all duration-200">
              <Video className="w-6 h-6 mb-2" />
              <div className="text-sm font-medium">视频管理</div>
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
