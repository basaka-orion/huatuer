import SwiftUI

struct GenerationProgressView: View {
    let progress: Double
    let status: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎨 AI正在创作中...")
                .font(.title2)
                .fontWeight(.semibold)
            
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: 200)
            
            Text(status)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

#Preview {
    GenerationProgressView(
        progress: 0.65,
        status: "正在分析您的涂鸦风格..."
    )
}
