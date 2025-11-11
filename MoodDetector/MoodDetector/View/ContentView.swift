//
//  ContentView.swift
//  MoodDetector
//
//  Created by Alessandro Cacace on 06/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var showingAdd = false
    
    private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
        }

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            Text(item.journal)
                        } label: {
                            Text(item.mood)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("MoodTracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(isPresented: $showingAdd) {
                AddView()
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(journal: "A", mood:"B", value: 3, summerize: "C", data: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
