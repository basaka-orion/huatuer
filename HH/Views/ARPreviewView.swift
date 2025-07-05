import SwiftUI

struct ARPreviewView: View {
    let artworkImage: UIImage
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🥽 AR艺术预览")
                .font(.title2)
                .fontWeight(.bold)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.1))
                    .frame(height: 300)
                
                VStack {
                    Image(systemName: "arkit")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("AR预览功能")
                        .font(.headline)
                    
                    Text("将您的艺术作品投影到现实世界中")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            }
            
            Button("启动AR预览") {
                // AR功能实现
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ARPreviewView(artworkImage: UIImage(systemName: "photo") ?? UIImage())
}
