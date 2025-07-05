//
//  ContentView.swift
//  华图儿AI创意绘画应用
//
//  Created by ooo on 2025/7/5.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 1 // 默认选中"画"

    var body: some View {
        ZStack {
            // 星空背景
            StarryBackground()

            TabView(selection: $selectedTab) {
                // 图迹页面
                HistoryView()
                    .tabItem {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("图迹")
                    }
                    .tag(0)

                // 主画板页面
                DrawingView()
                    .tabItem {
                        Image(systemName: "paintbrush.pointed.fill")
                        Text("画")
                    }
                    .tag(1)

                // 个人页面
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.circle.fill")
                        Text("我")
                    }
                    .tag(2)
            }
            .accentColor(.white)
        }
        .preferredColorScheme(.dark)
    }
}

// 星空背景组件
struct StarryBackground: View {
    @State private var animateStars = false

    var body: some View {
        ZStack {
            // 深色渐变背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.15, green: 0.1, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // 星星效果
            ForEach(0..<50, id: \.self) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .scaleEffect(animateStars ? 1.2 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: animateStars
                    )
            }
        }
        .onAppear {
            animateStars = true
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
