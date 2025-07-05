import SwiftUI
import CoreML
import Vision

// MARK: - 艺术风格定义
enum ArtStyle: String, CaseIterable {
    case vanGogh = "梵高·星夜"
    case picasso = "毕加索·立体主义"
    case monet = "莫奈·印象派"
    case dali = "达利·超现实主义"
    case kandinsky = "康定斯基·抽象派"
    case ukiyoe = "浮世绘·日式"
    case chinese = "中国水墨画"
    case oil = "古典油画"
    
    var icon: String {
        switch self {
        case .vanGogh: return "🌌"
        case .picasso: return "🔷"
        case .monet: return "🌸"
        case .dali: return "🦋"
        case .kandinsky: return "🎨"
        case .ukiyoe: return "🗾"
        case .chinese: return "🖌️"
        case .oil: return "🖼️"
        }
    }
    
    var description: String {
        switch self {
        case .vanGogh: return "后印象派大师，充满动感的笔触和鲜艳色彩"
        case .picasso: return "立体主义创始人，几何形状的抽象表现"
        case .monet: return "印象派代表，光影变化的细腻捕捉"
        case .dali: return "超现实主义，梦幻般的奇异世界"
        case .kandinsky: return "抽象艺术先驱，色彩与形状的音乐"
        case .ukiyoe: return "日本传统艺术，简洁优雅的线条美"
        case .chinese: return "中华传统水墨，意境深远的东方美学"
        case .oil: return "欧洲古典油画，细腻写实的传统技法"
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .vanGogh: return [.blue, .yellow, .orange]
        case .picasso: return [.blue, .gray, .black]
        case .monet: return [.pink, .purple, .blue]
        case .dali: return [.orange, .red, .yellow]
        case .kandinsky: return [.red, .blue, .green]
        case .ukiyoe: return [.red, .black, .white]
        case .chinese: return [.black, .gray, .white]
        case .oil: return [.brown, .gold, .orange]
        }
    }
}

// MARK: - AI风格迁移视图
struct StyleTransferView: View {
    @State private var selectedStyle: ArtStyle = .vanGogh
    @State private var isProcessing = false
    @State private var transferIntensity: Double = 0.8
    @State private var showStylePreview = false
    @State private var realTimeMode = true
    @State private var originalImage: UIImage?
    @State private var styledImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部控制栏
            topControlBar
            
            // 主要内容区域
            ZStack {
                // 背景渐变
                LinearGradient(
                    colors: selectedStyle.gradientColors.map { $0.opacity(0.1) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // 风格选择器
                    styleSelector
                    
                    // 图像预览区域
                    imagePreviewArea
                    
                    // 控制面板
                    controlPanel
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupStyleTransfer()
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
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("AI风格迁移大师")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("实时艺术风格转换")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: {
                showStylePreview.toggle()
            }) {
                Image(systemName: "eye")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
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
    
    // MARK: - 风格选择器
    private var styleSelector: some View {
        VStack(spacing: 16) {
            HStack {
                Text("选择艺术风格")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(selectedStyle.icon)
                    .font(.title)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ArtStyle.allCases, id: \.self) { style in
                        StyleCard(
                            style: style,
                            isSelected: selectedStyle == style
                        ) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                selectedStyle = style
                                applyStyleTransfer()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - 图像预览区域
    private var imagePreviewArea: some View {
        VStack(spacing: 16) {
            HStack {
                Text("实时预览")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("实时模式", isOn: $realTimeMode)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    .scaleEffect(0.8)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.3))
                    .frame(height: 300)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: selectedStyle.gradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                
                if isProcessing {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("AI正在施展魔法...")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                } else if let styledImage = styledImage {
                    Image(uiImage: styledImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .transition(.opacity.combined(with: .scale))
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.artframe")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("开始绘画，AI将实时转换风格")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - 控制面板
    private var controlPanel: some View {
        VStack(spacing: 16) {
            HStack {
                Text("风格强度")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(transferIntensity * 100))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.3))
                    )
            }
            
            Slider(value: $transferIntensity, in: 0.1...1.0, step: 0.1)
                .accentColor(.blue)
                .onChange(of: transferIntensity) { _, _ in
                    if realTimeMode {
                        applyStyleTransfer()
                    }
                }
            
            HStack(spacing: 16) {
                Button(action: {
                    applyStyleTransfer()
                }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("应用风格")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
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
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button(action: {
                    saveStyledImage()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("保存")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.green, .teal],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(styledImage == nil)
                .opacity(styledImage == nil ? 0.6 : 1.0)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - 私有方法
    private func setupStyleTransfer() {
        // 初始化AI风格迁移模型
        print("🎨 初始化AI风格迁移大师...")
    }
    
    private func applyStyleTransfer() {
        guard let originalImage = originalImage else { return }
        
        isProcessing = true
        
        // 模拟AI风格迁移处理
        DispatchQueue.global(qos: .userInitiated).async {
            // 这里应该调用实际的AI风格迁移模型
            // 目前使用模拟延迟
            Thread.sleep(forTimeInterval: 1.5)
            
            DispatchQueue.main.async {
                // 模拟生成风格化图像
                self.styledImage = originalImage // 实际应该是风格化后的图像
                self.isProcessing = false
            }
        }
    }
    
    private func saveStyledImage() {
        guard let styledImage = styledImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(styledImage, nil, nil, nil)
        
        // 显示保存成功提示
        print("🎨 风格化作品已保存到相册")
    }
}

// MARK: - 风格卡片组件
struct StyleCard: View {
    let style: ArtStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(style.icon)
                    .font(.title)
                
                Text(style.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: style.gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.white : Color.white.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .shadow(
                color: isSelected ? Color.black.opacity(0.3) : Color.clear,
                radius: isSelected ? 8 : 0,
                x: 0,
                y: isSelected ? 4 : 0
            )
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

#Preview {
    StyleTransferView()
        .preferredColorScheme(.dark)
}
