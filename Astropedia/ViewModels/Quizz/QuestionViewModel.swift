//
//  QuizzViewModel.swift
//  Astropedia
//
//  Created by Yves Charpentier on 04/12/2023.
//

import Foundation
import Combine

class QuestionViewModel: NSObject {
    
    let firebaseWrapper: FirebaseProtocol
    private var questions: [Question] = []
    private var isComplete: Bool { return questionAnswered == questionsToAnswer }
    
    @Published var questionAnswered: Int = 0
    @Published var questionsToAnswer: Int = 10
    @Published var isCorrect: Bool = false
    @Published var random: Question?
    @Published var score: Int = 0
    @Published var isShowedButton: Bool = true
    @Published var isGameEnabled: Bool = true
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
        super.init()
        fetchQuestion(collectionID: "questions")
    }
    
//    override init() {
//        super.init()
//        fetchQuestion(collectionID: "questions")
//    }
    
//    var random: Question?
//    var questions: [Question] = []
//    var isCorrect: Bool = false
    
    
    private final func fetchQuestion(collectionID: String) {
        firebaseWrapper.fetchQuestion(collectionID: collectionID) { question, error in
            if let question = question {
                self.questions = question
            } else {
                print("error")
            }
        }
    }
    
    private final func randomQuestion() -> Question { return questions.randomElement() ?? Question(text: "Pas de question", answer: false)}
    
    func checkAnswer(question: Question, userAnswer: Bool) {
        isGameEnabled = false
        if question.answer == userAnswer {
            isCorrect = true
            score += 1
        } else {
            isCorrect = false
        }
//        questionDelegate?.scoreChanged(for: userAnswer)
    }
    
    final func goToNextQuestion() {
        if isComplete {
            showEndGame()
        } else {
            showNextQuestion()
        }
    }
    
    private final func showEndGame() {
        
        isShowedButton = true
        isGameEnabled = true
//        questionDelegate?.showAnswerButton(isHidden: true)
//        questionDelegate?.newGameEnabled(isEnabled: true)
//        questionDelegate?.updateTitleGameButton(title: "Recommencer")
//        questionDelegate?.updateScore(correct: quizz.score, incorrect: quizz.questionsToAnswer - quizz.score)
//        questionDelegate?.updateQuestion(with: "Quizz terminé.")
    }
    
    private final func updateCurrentQuestion(question: Question, isHidden: Bool) {
        
//        questionDelegate?.updateQuestion(with: question.text)
//        questionDelegate?.currentQuestion(number: questionsAnswered, isHidden: isHidden)
    }
    
    private func showNextQuestion() {
        random = randomQuestion()
        questionAnswered += 1
        updateCurrentQuestion(question: random ?? Question(text: "Erreur", answer: false), isHidden: false)
    }
    
    func newGame() {
        random = randomQuestion()
        score = 0
        questionAnswered = 1
        isShowedButton = false
        updateCurrentQuestion(question: random ?? Question(text: "Erreur", answer: false), isHidden: false)
//        questionDelegate?.updateTitleGameButton(title: "Démarrer")
//        questionDelegate?.updateScore(correct: 0, incorrect: 0)
//        questionDelegate?.showAnswerButton(isHidden: false)
    }
}
