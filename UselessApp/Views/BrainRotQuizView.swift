import SwiftUI

struct BrainRotQuizView: View {
    @Binding var isPresented: Bool
    let onPass: () -> Void
    let onFail: () -> Void

    @State private var currentQuestion = 0
    @State private var selectedAnswers: [Int] = []
    @State private var showResult = false
    @State private var quizPassed = false

    let questions = [
        Question(
            text: "What does \"rizz\" refer to?",
            options: [
                "Charisma or charm",
                "The fizzy foam at the top of a soda",
                "A sort of raspberry-blueberry candy flavor",
                "A bad mood"
            ],
            correctAnswer: 0
        ),
        Question(
            text: "Which of these terms refers to taking a bit of your friend's food?",
            options: [
                "Fanum tax",
                "Treat toll",
                "Goodie tax",
                "Snack sneaking"
            ],
            correctAnswer: 0
        ),
        Question(
            text: "Which term describes someone who's a bit of a lone wolf, and may even be better than an alpha?",
            options: [
                "Sigma",
                "Omega",
                "Beta",
                "Zeta"
            ],
            correctAnswer: 0
        ),
        Question(
            text: "In which U.S. state are wild, strange, unfortunate things most likely to happen, according to the internet?",
            options: [
                "Only in Ohio",
                "Only in Florida",
                "Only in Alaska",
                "Only in Mississippi"
            ],
            correctAnswer: 0
        )
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                if !showResult {
                    // Question view
                    VStack(spacing: 20) {
                        Text("BRAIN ROT QUIZ")
                            .font(.system(size: 40, weight: .black))
                            .foregroundColor(.red)

                        Text("Answer correctly to save your file!")
                            .font(.title3)
                            .foregroundColor(.white)

                        Text("Question \(currentQuestion + 1) of \(questions.count)")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Spacer()

                        Text(questions[currentQuestion].text)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()

                        VStack(spacing: 15) {
                            ForEach(0..<questions[currentQuestion].options.count, id: \.self) { index in
                                Button(action: {
                                    selectAnswer(index)
                                }) {
                                    Text(questions[currentQuestion].options[index])
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 40)

                        Spacer()
                    }
                } else {
                    // Result view
                    VStack(spacing: 30) {
                        Image(systemName: quizPassed ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(quizPassed ? .green : .red)

                        Text(quizPassed ? "YOU PASSED!" : "YOU FAILED!")
                            .font(.system(size: 48, weight: .black))
                            .foregroundColor(quizPassed ? .green : .red)

                        Text(quizPassed ? "Your file is safe!" : "Your file will be deleted!")
                            .font(.title2)
                            .foregroundColor(.white)

                        Button(action: {
                            if quizPassed {
                                onPass()
                            } else {
                                onFail()
                            }
                            isPresented = false
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 50)
                                .padding(.vertical, 15)
                                .background(quizPassed ? Color.green : Color.red)
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(40)
        }
        .frame(width: 600, height: 700)
    }

    func selectAnswer(_ index: Int) {
        selectedAnswers.append(index)

        if selectedAnswers.count == questions.count {
            // Check if all answers are correct
            var allCorrect = true
            for (i, answer) in selectedAnswers.enumerated() {
                if answer != questions[i].correctAnswer {
                    allCorrect = false
                    break
                }
            }
            quizPassed = allCorrect
            showResult = true
        } else {
            // Move to next question
            currentQuestion += 1
        }
    }
}

struct Question {
    let text: String
    let options: [String]
    let correctAnswer: Int
}

#Preview {
    BrainRotQuizView(isPresented: .constant(true), onPass: {}, onFail: {})
}
