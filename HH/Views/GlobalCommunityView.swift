import SwiftUI
import Combine

// MARK: - 社区功能类型
enum CommunityFeature: String, CaseIterable {
    case gallery = "作品展示"
    case collaborate = "实时协作"
    case challenges = "创作挑战"
    case ranking = "AI评分榜"
    case live = "直播创作"
    case tutorial = "大师课堂"
    
    var icon: String {
        switch self {
        case .gallery: return "photo.artframe"
        case .collaborate: return "person.2.fill"
        case .challenges: return "trophy.fill"
        case .ranking: return "chart.bar.fill"
        case .live: return "video.fill"
        case .tutorial: return "graduationcap.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .gallery: return .purple
        case .collaborate: return .blue
        case .challenges: return .orange
        case .ranking: return .green
        case .live: return .red
        case .tutorial: return .indigo
        }
    }
    
    var description: String {
        switch self {
        case .gallery: return "分享你的艺术作品，获得全球关注"
        case .collaborate: return "与世界各地的艺术家实时协作创作"
        case .challenges: return "参与每日挑战，提升创作技能"
        case .ranking: return "AI智能评分，展示你的艺术水平"
        case .live: return "观看大师直播，学习创作技巧"
        case .tutorial: return "专业教程，从入门到精通"
        }
    }
}

// MARK: - 用户作品模型
struct ArtworkPost: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let artistAvatar: String
    let image: String
    let likes: Int
    let comments: Int
    let aiScore: Double
    let tags: [String]
    let timestamp: Date
    let isLiked: Bool
    let location: String
}

// MARK: - 挑战赛模型
struct CreativeChallenge: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let theme: String
    let difficulty: String
    let participants: Int
    let timeLeft: String
    let prize: String
    let image: String
    let isParticipating: Bool
}

// MARK: - 全球创作社区视图
struct GlobalCommunityView: View {
    @State private var selectedFeature: CommunityFeature = .gallery
    @State private var searchText = ""
    @State private var showCreatePost = false
    @State private var showJoinChallenge = false
    @State private var selectedChallenge: CreativeChallenge?
    @State private var isOnline = true
    @State private var onlineUsers = 1247
    
    // 模拟数据
    @State private var artworks: [ArtworkPost] = []
    @State private var challenges: [CreativeChallenge] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部状态栏
                topStatusBar
                
                // 功能选择器
                featureSelector
                
