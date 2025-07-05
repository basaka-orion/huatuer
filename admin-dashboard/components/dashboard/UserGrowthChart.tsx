'use client'

import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'

const data = [
  { month: '1月', users: 120 },
  { month: '2月', users: 180 },
  { month: '3月', users: 250 },
  { month: '4月', users: 320 },
  { month: '5月', users: 450 },
  { month: '6月', users: 580 },
  { month: '7月', users: 720 },
]

export default function UserGrowthChart() {
  return (
    <div className="h-64">
      <ResponsiveContainer width="100%" height="100%">
        <AreaChart data={data}>
          <defs>
            <linearGradient id="userGradient" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%" stopColor="#4c9aff" stopOpacity={0.8}/>
              <stop offset="95%" stopColor="#4c9aff" stopOpacity={0.1}/>
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.1)" />
          <XAxis 
            dataKey="month" 
            stroke="rgba(255,255,255,0.6)"
            fontSize={12}
          />
          <YAxis 
            stroke="rgba(255,255,255,0.6)"
            fontSize={12}
          />
          <Tooltip
            contentStyle={{
              backgroundColor: 'rgba(0,0,0,0.8)',
              border: '1px solid rgba(255,255,255,0.2)',
              borderRadius: '8px',
              color: 'white'
            }}
          />
          <Area
            type="monotone"
            dataKey="users"
            stroke="#4c9aff"
            strokeWidth={3}
            fillOpacity={1}
            fill="url(#userGradient)"
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  )
}
