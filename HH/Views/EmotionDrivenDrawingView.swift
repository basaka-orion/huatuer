import SwiftUI
import AVFoundation

// MARK: - 情感类型
enum EmotionType: String, CaseIterable {
    case happy = "开心"
    case sad = "悲伤"
    case angry = "愤怒"
    case surprised = "惊讶"
    case fearful = "恐惧"
    case disgusted = "厌恶"
    case neutral = "平静"
    case excited = "兴奋"
    case peaceful = "宁静"
    case romantic = "浪漫"
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .angry: return "😠"
        case .surprised: return "😲"
        case .fearful: return "😨"
        case .disgusted: return "🤢"
        case .neutral: return "😐"
        case .excited: return "🤩"
        case .peaceful: return "😌"
        case .romantic: return "😍"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return .yellow
        case .sad: return .blue
        case .angry: return .red
        case .surprised: return .orange
        case .fearful: return .purple
        case .disgusted: return .green
        case .neutral: return .gray
        case .excited: return .pink
        case .peaceful: return .mint
        case .romantic: return .red
        }
    }
    
    var brushStyle: String {
        switch self {
        case .happy: return "轻快跳跃"
        case .sad: return "缓慢流淌"
        case .angry: return "激烈锐利"
        case .surprised: return "突然爆发"
        case .fearful: return "颤抖不安"
        case .disgusted: return "扭曲变形"
        case .neutral: return "平稳均匀"
        case .excited: return "狂野奔放"
        case .peaceful: return "柔和舒缓"
        case .romantic: return "温柔细腻"
        }
    }
}

// MARK: - 情感数据模型
struct EmotionData {
    let type: EmotionType
    let intensity: Float
    let confidence: Float
    let timestamp: Date
}

// MARK: - 绘画建议
struct DrawingSuggestion {
    let emotion: EmotionType
    let colors: [Color]
    let brushSize: Float
    let opacity: Float
    let speed: Float
    let pattern: String
}

// MARK: - 情感识别绘画视图
struct EmotionDrivenDrawingView: View {
    @State private var currentEmotion: EmotionType = .neutral
    @State private var emotionIntensity: Float = 0.5
    @State private var isDetecting = false
    @State private var showCamera = false
    @State private var emotionHistory: [EmotionData] = []
    @State private var autoDrawing = false
    @State private var showEmotionAnalysis = false
    @State private var selectedEmotionMode: EmotionMode = .realtime
    @State private var drawingSuggestion: DrawingSuggestion?
    
    // 相机相关（模拟实现）
    @State private var cameraEnabled = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部控制栏
                topControlBar
                
                // 情感检测区域
                emotionDetectionArea
                
                // 绘画建议面板
                if let suggestion = drawingSuggestion {
                    drawingSuggestionPanel(suggestion)
                }
                
                // 主要绘画区域
                mainDrawingArea
                
