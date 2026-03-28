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
    @EnvironmentObject var languageManager: LanguageManager
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
    @State private var editingTodo: TodoItem? = nil
    @State private var showCalendar = false
    @State private var selectedTab = 0
    
    let freeLimit = 5
    let freeCategories: [Category] = [.personal, .work]
    
    var filteredTodos: [TodoItem] {
        var list = filterCategory == nil ? vm.todos : vm.todos.filter { $0.category == filterCategory }
        if !searchText.isEmpty {
            list = list.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        if searchText.isEmpty && filterCategory == nil {
            return list
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
        TabView(selection: $selectedTab) {
            
            // Ana Sayfa
            mainView
                .tabItem {
                    Label("Görevler", systemImage: "checklist")
                }
                .tag(0)
            
            // Takvim (Pro)
            Group {
                if premiumManager.isPremium {
                    CalendarView(todos: vm.todos)
                        .environmentObject(languageManager)
                } else {
                    proRequiredView(icon: "calendar", title: "Takvim")
                }
            }
            .tabItem {
                Label("Takvim", systemImage: "calendar")
            }
            .tag(1)
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .sheet(item: $editingTodo) { todo in
            EditTodoView(todo: todo) { updated in
                vm.update(updated)
            }
            .environmentObject(languageManager)
        }
        .sheet(isPresented: $showReminderSheet) {
            NavigationStack {
                VStack(spacing: 24) {
                    if let item = reminderItem {
                        Text(item.title).font(.headline)
                    }
                    DatePicker(
                        "reminder_time".localized(using: languageManager),
                        selection: $reminderDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .padding()
                }
                .navigationTitle("add_reminder".localized(using: languageManager))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("cancel".localized(using: languageManager)) { showReminderSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("save".localized(using: languageManager)) {
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
    
    // MARK: - Ana Görünüm
    var mainView: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: themeManager.isDarkMode
                        ? [Color.black, Color(hex: "1a1a2e")]
                        : [Color(hex: "f0f4ff"), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // Pro Banner
                    if !premiumManager.isPremium {
                        Button { showPaywall = true } label: {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("pro_banner".localized(using: languageManager))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("$0.99")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
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
                            CategoryChip(
                                title: "all".localized(using: languageManager),
                                icon: "square.grid.2x2.fill",
                                color: .blue,
                                isSelected: filterCategory == nil
                            ) { filterCategory = nil }
                            
                            ForEach(availableCategories, id: \.self) { category in
                                CategoryChip(
                                    title: category.title(using: languageManager),
                                    icon: category.icon,
                                    color: category.color,
                                    isSelected: filterCategory == category
                                ) { filterCategory = category }
                            }
                            
                            if !premiumManager.isPremium {
                                Button { showPaywall = true } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "lock.fill")
                                        Text("Pro")
                                    }
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.yellow.opacity(0.2))
                                    .foregroundColor(.orange)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.orange.opacity(0.4), lineWidth: 1))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    
                    // Arama (Pro)
                    if premiumManager.isPremium {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("search_task".localized(using: languageManager), text: $searchText)
                                .autocorrectionDisabled()
                        }
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    
                    // Görev ekleme
                    HStack(spacing: 8) {
                        TextField("new_task".localized(using: languageManager), text: $newTitle)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .autocorrectionDisabled()
                        
                        if premiumManager.isPremium {
                            Menu {
                                ForEach(Priority.allCases, id: \.self) { priority in
                                    Button {
                                        withAnimation { selectedPriority = priority }
                                    } label: {
                                        Label(priority.title(using: languageManager), systemImage: priority.icon)
                                    }
                                }
                            } label: {
                                Image(systemName: selectedPriority.icon)
                                    .font(.title2)
                                    .foregroundColor(priorityColor)
                                    .frame(width: 36, height: 36)
                                    .background(priorityColor.opacity(0.15))
                                    .clipShape(Circle())
                            }
                        }
                        
                        Menu {
                            ForEach(availableCategories, id: \.self) { category in
                                Button {
                                    withAnimation { selectedCategory = category }
                                } label: {
                                    Label(category.title(using: languageManager), systemImage: category.icon)
                                }
                            }
                        } label: {
                            Image(systemName: selectedCategory.icon)
                                .font(.title2)
                                .foregroundColor(selectedCategory.color)
                                .frame(width: 36, height: 36)
                                .background(selectedCategory.color.opacity(0.15))
                                .clipShape(Circle())
                        }
                        
                        Button {
                            if !premiumManager.isPremium && vm.todos.count >= freeLimit {
                                showLimitAlert = true
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    vm.add(title: newTitle, category: selectedCategory, priority: selectedPriority)
                                    newTitle = ""
                                }
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(newTitle.isEmpty ? Color.gray : Color.blue)
                                .clipShape(Circle())
                                .shadow(color: newTitle.isEmpty ? .clear : .blue.opacity(0.4), radius: 6, x: 0, y: 3)
                                .animation(.spring(), value: newTitle.isEmpty)
                        }
                        .disabled(newTitle.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    // Görev sayısı progress (ücretsiz)
                    if !premiumManager.isPremium {
                        HStack(spacing: 8) {
                            ProgressView(value: Double(min(vm.todos.count, freeLimit)), total: Double(freeLimit))
                                .tint(vm.todos.count >= freeLimit ? .red : .blue)
                                .animation(.easeInOut, value: vm.todos.count)
                            Text("\(vm.todos.count)/\(freeLimit)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(vm.todos.count >= freeLimit ? .red : .gray)
                                .frame(width: 35)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 6)
                    }
                    
                    // Görev listesi
                    List {
                        ForEach(filteredTodos) { item in
                            TodoRowView(
                                item: item,
                                languageManager: languageManager,
                                isPremium: premiumManager.isPremium,
                                onToggle: {
                                    withAnimation(.spring()) { vm.toggle(item) }
                                },
                                onReminder: {
                                    reminderItem = item
                                    reminderDate = item.reminderDate ?? Date()
                                    showReminderSheet = true
                                },
                                onEdit: {
                                    editingTodo = item
                                }
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                        .onDelete(perform: vm.delete)
                        .onMove(perform: vm.move)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .animation(.spring(), value: vm.todos.count)
                }
            }
            .navigationTitle("app_title".localized(using: languageManager))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation { themeManager.isDarkMode.toggle() }
                    } label: {
                        Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(themeManager.isDarkMode ? .yellow : .orange)
                            .frame(width: 32, height: 32)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Circle())
                            .animation(.spring(), value: themeManager.isDarkMode)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 8) {
                        Button {
                            withAnimation {
                                languageManager.language = languageManager.language == "tr" ? "en" : "tr"
                            }
                        } label: {
                            Text(languageManager.language == "tr" ? "🇹🇷" : "🇬🇧")
                                .font(.title3)
                                .frame(width: 32, height: 32)
                                .background(Color.gray.opacity(0.15))
                                .clipShape(Circle())
                        }
                        
                        if !premiumManager.isPremium {
                            Button { showPaywall = true } label: {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                        EditButton()
                    }
                }
            }
            .alert("limit_title".localized(using: languageManager), isPresented: $showLimitAlert) {
                Button("go_pro".localized(using: languageManager)) { showPaywall = true }
                Button("cancel".localized(using: languageManager), role: .cancel) {}
            } message: {
                Text("limit_message".localized(using: languageManager))
            }
        }
    }
    
    // MARK: - Pro Gerekli Görünüm
    func proRequiredView(icon: String, title: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.4))
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Bu özellik Pro sürümde mevcut")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button {
                showPaywall = true
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Pro'ya Geç — $0.99")
                        .fontWeight(.bold)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
                .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color.gray.opacity(0.15))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .shadow(color: isSelected ? color.opacity(0.4) : .clear, radius: 4, x: 0, y: 2)
        }
        .animation(.spring(), value: isSelected)
    }
}

// MARK: - Todo Row
struct TodoRowView: View {
    let item: TodoItem
    let languageManager: LanguageManager
    let isPremium: Bool
    let onToggle: () -> Void
    let onReminder: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? .green : .gray)
                    .font(.title2)
                    .animation(.spring(), value: item.isCompleted)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .strikethrough(item.isCompleted)
                    .foregroundColor(item.isCompleted ? .gray : .primary)
                    .fontWeight(.medium)
                    .animation(.easeInOut, value: item.isCompleted)
                
                HStack(spacing: 6) {
                    Label(item.category.title(using: languageManager), systemImage: item.category.icon)
                        .font(.caption)
                        .foregroundColor(item.category.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.category.color.opacity(0.15))
                        .cornerRadius(6)
                    
                    Label(item.priority.title(using: languageManager), systemImage: item.priority.icon)
                        .font(.caption)
                        .foregroundColor(item.priority.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.priority.color.opacity(0.15))
                        .cornerRadius(6)
                    
                    if let date = item.reminderDate {
                        Label(date.formatted(date: .omitted, time: .shortened), systemImage: "bell.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.15))
                            .cornerRadius(6)
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                // Düzenle butonu
                Button(action: onEdit) {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(.blue.opacity(0.7))
                        .font(.title3)
                }
                .buttonStyle(.plain)
                
                // Hatırlatıcı butonu (Pro)
                if isPremium {
                    Button(action: onReminder) {
                        Image(systemName: item.reminderDate != nil ? "bell.fill" : "bell")
                            .foregroundColor(item.reminderDate != nil ? .blue : .gray)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(16)
        .contentShape(Rectangle())
    }
}

// MARK: - Color Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager())
}
