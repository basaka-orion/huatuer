import SwiftUI

struct StyleLearnerView: View {
    @State private var selectedStyle = "印象派"
    
    let styles = ["印象派", "立体主义", "抽象表现主义", "超现实主义"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎨 AI风格学习器")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("选择您想要学习的艺术风格")
                .font(.body)
                .foregroundColor(.secondary)
            
            Picker("艺术风格", selection: $selectedStyle) {
                ForEach(styles, id: \.self) { style in
                    Text(style).tag(style)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 200)
                
                VStack {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("AI正在学习\(selectedStyle)风格")
                        .font(.headline)
                    
                    Text("分析大师作品的笔触、色彩和构图特点")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            }
            
            Button("开始学习") {
                // 风格学习功能实现
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    StyleLearnerView()
}