                // 主要内容区域
                ZStack {
                    // 背景
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.05),
                            selectedFeature.color.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // 内容视图
                    contentView
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadMockData()
        }
    }
    
    // MARK: - 顶部状态栏
    private var topStatusBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("🌍 全球创作社区")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                        .scaleEffect(isOnline ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isOnline)
                    
                    Text("\(onlineUsers) 位艺术家在线")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    // 搜索功能
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
                
                Button(action: {
                    showCreatePost = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(.blue)
                        )
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.3), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - 功能选择器
    private var featureSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(CommunityFeature.allCases, id: \.self) { feature in
                    FeatureTab(
                        feature: feature,
                        isSelected: selectedFeature == feature
                    ) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedFeature = feature
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - 内容视图
    private var contentView: some View {
        Group {
            switch selectedFeature {
            case .gallery:
                artworkGalleryView
            case .collaborate:
                collaborationView
            case .challenges:
                challengesView
            case .ranking:
                rankingView
            case .live:
                liveStreamView
            case .tutorial:
                tutorialView
            }
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    // MARK: - 作品展示视图
    private var artworkGalleryView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(artworks) { artwork in
                    ArtworkCard(artwork: artwork) {
                        // 点击作品详情
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - 协作视图
    private var collaborationView: some View {
        VStack(spacing: 20) {
            Text("🎨 实时协作画布")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("与全球艺术家一起创作")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Button(action: {
                // 开始协作
            }) {
                HStack {
                    Image(systemName: "person.2.fill")
                    Text("创建协作房间")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - 挑战赛视图
    private var challengesView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(challenges) { challenge in
                    ChallengeCard(challenge: challenge) {
                        selectedChallenge = challenge
                        showJoinChallenge = true
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - 排行榜视图
    private var rankingView: some View {
        VStack(spacing: 20) {
            Text("🏆 AI评分排行榜")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("本周最佳作品")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            // 排行榜列表
            VStack(spacing: 12) {
                ForEach(0..<5) { index in
                    RankingRow(rank: index + 1, score: 95 - index * 3)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - 直播视图
    private var liveStreamView: some View {
        VStack(spacing: 20) {
            Text("📺 大师直播")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("观看世界级艺术家现场创作")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            // 直播列表
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        LiveStreamCard(
                            title: "水彩风景画技法",
                            artist: "张大师",
                            viewers: 1234 + index * 100,
                            isLive: true
                        )
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - 教程视图
    private var tutorialView: some View {
        VStack(spacing: 20) {
            Text("📚 大师课堂")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("从基础到进阶的完整教程")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            // 教程分类
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(["基础绘画", "色彩理论", "构图技巧", "数字艺术"], id: \.self) { category in
                        TutorialCategoryCard(title: category)
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - 私有方法
    private func loadMockData() {
        // 加载模拟作品数据
        artworks = [
            ArtworkPost(
                title: "星空下的小镇",
                artist: "艺术家小明",
                artistAvatar: "👨‍🎨",
                image: "artwork1",
                likes: 234,
                comments: 45,
                aiScore: 9.2,
                tags: ["风景", "夜景", "星空"],
                timestamp: Date(),
                isLiked: false,
                location: "北京"
            ),
            ArtworkPost(
                title: "可爱的小猫",
                artist: "猫咪画家",
                artistAvatar: "👩‍🎨",
                image: "artwork2",
                likes: 567,
                comments: 89,
                aiScore: 8.8,
                tags: ["动物", "可爱", "宠物"],
                timestamp: Date(),
                isLiked: true,
                location: "上海"
            )
        ]
        
        // 加载模拟挑战数据
        challenges = [
            CreativeChallenge(
                title: "春日花朵",
                description: "用你的画笔描绘春天的美丽花朵",
                theme: "自然",
                difficulty: "初级",
                participants: 1234,
                timeLeft: "2天",
                prize: "1000元奖金",
                image: "challenge1",
                isParticipating: false
            ),
            CreativeChallenge(
                title: "未来城市",
                description: "想象并绘制2050年的未来城市",
                theme: "科幻",
                difficulty: "高级",
                participants: 567,
                timeLeft: "5天",
                prize: "专业绘画套装",
                image: "challenge2",
                isParticipating: true
            )
        ]
    }
}

// MARK: - 功能标签组件
struct FeatureTab: View {
    let feature: CommunityFeature
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: feature.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                Text(feature.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? feature.color : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.clear : Color.white.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - 作品卡片组件
struct ArtworkCard: View {
    let artwork: ArtworkPost
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // 作品图片
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 150)
                    .overlay(
                        Text("🎨")
                            .font(.system(size: 40))
                    )
                
                // 作品信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(artwork.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack {
                        Text(artwork.artistAvatar)
                            .font(.caption)
                        
                        Text(artwork.artist)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("⭐ \(artwork.aiScore, specifier: "%.1f")")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    
                    HStack {
                        Label("\(artwork.likes)", systemImage: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Label("\(artwork.comments)", systemImage: "message.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
    }
}

// MARK: - 挑战卡片组件
struct ChallengeCard: View {
    let challenge: CreativeChallenge
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(challenge.title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(challenge.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("🏆")
                            .font(.title)
                        
                        Text(challenge.timeLeft)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                
                HStack {
                    Label("\(challenge.participants) 参与者", systemImage: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(challenge.prize)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                challenge.isParticipating ? Color.orange : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
    }
}

// MARK: - 排行榜行组件
struct RankingRow: View {
    let rank: Int
    let score: Int
    
    var body: some View {
        HStack {
            Text("#\(rank)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(rank <= 3 ? .yellow : .white)
                .frame(width: 40)
            
            Text("👨‍🎨")
                .font(.title2)
            
            VStack(alignment: .leading) {
                Text("艺术家\(rank)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("AI评分: \(score)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            if rank <= 3 {
                Text(rank == 1 ? "🥇" : rank == 2 ? "🥈" : "🥉")
                    .font(.title)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - 直播卡片组件
struct LiveStreamCard: View {
    let title: String
    let artist: String
    let viewers: Int
    let isLive: Bool
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red.opacity(0.3))
                .frame(width: 80, height: 60)
                .overlay(
                    VStack {
                        Text("📺")
                            .font(.title2)
                        
                        if isLive {
                            Text("LIVE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                    }
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(artist)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(viewers) 观看中")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            Button(action: {
                // 观看直播
            }) {
                Text("观看")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.red)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - 教程分类卡片组件
struct TutorialCategoryCard: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text("📚")
                .font(.system(size: 40))
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    GlobalCommunityView()
        .preferredColorScheme(.dark)
}
