import SwiftUI
import Speech
import AVFoundation

// MARK: - AI助手状态
enum AIAssistantState {
    case idle
    case listening
    case thinking
    case speaking
    case analyzing
}

// MARK: - 绘画建议类型
enum DrawingSuggestion {
    case composition(String)
    case color(String)
    case technique(String)
    case style(String)
    case improvement(String)
    
    var icon: String {
        switch self {
        case .composition: return "rectangle.3.group"
        case .color: return "paintpalette"
        case .technique: return "paintbrush.pointed"
        case .style: return "wand.and.stars"
        case .improvement: return "arrow.up.circle"
        }
    }
    
    var title: String {
        switch self {
        case .composition: return "构图建议"
        case .color: return "色彩搭配"
        case .technique: return "绘画技巧"
        case .style: return "风格指导"
        case .improvement: return "改进建议"
        }
    }
}

// MARK: - AI绘画助手视图
struct AIAssistantView: View {
    @State private var assistantState: AIAssistantState = .idle
    @State private var currentMessage = "你好！我是小华，你的AI绘画助手。有什么可以帮助你的吗？"
    @State private var isVoiceEnabled = true
    @State private var suggestions: [DrawingSuggestion] = []
    @State private var showSuggestions = false
    @State private var userInput = ""
    @State private var conversationHistory: [ChatMessage] = []
    @State private var isAnalyzingDrawing = false
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部控制栏
            topControlBar
            
            // 主要内容区域
            ZStack {
                // 背景
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.1),
                        Color.blue.opacity(0.1),
                        Color.pink.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // AI助手头像和状态
                    assistantAvatar
                    
                    // 对话区域
                    conversationArea
                    
                    // 建议卡片
                    if showSuggestions {
                        suggestionsView
                    }
                    
                    Spacer()
                    
