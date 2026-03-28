//
//  NotificationManager.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import Foundation
import UserNotifications

class NotificationManager{
    static let shared = NotificationManager()
    
    func requestPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){
            granted, error in
            if granted {
                print("Bildirim izni verildi")
            } else{
                print("Bildirim izni reddedildi")
            }
        }
    }
    
    func schedule(for item : TodoItem, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Görev Hatırlatıcı"
        content.body = item.title
        content.sound = .default
        
        switch item.priority {
        case .low:
            content.subtitle = "🔹 Düşük Öncelikli"
        case .medium:
            content.subtitle =  "🔶 Orta Öncelikli"
        case .high:
            content.subtitle = "⚠️ Yüksek Öncelikli"
        }
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from:  date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancel(for item : TodoItem) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
    }
    
    
    
    
}
