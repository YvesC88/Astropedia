//
//  QuestionManager.swift
//  Astropedia
//
//  Created by Yves Charpentier on 18/06/2023.
//

import Foundation

protocol QuestionDelegate {
    func showAnswerButton(isHidden: Bool)
    func updateQuestion(with text: String)
    func updateScore(correct: Int, incorrect: Int)
    func currentQuestion(number: Int, isHidden: Bool)
    func scoreChanged(for answer: Bool)
    func newGameEnabled(isEnabled: Bool)
    func updateTitleGameButton(title: String)
}

class QuestionService {
    
    let firebaseWrapper: FirebaseProtocol
    var questionDelegate: QuestionDelegate?
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
    }
    
    var score = 0
    var random: Question?
    var questionsAnswered = 0
    let numberToAnswer = 10
    var questions: [Question] = []
    var isCorrect: Bool = false
    
    final func fetchQuestion(collectionID: String) {
        firebaseWrapper.fetchQuestion(collectionID: collectionID) { question, error in
            if let question = question {
                self.questions = question
            } else {
                print("error")
            }
        }
    }
    
    func randomQuestion() -> Question { return questions.randomElement() ?? Question(text: "Pas de question", answer: false)}
    
    func checkAnswer(question: Question, userAnswer: Bool) {
        questionDelegate?.newGameEnabled(isEnabled: false)
        if question.answer == userAnswer {
            isCorrect = true
            score += 1
        } else {
            isCorrect = false
        }
        questionDelegate?.scoreChanged(for: userAnswer)
    }
    
    final func goToNextQuestion() {
        if questionsAnswered == numberToAnswer {
            showEndGame()
        } else {
            showNextQuestion()
        }
    }
    
    private final func showEndGame() {
        updateCurrentQuestion(question: random ?? Question(text: "Erreur", answer: false), isHidden: false)
        questionDelegate?.showAnswerButton(isHidden: true)
        questionDelegate?.newGameEnabled(isEnabled: true)
        questionDelegate?.updateTitleGameButton(title: "Recommencer")
        questionDelegate?.updateScore(correct: score, incorrect: numberToAnswer - score)
        questionDelegate?.updateQuestion(with: "Quizz terminé.")
    }
    
    private final func updateCurrentQuestion(question: Question, isHidden: Bool) {
        questionDelegate?.updateQuestion(with: question.text)
        questionDelegate?.currentQuestion(number: questionsAnswered, isHidden: isHidden)
    }
    
    private func showNextQuestion() {
        random = randomQuestion()
        questionsAnswered += 1
        updateCurrentQuestion(question: random ?? Question(text: "Erreur", answer: false), isHidden: false)
    }
    
    func newGame() {
        random = randomQuestion()
        score = 0
        questionsAnswered = 1
        updateCurrentQuestion(question: random ?? Question(text: "Erreur", answer: false), isHidden: false)
        questionDelegate?.updateTitleGameButton(title: "Démarrer")
        questionDelegate?.updateScore(correct: 0, incorrect: 0)
        questionDelegate?.showAnswerButton(isHidden: false)
    }
}
