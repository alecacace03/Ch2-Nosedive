//
//  ChartsView.swift
//  MoodDetector
//
//  Created by Alessandro Cacace on 12/11/25.
//

import SwiftUI
import Charts
import SwiftData

struct ChartsView: View {
    
    // SwiftData model context from the environment
    @Environment(\.modelContext) private var modelContext
    
    // All items, sorted by date ascending
    @Query(sort: \Item.data) private var items: [Item]
    
    // Currently selected chart period (weekly or monthly)
    @State private var selectedPeriod: ChartPeriod = .weekly
    
    // Periods supported by the chart
    enum ChartPeriod: String, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
    }
    
    // Maps a numeric mood value (0...2) to an emoji displayed on the Y axis
    // The scale is split into 5 ranges
    func getEmoji(for value: Double) -> String {
        switch value {
        case 0..<0.4: return "😢"
        case 0.4..<0.8: return "😕"
        case 0.8..<1.2: return "😐"
        case 1.2..<1.6: return "🙂"
        case 1.6...2: return "😄"
        default: return "😐"
        }
    }
    
    // Filters items according to the selected period (last 7 days or last month)
    var filteredItems: [Item] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .weekly:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return items.filter { $0.data >= weekAgo }
        case .monthly:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return items.filter { $0.data >= monthAgo }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Period selector
                Picker("Period", selection: $selectedPeriod.animation(.easeInOut)) {
                    ForEach(ChartPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                Text("Mood trend")
                    .font(.headline)
                
                if filteredItems.isEmpty {
                    // Empty state for the selected period
                    Text("No data available for this period")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    // Line chart of mood values over time
                    Chart {
                        ForEach(filteredItems, id: \.self) { item in
                            // Smooth line connecting entries
                            LineMark(
                                x: .value("Date", item.data, unit: .day),
                                y: .value("Value", item.value)
                            )
                            .foregroundStyle(.blue)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            
                            // Points on each entry
                            PointMark(
                                x: .value("Date", item.data, unit: .day),
                                y: .value("Value", item.value)
                            )
                            .foregroundStyle(.blue)
                            .symbolSize(100)
                        }
                    }
                    // X axis shows days; stride is tighter for weekly and looser for monthly
                    .chartXAxis {
                        AxisMarks(
                            values: .stride(
                                by: .day,
                                count: selectedPeriod == .weekly ? 1 : 5
                            )
                        ) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.day().month())
                        }
                    }
                    // Y axis uses emojis instead of numeric labels to represent mood ranges
                    .chartYAxis {
                        AxisMarks(position: .leading, values: [0, 0.5, 1, 1.5, 2]) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel {
                                if let doubleValue = value.as(Double.self) {
                                    Text(getEmoji(for: doubleValue))
                                        .font(.title2)
                                }
                            }
                        }
                    }
                    // Lock the Y scale to the app's mood value domain
                    .chartYScale(domain: 0...2)
                    .frame(height: 300)
                    .padding()
                    
                    // Emoji legend for the Y-axis scale
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Legend:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 30) {
                            VStack{
                                Text("😢")
                                Text("0.0–0.4")
                            }
                            VStack{
                                Text("😕")
                                Text("0.4–0.8")
                            }
                            VStack{
                                Text("😐")
                                Text("0.8–1.2")
                            }
                            VStack{
                                Text("🙂")
                                Text("1.2–1.6")
                            }
                            VStack{
                                Text("😄")
                                Text("1.6–2.0")
                            }
                          
                        }
                        .font(.caption)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer()
                
            }
            .navigationTitle("Charts")
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        
        // Sample data for previews (last 30 days)
        let calendar = Calendar.current
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let item = Item(
                journal: "Journal \(i)",
                mood: "Happy",
                value: Double.random(in: 0...2),
                summerize: "Summary",
                data: date
            )
            container.mainContext.insert(item)
        }
        
        return ChartsView()
            .modelContainer(container)
    } catch {
        return Text("Error: \(error.localizedDescription)")
    }
}
