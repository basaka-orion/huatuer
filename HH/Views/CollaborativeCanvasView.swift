import SwiftUI

struct CollaborativeCanvasView: View {
    @State private var isConnected = false
    @State private var collaborators = ["小明", "小红", "小华"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("👥 实时协作画布")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                Circle()
                    .fill(isConnected ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                
                Text(isConnected ? "已连接" : "未连接")
                    .font(.caption)
                    .foregroundColor(isConnected ? .green : .red)
            }
            
            if isConnected {
                VStack(alignment: .leading, spacing: 10) {
                    Text("当前协作者：")
                        .font(.headline)
                    
                    ForEach(collaborators, id: \.self) { collaborator in
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                            
                            Text(collaborator)
                                .font(.body)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                
                VStack {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("协作画布")
                        .font(.headline)
                    
                    Text("与朋友一起实时创作艺术作品")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            }
            
            Button(isConnected ? "断开连接" : "开始协作") {
                isConnected.toggle()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    CollaborativeCanvasView()
}
