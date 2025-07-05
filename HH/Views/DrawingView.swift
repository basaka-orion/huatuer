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
