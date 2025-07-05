//
//  DrawingView.swift
//  华图儿AI创意绘画应用
//
//  Created by ooo on 2025/7/5.
//

import SwiftUI
import PencilKit
import Speech

struct DrawingView: View {
    @State private var canvasView = PKCanvasView()
    @State private var isDrawingToolsVisible = false
    @State private var isVoiceRecording = false
    @State private var voiceDescription = ""
    @State private var selectedStyle = "anime"
    @State private var showCompletionDialog = false
    @State private var showGenerationProgress = false
    @State private var generationProgress = 0.0
    @State private var currentStep = "准备中..."
    @State private var showARPreview = false
    @State private var showAIMentor = false
    @State private var showStyleLearner = false
    @State private var showCollaborativeCanvas = false
    @State private var showStyleTransfer = false
    @State private var showMusicDrawing = false
    @State private var showAIAssistant = false
    @State private var showGlobalCommunity = false
    @State private var showThreeDCreation = false
    @State private var showEmotionDrawing = false
    
    // 语音识别
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    
    let styles = ["anime", "realistic", "cartoon", "watercolor", "oil_painting"]
    let styleNames = ["动漫", "写实", "卡通", "水彩", "油画"]
    
    var body: some View {
        ZStack {
            // 主画板
            DrawingCanvas(canvasView: $canvasView)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .white.opacity(0.1), radius: 10)
                )
                .padding()
            
            VStack {
                Spacer()
                
                // 底部工具栏
                VStack(spacing: 16) {
                    // 第一行：新增AI功能
                    HStack {
                        Spacer()

                        // 风格迁移按钮
                        Button(action: {
                            showStyleTransfer = true
                        }) {
                            VStack(spacing: 4) {
                                Text("🎨")
                                    .font(.title2)
                                Text("风格迁移")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 70, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .white.opacity(0.2), radius: 8)
                            )
                        }

                        Spacer()

                        // 音乐绘画按钮
                        Button(action: {
                            showMusicDrawing = true
                        }) {
                            VStack(spacing: 4) {
                                Text("🎵")
                                    .font(.title2)
                                Text("音乐绘画")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 70, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .white.opacity(0.2), radius: 8)
                            )
                        }

                        Spacer()

                        // AI助手按钮
                        Button(action: {
                            showAIAssistant = true
                        }) {
                            VStack(spacing: 4) {
                                Text("🤖")
                                    .font(.title2)
                                Text("AI助手")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 70, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .white.opacity(0.2), radius: 8)
                            )
                        }

