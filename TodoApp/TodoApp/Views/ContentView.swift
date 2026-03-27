//
//  ContentView.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var vm = TodoViewModel()
    @State private var newTitle = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack{
                    TextField("Yeni görev...", text: $newTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    Button {
                        vm.add(title: newTitle)
                        newTitle = ""
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
                .padding()
                
                // Görev Listesi
                
                List{
                    ForEach(vm.todos) { item in
                        HStack{
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.isCompleted ? .green : .gray)
                                .font(.title3)
                                .onTapGesture {
                                    vm.toggle(item)
                                }
                            
                            Text(item.title)
                                .strikethrough(item.isCompleted)
                                .foregroundStyle(item.isCompleted ? .gray : .primary)
                            
                        }
                    }
                    .onDelete(perform: vm.delete)
                }
            }
            .navigationTitle("Görevlerim")
            .toolbar{
                EditButton()
            }
        }
    }
    
    
}

#Preview {
    ContentView()
}
