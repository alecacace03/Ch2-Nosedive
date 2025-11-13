//
//  ContentView.swift
//  MoodDetector
//
//  Created by Alessandro Cacace on 06/11/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    // Environment and data
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.data, order: .reverse) private var items: [Item]  // Newest first
    @State private var showingAdd = false  // Controls navigation to AddView

    var body: some View {
        NavigationStack {
            VStack {
                if items.isEmpty {
                    // Empty state when there are no notes
                    VStack(spacing: 16) {
                        Image(systemName: "note.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No notes")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("Tap + to create your first note")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    // List of notes
                    List {
                        ForEach(items) { item in
                            NavigationLink {
                                DetailView(item: item)
                            } label: {
                                ItemRow(item: item)
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.plain)
                }
            }
            // Home title
            .navigationTitle("MoodTracker")
            .navigationBarTitleDisplayMode(.large)
            
            // Toolbar with edit and add actions
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
            // Navigate to AddView when requested
            .navigationDestination(isPresented: $showingAdd) {
                AddView()
            }
        }
    }
    
    // Deletes selected items from the model context
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let itemToDelete = items[index]
                modelContext.delete(itemToDelete)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        
        // Sample data for previews
        let moods = ["😄", "😐", "🙂", "😕", "😢"]
        let summaries = ["Great day", "Normal day", "A bit stressful", "Very productive", "Total relax"]
        
        for i in 0..<10 {
            let item = Item(
                journal: "Today was a \(summaries[i % summaries.count].lowercased()) day. I did many interesting things and had time to reflect on various aspects of my life. I feel grateful for everything I have.",
                mood: moods[i % moods.count],
                value: Double.random(in: 0...2),
                summerize: summaries[i % summaries.count],
                data: Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            )
            container.mainContext.insert(item)
        }
        
        return TabBarView()
            .modelContainer(container)
    } catch {
        return Text("Error: \(error.localizedDescription)")
    }
}
