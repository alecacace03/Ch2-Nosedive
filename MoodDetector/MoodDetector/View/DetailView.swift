//
//  DetailView.swift
//  MoodDetector
//
//  Created by Alessandro Cacace on 13/11/25.
//

import SwiftUI
import SwiftData

struct DetailView: View {
    let item: Item  // The item to display
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    // Mood emoji
                    Text(item.mood)
                        .font(.system(size: 60))
                    
                    Capsule()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 2, height: 30)
                    
                    Text(String(Int(item.value)))
                        .font(.system(size: 40))
                        .padding(.horizontal, 7)
                        
                    
                    Spacer()
                    
                    // Date in long format
                    Text(item.data.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Summary (property stored as 'summerize')
                Text(item.summerize)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Divider()
                
                // Full journal entry
                Text(item.journal)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    // Sample Item for preview
    let sample = Item(
        journal: "Today was a productive day. I took a walk in the park and read a good book.",
        mood: "🙂",
        value: 5,
        summerize: "Productive and calm day.",
        data: Date()
    )
    return NavigationStack { DetailView(item: sample) }
}