                    // 输入区域
                    inputArea
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupAIAssistant()
            generateInitialSuggestions()
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
                Text("🤖 AI助手小华")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("你的专属绘画导师")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: {
                isVoiceEnabled.toggle()
            }) {
                Image(systemName: isVoiceEnabled ? "speaker.wave.2" : "speaker.slash")
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
    
    // MARK: - AI助手头像
    private var assistantAvatar: some View {
        VStack(spacing: 16) {
            ZStack {
                // 外圈动画
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .blue, .pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(assistantState == .thinking ? 360 : 0))
                    .animation(
                        assistantState == .thinking ?
                        .linear(duration: 2).repeatForever(autoreverses: false) :
                        .default,
                        value: assistantState
                    )
                
                // 内圈背景
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)
                
                // AI头像
                Text("🤖")
                    .font(.system(size: 50))
                    .scaleEffect(assistantState == .speaking ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: assistantState)
            }
            
            // 状态指示器
            HStack(spacing: 8) {
                Circle()
                    .fill(stateColor)
                    .frame(width: 8, height: 8)
                    .scaleEffect(assistantState == .listening ? 1.5 : 1.0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: assistantState)
                
                Text(stateText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    // MARK: - 对话区域
    private var conversationArea: some View {
        VStack(spacing: 16) {
            HStack {
                Text("对话记录")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    showSuggestions.toggle()
                }) {
                    Text(showSuggestions ? "隐藏建议" : "显示建议")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    // 当前消息
                    MessageBubble(
                        message: currentMessage,
                        isFromAI: true,
                        timestamp: Date()
                    )
                    
                    // 历史对话
                    ForEach(conversationHistory.reversed(), id: \.id) { message in
                        MessageBubble(
                            message: message.content,
                            isFromAI: message.isFromAI,
                            timestamp: message.timestamp
                        )
                    }
                }
                .padding(.vertical)
            }
            .frame(height: 200)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    // MARK: - 建议视图
    private var suggestionsView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("AI建议")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    generateNewSuggestions()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(suggestions.indices, id: \.self) { index in
                    SuggestionCard(suggestion: suggestions[index]) {
                        applySuggestion(suggestions[index])
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .transition(.opacity.combined(with: .scale))
    }
    
    // MARK: - 输入区域
    private var inputArea: some View {
        VStack(spacing: 12) {
            // 文本输入
            HStack {
                TextField("输入你的问题...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(.blue)
                        )
                }
                .disabled(userInput.isEmpty)
            }
            
            // 语音和分析按钮
            HStack(spacing: 20) {
                Button(action: {
                    startVoiceInput()
                }) {
                    HStack {
                        Image(systemName: assistantState == .listening ? "mic.fill" : "mic")
                        Text(assistantState == .listening ? "正在听..." : "语音输入")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(assistantState == .listening ? .red : .purple)
                    )
                }
                
                Button(action: {
                    analyzeCurrentDrawing()
                }) {
                    HStack {
                        Image(systemName: isAnalyzingDrawing ? "eye.fill" : "eye")
                        Text(isAnalyzingDrawing ? "分析中..." : "分析画作")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isAnalyzingDrawing ? .orange : .green)
                    )
                }
                .disabled(isAnalyzingDrawing)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - 计算属性
    private var stateColor: Color {
        switch assistantState {
        case .idle: return .green
        case .listening: return .blue
        case .thinking: return .orange
        case .speaking: return .purple
        case .analyzing: return .red
        }
    }
    
    private var stateText: String {
        switch assistantState {
        case .idle: return "待命中"
        case .listening: return "正在聆听"
        case .thinking: return "思考中"
        case .speaking: return "回答中"
        case .analyzing: return "分析中"
        }
    }
    
    // MARK: - 私有方法
    private func setupAIAssistant() {
        print("🤖 初始化AI助手小华...")
        // 设置语音识别和合成
    }
    
    private func generateInitialSuggestions() {
        suggestions = [
            .composition("尝试使用三分法则来构图，让主体更突出"),
            .color("使用互补色搭配，如蓝色和橙色"),
            .technique("用轻柔的笔触表现远景，重笔触表现近景"),
            .style("尝试印象派风格，注重光影变化")
        ]
        showSuggestions = true
    }
    
    private func generateNewSuggestions() {
        let allSuggestions = [
            .composition("使用对角线构图增加动感"),
            .composition("尝试中心构图突出主题"),
            .color("使用暖色调营造温馨氛围"),
            .color("冷色调可以表现宁静感"),
            .technique("用干笔法表现粗糙质感"),
            .technique("湿画法可以创造柔和效果"),
            .style("尝试抽象表现主义"),
            .style("写实风格注重细节刻画"),
            .improvement("增加明暗对比"),
            .improvement("丰富色彩层次")
        ]
        
        suggestions = Array(allSuggestions.shuffled().prefix(4))
    }
    
    private func sendMessage() {
        guard !userInput.isEmpty else { return }
        
        let userMessage = ChatMessage(
            content: userInput,
            isFromAI: false,
            timestamp: Date()
        )
        
        conversationHistory.append(userMessage)
        
        // 清空输入
        let input = userInput
        userInput = ""
        
        // AI处理
        processUserInput(input)
    }
    
    private func processUserInput(_ input: String) {
        assistantState = .thinking
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let response = generateAIResponse(for: input)
            
            let aiMessage = ChatMessage(
                content: response,
                isFromAI: true,
                timestamp: Date()
            )
            
            conversationHistory.append(aiMessage)
            currentMessage = response
            
            assistantState = .speaking
            
            if isVoiceEnabled {
                speakMessage(response)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                assistantState = .idle
            }
        }
    }
    
    private func generateAIResponse(for input: String) -> String {
        // 简单的AI响应生成（实际应该调用AI API）
        let responses = [
            "这是一个很好的问题！让我来帮你分析一下...",
            "根据你的描述，我建议你可以尝试...",
            "从艺术的角度来看，你可以考虑...",
            "这个技巧确实很有用，让我详细解释一下...",
            "我理解你的困惑，让我们一步步来解决..."
        ]
        
        return responses.randomElement() ?? "我正在思考你的问题..."
    }
    
    private func startVoiceInput() {
        if assistantState == .listening {
            stopVoiceInput()
        } else {
            assistantState = .listening
            // 开始语音识别
            print("🎤 开始语音识别...")
        }
    }
    
    private func stopVoiceInput() {
        assistantState = .idle
        // 停止语音识别
        print("🎤 停止语音识别")
    }
    
    private func speakMessage(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = 0.5
        speechSynthesizer.speak(utterance)
    }
    
    private func analyzeCurrentDrawing() {
        isAnalyzingDrawing = true
        assistantState = .analyzing
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let analysis = "我看到你的画作很有创意！建议在色彩搭配上可以更加大胆一些，尝试使用对比色来增强视觉冲击力。"
            
            let aiMessage = ChatMessage(
                content: analysis,
                isFromAI: true,
                timestamp: Date()
            )
            
            conversationHistory.append(aiMessage)
            currentMessage = analysis
            
            isAnalyzingDrawing = false
            assistantState = .speaking
            
            if isVoiceEnabled {
                speakMessage(analysis)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                assistantState = .idle
            }
        }
    }
    
    private func applySuggestion(_ suggestion: DrawingSuggestion) {
        let message: String
        
        switch suggestion {
        case .composition(let advice):
            message = "构图建议：\(advice)"
        case .color(let advice):
            message = "色彩建议：\(advice)"
        case .technique(let advice):
            message = "技巧建议：\(advice)"
        case .style(let advice):
            message = "风格建议：\(advice)"
        case .improvement(let advice):
            message = "改进建议：\(advice)"
        }
        
        currentMessage = message
        
        let aiMessage = ChatMessage(
            content: message,
            isFromAI: true,
            timestamp: Date()
        )
        
        conversationHistory.append(aiMessage)
        
        if isVoiceEnabled {
            speakMessage(message)
        }
    }
}

// MARK: - 聊天消息模型
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isFromAI: Bool
    let timestamp: Date
}

// MARK: - 消息气泡组件
struct MessageBubble: View {
    let message: String
    let isFromAI: Bool
    let timestamp: Date
    
    var body: some View {
        HStack {
            if !isFromAI {
                Spacer()
            }
            
            VStack(alignment: isFromAI ? .leading : .trailing, spacing: 4) {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(isFromAI ? .white : .black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isFromAI ? .blue : .white)
                    )
                
                Text(timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            if isFromAI {
                Spacer()
            }
        }
    }
}

// MARK: - 建议卡片组件
struct SuggestionCard: View {
    let suggestion: DrawingSuggestion
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: suggestion.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(suggestion.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

#Preview {
    AIAssistantView()
        .preferredColorScheme(.dark)
}
