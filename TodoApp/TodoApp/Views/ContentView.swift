//
//  ContentView.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var vm = TodoViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var premiumManager = PremiumManager.shared
    @State private var newTitle = ""
    @State private var selectedCategory: Category = .personal
    @State private var selectedPriority: Priority = .medium
    @State private var filterCategory: Category? = nil
    @State private var reminderItem: TodoItem? = nil
    @State private var reminderDate = Date()
    @State private var showReminderSheet = false
    @State private var showPaywall = false
    @State private var showLimitAlert = false
    @State private var searchText = ""
    
    let freeLimit = 5
    let freeCategories: [Category] = [.personal, .work]
    
    var filteredTodos: [TodoItem] {
        var list = filterCategory == nil ? vm.todos : vm.todos.filter { $0.category == filterCategory }
        if !searchText.isEmpty {
            list = list.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        return list.sorted { $0.priority > $1.priority }
    }
    
    var priorityColor: Color {
        switch selectedPriority {
        case .low:    return .green
        case .medium: return .orange
        case .high:   return .red
        }
    }
    
    var availableCategories: [Category] {
        premiumManager.isPremium ? Category.allCases : freeCategories
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // Pro Banner (ücretsiz kullanıcılar için)
                if !premiumManager.isPremium {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Pro'ya geç — Sınırsız görev & daha fazlası")
                                .font(.caption)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("$0.99")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                    }
                }
                
                // İstatistikler (Pro)
                if premiumManager.isPremium {
                    StatsView(todos: vm.todos)
                        .padding(.top, 8)
                }
                
                // Kategori Filtresi
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button {
                            filterCategory = nil
                        } label: {
                            Text("Tümü")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(filterCategory == nil ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(filterCategory == nil ? .white : .primary)
                                .clipShape(Capsule())
                        }
                        
                        ForEach(availableCategories, id: \.self) { category in
                            Button {
                                filterCategory = category
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: category.icon)
                                    Text(category.rawValue)
                                }
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(filterCategory == category ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(filterCategory == category ? .white : .primary)
                                .clipShape(Capsule())
                            }
                        }
                        
                        // Pro kategoriler kilidi
                        if !premiumManager.isPremium {
                            Button {
                                showPaywall = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "lock.fill")
                                    Text("Pro")
                                }
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.yellow.opacity(0.2))
                                .foregroundColor(.orange)
                                .clipShape(Capsule())
                            }
                        }
                    }
                    .padding()
                }
                
                // Arama (Pro)
                if premiumManager.isPremium {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Görev ara...", text: $searchText)
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                
                // Görev ekleme alanı
                HStack {
                    TextField("Yeni görev...", text: $newTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    if premiumManager.isPremium {
                        Menu {
                            ForEach(Priority.allCases, id: \.self) { priority in
                                Button {
                                    selectedPriority = priority
                                } label: {
                                    Label(priority.title, systemImage: priority.icon)
                                }
                            }
                        } label: {
                            Image(systemName: selectedPriority.icon)
                                .font(.title2)
                                .foregroundColor(priorityColor)
                        }
                    }
                    
                    Menu {
                        ForEach(availableCategories, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                Label(category.rawValue, systemImage: category.icon)
                            }
                        }
                    } label: {
                        Image(systemName: selectedCategory.icon)
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Button {
                        if !premiumManager.isPremium && vm.todos.count >= freeLimit {
                            showLimitAlert = true
                        } else {
                            vm.add(title: newTitle, category: selectedCategory, priority: selectedPriority)
                            newTitle = ""
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Görev sayısı (ücretsiz)
                if !premiumManager.isPremium {
                    HStack {
                        Text("\(vm.todos.count)/\(freeLimit) görev kullanılıyor")
                            .font(.caption)
                            .foregroundColor(vm.todos.count >= freeLimit ? .red : .gray)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                }
                
                // Görev listesi
                List {
                    ForEach(filteredTodos) { item in
                        HStack {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isCompleted ? .green : .gray)
                                .font(.title3)
                                .onTapGesture {
                                    vm.toggle(item)
                                }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .strikethrough(item.isCompleted)
                                    .foregroundColor(item.isCompleted ? .gray : .primary)
                                
                                HStack(spacing: 8) {
                                    HStack(spacing: 4) {
                                        Image(systemName: item.category.icon)
                                        Text(item.category.rawValue)
                                    }
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: item.priority.icon)
                                        Text(item.priority.title)
                                    }
                                    
                                    if let date = item.reminderDate {
                                        HStack(spacing: 4) {
                                            Image(systemName: "bell.fill")
                                            Text(date.formatted(date: .omitted, time: .shortened))
                                        }
                                        .foregroundColor(.blue)
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if premiumManager.isPremium {
                                Button {
                                    reminderItem = item
                                    reminderDate = Date()
                                    showReminderSheet = true
                                } label: {
                                    Image(systemName: item.reminderDate != nil ? "bell.fill" : "bell")
                                        .foregroundColor(item.reminderDate != nil ? .blue : .gray)
                                }
                            }
                        }
                    }
                    .onDelete(perform: vm.delete)
                }
            }
            .navigationTitle("Görevlerim")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        themeManager.isDarkMode.toggle()
                    } label: {
                        Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(themeManager.isDarkMode ? .yellow : .orange)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !premiumManager.isPremium {
                            Button {
                                showPaywall = true
                            } label: {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        EditButton()
                    }
                }
            }
            .alert("Limit Doldu! 🚫", isPresented: $showLimitAlert) {
                Button("Pro'ya Geç") { showPaywall = true }
                Button("İptal", role: .cancel) {}
            } message: {
                Text("Ücretsiz sürümde en fazla 5 görev ekleyebilirsin. Pro'ya geçerek sınırsız görev ekle!")
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showReminderSheet) {
                NavigationStack {
                    VStack(spacing: 24) {
                        if let item = reminderItem {
                            Text(item.title)
                                .font(.headline)
                        }
                        DatePicker("Hatırlatma Zamanı", selection: $reminderDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                            .padding()
                    }
                    .navigationTitle("Hatırlatıcı Ekle")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("İptal") { showReminderSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Kaydet") {
                                if let item = reminderItem {
                                    vm.setReminder(for: item, at: reminderDate)
                                }
                                showReminderSheet = false
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
