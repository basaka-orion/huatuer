import SwiftUI

struct CompletionDialog: View {
    let artworkImage: UIImage
    let onSave: () -> Void
    let onShare: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎨 创作完成！")
                .font(.title)
                .fontWeight(.bold)
            
            Image(uiImage: artworkImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 200, maxHeight: 200)
                .cornerRadius(12)
                .shadow(radius: 5)
            
            Text("您的艺术作品已经生成完成！")
                .font(.body)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 15) {
                Button("保存") {
                    onSave()
                }
                .buttonStyle(.borderedProminent)
                
                Button("分享") {
                    onShare()
                }
                .buttonStyle(.bordered)
                
                Button("关闭") {
                    onClose()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

#Preview {
    CompletionDialog(
        artworkImage: UIImage(systemName: "photo") ?? UIImage(),
        onSave: {},
        onShare: {},
        onClose: {}
    )
}
