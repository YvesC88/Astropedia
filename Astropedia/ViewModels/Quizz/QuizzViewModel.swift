//
//  QuizzViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 04/12/2023.
//

import Foundation
import Combine

final class QuizzViewModel: NSObject {
    
    private let firebaseWrapper: FirebaseProtocol
    private var questions: [Question] = []
    private var gameState: GameState = .notStarted
    private var isComplete: Bool { return questionAnswered == questionsToAnswer }
    
    @Published var questionAnswered: Int = 0
    @Published var questionsToAnswer: Int = 10
    @Published var isCorrect: Bool = false
    @Published var random = Question(text: "Testez vos connaissances sur le Système Solaire", answer: true)
    @Published var trueScore: Int = 0
    @Published var falseScore: Int = 0
    @Published var isShowedButton: Bool = true
    @Published var isGameEnabled: Bool = true
    @Published var isScoreChanged: Bool = false
    @Published var titleButton: String = "Démarrer"
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
        super.init()
        fetchQuestion(collectionID: "questions")
    }
    
    
    private final func fetchQuestion(collectionID: String) {
        firebaseWrapper.fetchQuestion(collectionID: collectionID) { question, error in
            if let question = question {
                self.questions = question
            } else {
                print("error")
            }
        }
    }
    
    private final func randomQuestion() -> Question {
        return questions.randomElement() ?? Question(text: "Pas de question", answer: false)
    }
    
    final func checkAnswer(question: Question, userAnswer: Bool) {
        isGameEnabled = false
        isCorrect = question.answer == userAnswer
        isScoreChanged = userAnswer
        if isCorrect {
            trueScore += 1
        } else {
            falseScore += 1
        }
    }
    
    final func goToNextQuestion() {
        if isComplete {
            showEndGame()
        } else {
            showNextQuestion()
        }
    }
    
    private final func showEndGame() {
        gameState = .ended
        isShowedButton = true
        isGameEnabled = true
        random = Question(text: "Quizz terminé.", answer: true)
        titleButton = "Recommencer"
        questionAnswered = 0
    }
    
    private final func showNextQuestion() {
        gameState = .inProgress
        random = randomQuestion()
        questionAnswered += 1
    }
    
    final func newGame() {
        gameState = .inProgress
        random = randomQuestion()
        trueScore = 0
        falseScore = 0
        questionAnswered = 1
        isShowedButton = false
        titleButton = "Démarrer"
    }
    
    final func getProgess() -> Float {
        let progress = Float(self.questionAnswered) / Float(self.questionsToAnswer)
        return progress
    }
}
