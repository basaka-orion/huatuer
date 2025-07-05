//
//  DrawingToolsPanel.swift
//  华图儿AI创意绘画应用
//
//  Created by ooo on 2025/7/5.
//

import SwiftUI
import PencilKit

struct DrawingToolsPanel: View {
    @Binding var canvasView: PKCanvasView
    @State private var selectedTool: PKInkingTool.InkType = .pen
    @State private var selectedColor: Color = .black
    @State private var brushSize: Double = 5.0
    
    let colors: [Color] = [
        .black, .white, .red, .blue, .green, .yellow, .orange, .purple, .pink, .brown
    ]
    
    let tools: [(PKInkingTool.InkType, String, String)] = [
        (.pen, "钢笔", "pencil.tip"),
        (.marker, "马克笔", "highlighter"),
        (.pencil, "铅笔", "pencil"),
        (.monoline, "单线", "minus")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // 工具选择
            VStack(alignment: .leading, spacing: 12) {
                Text("绘画工具")
                    .font(.headline)
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                    ForEach(tools, id: \.0.rawValue) { tool in
                        Button(action: {
                            selectedTool = tool.0
                            updateCanvasTool()
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: tool.2)
                                    .font(.title2)
                                    .foregroundColor(selectedTool == tool.0 ? .blue : .white)
                                
                                Text(tool.1)
                                    .font(.caption)
                                    .foregroundColor(selectedTool == tool.0 ? .blue : .white.opacity(0.8))
                            }
                            .frame(width: 60, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedTool == tool.0 ? 
                                          Color.blue.opacity(0.2) : 
                                          Color.white.opacity(0.1))
                                    .stroke(selectedTool == tool.0 ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        }
                    }
                }
            }
            
            // 颜色选择
            VStack(alignment: .leading, spacing: 12) {
                Text("颜色")
                    .font(.headline)
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
                    ForEach(colors, id: \.self) { color in
                        Button(action: {
                            selectedColor = color
                            updateCanvasTool()
                        }) {
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.white : Color.clear, lineWidth: 3)
                                )
                                .shadow(color: color.opacity(0.5), radius: selectedColor == color ? 5 : 2)
                        }
                    }
                }
            }
            
            // 画笔大小
            VStack(alignment: .leading, spacing: 12) {
                Text("画笔大小")
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("细")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Slider(value: $brushSize, in: 1...20, step: 1) {
                            Text("画笔大小")
                        }
                        .accentColor(.blue)
                        .onChange(of: brushSize) { _ in
                            updateCanvasTool()
                        }
                        
                        Text("粗")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // 画笔预览
                    Circle()
                        .fill(selectedColor)
                        .frame(width: brushSize * 2, height: brushSize * 2)
                        .animation(.easeInOut(duration: 0.2), value: brushSize)
                }
            }
            
            // 操作按钮
            HStack(spacing: 15) {
                // 撤销
                Button(action: {
                    canvasView.undoManager?.undo()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.title2)
                        Text("撤销")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
                
                // 重做
                Button(action: {
                    canvasView.undoManager?.redo()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.uturn.forward")
                            .font(.title2)
                        Text("重做")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
                
                // 清空
                Button(action: {
                    canvasView.drawing = PKDrawing()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.title2)
                        Text("清空")
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                    .frame(width: 50, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .white.opacity(0.1), radius: 10)
        )
        .onAppear {
            updateCanvasTool()
        }
    }
    
    private func updateCanvasTool() {
        let uiColor = UIColor(selectedColor)
        let tool = PKInkingTool(selectedTool, color: uiColor, width: brushSize)
        canvasView.tool = tool
    }
}

#Preview {
    DrawingToolsPanel(canvasView: .constant(PKCanvasView()))
        .background(Color.black)
}
