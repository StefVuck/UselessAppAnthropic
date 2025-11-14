import SwiftUI
import Speech

struct DictationLoginView: View {
    @StateObject private var dictationService = DictationService()
    @State private var currentField: LoginField = .username
    @State private var spokenUsername = ""
    @State private var spokenPassword = ""
    @State private var attemptCount = 0
    @State private var showBypassOption = false
    @State private var instructionMessage = "Please speak your username clearly"
    @State private var isAuthenticated = false
    @State private var pulseAnimation = false
    @State private var shakeOffset: CGFloat = 0
    @State private var showGoodBoyPopup = false

    // Target credentials (for demo)
    private let targetUsername = "test"
    private let targetPassword = "test"

    enum LoginField {
        case username, password
    }

    var body: some View {
        ZStack {
            // Professional corporate background
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("Secure Voice Authentication")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("Enterprise-Grade Security")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .italic()
                }
                .padding(.top, 40)

                // Attempt Counter
                Text("Attempt \(attemptCount) of ∞")
                    .font(.caption)
                    .foregroundColor(attemptCount > 10 ? .red : .gray)
                    .fontWeight(attemptCount > 10 ? .bold : .regular)

                Spacer()

                // Microphone Icon with Pulse Animation
                ZStack {
                    // Pulse rings
                    if dictationService.isListening {
                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 3)
                            .frame(width: 120, height: 120)
                            .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                            .opacity(pulseAnimation ? 0 : 1)

                        Circle()
                            .stroke(Color.blue.opacity(0.2), lineWidth: 3)
                            .frame(width: 120, height: 120)
                            .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                            .opacity(pulseAnimation ? 0 : 0.5)
                    }

                    // Microphone icon
                    Image(systemName: dictationService.isListening ? "mic.fill" : "mic.slash.fill")
                        .font(.system(size: 50))
                        .foregroundColor(dictationService.isListening ? .blue : .gray)
                        .frame(width: 100, height: 100)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 10)
                        )
                }
                .offset(x: shakeOffset)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        pulseAnimation = true
                    }
                }

                // Volume Meter
                if dictationService.isListening {
                    VolumeMeterView(audioLevel: dictationService.audioLevel)
                        .frame(height: 30)
                        .padding(.horizontal, 40)
                }

                // Instructions
                Text(instructionMessage)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)

                // Current Field Display
                VStack(spacing: 15) {
                    // Username Field
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Username")
                            .font(.caption)
                            .foregroundColor(.gray)

                        HStack {
                            Text(spokenUsername.isEmpty ? "Speak to enter..." : spokenUsername)
                                .foregroundColor(spokenUsername.isEmpty ? .gray : .white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(currentField == .username ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                    }

                    // Password Field
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Password")
                            .font(.caption)
                            .foregroundColor(.gray)

                        HStack {
                            Text(spokenPassword.isEmpty ? "Speak to enter..." : String(repeating: "•", count: spokenPassword.count))
                                .foregroundColor(spokenPassword.isEmpty ? .gray : .white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(currentField == .password ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }
                .padding(.horizontal, 40)

                // Live Transcription
                if dictationService.isListening {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Hearing:")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text(dictationService.transcribedText.isEmpty ? "..." : dictationService.transcribedText)
                            .font(.body)
                            .foregroundColor(.cyan)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.cyan.opacity(0.1))
                            )
                    }
                    .padding(.horizontal, 40)
                }

                Spacer()

                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: handleMicrophoneButton) {
                        HStack {
                            Image(systemName: dictationService.isListening ? "stop.circle.fill" : "mic.circle.fill")
                            Text(dictationService.isListening ? "Stop Listening" : "Start Dictation")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 300)
                        .background(dictationService.isListening ? Color.red : Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(dictationService.authorizationStatus != .authorized)

                    if !dictationService.isListening && !spokenUsername.isEmpty && !spokenPassword.isEmpty {
                        Button(action: attemptLogin) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Attempt Login")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 300)
                            .background(Color.green)
                            .cornerRadius(10)
                        }
                    }

                    // Bypass option (hidden until 5 attempts)
                    if showBypassOption {
                        Button(action: {
                            if dictationService.transcribedText.lowercased().contains("give up") {
                                bypassLogin()
                            } else {
                                instructionMessage = "Say 'I give up' to bypass"
                                dictationService.startDictation()
                            }
                        }) {
                            Text("Bypass (say 'I give up')")
                                .font(.caption)
                                .foregroundColor(.yellow)
                                .underline()
                        }
                    }

                    // Debug skip button
                    Button(action: {
                        showGoodBoyPopup = true
                    }) {
                        Text("DEBUG: Skip Login")
                            .font(.caption2)
                            .foregroundColor(.red.opacity(0.6))
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .frame(minWidth: 600, minHeight: 800)
        .onChange(of: dictationService.authorizationStatus) { _, newStatus in
            if newStatus != .authorized {
                instructionMessage = "Please grant microphone and speech recognition permissions"
            }
        }
        .preferredColorScheme(.dark)
        .overlay(
            Group {
                if showGoodBoyPopup {
                    GoodBoyPopup(isPresented: $showGoodBoyPopup, onDismiss: {
                        isAuthenticated = true
                    })
                }
            }
        )
        .sheet(isPresented: $isAuthenticated) {
            ContentView()
                .frame(minWidth: 600, minHeight: 500)
        }
    }

    // MARK: - Actions

    func handleMicrophoneButton() {
        if dictationService.isListening {
            dictationService.stopDictation()
            // Capture the transcribed text
            if currentField == .username {
                spokenUsername = dictationService.transcribedText.trimmingCharacters(in: .whitespacesAndNewlines)
                currentField = .password
                instructionMessage = getPasswordInstruction()
            } else {
                spokenPassword = dictationService.transcribedText.trimmingCharacters(in: .whitespacesAndNewlines)
                instructionMessage = "Ready to attempt login"
            }
        } else {
            dictationService.resetTranscription()
            dictationService.startDictation()

            if currentField == .username {
                instructionMessage = getUsernameInstruction()
            } else {
                instructionMessage = getPasswordInstruction()
            }
        }
    }

    func attemptLogin() {
        attemptCount += 1

        // Check if credentials match (very loosely)
        let usernameMatch = spokenUsername.lowercased().replacingOccurrences(of: " ", with: "") == targetUsername
        let passwordMatch = spokenPassword.lowercased().replacingOccurrences(of: " ", with: "") == targetPassword

        if usernameMatch && passwordMatch {
            instructionMessage = "Authentication successful! Welcome."
            showGoodBoyPopup = true
        } else {
            // Failed attempt
            triggerShakeAnimation()

            // Update message based on attempt count
            instructionMessage = getFailureMessage()

            // Show bypass after 5 attempts
            if attemptCount >= 5 {
                showBypassOption = true
            }

            // Reset for retry
            currentField = .username
            spokenUsername = ""
            spokenPassword = ""
        }
    }

    func bypassLogin() {
        instructionMessage = "Fine. You win. Welcome."
        showGoodBoyPopup = true
    }

    func triggerShakeAnimation() {
        withAnimation(.easeInOut(duration: 0.1).repeatCount(4, autoreverses: true)) {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            shakeOffset = 0
        }
    }

    // MARK: - Dynamic Messages

    func getUsernameInstruction() -> String {
        switch attemptCount {
        case 0: return "Please speak your username clearly"
        case 1: return "Speak your username (try speaking more clearly this time)"
        case 2: return "Username. Speak. Now. Enunciate."
        case 3...5: return "Are you even trying? Say your username."
        case 6...10: return "This is painful. Just say 'test' for username."
        default: return "I'm begging you. Username is 'test'."
        }
    }

    func getPasswordInstruction() -> String {
        switch attemptCount {
        case 0: return "Now speak your password"
        case 1: return "Speak your password (remember: no keyboard)"
        case 2: return "Password. Use your voice. We've been over this."
        case 3...5: return "JUST. SAY. THE. PASSWORD."
        case 6...10: return "The password is literally just 'test'"
        default: return "Say 'test'. That's it. Just 'test'."
        }
    }

    func getFailureMessage() -> String {
        switch attemptCount {
        case 1: return "Authentication failed. Please try again."
        case 2: return "Still not quite right. Speak more clearly."
        case 3: return "Really? Try again. Enunciate."
        case 4: return "I heard '\(spokenUsername)' and '\(spokenPassword)'. Is that what you meant?"
        case 5: return "This is attempt #5. Maybe check if your microphone works?"
        case 6...8: return "Hint: Both username and password are 'test'"
        case 9...12: return "LITERALLY just say 'test' twice."
        default: return "I have lost all faith in humanity."
        }
    }
}

// MARK: - Volume Meter Component

struct VolumeMeterView: View {
    let audioLevel: Float
    private let barCount = 20

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor(for: index))
                    .frame(width: 8)
                    .opacity(isBarActive(index: index) ? 1.0 : 0.3)
            }
        }
        .padding(.vertical, 5)
    }

    func isBarActive(index: Int) -> Bool {
        let normalizedLevel = min(audioLevel * 50, 1.0) // Scale up audio level
        let activeBarCount = Int(normalizedLevel * Float(barCount))
        return index < activeBarCount
    }

    func barColor(for index: Int) -> Color {
        let ratio = Float(index) / Float(barCount)
        if ratio < 0.5 {
            return .green
        } else if ratio < 0.8 {
            return .yellow
        } else {
            return .red
        }
    }
}

// MARK: - Good Boy Popup

struct GoodBoyPopup: View {
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissPopup()
                }

            // Popup content
            VStack(spacing: 30) {
                // "GOOD BOY" text
                Text("GOOD BOY")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)

                // John Pork image
                if let nsImage = NSImage(named: "John_Pork") {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 400, maxHeight: 400)
                        .cornerRadius(20)
                        .shadow(color: .white.opacity(0.3), radius: 20)
                } else {
                    Text("Image not found")
                        .foregroundColor(.red)
                }

                // Dismiss button
                Button(action: dismissPopup) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black)
                    .shadow(color: .white.opacity(0.2), radius: 30)
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    func dismissPopup() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.8
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPresented = false
            onDismiss()
        }
    }
}

#Preview {
    DictationLoginView()
}
