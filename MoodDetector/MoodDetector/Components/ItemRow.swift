//
//  ItemRow.swift
//  MoodDetector
//
//  Created by Alessandro Cacace on 13/11/25.
//

import SwiftUI

struct ItemRow: View {
    let item: Item  // The item to render in a list row
    
    var body: some View {
        HStack {
            // Mood emoji
            Text(item.mood)
                .font(.title2)
            
            // Summary, preview, and date
            VStack(alignment: .leading, spacing: 4) {
                // Summary (property is 'summerize')
                Text(item.summerize)
                    .font(.headline)
                    .lineLimit(1)
                
                // Journal preview
                Text(item.journal)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                // Date (abbreviated)
                Text(item.data.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        
        .padding(.vertical, 4)
    }
}

#Preview {
   // Provide an Item to preview if desired
}
