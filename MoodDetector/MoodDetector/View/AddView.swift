//
//  AddView.swift
//  MoodDetector
//
//  Created by Alessandro Cacace on 06/11/25.
//

import SwiftUI
import NaturalLanguage
import FoundationModels
import SwiftData

struct AddView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var dailyDescription: String = ""
    let placeholder = "What's on your mind?"
    @FocusState private var isEditorFocused: Bool
    
    private var score: Double {
           let scoreString = getSentimentScore(from: dailyDescription) ?? "0.0"
           return Double(scoreString) ?? 0.0
       }
    
    private var moodEmoji: String {
            switch score {
            case ..<(-0.6):
                return "😢"
            case -0.6..<(-0.2):
                return "😕"
            case -0.2..<0.2:
                return "😐"
            case 0.2..<0.6:
                return "🙂"
            default: // Covers 0.6 and above
                return "😆"
            }
        }
    
    private var model = SystemLanguageModel.default
    
    var body: some View {
        
        
            ScrollView{
                VStack{
                    
                    ZStack{
                        
                       TextEditor(text: $dailyDescription)
                        // 3. Applica modificatori per stile e dimensione
                            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 300)// Imposta un'altezza minima
                            .scrollContentBackground(.hidden)
                            .background(Color(.secondarySystemBackground))
                            .focused($isEditorFocused)
                            .padding(5)
                            
                        

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
                        
                    
                   
                        
                Text(score + 1, format: .number.precision(.fractionLength(1)))
                                    
                    
                Text(moodEmoji)
                        .font(.system(size: 70))
                        .padding()
                        
                    
                        
                  
                    
                }.toolbar {
                        
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button("Save") {
                                            Task {
                                                    await saveItem()
                                                                    }
                                        }
                                        // Disable save button if there is no text
                                        .disabled(dailyDescription.isEmpty)
                                    }
                    }
                    
            }.navigationTitle("Diary of the day")
                .navigationBarTitleDisplayMode(.large)
                .onTapGesture {
                
                isEditorFocused = false
            }
                .ignoresSafeArea(.keyboard, edges: .bottom)
        
    }
    
    private func saveItem() async{
        
        var summary: String = createSimpleSummary(from: dailyDescription)
        
        switch model.availability {
            
            
                case .available:
                    // Show your intelligence UI.
            do{
                summary = try await summarizeText(dailyDescription)
            }catch{
                // Fallback to simple summary on error
                summary = createSimpleSummary(from: dailyDescription)
                print("Errore durante il riassunto: \(error.localizedDescription)")
            }
            
                case .unavailable(.deviceNotEligible):
                    // Show an alternative UI.
                summary = createSimpleSummary(from: dailyDescription)
                case .unavailable(.appleIntelligenceNotEnabled):
                    // Ask the person to turn on Apple Intelligence.
                summary = createSimpleSummary(from: dailyDescription)
                case .unavailable(.modelNotReady):
                    // The model isn't ready because it's downloading or because of other system reasons.
                summary = createSimpleSummary(from: dailyDescription)
                case .unavailable(_):
                    // The model is unavailable for an unknown reason.
                summary = createSimpleSummary(from: dailyDescription)
                }
        
            // Create the new Item
            let newItem = Item(
                journal: dailyDescription,
                mood: moodEmoji,
                value: score + 1, // Storing score as an Int (e.g., -6, 0, 8)
                summerize: summary, // You can use FoundationModels here later
                data: Date()
            )
            
            // Insert it into the context
            modelContext.insert(newItem)
            
            // Go back to the previous screen
            dismiss()
        }
    
    private func summarizeText(_ text: String) async throws -> String {
        
        let tagger = NSLinguisticTagger(tagSchemes: [.language], options: 0)
        tagger.string = text
        let detectedLanguage = tagger.dominantLanguage
        
        let instructions : String
        
        let prompt : String
        
        let instructionsEn = "Summarize the text in one concise, natural sentence, without mentioning the text or author or the writer, only content in first person. Never include phrases like “This text,” “This user,” or “The following describes.” NEVER explain, apologize, or mention context. If the text is short, incomplete, or unclear, infer a plausible short summary rather than stating it's too short."
        
        let instructionsIt = "Riassumi il testo in un'unica frase concisa e naturale, senza riferimenti al testo o all'autore o allo scrittore, solo contenuto in prima persona. Non includere mai frasi come Questo testo , Questo utente o Quanto segue descrive. MAI spiegare, scusarti o menzionare il contesto. Se il testo è breve, incompleto o poco chiaro, deduci un breve riassunto plausibile anziché affermare che è troppo breve."


            
        let promptEn = "\(text)"
        
        let promptIt = "\(text)"
        
        if detectedLanguage == "it" {
            instructions = instructionsIt
        } else {
            instructions = instructionsEn
        }
        
        if detectedLanguage == "it" {
            prompt = promptIt
        } else {
            prompt = promptEn
        }
        
        let session = LanguageModelSession(instructions: instructions)
        
        let response = try await session.respond(to: prompt)
        return response.content
        }
    
    private func createSimpleSummary(from text: String) -> String {
            
            // Pulisce il testo da spazi bianchi iniziali/finali
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Cerca il primo punto, che di solito segna la fine di una frase.
            if let firstSentenceEnd = trimmedText.firstIndex(of: ".") {
                // Estrae la sottostringa fino al punto (incluso)
                let firstSentence = trimmedText[...firstSentenceEnd]
                return String(firstSentence)
                
            } else {
                // Non c'è un punto? Prendi le prime 100 parole
                // o semplicemente tronca il testo.
                let words = trimmedText.split(separator: " ")
                if words.count > 7 {
                    let firstSeven = words.prefix(7).joined(separator: " ") // Prendi le prime 7 parole e le unisci
                        return firstSeven + "..."
                } else {
                    
                    return trimmedText
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
}

#Preview {
    AddView()
}
