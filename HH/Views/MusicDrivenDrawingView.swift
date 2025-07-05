import SwiftUI
import AVFoundation

// MARK: - 音乐情感类型
enum MusicEmotion: String, CaseIterable {
    case happy = "快乐"
    case sad = "忧伤"
    case energetic = "激昂"
    case peaceful = "宁静"
    case mysterious = "神秘"
    case romantic = "浪漫"
    case dramatic = "戏剧性"
    case dreamy = "梦幻"
    
    var colors: [Color] {
        switch self {
        case .happy: return [.yellow, .orange, .pink]
        case .sad: return [.blue, .indigo, .gray]
        case .energetic: return [.red, .orange, .yellow]
        case .peaceful: return [.green, .mint, .cyan]
        case .mysterious: return [.purple, .black, .indigo]
        case .romantic: return [.pink, .red, .purple]
        case .dramatic: return [.red, .black, .orange]
        case .dreamy: return [.purple, .blue, .pink]
        }
    }
    
    var icon: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .energetic: return "⚡"
        case .peaceful: return "🕊️"
        case .mysterious: return "🌙"
        case .romantic: return "💕"
        case .dramatic: return "🎭"
        case .dreamy: return "✨"
        }
    }
}

// MARK: - 音频分析数据
struct AudioAnalysis {
    let frequency: Float
    let amplitude: Float
    let tempo: Float
    let emotion: MusicEmotion
    let spectralCentroid: Float
    let zeroCrossingRate: Float
}

// MARK: - 音乐驱动绘画视图
struct MusicDrivenDrawingView: View {
    @State private var isRecording = false
    @State private var isPlaying = false
    @State private var audioEngine = AVAudioEngine()
    @State private var audioAnalysis: AudioAnalysis?
    @State private var currentEmotion: MusicEmotion = .peaceful
    @State private var brushSize: CGFloat = 5.0
    @State private var brushOpacity: Double = 1.0
    @State private var autoDrawing = false
    @State private var musicVisualization: [Float] = Array(repeating: 0, count: 64)
    @State private var drawingPath: Path = Path()
    @State private var currentColor: Color = .blue
    
    var body: some View {
        ZStack {
            // 背景渐变随音乐变化
            AnimatedBackground(emotion: currentEmotion)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部控制栏
                topControlBar
                
                // 主绘画区域
                drawingCanvas
                
                // 音乐可视化区域
                musicVisualizationView
                
                // 底部控制面板
                bottomControlPanel
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupAudioEngine()
        }
        .onDisappear {
            stopAudioEngine()
        }
    }
    
    // MARK: - 顶部控制栏
    private var topControlBar: some View {
        HStack {
            Button(action: {
                // 返回主界面
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
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("🎵 音乐驱动绘画")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("让音乐指引你的画笔")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: {
                clearCanvas()
            }) {
                Image(systemName: "trash")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                    )
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    // MARK: - 绘画画布
    private var drawingCanvas: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(height: 400)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(currentColor.opacity(0.5), lineWidth: 2)
                )
            
            // 绘画路径
            drawingPath
                .stroke(
                    currentColor,
                    style: StrokeStyle(
                        lineWidth: brushSize,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .opacity(brushOpacity)
            
            // 音乐驱动的粒子效果
            if isPlaying {
                MusicParticleEffect(
                    audioAnalysis: audioAnalysis,
                    emotion: currentEmotion
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if !autoDrawing {
                        addPointToPath(value.location)
                    }
                }
        )
    }
    
    // MARK: - 音乐可视化
    private var musicVisualizationView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("音乐分析")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(currentEmotion.icon + " " + currentEmotion.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(currentEmotion.colors.first?.opacity(0.3) ?? Color.blue.opacity(0.3))
                    )
            }
            
            // 频谱可视化
            HStack(spacing: 2) {
                ForEach(0..<musicVisualization.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: currentEmotion.colors,
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 4, height: CGFloat(musicVisualization[index]) * 60)
                        .animation(.easeInOut(duration: 0.1), value: musicVisualization[index])
                }
            }
            .frame(height: 60)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
    }
    
