import SwiftUI
import SceneKit
import ARKit

// MARK: - 3D创作模式类型
enum ThreeDMode: String, CaseIterable {
    case sculpting = "3D雕塑"
    case painting = "立体绘画"
    case modeling = "3D建模"
    case ar = "AR创作"
    case vr = "VR沉浸"
    case animation = "3D动画"
    
    var icon: String {
        switch self {
        case .sculpting: return "cube.fill"
        case .painting: return "paintbrush.pointed.fill"
        case .modeling: return "square.3.layers.3d"
        case .ar: return "arkit"
        case .vr: return "visionpro"
        case .animation: return "play.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .sculpting: return .brown
        case .painting: return .purple
        case .modeling: return .blue
        case .ar: return .green
        case .vr: return .red
        case .animation: return .orange
        }
    }
    
    var description: String {
        switch self {
        case .sculpting: return "像雕塑家一样塑造3D形体"
        case .painting: return "在3D空间中自由绘画"
        case .modeling: return "创建复杂的3D模型"
        case .ar: return "在现实世界中创作虚拟艺术"
        case .vr: return "沉浸式虚拟现实创作体验"
        case .animation: return "为3D作品添加动画效果"
        }
    }
}

// MARK: - 3D工具类型
enum ThreeDTool: String, CaseIterable {
    case brush = "画笔"
    case chisel = "雕刻刀"
    case extrude = "拉伸"
    case smooth = "平滑"
    case texture = "纹理"
    case light = "光照"
    
    var icon: String {
        switch self {
        case .brush: return "paintbrush.fill"
        case .chisel: return "hammer.fill"
        case .extrude: return "arrow.up.and.down"
        case .smooth: return "wand.and.rays"
        case .texture: return "square.grid.3x3.fill"
        case .light: return "lightbulb.fill"
        }
    }
}

// MARK: - 3D材质类型
enum ThreeDMaterial: String, CaseIterable {
    case clay = "粘土"
    case metal = "金属"
    case glass = "玻璃"
    case wood = "木材"
    case stone = "石材"
    case fabric = "布料"
    
    var color: Color {
        switch self {
        case .clay: return .brown
        case .metal: return .gray
        case .glass: return .cyan
        case .wood: return .orange
        case .stone: return .gray
        case .fabric: return .purple
        }
    }
}

// MARK: - 3D立体创作视图
struct ThreeDCreationView: View {
    @State private var selectedMode: ThreeDMode = .sculpting
    @State private var selectedTool: ThreeDTool = .brush
    @State private var selectedMaterial: ThreeDMaterial = .clay
    @State private var brushSize: Float = 0.5
    @State private var brushStrength: Float = 0.7
    @State private var showARView = false
    @State private var showVRView = false
    @State private var isRecording = false
    @State private var showExportOptions = false
    @State private var rotationX: Float = 0
    @State private var rotationY: Float = 0
    @State private var zoom: Float = 1.0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部工具栏
                topToolbar
                
                // 模式选择器
                modeSelector
                
