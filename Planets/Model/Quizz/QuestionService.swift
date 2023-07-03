//
//  QuestionManager.swift
//  Planets
//
//  Created by Yves Charpentier on 18/06/2023.
//

import Foundation

protocol QuestionDelegate {
    func showAnswerButton(isHidden: Bool)
    func showScoreLabel(isHidden: Bool)
    func updateQuestion(with question: Question)
    func updateScore(correct: Int, incorrect: Int)
    func updateQuestionLabel(with text: String)
    func currentQuestion(number: Int, isHidden: Bool)
    func scoreChanged(isChanged: Bool, for answer: Bool)
    func randomNumber(number: Int)
    func newGameEnabled(isEnabled: Bool)
    func updateTitleGameButton(title: String)
}

class QuestionService {
    
    let firebaseWrapper: FirebaseProtocol
    
    init(wrapper: FirebaseProtocol) {
        self.firebaseWrapper = wrapper
    }
    
    var score = 0
    var randomNumber: Int?
    var questionsAnswered = 0
    var questionDelegate: QuestionDelegate?
    var numberOfQuestion: Int?
    let numberToAnswer = 10
    var questions: [Question] = []
    
    func fetchQuestion(collectionID: String, completion: @escaping ([Question]?, String?) -> ()) {
        firebaseWrapper.fetchQuestion(collectionID: collectionID) { question, error in
            if let question = question {
                completion(question, nil)
                self.numberOfQuestion = question.count
                self.questions = question
            } else {
                completion([], error)
            }
        }
    }
    
    func checkAnswer(question: Question, userAnswer: Bool) {
        questionDelegate?.newGameEnabled(isEnabled: false)
        let isCorrectAnswer = (question.answer == userAnswer)
        updateScoreAndNotify(isCorrectAnswer: isCorrectAnswer, userAnswer: userAnswer)
    }
    
    private func updateScoreAndNotify(isCorrectAnswer: Bool, userAnswer: Bool) {
        if isCorrectAnswer {
            score += 1
        }
        questionDelegate?.scoreChanged(isChanged: isCorrectAnswer, for: userAnswer)
    }
    
    func goToNextQuestion() {
        if questionsAnswered == 10 {
            showEndGame()
        } else {
            showNextQuestion()
        }
    }
    
    private func showEndGame() {
        questionDelegate?.currentQuestion(number: 10, isHidden: false)
        questionDelegate?.showAnswerButton(isHidden: true)
        questionDelegate?.showScoreLabel(isHidden: false)
        questionDelegate?.newGameEnabled(isEnabled: true)
        questionDelegate?.updateTitleGameButton(title: "Recommencer")
        questionDelegate?.updateScore(correct: score, incorrect: numberToAnswer - score )
        questionDelegate?.updateQuestionLabel(with: "Partie terminée.")
    }
    
    private func showNextQuestion() {
        randomNumber = random()
        questionDelegate?.randomNumber(number: randomNumber!)
        questionsAnswered += 1
        questionDelegate?.updateQuestion(with: questions[randomNumber!])
        questionDelegate?.currentQuestion(number: questionsAnswered, isHidden: false)
    }
    
    func newGame() {
        randomNumber = random()
        questionDelegate?.updateTitleGameButton(title: "Nouvelle partie")
        questionDelegate?.randomNumber(number: randomNumber!)
        questionDelegate?.updateQuestion(with: questions[randomNumber!])
        questionDelegate?.updateScore(correct: 0, incorrect: 0)
        questionDelegate?.showAnswerButton(isHidden: false)
        questionDelegate?.showScoreLabel(isHidden: true)
        questionDelegate?.currentQuestion(number: 1, isHidden: false)
        score = 0
        questionsAnswered = 1
    }
    
    func random() -> Int { return Int.random(in: 0..<numberOfQuestion!)}
}
