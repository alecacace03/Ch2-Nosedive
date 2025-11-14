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
    
    // Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Editor state
    @State private var dailyDescription: String = ""
    @FocusState private var isEditorFocused: Bool
    
    // Apple Intelligence language model (availability-checked)
    private var model = SystemLanguageModel.default
    
    // MARK: - Derived State
    
    // Sentiment score derived from the text (as Double, -1...1)
    private var rawScore: Double {
        let scoreString = getSentimentScore(from: dailyDescription) ?? "0.0"
        return Double(scoreString) ?? 0.0
    }
    
    // Normalized score shown to user (0...2)
    private var normalizedScore: Double {
        (rawScore + 1.0) * 5.0
    }
    
    // Emoji derived from the raw score
    private var moodEmoji: String {
        switch rawScore {
        case ..<(-0.6):       return "😢"
        case -0.6..<(-0.2):   return "😕"
        case -0.2..<0.2:      return "😐"
        case 0.2..<0.6:       return "🙂"
        default:              return "😆"
        }
    }
    
    // Readable mood label for accessibility and clarity
    private var moodLabel: String {
        switch rawScore {
        case ..<(-0.6):       return "Very Sad"
        case -0.6..<(-0.2):   return "A Bit Down"
        case -0.2..<0.2:      return "Neutral"
        case 0.2..<0.6:       return "Content"
        default:              return "Very Happy"
        }
    }
    
    // Brief mood description shown under the score
    private var moodDescription: String {
        switch rawScore {
        case ..<(-0.6):
            return "It looks like today feels heavy. Writing can help."
        case -0.6..<(-0.2):
            return "A few things might be weighing on you."
        case -0.2..<0.2:
            return "A balanced day. Not too bad, not too great."
        case 0.2..<0.6:
            return "A good, positive vibe overall."
        default:
            return "A great day! Keep the momentum."
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack{
        ScrollView {
            VStack(spacing: 20) {
                
                // Header Card: Mood overview
                moodHeaderCard
                
                // Tips
                tipCard
                
                // Minimal Editor Card (more space for writing)
                editorCard
                
                
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await saveItem() }
                    } label: {
                        Image(systemName: "checkmark")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                            
                    }
                    .buttonStyle(.glassProminent)
                    
                    .disabled(dailyDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("Save entry")
                    .accessibilityHint("Saves your journal entry with mood analysis")
                    
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button() {
                        dismiss()
                        
                    }label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)

                            
                    }
                }
            }
        }
        .navigationTitle("Diary of the Day")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            isEditorFocused = false
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .animation(.easeInOut(duration: 0.2), value: rawScore)
    }
    }
    
    // MARK: - Cards
    
    private var moodHeaderCard: some View {
        VStack(spacing: 12) {
            // Emoji
            Text(moodEmoji)
                .font(.system(size: 72))
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            
            // Score + Label
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Text(normalizedScore, format: .number.precision(.fractionLength(0)))
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .accessibilityLabel("Mood score")
                        .accessibilityValue("\(normalizedScore, format: .number.precision(.fractionLength(1))) out of 10")
                    
                    Capsule()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(width: 1, height: 24)
                    
                    Text(moodLabel)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .accessibilityLabel("Mood")
                        .accessibilityValue(moodLabel)
                }
                
                Text(moodDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .accessibilityLabel("Mood description")
                    .accessibilityValue(moodDescription)
            }
            .padding(.bottom, 4)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Mood overview")
        .accessibilityHint("Shows your current mood and score based on your text")
    }
    
    // Minimal, distraction-free editor with maximum writing space
    private var editorCard: some View {
        VStack(spacing: 10) {
            
            HStack {
                Spacer()
                Text("\(dailyDescription.count) characters")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Character count")
                    .accessibilityValue("\(dailyDescription.count) characters")
            }
            .padding(.horizontal, 6)
            
            ZStack(alignment: .topLeading) {
                // Background with subtle border
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                    )
                
                // Large, comfortable editor
                TextEditor(text: $dailyDescription)
                    .frame(minHeight: 360, maxHeight: 600)  // much larger writing area
                    .padding(18) // generous padding inside
                    .background(Color.clear)
                    .focused($isEditorFocused)
                    .font(.body) // keep it readable and adaptive
                    .accessibilityLabel("Journal text")
                    .accessibilityHint("Describe your day and how you feel")
                
                // Clean placeholder
                if dailyDescription.isEmpty {
                    Text("Write your thoughts here…")
                        .foregroundColor(Color(UIColor.placeholderText))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 25)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }
            
            // Subtle footer with character count
            
        }
        .padding(2) // tight outer padding to maximize space
    }
    
    private var tipCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb")
                .foregroundStyle(.yellow)
                .font(.title3)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Tip")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("Write naturally. Your mood score updates as you type, and your entry will be summarized when you save.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        
    }
    
    // MARK: - Save
    
    // Saves a new Item using a summary from Apple Intelligence when available, with a safe fallback
    private func saveItem() async {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        
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
            journal: dailyDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            mood: moodEmoji,
            value: normalizedScore,  // Store normalized score (0...2)
            summerize: summary,
            data: Date()
        )
        
        modelContext.insert(newItem)
        generator.notificationOccurred(.success)
        dismiss()
    }
    
    // MARK: - Summarization
    
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
    
    // MARK: - Fallback Summary
    
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
    
    // MARK: - Sentiment
    
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
    AddView()
}
