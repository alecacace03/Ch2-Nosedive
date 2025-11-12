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
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.data) private var items: [Item]
    
    @State private var selectedPeriod: ChartPeriod = .weekly
    
    enum ChartPeriod: String, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
    }
    
    // Funzione per ottenere l'emoticon in base al valore
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
    
    // Filtra gli items in base al periodo selezionato
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
        NavigationStack{
            VStack {
                // Selettore periodo
                Picker("Periodo", selection: $selectedPeriod.animation(.easeInOut)) {
                    ForEach(ChartPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                Text("Andamento dell'umore")
                    .font(.headline)
                
                if filteredItems.isEmpty {
                    Text("Nessun dato disponibile per questo periodo")
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    Chart {
                        ForEach(filteredItems, id: \.self) { item in
                            LineMark(
                                x: .value("Data", item.data, unit: .day),
                                y: .value("Valore", item.value)
                            )
                            .foregroundStyle(.blue)
                            .interpolationMethod(.catmullRom)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            
                            PointMark(
                                x: .value("Data", item.data, unit: .day),
                                y: .value("Valore", item.value)
                            )
                            .foregroundStyle(.blue)
                            .symbolSize(100)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: selectedPeriod == .weekly ? .day : .day, count: selectedPeriod == .weekly ? 1 : 5)) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: selectedPeriod == .weekly ? .dateTime.day().month() : .dateTime.day().month())
                        }
                    }
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
                    .chartYScale(domain: 0...2)
                    .frame(height: 300)
                    .padding()
                    
                    // Legenda emoticon
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Legenda:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 0) {
                            Label("😢 0-0.4", systemImage: "")
                            Label("😕 0.4-0.8", systemImage: "")
                            Label("😐 0.8-1.2", systemImage: "")
                            Label("🙂 1.2-1.6", systemImage: "")
                            Label("😄 1.6-2", systemImage: "")
                        }
                        .font(.caption)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer()
                
            }.navigationTitle("Charts")
        }
    }
}
#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Item.self, configurations: config)
        
        // Aggiungi dati di esempio
        let calendar = Calendar.current
        for i in 0..<30 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let item = Item(
                journal: "Giornale \(i)",
                mood: "Felice",
                value: Double.random(in: 0...2),
                summerize: "Sommario",
                data: date
            )
            container.mainContext.insert(item)
        }
        
        return ChartsView()
            .modelContainer(container)
    } catch {
        return Text("Errore: \(error.localizedDescription)")
    }
}
