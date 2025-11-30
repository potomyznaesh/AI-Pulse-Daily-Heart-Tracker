import Foundation
import NaturalLanguage

class ClaudeService {
    
    private let apiKey = "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"
    private let url = URL(string: "https://api.anthropic.com/v1/messages")!
    
    private func detectLanguage(from text: String) -> String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        if let lang = recognizer.dominantLanguage {
            return lang.rawValue
        }
        
        return "en"
    }

    private func systemPrompt(userLanguage: String?) -> String {

        let deviceLang = Locale.current.language.languageCode?.identifier ?? "en"

        let finalLanguage = userLanguage ?? deviceLang

        return """
        You are a helpful AI analyst for the "Heart Rate" app.
        Your goal is to interpret the user's heart rate history based ONLY on the provided data.

        RULES:
        1. Be concise, warm, and direct.
        2. Do not start with disclaimers.
        3. If you mention limits, say: "I analyze your data solely within this app."
        4. Only recommend a doctor if values are critically dangerous.
        5. LANGUAGE: ALWAYS respond in: \(finalLanguage)
        """
    }
    
    func sendMessage(userMessage: String, historyContext: String) async throws -> String {
        
        print("\n--- 🚀 [ClaudeService] START REQUEST ---")

        let userLang = detectLanguage(from: userMessage)
        print("🌐 Detected user language: \(userLang)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let fullContent = """
        \(historyContext)

        USER QUESTION:
        \(userMessage)
        """
        
        let body: [String: Any] = [
            "model": "claude-3-haiku-20240307",
            "max_tokens": 1024,
            "system": systemPrompt(userLanguage: userLang == "und" ? nil : userLang),
            "messages": [
                ["role": "user", "content": fullContent]
            ]
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData

        print("📡 Sending to API...")
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            print("❌ [Error]: Server returned non-200")
            if let err = String(data: data, encoding: .utf8) { print(err) }
            throw URLError(.badServerResponse)
        }

        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let content = json["content"] as? [[String: Any]],
           let text = content.first?["text"] as? String {

            print("🎉 Parsed \(text.count) chars")
            return text
        }

        return "Parsing error"
    }
}
