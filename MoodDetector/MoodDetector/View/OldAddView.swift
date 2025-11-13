//
//  OldAddView.swift
//  MoodDetector
//
//  Created by Alessandro Cacace on 13/11/25.
//

import SwiftUI
import NaturalLanguage
import FoundationModels
import SwiftData

struct OldAddView: View {
    
    // Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Editor state
    @State private var dailyDescription: String = ""
    let placeholder = "What's on your mind?"
    @FocusState private var isEditorFocused: Bool
    
    // Sentiment score derived from the text (as Double)
    private var score: Double {
        let scoreString = getSentimentScore(from: dailyDescription) ?? "0.0"
        return Double(scoreString) ?? 0.0
    }
    
    // Emoji derived from the score
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
        default:
            return "😆"
        }
    }
    
    // Apple Intelligence language model (availability-checked)
    private var model = SystemLanguageModel.default
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    // Main text editor
                    TextEditor(text: $dailyDescription)
                        .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 300)
                        .scrollContentBackground(.hidden)
                        .background(Color(.secondarySystemBackground))
                        .focused($isEditorFocused)
                        .padding(5)
                    
                    // Placeholder when empty
                    if dailyDescription.isEmpty {
                        Text(placeholder)
                            .foregroundColor(Color(UIColor.placeholderText))
                            .allowsHitTesting(false)
                    }
                }
                .padding()
                
                // Character count
                Text("Characters: \(dailyDescription.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Mood score and emoji preview
                Text("MOOD SCORE:")
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Show score normalized to 0...2 (original score is roughly -1...1)
                Text(score + 1, format: .number.precision(.fractionLength(1)))
                
                Text(moodEmoji)
                    .font(.system(size: 70))
                    .padding()
            }
            .toolbar {
                // Save button (disabled if editor is empty)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveItem()
                        }
                    }
                    .disabled(dailyDescription.isEmpty)
                }
            }
        }
        .navigationTitle("Diary of the day")
        .navigationBarTitleDisplayMode(.large)
        .onTapGesture {
            // Dismiss keyboard when tapping outside the editor
            isEditorFocused = false
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    // Saves a new Item using a summary from Apple Intelligence when available, with a safe fallback
    private func saveItem() async {
        var summary: String = createSimpleSummary(from: dailyDescription)
        
        switch model.availability {
        case .available:
            // Try summarization via Apple Intelligence
            do {
                summary = try await summarizeText(dailyDescription)
            } catch {
                // Fallback to simple summary on error
                summary = createSimpleSummary(from: dailyDescription)
                print("Error during summarization: \(error.localizedDescription)")
            }
        case .unavailable(.deviceNotEligible),
             .unavailable(.appleIntelligenceNotEnabled),
             .unavailable(.modelNotReady),
             .unavailable(_):
            // Fallbacks for all unavailable cases
            summary = createSimpleSummary(from: dailyDescription)
        }
        
        // Create and insert the new item
        let newItem = Item(
            journal: dailyDescription,
            mood: moodEmoji,
            value: score + 1,  // Store normalized score (0...2)
            summerize: summary,
            data: Date()
        )
        
        modelContext.insert(newItem)
        dismiss()
    }
    
    // Summarizes text using LanguageModelSession with language-aware instructions
    private func summarizeText(_ text: String) async throws -> String {
        let tagger = NSLinguisticTagger(tagSchemes: [.language], options: 0)
        tagger.string = text
        let detectedLanguage = tagger.dominantLanguage
        
        let instructionsEn = "Summarize the text in one concise, natural sentence, in first person only. Do not mention the text, author, or writer. Never include phrases like “This text,” “This user,” or “The following describes.” Do not explain, apologize, or mention context. If the text is short or unclear, infer a plausible short summary."
        let instructionsIt = "Riassumi il testo in un'unica frase concisa e naturale, solo in prima persona. Non menzionare il testo, l'autore o lo scrittore. Non includere frasi come “Questo testo”, “Questo utente” o “Quanto segue descrive”. Non spiegare, non scusarti e non menzionare il contesto. Se il testo è breve o poco chiaro, deduci un breve riassunto plausibile."
        
        let instructions = (detectedLanguage == "it") ? instructionsIt : instructionsEn
        let prompt = text
        
        let session = LanguageModelSession(instructions: instructions)
        let response = try await session.respond(to: prompt)
        return response.content
    }
    
    // Simple, local summary fallback (first sentence or first 7 words)
    private func createSimpleSummary(from text: String) -> String {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let firstSentenceEnd = trimmedText.firstIndex(of: ".") {
            let firstSentence = trimmedText[...firstSentenceEnd]
            return String(firstSentence)
        } else {
            let words = trimmedText.split(separator: " ")
            if words.count > 7 {
                let firstSeven = words.prefix(7).joined(separator: " ")
                return firstSeven + "..."
            } else {
                return trimmedText
            }
        }
    }
    
    // Returns the sentiment score as a String from -1.0 (negative) to 1.0 (positive)
    func getSentimentScore(from text: String) -> String? {
        let tagger = NLTagger(tagSchemes: [.tokenType, .sentimentScore])
        tagger.string = text
        var detectedSentiment: String?
        
        tagger.enumerateTags(
            in: text.startIndex ..< text.endIndex,
            unit: .paragraph,
            scheme: .sentimentScore,
            options: []
        ) { sentiment, _ in
            if let sentimentScore = sentiment {
                detectedSentiment = sentimentScore.rawValue
            }
            return true
        }
        
        return detectedSentiment
    }
}

#Preview {
    OldAddView()
}