                // 主要创作区域
                ZStack {
                    // 3D场景背景
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.8),
                            selectedMode.color.opacity(0.3),
                            Color.black.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // 3D创作界面
                    threeDCreationInterface
                }
                
                // 底部工具面板
                bottomToolPanel
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
    }
    
    // MARK: - 顶部工具栏
    private var topToolbar: some View {
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
                Text("🎨 3D立体创作")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(selectedMode.rawValue)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // 录制按钮
                Button(action: {
                    isRecording.toggle()
                }) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                        .font(.title2)
                        .foregroundColor(isRecording ? .red : .white)
                        .padding()
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
                
                // 导出按钮
                Button(action: {
                    showExportOptions = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    // MARK: - 模式选择器
    private var modeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(ThreeDMode.allCases, id: \.self) { mode in
                    ThreeDModeTab(
                        mode: mode,
                        isSelected: selectedMode == mode
                    ) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedMode = mode
                            
                            // 特殊模式处理
                            if mode == .ar {
                                showARView = true
                            } else if mode == .vr {
                                showVRView = true
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - 3D创作界面
    private var threeDCreationInterface: some View {
        VStack {
            // 3D场景视图
            threeDSceneView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
            
            // 创作提示
            creationHints
        }
    }
    
    // MARK: - 3D场景视图
    private var threeDSceneView: some View {
        ZStack {
            // 模拟3D场景
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.9),
                            selectedMode.color.opacity(0.2),
                            Color.black.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    // 3D网格背景
                    VStack(spacing: 20) {
                        ForEach(0..<8) { row in
                            HStack(spacing: 20) {
                                ForEach(0..<8) { col in
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 2, height: 2)
                                }
                            }
                        }
                    }
                    .opacity(0.3)
                )
            
            // 3D对象预览
            threeDObjectPreview
            
            // 手势控制提示
            gestureHints
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    rotationX += Float(value.translation.y * 0.01)
                    rotationY += Float(value.translation.x * 0.01)
                }
        )
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    zoom = Float(value)
                }
        )
    }
    
    // MARK: - 3D对象预览
    private var threeDObjectPreview: some View {
        VStack {
            // 根据选择的模式显示不同的3D对象
            Group {
                switch selectedMode {
                case .sculpting:
                    sculptingPreview
                case .painting:
                    paintingPreview
                case .modeling:
                    modelingPreview
                case .ar:
                    arPreview
                case .vr:
                    vrPreview
                case .animation:
                    animationPreview
                }
            }
            .scaleEffect(CGFloat(zoom))
            .rotation3DEffect(
                .degrees(Double(rotationX * 180 / .pi)),
                axis: (x: 1, y: 0, z: 0)
            )
            .rotation3DEffect(
                .degrees(Double(rotationY * 180 / .pi)),
                axis: (x: 0, y: 1, z: 0)
            )
        }
    }
    
    // MARK: - 雕塑预览
    private var sculptingPreview: some View {
        VStack(spacing: 8) {
            Text("🗿")
                .font(.system(size: 80))
                .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)
            
            Text("3D雕塑作品")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - 绘画预览
    private var paintingPreview: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.purple, .blue, .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Text("🎨")
                    .font(.system(size: 40))
            }
            
            Text("立体绘画")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - 建模预览
    private var modelingPreview: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(selectedMaterial.color)
                        .frame(width: 20, height: 20)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                }
            }
            
            Text("3D建模")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - AR预览
    private var arPreview: some View {
        VStack(spacing: 8) {
            Text("📱")
                .font(.system(size: 80))
                .overlay(
                    Text("AR")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .offset(y: 20)
                )
            
            Text("增强现实创作")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - VR预览
    private var vrPreview: some View {
        VStack(spacing: 8) {
            Text("🥽")
                .font(.system(size: 80))
                .overlay(
                    Text("VR")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .offset(y: 20)
                )
            
            Text("虚拟现实沉浸")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - 动画预览
    private var animationPreview: some View {
        VStack(spacing: 8) {
            Text("🎬")
                .font(.system(size: 80))
                .scaleEffect(isRecording ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isRecording)
            
            Text("3D动画制作")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - 手势提示
    private var gestureHints: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Label("拖拽旋转", systemImage: "rotate.3d")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Label("捏合缩放", systemImage: "magnifyingglass")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Label("双击重置", systemImage: "arrow.clockwise")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            }
        }
        .padding()
    }
    
    // MARK: - 创作提示
    private var creationHints: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("💡 创作提示")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(selectedMode.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action: {
                // 显示详细教程
            }) {
                Text("查看教程")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedMode.color)
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
    }
    
    // MARK: - 底部工具面板
    private var bottomToolPanel: some View {
        VStack(spacing: 16) {
            // 工具选择
            toolSelector
            
            // 材质选择
            materialSelector
            
            // 参数调节
            parameterControls
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    // MARK: - 工具选择器
    private var toolSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🛠️ 工具")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ThreeDTool.allCases, id: \.self) { tool in
                        ToolButton(
                            tool: tool,
                            isSelected: selectedTool == tool
                        ) {
                            selectedTool = tool
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - 材质选择器
    private var materialSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🎨 材质")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ThreeDMaterial.allCases, id: \.self) { material in
                        MaterialButton(
                            material: material,
                            isSelected: selectedMaterial == material
                        ) {
                            selectedMaterial = material
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - 参数控制
    private var parameterControls: some View {
        VStack(spacing: 12) {
            // 画笔大小
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("画笔大小")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(Int(brushSize * 100))%")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                Slider(value: $brushSize, in: 0.1...1.0)
                    .accentColor(selectedMode.color)
            }
            
            // 强度
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("强度")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(Int(brushStrength * 100))%")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                
                Slider(value: $brushStrength, in: 0.1...1.0)
                    .accentColor(selectedMode.color)
            }
        }
    }
}

// MARK: - 3D模式标签组件
struct ThreeDModeTab: View {
    let mode: ThreeDMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                Text(mode.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? mode.color : Color.clear)
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

// MARK: - 工具按钮组件
struct ToolButton: View {
    let tool: ThreeDTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tool.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                
                Text(tool.rawValue)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected ? Color.clear : Color.white.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
}

// MARK: - 材质按钮组件
struct MaterialButton: View {
    let material: ThreeDMaterial
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Circle()
                    .fill(material.color)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(
                                isSelected ? Color.white : Color.clear,
                                lineWidth: 2
                            )
                    )
                
                Text(material.rawValue)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.black.opacity(0.3) : Color.clear)
            )
        }
    }
}

#Preview {
    ThreeDCreationView()
        .preferredColorScheme(.dark)
}
