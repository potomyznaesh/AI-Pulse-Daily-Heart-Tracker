import SwiftUI

struct ResultFlowView: View {
    @EnvironmentObject var historyStore: HistoryStore
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("isPremiumUser") private var isPremiumUser = false
    
    @State private var currentSessionChat: [ChatMessage] = []
    @State private var tempChatHistory: [ChatMessage] = []
    
    let result: MeasurementResult
    var onMeasureAgain: () -> Void
    var onAskAI: () -> Void
    
    @State private var step = 1
    @State private var selectedMood: String? = nil
    @State private var selectedActivity: String? = nil
    
    private let buttonGradient = AppTheme.Gradients.primary
    
    private let aiButtonGradient = AppTheme.Gradients.primary
    
    private var statusColor: Color {
        switch result.status {
        case .low: return AppTheme.Colors.lowBPM
        case .normal: return AppTheme.Colors.normalBPM
        case .high: return AppTheme.Colors.highBPM
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            Capsule()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            
            ZStack {
                if step == 1 {
                    resultStep
                        .locked(isLocked: Binding(
                            get: { !isPremiumUser },
                            set: { _ in }
                        ))
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                } else {
                    moodStep
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            }
            .animation(.easeInOut(duration: 0.35), value: step)
            .padding(.top, 28)
            
            Spacer(minLength: 0)
            
            if isPremiumUser {
                VStack(spacing: 0) {
                    Divider()
                        .padding(.bottom, 12)
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            if step == 1 {
                                onMeasureAgain()
                            } else {
                                withAnimation { step = 1 }
                            }
                        }) {
                            HStack {
                                if step == 1 {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Measure again")
                                } else {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                            }
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Capsule())
                        }
                        
                        Button(action: {
                            if step == 1 {
                                withAnimation { step = 2 }
                            } else {
                                historyStore.addMeasurement(
                                    bpm: result.bpm,
                                    resultStatus: result.status,
                                    mood: selectedMood,
                                    activity: selectedActivity,
                                    chatHistory: tempChatHistory
                                )
                                dismiss()
                            }
                        }) {
                            HStack {
                                if step == 1 {
                                    Text("Next step")
                                } else {
                                    Image(systemName: "checkmark")
                                    Text("Save result")
                                }
                            }
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(buttonGradient)
                            .clipShape(Capsule())
                        }
                        .disabled(step == 2 && (selectedMood == nil || selectedActivity == nil))
                        .opacity(step == 2 && (selectedMood == nil || selectedActivity == nil) ? 0.6 : 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(Color.white)
        .clipShape(RoundedCorner(radius: 32, corners: [.topLeft, .topRight]))
        .animation(.easeInOut, value: isPremiumUser)
    }
    
    private var resultStep: some View {
        VStack {
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 8) {
                    Text("\(result.bpm)")
                        .font(.system(size: 85, weight: .bold))
                        .foregroundColor(.black)
                    
                    VStack(spacing: 6) {
                        GradientHeartIcon()
                        
                        Text("BPM")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 8)
                }
                
                Spacer()
                
                NavigationLink(destination: ChatAIView(
                    contextItem: MeasurementHistoryItem(
                        bpm: result.bpm,
                        status: result.status,
                        mood: selectedMood,
                        activity: selectedActivity
                    ),
                    tempHistory: $tempChatHistory
                )) {
                    HStack(spacing: 8) {
                        Text("Ask AI")
                            .font(.system(size: 18, weight: .semibold))
                        Image("askai")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                    .foregroundStyle(aiButtonGradient)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.white.opacity(0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(Capsule())
                    )
                    .overlay(
                        Capsule()
                            .stroke(aiButtonGradient, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
                }
            }
            .padding(.horizontal, 28)
            
            Spacer(minLength: 30)
            
            VStack(spacing: 8) {
                Text(result.status.rawValue)
                    .font(.system(size: 38, weight: .heavy))
                    .foregroundColor(statusColor)
                Text(result.date)
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }
            .multilineTextAlignment(.center)
            
            Spacer(minLength: 35)
            
            VStack(spacing: 14) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.gray.opacity(0.25),
                                    AppTheme.Colors.normalBPM.opacity(0.3),
                                    AppTheme.Colors.normalBPM,
                                    AppTheme.Colors.moodYellow,
                                    AppTheme.Colors.highBPM
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 28)
                    
                    GeometryReader { geo in
                        let x = thumbPosition(width: geo.size.width)
                        
                        Circle()
                            .fill(statusColor)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 5)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 3)
                            .position(x: x, y: geo.size.height / 2)
                    }
                }
                .frame(height: 28)
                .padding(.horizontal, 16)
                
                HStack {
                    Text("Low")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("Normal")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundColor(AppTheme.Colors.normalBPM)
                    Spacer()
                    Text("High")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundColor(AppTheme.Colors.highBPM)
                }
                .padding(.horizontal, 28)
            }
            
            Spacer(minLength: 20)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var moodStep: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                HStack(alignment: .top) {
                    Text("\(result.bpm)")
                        .font(.system(size: 85, weight: .bold))
                        .foregroundColor(.black)
                    VStack(alignment: .leading, spacing: 4) {
                        GradientHeartIcon(width: 28, height: 28)
                        Text("BPM")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("How is your mood?")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.black)
                
                HStack(spacing: 12) {
                    ForEach(MoodOption.allCases, id: \.self) { mood in
                        let isSelected = (selectedMood == mood.rawValue)
                        
                        VStack(spacing: 6) {
                            Image(mood.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            
                            Text(mood.rawValue)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSelected ? AppTheme.Colors.primary.opacity(0.1) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isSelected ? AppTheme.Colors.primary : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedMood = mood.rawValue
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("What have you been up to?")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
                
                HStack(spacing: 12) {
                    ForEach(ActivityOption.allCases, id: \.self) { act in
                        let isSelected = (selectedActivity == act.rawValue)
                        
                        VStack(spacing: 6) {
                            Image(act.image)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(AppTheme.Colors.primary)
                            
                            Text(act.rawValue)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSelected ? Color(hex: "FF1C64").opacity(0.1) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isSelected ? Color(hex: "FF1C64") : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedActivity = act.rawValue
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func remap(_ value: CGFloat, fromLow: CGFloat, fromHigh: CGFloat, toLow: CGFloat, toHigh: CGFloat) -> CGFloat {
        let fromPercentage = (value - fromLow) / (fromHigh - fromLow)
        let toValue = (fromPercentage * (toHigh - toLow)) + toLow
        return toValue
    }
    
    private func thumbPosition(width: CGFloat) -> CGFloat {
        let bpm = CGFloat(result.bpm)
        let normalized: CGFloat
        
        let lowAnchor: CGFloat = 0.15
        let normalStart: CGFloat = 0.35
        let normalEnd: CGFloat = 0.65
        let highAnchor: CGFloat = 0.85
        
        switch result.status {
        case .low:
            normalized = remap(bpm, fromLow: 40, fromHigh: 60, toLow: lowAnchor, toHigh: normalStart)
        case .normal:
            normalized = remap(bpm, fromLow: 61, fromHigh: 100, toLow: normalStart, toHigh: normalEnd)
        case .high:
            normalized = remap(bpm, fromLow: 101, fromHigh: 180, toLow: normalEnd, toHigh: highAnchor)
        }
        
        let clampedNormalized = max(lowAnchor, min(highAnchor, normalized))
        let padding: CGFloat = 20
        return (width - padding * 2) * clampedNormalized + padding
    }
}

enum MoodOption: String, CaseIterable {
    case Crying, Sad, Irritated, Normal, Happy
    var image: String { "mood_\(rawValue.lowercased())" }
}

enum ActivityOption: String, CaseIterable {
    case Sleep, Morning, Sitting, Exercising, Jogging
    var image: String { "act_\(rawValue.lowercased())" }
}