    // MARK: - 底部控制面板
    private var bottomControlPanel: some View {
        VStack(spacing: 16) {
            // 录音/播放控制
            HStack(spacing: 20) {
                Button(action: {
                    toggleRecording()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.title)
                            .foregroundColor(isRecording ? .red : .white)
                        
                        Text(isRecording ? "停止录音" : "开始录音")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
                
                Button(action: {
                    togglePlayback()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Text(isPlaying ? "暂停" : "播放")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
                
                Button(action: {
                    autoDrawing.toggle()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: autoDrawing ? "wand.and.stars.inverse" : "wand.and.stars")
                            .font(.title)
                            .foregroundColor(autoDrawing ? .yellow : .white)
                        
                        Text(autoDrawing ? "手动绘画" : "AI绘画")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
            }
            
            // 画笔设置
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("画笔大小: \(Int(brushSize))")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Slider(value: $brushSize, in: 1...20, step: 1)
                        .accentColor(currentColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("透明度: \(Int(brushOpacity * 100))%")
                        .font(.caption)
                        .foregroundColor(.white)
                    
                    Slider(value: $brushOpacity, in: 0.1...1.0, step: 0.1)
                        .accentColor(currentColor)
                        .frame(width: 100)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    // MARK: - 私有方法
    private func setupAudioEngine() {
        // 设置音频引擎和分析
        print("🎵 初始化音频引擎...")
    }
    
    private func stopAudioEngine() {
        audioEngine.stop()
        isRecording = false
        isPlaying = false
    }
    
    private func toggleRecording() {
        isRecording.toggle()
        if isRecording {
            startAudioAnalysis()
        } else {
            stopAudioAnalysis()
        }
    }
    
    private func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startMusicVisualization()
        } else {
            stopMusicVisualization()
        }
    }
    
    private func startAudioAnalysis() {
        // 开始实时音频分析
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if !isRecording {
                timer.invalidate()
                return
            }
            
            // 模拟音频分析数据
            let analysis = AudioAnalysis(
                frequency: Float.random(in: 100...2000),
                amplitude: Float.random(in: 0.1...1.0),
                tempo: Float.random(in: 60...180),
                emotion: MusicEmotion.allCases.randomElement() ?? .peaceful,
                spectralCentroid: Float.random(in: 500...3000),
                zeroCrossingRate: Float.random(in: 0.01...0.5)
            )
            
            updateDrawingFromAudio(analysis)
        }
    }
    
    private func stopAudioAnalysis() {
        // 停止音频分析
    }
    
    private func startMusicVisualization() {
        // 开始音乐可视化
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if !isPlaying {
                timer.invalidate()
                return
            }
            
            // 更新频谱数据
            for i in 0..<musicVisualization.count {
                musicVisualization[i] = Float.random(in: 0...1)
            }
        }
    }
    
    private func stopMusicVisualization() {
        // 停止音乐可视化
        musicVisualization = Array(repeating: 0, count: 64)
    }
    
    private func updateDrawingFromAudio(_ analysis: AudioAnalysis) {
        // 根据音频分析更新绘画参数
        currentEmotion = analysis.emotion
        currentColor = currentEmotion.colors.randomElement() ?? .blue
        brushSize = CGFloat(analysis.amplitude * 15 + 5)
        brushOpacity = Double(analysis.amplitude)
        
        if autoDrawing {
            // AI自动绘画
            generateAutoDrawing(from: analysis)
        }
    }
    
    private func generateAutoDrawing(from analysis: AudioAnalysis) {
        // 基于音频分析生成自动绘画路径
        let centerX = UIScreen.main.bounds.width / 2
        let centerY: CGFloat = 200
        
        let radius = CGFloat(analysis.amplitude * 100)
        let angle = CGFloat(analysis.frequency / 1000 * .pi * 2)
        
        let x = centerX + cos(angle) * radius
        let y = centerY + sin(angle) * radius
        
        addPointToPath(CGPoint(x: x, y: y))
    }
    
    private func addPointToPath(_ point: CGPoint) {
        if drawingPath.isEmpty {
            drawingPath.move(to: point)
        } else {
            drawingPath.addLine(to: point)
        }
    }
    
    private func clearCanvas() {
        drawingPath = Path()
    }
}

// MARK: - 动画背景
struct AnimatedBackground: View {
    let emotion: MusicEmotion
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: emotion.colors.map { $0.opacity(0.3) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 动态粒子效果
            ForEach(0..<20, id: \.self) { _ in
                Circle()
                    .fill(emotion.colors.randomElement()?.opacity(0.1) ?? Color.blue.opacity(0.1))
                    .frame(width: CGFloat.random(in: 20...80))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .offset(y: animationOffset)
                    .animation(
                        .linear(duration: Double.random(in: 3...8))
                        .repeatForever(autoreverses: false),
                        value: animationOffset
                    )
            }
        }
        .onAppear {
            animationOffset = -UIScreen.main.bounds.height
        }
    }
}

// MARK: - 音乐粒子效果
struct MusicParticleEffect: View {
    let audioAnalysis: AudioAnalysis?
    let emotion: MusicEmotion
    
    var body: some View {
        ZStack {
            if let analysis = audioAnalysis {
                ForEach(0..<Int(analysis.amplitude * 10), id: \.self) { _ in
                    Circle()
                        .fill(emotion.colors.randomElement() ?? .blue)
                        .frame(width: CGFloat.random(in: 2...8))
                        .position(
                            x: CGFloat.random(in: 0...400),
                            y: CGFloat.random(in: 0...400)
                        )
                        .opacity(Double(analysis.amplitude))
                        .scaleEffect(CGFloat(analysis.amplitude))
                }
            }
        }
    }
}

#Preview {
    MusicDrivenDrawingView()
        .preferredColorScheme(.dark)
}
