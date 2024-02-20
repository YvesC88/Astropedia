//
//  QuizzViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 04/12/2023.
//

import Foundation
import Combine

final class QuizzViewModel {
    
    private let firebaseWrapper: FirebaseProtocol
    private var questions: [Question] = []
    private var gameState: GameState = .notStarted
    private var isComplete: Bool { return questionAnswered == questionsToAnswer }
    
    // Tips pas besoin de repeter le type. On sait que un `false` c'est un bool. Swift le sait aussi comme un grand. Idem pour une string etc.
    @Published private(set) var questionAnswered = 0
    @Published private(set) var questionsToAnswer = 10
    @Published private(set) var isCorrect = false
    @Published private(set) var random = Question(text: "Testez vos connaissances sur le Système Solaire", answer: true)
    @Published private(set) var trueScore = 0
    @Published private(set) var falseScore = 0
    @Published private(set) var isShowedButton = true
    @Published private(set) var isScoreChanged = false
    @Published private(set) var titleButton = "Démarrer"
    @Published private(set) var isButtonEnabled = true

    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
        fetchQuestion(collectionID: "questions")
    }
    
    
    private func fetchQuestion(collectionID: String) {
        // Retain cycle ici! Fait capturer self en weak !
        firebaseWrapper.fetchQuestion(collectionID: collectionID) { question, error in
            if let question = question {
                self.questions = question
            } else {
                print("error") // Inutile pour la prod
            }
        }
    }
    
    private func randomQuestion() -> Question {
        return questions.randomElement() ?? Question(text: "Pas de question", answer: false)
    }
    
    func checkAnswer(question: Question, userAnswer: Bool) {
        isButtonEnabled = false
        isCorrect = question.answer == userAnswer
        isScoreChanged = userAnswer
        if isCorrect {
            trueScore += 1
        } else {
            falseScore += 1
        }
    }
    
    func goToNextQuestion() {
        if isComplete {
            showEndGame()
        } else {
            showNextQuestion()
        }
    }
    
    private func showEndGame() {
        gameState = .ended
        isShowedButton = true
        random = Question(text: "Quizz terminé.", answer: true)
        titleButton = "Recommencer"
        questionAnswered = 0
    }
    
    private func showNextQuestion() {
        gameState = .inProgress
        isButtonEnabled = true
        random = randomQuestion()
        questionAnswered += 1
    }
    
    func newGame() {
        gameState = .inProgress
        isButtonEnabled = true
        random = randomQuestion()
        trueScore = 0
        falseScore = 0
        questionAnswered = 1
        isShowedButton = false
        titleButton = "Démarrer"
    }
    
    func getProgess() -> Float {
        let progress = Float(self.questionAnswered) / Float(self.questionsToAnswer)
        return progress
    }
}
