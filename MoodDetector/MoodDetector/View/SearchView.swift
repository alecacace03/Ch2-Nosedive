//
//  SearchView.swift
//  MoodDetector
//
//  Created by Alessandro Cacace on 13/11/25.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    
    // Environment and data access
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.data, order: .reverse) private var items: [Item]  // All items, newest first
    
    // Search state
    @State private var searchText = ""  // Text typed in the search field
    
    // Filters items based on the search text across multiple fields
    var filteredItems: [Item] {
        if searchText.isEmpty {
            // No search text -> show all items
            return items
        } else {
            // Filter by summary, journal, or mood
            return items.filter { item in
                let matchesSummary = item.summerize.localizedCaseInsensitiveContains(searchText)
                let matchesJournal = item.journal.localizedCaseInsensitiveContains(searchText)
                let matchesMood = item.mood.localizedCaseInsensitiveContains(searchText)
                return matchesSummary || matchesJournal || matchesMood
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if filteredItems.isEmpty {
                    // Empty state for search results
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text(searchText.isEmpty ? "Search your notes" : "No results")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        if !searchText.isEmpty {
                            Text("Try different keywords")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Search by summary, text, or mood")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // List of matching results
                    List {
                        ForEach(filteredItems) { item in
                            NavigationLink {
                                DetailView(item: item)
                            } label: {
                                ItemRow(item: item)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            // Search screen title
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            
            // Search field visible in this view
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search notes"
            )
            
            // No toolbar here (no Add or Edit on the Search screen)
        }
    }
}

#Preview {
    SearchView()
}
