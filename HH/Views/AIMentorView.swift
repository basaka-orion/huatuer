import SwiftUI

struct AIMentorView: View {
    let artworkImage: UIImage
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎓 AI艺术导师")
                .font(.title2)
                .fontWeight(.bold)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("作品分析")
                        .font(.headline)
                    
                    Text("您的作品展现了很好的色彩搭配和构图感。建议在下次创作中可以尝试：")
                        .font(.body)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• 增加更多的明暗对比")
                        Text("• 尝试使用冷暖色调的搭配")
                        Text("• 在细节处理上可以更加精细")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("推荐学习")
                        .font(.headline)
                    
                    Text("基于您的创作风格，推荐学习印象派技法")
                        .font(.body)
                }
            }
            .frame(maxHeight: 200)
            
            Button("获取更多指导") {
                // AI导师功能实现
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    AIMentorView(artworkImage: UIImage(systemName: "photo") ?? UIImage())
}
