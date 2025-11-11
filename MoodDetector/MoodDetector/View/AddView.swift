//
//  AddView.swift
//  MoodDetector
//
//  Created by Alessandro Cacace on 06/11/25.
//

import SwiftUI
import NaturalLanguage
import FoundationModels

struct AddView: View {
    @State private var dailyDescription: String = ""
    let placeholder = "What's on your mind?"
    @State private var showingScore = false
    @FocusState private var isEditorFocused: Bool
    
    var body: some View {
        
        
            ScrollView{
                VStack{
                    
                    ZStack{
                        
                        TextEditor(text: $dailyDescription)
                        // 3. Applica modificatori per stile e dimensione
                            .frame(width: 350, height: 300)// Imposta un'altezza minima
                            .scrollContentBackground(.hidden)
                            .background(Color(.secondarySystemBackground))
                            .focused($isEditorFocused)
                        
                        if dailyDescription.isEmpty {
                            Text(placeholder)
                                .foregroundColor(Color(UIColor.placeholderText))
                            
                                .allowsHitTesting(false)
                            
                        }
                        
                    }
                    .padding()
                    
                    Text("Caracters: \(dailyDescription.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    
                    
                   Text("MOOD SCORE:")
                        .padding(.top, 50)
                        .padding(.bottom,20)
                        .font(.headline)
                        .foregroundColor(.primary)
                        
                    
                   
                        
                        let score = Double(getSentimentScore(from: dailyDescription) ?? "0.0") ?? 0.0
                        Text(score, format: .number.precision(.fractionLength(1)))
                    if score < -0.6 {
                        
                        Text("😡")
                            .font(.system(size: 70))
                            .padding()
                    }else if score >= -0.6 && score < -0.2 {
                        Text("😔")
                            .font(.system(size: 70))
                            .padding()
                        
                    }else if score >= -0.2 && score < 0.2 {
                        
                        Text("😐")
                            .font(.system(size: 70))
                            .padding()
                    }else if score >= 0.2 && score < 0.6 {
                        
                        Text("😄")
                            .font(.system(size: 70))
                            .padding()
                    }else if score > 0.6 {
                        Text("😆")
                            .font(.system(size: 70))
                            .padding()
                    }
                        
                    
                        
                  
                    
                }.toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer() // Push to the right
                            Button("Done") {
                                isEditorFocused = false
                            }
                        }
                    }
                    
            }.navigationTitle("Diary of the day")
                .navigationBarTitleDisplayMode(.large)
                .onTapGesture {
                
                isEditorFocused = false
            }
        
    }
}

func getSentimentScore(from text: String) -> String? {
    
    // 1.
    let tagger = NLTagger(tagSchemes: [.tokenType, .sentimentScore])
    tagger.string = text
    var detectedSentiment: String?
    
    // 2.
    tagger.enumerateTags(in: text.startIndex ..< text.endIndex,
                         unit: .paragraph,
                         scheme: .sentimentScore, options: []) { sentiment, _ in
        
        if let sentimentScore = sentiment {
            detectedSentiment = sentimentScore.rawValue
        }
        
        return true
    }
    
    return detectedSentiment
}





#Preview {
    AddView()
}
