import SwiftUI

struct ChatAIView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var historyStore: HistoryStore
    
    var existingItemID: UUID?
    
    @Binding var temporaryChatHistory: [ChatMessage]
    
    var contextItem: MeasurementHistoryItem?
    
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var isLoading = false
    
    @State private var localMessages: [ChatMessage] = []
    
    private let claudeService = ClaudeService()
    private let primaryGradient = LinearGradient(colors: [Color(hex: "FFA4B1"), Color(hex: "FF1C64")], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    init(existingItemID: UUID? = nil, contextItem: MeasurementHistoryItem? = nil, tempHistory: Binding<[ChatMessage]>? = nil) {
        self.existingItemID = existingItemID
        self.contextItem = contextItem
        self._temporaryChatHistory = tempHistory ?? Binding.constant([])
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Circle())
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Heart Rate")
                            .font(.system(size: 20, weight: .bold))
                        Text("AI")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(primaryGradient)
                    }
                    Spacer()
                    Rectangle().fill(Color.clear).frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.top, 15)
            }
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if localMessages.isEmpty {
                            Text("Hello! I can analyze this specific measurement. How can I help?")
                                .font(.system(size: 17))
                                .foregroundColor(.gray)
                                .padding(.top, 20)
                                .padding(.horizontal, 24)
                        }
                        
                        ForEach(localMessages) { message in
                            if message.isUser {
                                HStack {
                                    Spacer()
                                    Text(message.text)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(primaryGradient)
                                        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight, .bottomLeft]))
                                        .clipShape(RoundedCorner(radius: 4, corners: [.bottomRight]))
                                }
                            } else {
                                Text(message.text)
                                    .font(.system(size: 17))
                                    .foregroundColor(.black)
                                    .lineSpacing(4)
                            }
                        }
                        
                        if isLoading {
                            HStack {
                                ProgressView().tint(Color(hex: "FF1C64"))
                                Text("AI is typing...").font(.caption).foregroundColor(.gray)
                            }
                            .padding(.leading, 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                .onChange(of: localMessages.count) { _ in
                    if let lastId = localMessages.last?.id {
                        withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                    }
                }
            }
            
            VStack(spacing: 0) {
                Divider().opacity(0)
                HStack(spacing: 12) {
                    TextField("Ask about this result...", text: $inputText, axis: .vertical)
                        .focused($isInputFocused)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.gray.opacity(0.15)))
                        .overlay(Capsule().stroke(primaryGradient, lineWidth: isInputFocused || !inputText.isEmpty ? 1.5 : 0))
                        .accentColor(Color(hex: "FF1C64"))
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(!inputText.isEmpty ? AnyShapeStyle(primaryGradient) : AnyShapeStyle(Color.gray.opacity(0.3)))
                            .clipShape(Circle())
                    }
                    .disabled(inputText.isEmpty || isLoading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 12)
            }
            .background(Color.white)
        }
        .navigationBarHidden(true)
        .onTapGesture { isInputFocused = false }
        .onAppear {
            loadInitialMessages()
        }
    }
    
    func loadInitialMessages() {
        if let id = existingItemID,
           let item = historyStore.history.first(where: { $0.id == id }) {
            self.localMessages = item.chatHistory
        }
        else {
            self.localMessages = temporaryChatHistory
        }
        
        if localMessages.isEmpty, let item = contextItem {
             inputText = "Analyze this measurement: \(item.bpm) BPM, Status: \(item.status.rawValue)"
             sendMessage()
        }
    }
    
    func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        let userMsg = ChatMessage(text: inputText, isUser: true)
        appendMessage(userMsg)
        
        let promptText = inputText
        inputText = ""
        isLoading = true
        
        let contextData: String
        if let item = contextItem {
            contextData = """
            FOCUSED MEASUREMENT:
            Date: \(item.formattedDate)
            BPM: \(item.bpm)
            Status: \(item.status.rawValue)
            Mood: \(item.mood ?? "Not set")
            Activity: \(item.activity ?? "Not set")
            """
        } else {
            contextData = "No measurement context provided."
        }
        
        Task {
            do {
                let response = try await claudeService.sendMessage(userMessage: promptText, historyContext: contextData)
                await MainActor.run {
                    let aiMsg = ChatMessage(text: response, isUser: false)
                    appendMessage(aiMsg)
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    appendMessage(ChatMessage(text: "Error: \(error.localizedDescription)", isUser: false))
                    isLoading = false
                }
            }
        }
    }
    
    func appendMessage(_ msg: ChatMessage) {
        withAnimation {
            localMessages.append(msg)
        }
        
        if let id = existingItemID {
            historyStore.updateChatHistory(for: id, newHistory: localMessages)
        }
        
        temporaryChatHistory = localMessages
    }
}
