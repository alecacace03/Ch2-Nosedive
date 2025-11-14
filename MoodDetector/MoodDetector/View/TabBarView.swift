//
//  TabBarView.swift
//  MoodDetector
//
//  Created by Alessandro Cacace on 12/11/25.
//

import SwiftUI

struct TabBarView: View {
    
    @State private var selectedTab = 0  // Currently selected tab
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab
            Tab("Home", systemImage: "house", value: 0) {
                ContentView()
            }
            
            // Charts tab
            Tab("Charts", systemImage: "chart.bar.xaxis", value: 1) {
                ChartsView()
            }
            
           
            
            // Search tab (marked with search role for better platform semantics)
            Tab("Search", systemImage: "magnifyingglass", value: 2, role: .search) {
                NavigationStack {
                    SearchView()
                }
            }
        }
    }
}

#Preview {
    TabBarView()
}
