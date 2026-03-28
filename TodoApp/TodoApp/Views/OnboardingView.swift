//
//  OnboardingView.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "checkmark.circle.fill",
            iconColor: .blue,
            title: "Görevlerini Yönet",
            description: "Günlük görevlerini kolayca ekle, düzenle ve tamamla.",
            background: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)]
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            iconColor: .green,
            title: "İstatistiklerini Takip Et",
            description: "Üretkenliğini analiz et, tamamlama oranını gör.",
            background: [Color.green.opacity(0.1), Color.teal.opacity(0.05)]
        ),
        OnboardingPage(
            icon: "bell.fill",
            iconColor: .orange,
            title: "Hiçbir Şeyi Kaçırma",
            description: "Hatırlatıcılar ile görevlerini zamanında tamamla.",
            background: [Color.orange.opacity(0.1), Color.yellow.opacity(0.05)]
        ),
        OnboardingPage(
            icon: "star.fill",
            iconColor: .yellow,
            title: "Pro ile Daha Fazlası",
            description: "Sınırsız görev, takvim, arama ve çok daha fazlası.",
            background: [Color.yellow.opacity(0.1), Color.orange.opacity(0.05)]
        )
    ]
    
    var body: some View {
        ZStack {
            // Arka plan
            LinearGradient(
                colors: pages[currentPage].background,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            VStack(spacing: 0) {
                // Skip butonu
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Geç") {
                            withAnimation {
                                hasSeenOnboarding = true
                            }
                        }
                        .foregroundColor(.gray)
                        .padding()
                    }
                }
                
                Spacer()
                
                // İkon
                ZStack {
                    Circle()
                        .fill(pages[currentPage].iconColor.opacity(0.15))
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(pages[currentPage].iconColor.opacity(0.1))
                        .frame(width: 110, height: 110)
                    
                    Image(systemName: pages[currentPage].icon)
                        .font(.system(size: 55))
                        .foregroundColor(pages[currentPage].iconColor)
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentPage)
                .padding(.bottom, 40)
                
                // Başlık & Açıklama
                VStack(spacing: 16) {
                    Text(pages[currentPage].title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                    
                    Text(pages[currentPage].description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .transition(.opacity)
                }
                .animation(.easeInOut(duration: 0.3), value: currentPage)
                
                Spacer()
                
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? pages[currentPage].iconColor : Color.gray.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 32)
                
                // Buton
                Button {
                    withAnimation(.spring()) {
                        if currentPage < pages.count - 1 {
                            currentPage += 1
                        } else {
                            hasSeenOnboarding = true
                        }
                    }
                } label: {
                    Text(currentPage < pages.count - 1 ? "Devam Et" : "Başla! 🚀")
                        .fontWeight(.bold)
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(pages[currentPage].iconColor)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: pages[currentPage].iconColor.opacity(0.4), radius: 8, x: 0, y: 4)
                        .animation(.spring(), value: currentPage)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 && currentPage < pages.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else if value.translation.width > 50 && currentPage > 0 {
                        withAnimation { currentPage -= 1 }
                    }
                }
        )
    }
}

struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let background: [Color]
}

#Preview {
    OnboardingView()
}
