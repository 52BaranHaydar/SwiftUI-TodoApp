//
//  PremiumManager.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import Foundation
import StoreKit
import Combine

class PremiumManager: ObservableObject {
    static let shared = PremiumManager()
    
    @Published var isPremium: Bool = false
    
    private let premiumKey = "isPremium"
    private let productID = "com.52baranhaydar.todoapp.pro"
    
    init() {
        isPremium = UserDefaults.standard.bool(forKey: premiumKey)
    }
    
    // Gerçek ödeme (App Store)
    func purchase() async {
        do {
            let products = try await Product.products(for: [productID])
            guard let product = products.first else { return }
            let result = try await product.purchase()
            
            switch result {
            case .success:
                await MainActor.run {
                    self.isPremium = true
                    UserDefaults.standard.set(true, forKey: premiumKey)
                }
            default:
                break
            }
        } catch {
            print("Satın alma hatası: \(error)")
        }
    }
    
    // Restore purchases
    func restore() async {
        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if transaction.productID == productID {
                        await MainActor.run {
                            self.isPremium = true
                            UserDefaults.standard.set(true, forKey: premiumKey)
                        }
                    }
                }
            }
        } catch {
            print("Restore hatası: \(error)")
        }
    }
    
    // Test için (simülatörde)
    func simulatePurchase() {
        isPremium = true
        UserDefaults.standard.set(true, forKey: premiumKey)
    }
    
    func revokePremium() {
        isPremium = false
        UserDefaults.standard.set(false, forKey: premiumKey)
    }
}