                        Spacer()
                    }

                    // 第二行：更多AI功能
                    HStack {
                        Spacer()

                        // 全球社区按钮
                        Button(action: {
                            showGlobalCommunity = true
                        }) {
                            VStack(spacing: 4) {
                                Text("🌍")
                                    .font(.title2)
                                Text("全球社区")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 70, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .white.opacity(0.2), radius: 8)
                            )
                        }

                        Spacer()

                        // 3D创作按钮
                        Button(action: {
                            showThreeDCreation = true
                        }) {
                            VStack(spacing: 4) {
                                Text("🎬")
                                    .font(.title2)
                                Text("3D创作")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 70, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .white.opacity(0.2), radius: 8)
                            )
                        }

                        Spacer()

                        // 情感绘画按钮
                        Button(action: {
                            showEmotionDrawing = true
                        }) {
                            VStack(spacing: 4) {
                                Text("🧠")
                                    .font(.title2)
                                Text("情感绘画")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 70, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .white.opacity(0.2), radius: 8)
                            )
                        }

                        Spacer()
                    }

                    // 第三行：原有AI功能
                    HStack {
                        Spacer()

                        // AR预览按钮
                        Button(action: {
                            showARPreview = true
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "arkit")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("AR预览")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 70, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .white.opacity(0.2), radius: 8)
                            )
                        }

                        Spacer()

                        // AI导师按钮
                        Button(action: {
                            showAIMentor = true
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "brain.head.profile")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("AI导师")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 70, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .white.opacity(0.2), radius: 8)
                            )
                        }

                        Spacer()

                        // 风格学习器按钮
                        Button(action: {
                            showStyleLearner = true
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "graduationcap.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("风格学习")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 70, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)
                                    .shadow(color: .white.opacity(0.2), radius: 8)
                            )
                        }

                        Spacer()
                    }

                    // 第二行：原有工具
                    HStack {
                        // 左下角 - 画笔工具
                        Button(action: {
                            withAnimation(.spring()) {
                                isDrawingToolsVisible.toggle()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: .white.opacity(0.2), radius: 8)

                                Image(systemName: "paintbrush.pointed.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }

                        Spacer()

                        // 中间 - 语音输入
                        Button(action: {
                            if isVoiceRecording {
                                stopRecording()
                            } else {
                                startRecording()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(isVoiceRecording ?
                                          LinearGradient(colors: [.red, .pink], startPoint: .top, endPoint: .bottom) :
                                          LinearGradient(colors: [.blue, .purple], startPoint: .top, endPoint: .bottom))
                                    .frame(width: 70, height: 70)
                                    .shadow(color: isVoiceRecording ? .red.opacity(0.5) : .blue.opacity(0.3), radius: 10)
                                    .scaleEffect(isVoiceRecording ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isVoiceRecording)

                                Image(systemName: isVoiceRecording ? "mic.fill" : "mic")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }

                        Spacer()

                        // 协作画布按钮
                        Button(action: {
                            showCollaborativeCanvas = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: .white.opacity(0.2), radius: 8)

                                Image(systemName: "person.2.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }

                        Spacer()

                        // 右下角 - 风格选择
                        Menu {
                            ForEach(Array(styles.enumerated()), id: \.offset) { index, style in
                                Button(styleNames[index]) {
                                    selectedStyle = style
                                }
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: .white.opacity(0.2), radius: 8)

                                Image(systemName: "paintpalette.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
            
            // 右上角 - 完成按钮
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showCompletionDialog = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 50, height: 50)
                                .shadow(color: .green.opacity(0.3), radius: 8)
                            
                            Image(systemName: "checkmark")
                                .font(.title3)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.trailing, 30)
                    .padding(.top, 60)
                }
                
                Spacer()
            }
            
            // 绘画工具面板
            if isDrawingToolsVisible {
                VStack {
                    Spacer()
                    
                    HStack {
                        DrawingToolsPanel(canvasView: $canvasView)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        
                        Spacer()
                    }
                    .padding(.bottom, 120)
                }
            }
            
            // 语音描述显示
            if !voiceDescription.isEmpty {
                VStack {
                    HStack {
                        Text("语音描述: \(voiceDescription)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                            .shadow(color: .white.opacity(0.1), radius: 5)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 100)
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showCompletionDialog) {
            CompletionDialog(
                hasVoiceDescription: !voiceDescription.isEmpty,
                onGenerate: startGeneration,
                onRecordVoice: {
                    showCompletionDialog = false
                    startRecording()
                },
                onCancel: { showCompletionDialog = false }
            )
        }
        .sheet(isPresented: $showGenerationProgress) {
            GenerationProgressView(
                progress: $generationProgress,
                currentStep: $currentStep
            )
        }
        .sheet(isPresented: $showARPreview) {
            if let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0) {
                ARPreviewView(artworkImage: image)
            }
        }
        .sheet(isPresented: $showAIMentor) {
            if let image = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0) {
                AIMentorView(artworkImage: image)
            }
        }
        .sheet(isPresented: $showStyleLearner) {
            StyleLearnerView()
        }
        .fullScreenCover(isPresented: $showCollaborativeCanvas) {
            CollaborativeCanvasView()
        }
        .fullScreenCover(isPresented: $showStyleTransfer) {
            StyleTransferView()
        }
        .fullScreenCover(isPresented: $showMusicDrawing) {
            MusicDrivenDrawingView()
        }
        .fullScreenCover(isPresented: $showAIAssistant) {
            AIAssistantView()
        }
        .fullScreenCover(isPresented: $showGlobalCommunity) {
            GlobalCommunityView()
        }
        .fullScreenCover(isPresented: $showThreeDCreation) {
            ThreeDCreationView()
        }
        .fullScreenCover(isPresented: $showEmotionDrawing) {
            EmotionDrivenDrawingView()
        }
    }
    
    private func startRecording() {
        // 实现语音录制逻辑
        isVoiceRecording = true
        // TODO: 集成语音识别
    }
    
    private func stopRecording() {
        isVoiceRecording = false
        // TODO: 停止语音识别并获取结果
        voiceDescription = "示例语音描述：一只可爱的小猫在花园里玩耍"
    }
    
    private func startGeneration() {
        showCompletionDialog = false
        showGenerationProgress = true
        
        // 模拟生成进度
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if generationProgress < 1.0 {
                generationProgress += 0.01
                
                if generationProgress < 0.3 {
                    currentStep = "正在分析草图..."
                } else if generationProgress < 0.6 {
                    currentStep = "正在生成图片..."
                } else if generationProgress < 0.9 {
                    currentStep = "正在制作动画..."
                } else {
                    currentStep = "即将完成..."
                }
            } else {
                timer.invalidate()
                showGenerationProgress = false
                generationProgress = 0.0
            }
        }
    }
}

// 画布组件
struct DrawingCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = UIColor.clear
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}

#Preview {
    DrawingView()
}
