import SwiftUI

struct PathWordleView: View {
    let targetPath: String
    @State private var guesses: [String] = []
    @State private var currentGuess = ""
    @State private var isGameWon = false
    @State private var maxGuesses = 6
    @Binding var isPresented: Bool

    let allFolders = [
        "DOCUMENTS", "DOWNLOADS", "PICTURES", "DESKTOP", "MUSIC",
        "VIDEOS", "PROJECTS", "PERSONAL", "ARCHIVE", "BACKUP",
        "WORKSPACE", "LIBRARY", "SHARED", "PUBLIC", "PRIVATE",
        "PHOTOS", "TELEPORTED", "CHAOTIC", "PLAYGROUND", "TEMP"
    ]

    var targetFolder: String {
        let components = targetPath.components(separatedBy: "/")
        return components.last?.uppercased() ?? "UNKNOWN"
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("FIND YOUR FILE")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.orange)

            Text("Your file was teleported!")
                .font(.title3)
                .foregroundColor(.secondary)

            Text("Guess the folder name to reveal its location")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()

            if !isGameWon {
                VStack(spacing: 12) {
                    ForEach(guesses, id: \.self) { guess in
                        GuessRow(guess: guess, target: targetFolder)
                    }

                    ForEach(0..<(maxGuesses - guesses.count), id: \.self) { _ in
                        EmptyGuessRow()
                    }
                }
                .padding()

                HStack {
                    TextField("Type folder name...", text: $currentGuess)
                        .textFieldStyle(.roundedBorder)
                        .textCase(.uppercase)
                        .autocorrectionDisabled()
                        .onSubmit {
                            submitGuess()
                        }

                    Button("GUESS") {
                        submitGuess()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(currentGuess.isEmpty)
                }
                .padding()

                Text("Guesses: \(guesses.count)/\(maxGuesses)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                        ForEach(allFolders, id: \.self) { folder in
                            Button(folder) {
                                currentGuess = folder
                            }
                            .font(.system(size: 10, weight: .semibold))
                            .padding(8)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                            .disabled(guesses.contains(folder))
                            .opacity(guesses.contains(folder) ? 0.3 : 1.0)
                        }
                    }
                }
                .frame(height: 150)
                .padding()
            } else {
                VStack(spacing: 15) {
                    Text("🎉 YOU FOUND IT!")
                        .font(.title.bold())
                        .foregroundColor(.green)

                    Text("Your file is located at:")
                        .font(.headline)

                    Text(targetPath)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .textSelection(.enabled)

                    Button("Close") {
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top)
                }
                .padding()
            }

            if guesses.count >= maxGuesses && !isGameWon {
                VStack(spacing: 15) {
                    Text("😅 GAME OVER")
                        .font(.title.bold())
                        .foregroundColor(.red)

                    Text("The folder was: \(targetFolder)")
                        .font(.headline)

                    Text("Your file is at:")
                        .font(.subheadline)

                    Text(targetPath)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .textSelection(.enabled)

                    Button("Close") {
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .padding(40)
        .frame(width: 600, height: 700)
    }

    func submitGuess() {
        let guess = currentGuess.uppercased().trimmingCharacters(in: .whitespaces)

        guard !guess.isEmpty else { return }
        guard !guesses.contains(guess) else {
            currentGuess = ""
            return
        }

        guesses.append(guess)
        currentGuess = ""

        if guess == targetFolder {
            isGameWon = true
        }
    }
}

struct GuessRow: View {
    let guess: String
    let target: String

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(guess.enumerated()), id: \.offset) { index, char in
                LetterBox(
                    letter: String(char),
                    state: letterState(at: index, char: char)
                )
            }
        }
    }

    func letterState(at index: Int, char: Character) -> LetterState {
        let targetArray = Array(target)

        if index < targetArray.count && targetArray[index] == char {
            return .correct
        }

        if target.contains(char) {
            return .wrongPosition
        }

        return .notInWord
    }
}

struct EmptyGuessRow: View {
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<10, id: \.self) { _ in
                LetterBox(letter: "", state: .empty)
            }
        }
    }
}

struct LetterBox: View {
    let letter: String
    let state: LetterState

    var body: some View {
        Text(letter)
            .font(.system(size: 20, weight: .bold))
            .frame(width: 40, height: 50)
            .background(state.color)
            .foregroundColor(.white)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
            )
    }
}

enum LetterState {
    case empty
    case notInWord
    case wrongPosition
    case correct

    var color: Color {
        switch self {
        case .empty: return Color.gray.opacity(0.2)
        case .notInWord: return Color.gray.opacity(0.6)
        case .wrongPosition: return Color.yellow.opacity(0.8)
        case .correct: return Color.green
        }
    }
}

#Preview {
    PathWordleView(
        targetPath: "/Users/test/Documents/ChaoticPlayground/Teleported/file.txt",
        isPresented: .constant(true)
    )
}
