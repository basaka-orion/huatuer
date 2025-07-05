-- 华图儿AI创意绘画应用数据库结构
-- 创建时间: 2025-07-05
-- 描述: 完整的数据库表结构，支持用户管理、创作任务、历史记录和分享功能

-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 用户表
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    nickname VARCHAR(100),
    avatar_url TEXT,
    bio TEXT,
    preferences JSONB DEFAULT '{}',
    brush_count INTEGER DEFAULT 5, -- 画笔数量
    total_creations INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE
);

-- 创作任务表
CREATE TABLE creation_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200),
    description TEXT,
    sketch_image_url TEXT, -- 原始草图URL
    voice_description TEXT, -- 语音描述文本
    voice_audio_url TEXT, -- 语音文件URL
    style_preference VARCHAR(50) DEFAULT 'anime', -- 风格偏好
    status VARCHAR(20) DEFAULT 'pending', -- pending, processing, completed, failed
    progress INTEGER DEFAULT 0, -- 进度百分比
    generated_image_url TEXT, -- 生成的图片URL
    generated_video_url TEXT, -- 生成的视频URL
    creation_process_video_url TEXT, -- 创作过程视频URL
    process_duration INTEGER DEFAULT 10, -- 过程视频时长(秒)
    error_message TEXT,
    brush_consumed INTEGER DEFAULT 1, -- 消耗的画笔数量
    is_shared BOOLEAN DEFAULT FALSE,
    share_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- 创作步骤表（用于时间线展示）
CREATE TABLE creation_steps (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID REFERENCES creation_tasks(id) ON DELETE CASCADE,
    step_type VARCHAR(50) NOT NULL, -- sketch, voice_input, ai_generation, video_generation
    step_name VARCHAR(100) NOT NULL,
    step_data JSONB, -- 存储步骤相关数据
    duration_seconds INTEGER,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 分享记录表
CREATE TABLE share_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID REFERENCES creation_tasks(id) ON DELETE CASCADE,
    shared_by UUID REFERENCES users(id) ON DELETE CASCADE,
    share_platform VARCHAR(50), -- wechat, weibo, qq, etc.
    share_url TEXT,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 邀请奖励表
CREATE TABLE invitation_rewards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inviter_id UUID REFERENCES users(id) ON DELETE CASCADE,
    invitee_id UUID REFERENCES users(id) ON DELETE CASCADE,
    reward_brushes INTEGER DEFAULT 5,
    status VARCHAR(20) DEFAULT 'pending', -- pending, completed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- 用户收藏表
CREATE TABLE user_favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    task_id UUID REFERENCES creation_tasks(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, task_id)
);

-- 系统配置表
CREATE TABLE system_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value JSONB NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 插入默认系统配置
INSERT INTO system_configs (config_key, config_value, description) VALUES
('default_brush_count', '5', '新用户默认画笔数量'),
('invitation_reward_brushes', '5', '邀请奖励画笔数量'),
('max_process_duration', '30', '最大创作过程视频时长(秒)'),
('supported_styles', '["anime", "realistic", "cartoon", "watercolor", "oil_painting"]', '支持的绘画风格'),
('ai_generation_timeout', '300', 'AI生成超时时间(秒)');

-- 创建索引
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_creation_tasks_user_id ON creation_tasks(user_id);
CREATE INDEX idx_creation_tasks_status ON creation_tasks(status);
CREATE INDEX idx_creation_tasks_created_at ON creation_tasks(created_at DESC);
CREATE INDEX idx_creation_steps_task_id ON creation_steps(task_id);
CREATE INDEX idx_share_records_task_id ON share_records(task_id);
CREATE INDEX idx_invitation_rewards_inviter ON invitation_rewards(inviter_id);
CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);

-- 创建更新时间触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为需要的表添加更新时间触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_creation_tasks_updated_at BEFORE UPDATE ON creation_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_system_configs_updated_at BEFORE UPDATE ON system_configs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS (Row Level Security) 安全策略
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE creation_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE creation_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE share_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitation_rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

-- 用户只能访问自己的数据
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- 创作任务策略
CREATE POLICY "Users can view own tasks" ON creation_tasks
    FOR SELECT USING (auth.uid() = user_id OR is_shared = true);

CREATE POLICY "Users can create own tasks" ON creation_tasks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tasks" ON creation_tasks
    FOR UPDATE USING (auth.uid() = user_id);

-- 创作步骤策略
CREATE POLICY "Users can view own task steps" ON creation_steps
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM creation_tasks 
            WHERE creation_tasks.id = creation_steps.task_id 
            AND (creation_tasks.user_id = auth.uid() OR creation_tasks.is_shared = true)
        )
    );

-- 分享记录策略
CREATE POLICY "Users can view share records" ON share_records
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM creation_tasks 
            WHERE creation_tasks.id = share_records.task_id 
            AND (creation_tasks.user_id = auth.uid() OR creation_tasks.is_shared = true)
        )
    );

-- 邀请奖励策略
CREATE POLICY "Users can view own invitations" ON invitation_rewards
    FOR SELECT USING (auth.uid() = inviter_id OR auth.uid() = invitee_id);

-- 收藏策略
CREATE POLICY "Users can manage own favorites" ON user_favorites
    FOR ALL USING (auth.uid() = user_id);