                // 底部工具栏
                bottomToolbar
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear {
            setupCamera()
            generateDrawingSuggestion()
        }
    }
    
    // MARK: - 情感模式
    enum EmotionMode: String, CaseIterable {
        case realtime = "实时检测"
        case manual = "手动选择"
        case history = "历史分析"
        
        var icon: String {
            switch self {
            case .realtime: return "camera.fill"
            case .manual: return "hand.point.up.fill"
            case .history: return "chart.line.uptrend.xyaxis"
            }
        }
    }
    
    // MARK: - 顶部控制栏
    private var topControlBar: some View {
        HStack {
            Button(action: {
                // 返回
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("🧠 情感识别绘画")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("AI读懂你的心情，创作独特艺术")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // 情感分析按钮
                Button(action: {
                    showEmotionAnalysis.toggle()
                }) {
                    Image(systemName: "brain.head.profile")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(.purple)
                        )
                }
                
                // 自动绘画开关
                Button(action: {
                    autoDrawing.toggle()
                }) {
                    Image(systemName: autoDrawing ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(autoDrawing ? .red : .green)
                        )
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    // MARK: - 情感检测区域
    private var emotionDetectionArea: some View {
        VStack(spacing: 16) {
            // 模式选择器
            emotionModeSelector
            
            // 当前情感显示
            currentEmotionDisplay
            
            // 情感强度指示器
            emotionIntensityIndicator
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(currentEmotion.color, lineWidth: 2)
                )
        )
        .padding(.horizontal)
    }
    
    // MARK: - 情感模式选择器
    private var emotionModeSelector: some View {
        HStack(spacing: 12) {
            ForEach(EmotionMode.allCases, id: \.self) { mode in
                Button(action: {
                    selectedEmotionMode = mode
                    if mode == .realtime {
                        startEmotionDetection()
                    } else {
                        stopEmotionDetection()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: mode.icon)
                            .font(.caption)
                        
                        Text(mode.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedEmotionMode == mode ? .white : .white.opacity(0.6))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedEmotionMode == mode ? currentEmotion.color : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(
                                        selectedEmotionMode == mode ? Color.clear : Color.white.opacity(0.3),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
            }
        }
    }
    
    // MARK: - 当前情感显示
    private var currentEmotionDisplay: some View {
        HStack(spacing: 20) {
            // 情感图标
            VStack(spacing: 8) {
                Text(currentEmotion.emoji)
                    .font(.system(size: 60))
                    .scaleEffect(isDetecting ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isDetecting)
                
                Text(currentEmotion.rawValue)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // 情感详情
            VStack(alignment: .trailing, spacing: 8) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("强度")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("\(Int(emotionIntensity * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(currentEmotion.color)
                }
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("绘画风格")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(currentEmotion.brushStyle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - 情感强度指示器
    private var emotionIntensityIndicator: some View {
        VStack(spacing: 8) {
            HStack {
                Text("情感强度")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("影响绘画表现")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // 强度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [currentEmotion.color.opacity(0.6), currentEmotion.color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(emotionIntensity), height: 8)
                        .animation(.easeInOut(duration: 0.3), value: emotionIntensity)
                }
            }
            .frame(height: 8)
        }
    }
    
    // MARK: - 绘画建议面板
    private func drawingSuggestionPanel(_ suggestion: DrawingSuggestion) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("🎨 AI绘画建议")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    applyDrawingSuggestion(suggestion)
                }) {
                    Text("应用建议")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(suggestion.emotion.color)
                        )
                }
            }
            
            // 建议详情
            HStack(spacing: 16) {
                // 推荐颜色
                VStack(alignment: .leading, spacing: 4) {
                    Text("推荐色彩")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 4) {
                        ForEach(suggestion.colors.indices, id: \.self) { index in
                            Circle()
                                .fill(suggestion.colors[index])
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                
                Spacer()
                
                // 画笔参数
                VStack(alignment: .trailing, spacing: 4) {
                    Text("画笔设置")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("大小: \(Int(suggestion.brushSize * 100))%")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("透明度: \(Int(suggestion.opacity * 100))%")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(suggestion.emotion.color.opacity(0.5), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
    
    // MARK: - 主要绘画区域
    private var mainDrawingArea: some View {
        VStack {
            // 绘画画布
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.9),
                                currentEmotion.color.opacity(0.1),
                                Color.black.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // 情感可视化效果
                emotionVisualizationEffect
                
                // 绘画提示
                if !autoDrawing {
                    drawingPrompts
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
        }
    }
    
    // MARK: - 情感可视化效果
    private var emotionVisualizationEffect: some View {
        ZStack {
            // 根据情感类型显示不同的视觉效果
            switch currentEmotion {
            case .happy:
                happyVisualization
            case .sad:
                sadVisualization
            case .angry:
                angryVisualization
            case .peaceful:
                peacefulVisualization
            default:
                neutralVisualization
            }
        }
        .opacity(Double(emotionIntensity))
    }
    
    // MARK: - 开心可视化
    private var happyVisualization: some View {
        VStack {
            ForEach(0..<5) { row in
                HStack {
                    ForEach(0..<8) { col in
                        Circle()
                            .fill(Color.yellow.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(isDetecting ? 1.5 : 1.0)
                            .animation(
                                .easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true)
                                .delay(Double(row + col) * 0.1),
                                value: isDetecting
                            )
                    }
                }
            }
        }
    }
    
    // MARK: - 悲伤可视化
    private var sadVisualization: some View {
        VStack(spacing: 20) {
            ForEach(0..<3) { _ in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue.opacity(0.4))
                    .frame(width: 2, height: 60)
                    .offset(y: isDetecting ? 20 : 0)
                    .animation(
                        .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                        value: isDetecting
                    )
            }
        }
    }
    
    // MARK: - 愤怒可视化
    private var angryVisualization: some View {
        ZStack {
            ForEach(0..<6) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.red.opacity(0.5))
                    .frame(width: 40, height: 4)
                    .rotationEffect(.degrees(Double(index) * 30))
                    .scaleEffect(isDetecting ? 1.5 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.3)
                        .repeatForever(autoreverses: true),
                        value: isDetecting
                    )
            }
        }
    }
    
    // MARK: - 宁静可视化
    private var peacefulVisualization: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .stroke(Color.mint.opacity(0.3), lineWidth: 2)
                    .frame(width: CGFloat(50 + index * 30))
                    .scaleEffect(isDetecting ? 1.2 : 1.0)
                    .animation(
                        .easeInOut(duration: 3)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: isDetecting
                    )
            }
        }
    }
    
    // MARK: - 中性可视化
    private var neutralVisualization: some View {
        VStack(spacing: 10) {
            ForEach(0..<5) { _ in
                HStack(spacing: 10) {
                    ForEach(0..<8) { _ in
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
    }
    
    // MARK: - 绘画提示
    private var drawingPrompts: some View {
        VStack(spacing: 12) {
            Text("💡 根据你的\(currentEmotion.rawValue)情感")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("建议使用\(currentEmotion.brushStyle)的笔触")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Button(action: {
                autoDrawing = true
            }) {
                HStack {
                    Image(systemName: "wand.and.rays")
                    Text("让AI帮你绘画")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(currentEmotion.color)
                )
            }
        }
    }
    
    // MARK: - 底部工具栏
    private var bottomToolbar: some View {
        HStack {
            // 情感历史
            Button(action: {
                // 显示情感历史
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("历史")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            }
            
            Spacer()
            
            // 手动选择情感
            if selectedEmotionMode == .manual {
                emotionManualSelector
            }
            
            Spacer()
            
            // 保存作品
            Button(action: {
                // 保存情感绘画作品
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("保存")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.green)
                )
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    // MARK: - 手动情感选择器
    private var emotionManualSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(EmotionType.allCases, id: \.self) { emotion in
                    Button(action: {
                        currentEmotion = emotion
                        generateDrawingSuggestion()
                    }) {
                        VStack(spacing: 2) {
                            Text(emotion.emoji)
                                .font(.title2)
                            
                            Text(emotion.rawValue)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(currentEmotion == emotion ? emotion.color : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            currentEmotion == emotion ? Color.clear : Color.white.opacity(0.3),
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - 私有方法
    private func setupCamera() {
        // 设置相机用于面部表情识别
        // 这里是模拟实现
    }
    
    private func startEmotionDetection() {
        isDetecting = true
        // 开始实时情感检测
        // 模拟情感变化
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            if isDetecting {
                let randomEmotion = EmotionType.allCases.randomElement() ?? .neutral
                let randomIntensity = Float.random(in: 0.3...0.9)
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentEmotion = randomEmotion
                    emotionIntensity = randomIntensity
                }
                
                generateDrawingSuggestion()
                
                // 记录情感历史
                emotionHistory.append(EmotionData(
                    type: randomEmotion,
                    intensity: randomIntensity,
                    confidence: 0.85,
                    timestamp: Date()
                ))
            }
        }
    }
    
    private func stopEmotionDetection() {
        isDetecting = false
    }
    
    private func generateDrawingSuggestion() {
        let colors: [Color]
        let brushSize: Float
        let opacity: Float
        let speed: Float
        let pattern: String
        
        switch currentEmotion {
        case .happy:
            colors = [.yellow, .orange, .pink]
            brushSize = 0.7
            opacity = 0.8
            speed = 1.2
            pattern = "跳跃式点画"
        case .sad:
            colors = [.blue, .indigo, .gray]
            brushSize = 0.3
            opacity = 0.6
            speed = 0.5
            pattern = "垂直流淌"
        case .angry:
            colors = [.red, .orange, .black]
            brushSize = 0.9
            opacity = 0.9
            speed = 1.5
            pattern = "锐利线条"
        case .peaceful:
            colors = [.mint, .green, .blue]
            brushSize = 0.5
            opacity = 0.7
            speed = 0.8
            pattern = "圆形扩散"
        default:
            colors = [.gray, .white, .black]
            brushSize = 0.5
            opacity = 0.7
            speed = 1.0
            pattern = "均匀涂抹"
        }
        
        drawingSuggestion = DrawingSuggestion(
            emotion: currentEmotion,
            colors: colors,
            brushSize: brushSize,
            opacity: opacity,
            speed: speed,
            pattern: pattern
        )
    }
    
    private func applyDrawingSuggestion(_ suggestion: DrawingSuggestion) {
        // 应用AI绘画建议
        withAnimation(.easeInOut(duration: 0.5)) {
            // 这里会应用建议的参数到实际绘画工具
        }
    }
}

#Preview {
    EmotionDrivenDrawingView()
        .preferredColorScheme(.dark)
}
