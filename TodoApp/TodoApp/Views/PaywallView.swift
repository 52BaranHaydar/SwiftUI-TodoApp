//
//  PaywallView.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import SwiftUI
import Combine

struct PaywallView: View {
    @ObservedObject var premiumManager = PremiumManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var isPurchasing = false
    
    let features: [(icon: String, color: Color, title: String, description: String)] = [
        ("infinity", .blue, "Sınırsız Görev", "İstediğin kadar görev ekle"),
        ("bell.fill", .orange, "Bildirimler", "Hatırlatıcı ile hiçbir görevi kaçırma"),
        ("moon.fill", .purple, "Dark Mode", "Gözlerini yorma"),
        ("chart.bar.fill", .green, "İstatistikler", "Üretkenliğini takip et"),
        ("magnifyingglass", .red, "Görev Arama", "Görevlerini hızlıca bul"),
        ("clock.fill", .teal, "Geçmiş", "Tamamlanan görevleri gör")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(.yellow)
                        
                        Text("TodoApp Pro")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Tüm özelliklerin kilidini aç")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Özellikler
                    VStack(spacing: 12) {
                        ForEach(features, id: \.title) { feature in
                            HStack(spacing: 16) {
                                Image(systemName: feature.icon)
                                    .font(.title2)
                                    .foregroundColor(feature.color)
                                    .frame(width: 36)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(feature.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(feature.description)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Fiyat & Satın Al
                    VStack(spacing: 12) {
                        Text("Tek seferlik ödeme")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button {
                            isPurchasing = true
                            Task {
                                await premiumManager.purchase()
                                isPurchasing = false
                                if premiumManager.isPremium {
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack {
                                if isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Pro'ya Geç — $0.99")
                                        .fontWeight(.bold)
                                        .font(.title3)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        Button {
                            Task {
                                await premiumManager.restore()
                                if premiumManager.isPremium { dismiss() }
                            }
                        } label: {
                            Text("Satın alımları geri yükle")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Button("🧪 Test: Pro'yu Aktif Et") {
                            premiumManager.simulatePurchase()
                            dismiss()
                        }
                        .font(.caption)
                        .foregroundColor(.green)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

#Preview {
    PaywallView()
}
