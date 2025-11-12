//
//  TabBarView.swift
//  MoodDetector
//
//  Created by Alessandro Cacace on 12/11/25.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        
        TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
            ContentView().tabItem { Image(systemName: "house"); Text("Home")}.tag(1)
            ChartsView().tabItem {Image(systemName: "chart.bar.xaxis"); Text("Charts") }.tag(2)
        }
    }
}

#Preview {
    TabBarView()
}
