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
    
    // 1. DATI E AMBIENTE
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.data) private var items: [Item]
    
    // 2. STATO DEL PERIODO SELEZIONATO
    @State private var selectedPeriod: ChartPeriod = .weekly
    
    // 3. ENUM PER I PERIODI
    enum ChartPeriod: String, CaseIterable {
        case weekly = "Week"
        case monthly = "Month"
        
        // Helper per avere icone
        var icon: String {
            switch self {
            case .weekly: return "7.calendar"
            case .monthly: return "calendar"
            }
        }
    }
    
    // 4. MAPPA VALORI → EMOJI
    func getEmoji(for value: Double) -> String {
        switch value {
        case 0..<2.0: return "😢"
        case 2.0..<4.0: return "😕"
        case 4.0..<6.0: return "😐"
        case 6.0..<8.0: return "🙂"
        case 8.0...10: return "😄"
        default: return "😐"
        }
    }
    
    // 5. FILTRA ITEMS PER PERIODO
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
    
    // 6. CALCOLA MEDIA DEL PERIODO
    var averageMood: Double? {
        guard !filteredItems.isEmpty else { return nil }
        let sum = filteredItems.reduce(0.0) { $0 + $1.value }
        return sum / Double(filteredItems.count)
    }
    
    // 7. CALCOLA TREND (positivo/negativo/neutro)
    var moodTrend: TrendDirection {
        guard filteredItems.count >= 2 else { return .neutral }
        
        let firstHalf = filteredItems.prefix(filteredItems.count / 2)
        let secondHalf = filteredItems.suffix(filteredItems.count / 2)
        
        let firstAvg = firstHalf.reduce(0.0) { $0 + $1.value } / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0.0) { $0 + $1.value } / Double(secondHalf.count)
        
        let difference = secondAvg - firstAvg
        
        if difference > 0.1 { return .up }
        else if difference < -0.1 { return .down }
        else { return .neutral }
    }
    
    enum TrendDirection {
        case up, down, neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "arrow.right"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .orange
            }
        }
        
        var text: String {
            switch self {
            case .up: return "In improvement"
            case .down: return "Declining"
            case .neutral: return "Stable"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // 8. HEADER CON STATISTICHE
                    if let average = averageMood {
                        VStack(spacing: 12) {
                            HStack {
                                // Emoji media
                                Text(getEmoji(for: average))
                                    .font(.system(size: 50))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Average Mood")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(String(format: "%.2f", average))
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                                
                                Spacer()
                                
                                // Trend indicator
                                VStack(alignment: .trailing, spacing: 4) {
                                    HStack(spacing: 4) {
                                        Image(systemName: moodTrend.icon)
                                        Text(moodTrend.text)
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(moodTrend.color)
                                    
                                    Text("\(filteredItems.count) items")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.secondarySystemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // 9. SELETTORE PERIODO PERSONALIZZATO
                    HStack(spacing: 0) {
                        ForEach(ChartPeriod.allCases, id: \.self) { period in
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedPeriod = period
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: period.icon)
                                        .font(.title3)
                                    
                                    Text(period.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(selectedPeriod == period ? .semibold : .regular)
                                }
                                .foregroundColor(selectedPeriod == period ? .white : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    selectedPeriod == period ? Color.accentColor : Color.clear
                                )
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // 10. GRAFICO O STATO VUOTO
                    if filteredItems.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No data available")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text("Add notes to see your progress")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 300)
                        .padding()
                        
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mood trend")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            // 11. GRAFICO
                            Chart {
                                ForEach(filteredItems, id: \.self) { item in
                                    // Linea
                                    LineMark(
                                        x: .value("Date", item.data, unit: .day),
                                        y: .value("Value", item.value)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.accentColor, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    
                                    // Area sotto la linea
                                    AreaMark(
                                        x: .value("Date", item.data, unit: .day),
                                        y: .value("Value", item.value)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.accentColor.opacity(0.3), .purple.opacity(0.1)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .interpolationMethod(.catmullRom)
                                    
                                    // Punti
                                    PointMark(
                                        x: .value("Date", item.data, unit: .day),
                                        y: .value("Value", item.value)
                                    )
                                    .foregroundStyle(.blue)
                                    .symbolSize(80)
                                }
                            }
                            .chartXAxis {
                                AxisMarks(
                                    values: .stride(
                                        by: .day,
                                        count: selectedPeriod == .weekly ? 1 : 5
                                    )
                                ) { value in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                        .foregroundStyle(.gray.opacity(0.3))
                                    AxisTick()
                                    AxisValueLabel(format: .dateTime.day().month())
                                        .font(.caption)
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading, values: [0, 2.5, 5, 7.5, 10]) { value in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                        .foregroundStyle(.gray.opacity(0.3))
                                    AxisTick()
                                    AxisValueLabel {
                                        if let doubleValue = value.as(Double.self) {
                                            Text(getEmoji(for: doubleValue))
                                                .font(.title3)
                                        }
                                    }
                                }
                            }
                            .chartYScale(domain: 0...10)
                            .frame(height: 280)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.secondarySystemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                            )
                            .padding(.horizontal)
                        }
                        
                        // 12. LEGENDA MIGLIORATA
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Legend")
                                .font(.headline)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                LegendItem(emoji: "😢", range: "0.0 – 2.0", label: "Very Sad")
                                LegendItem(emoji: "😕", range: "2.0 – 4.0", label: "A Bit Down")
                                LegendItem(emoji: "😐", range: "4.0 – 6.0", label: "Neutral")
                                LegendItem(emoji: "🙂", range: "6.0 – 8.0", label: "Content")
                                LegendItem(emoji: "😄", range: "8.0 – 10", label: "Very Happy")
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                        )
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Charts")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// 13. COMPONENTE PER LA LEGENDA
struct LegendItem: View {
    let emoji: String
    let range: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.title)
            
            Text(range)
                .font(.caption2)
                .fontWeight(.medium)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
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
                value: Double(Int.random(in: 0...10)),
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
