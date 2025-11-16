# 📉 Nosedive

> **Nosedive** is a modern journaling application for iOS that uses on-device language models (Apple Intelligence) to automatically detect your mood, generate entry summaries, and visualize your emotional trends over time.

## 🌟 Features

* **Intelligent Mood Detection:** Analyzes your text in real-time using the **Natural Language** framework to provide a precise mood score (0-10) and corresponding emoji (e.g., 😢 to 😆).
* **Automatic Summaries:** Utilizes **SystemLanguageModel** (Apple Intelligence/AI) to generate concise, first-person summaries of your journal entries upon saving. Includes a robust local fallback for when the language model is unavailable.
* **Data Visualization:** A dedicated **Charts** view displays your average mood and mood trend (improving, declining, or stable) over customizable weekly or monthly periods.
* **Persistent Storage:** All journal entries are stored reliably using **SwiftData**.
* **Full-Text Search:** Quickly search and filter entries across the journal text, mood score, or generated summary.
* **Distraction-Free Editor:** A dedicated **Add View** provides a clean interface focused on writing, with real-time mood feedback updating as you type.

## ⚙️ Technologies Used

The project is built entirely within the Apple ecosystem, leveraging the latest native frameworks for performance and stability.

* **Platform:** iOS / iPadOS (Deployment Target: 26.0+)
* **Language:** Swift 5.0+
* **UI Framework:** SwiftUI
* **Persistence:** SwiftData
* **Analytics/Charting:** Swift Charts
* **Intelligence/NLP:** NaturalLanguage and FoundationModels (Apple Intelligence APIs)

## 📦 Installation and Setup

To get a local copy of Nosedive up and running, follow these simple steps.

### Prerequisites

* Xcode (Latest stable version is highly recommended)
* An iPhone or iPad running iOS 26.0+ (required for SwiftData and the specific language model APIs used)

### Steps

1.  **Clone the repository:**
    ```bash
    git clone [Your Repository URL]
    cd RepoDemo/MoodDetector
    ```

2.  **Open in Xcode:**
    ```bash
    open MoodDetector.xcodeproj
    ```

3.  **Run the Project:**
    * Select the **MoodDetector** target.
    * Choose a compatible device or simulator (iOS 26.0 or newer).
    * Click the **Run** button (▶) or press `Cmd + R`.

The app will compile, install on the selected device/simulator, and initialize the SwiftData database.

## 💡 Usage

Nosedive features a simple, three-tab navigation interface:

1.  **Home:** View a chronological list of all your journal entries.
2.  **Charts:** Visualize your mood trends over the last week or month.
3.  **Search:** Find specific entries by keywords in the summary, text, or mood.

To create a new entry:

1.  Navigate to the **Home** tab.
2.  Tap the **+** button in the top right corner.
3.  Write about your day. Observe how the real-time score and emoji update as the natural language model analyzes your text.
4.  Tap **Save** (✓) to finalize the entry. The summary will be generated upon saving.

## 📝 License

This project is licensed under the **MIT License**.

See the [LICENSE](LICENSE) file for details.

