//
//  QuestionManager.swift
//  Planets
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
    var randomNumber: Int = 0
    var questionsAnswered = 0
    var numberOfQuestion: Int = 0
    let numberToAnswer = 10
    var questions: [Question] = []
    var isCorrect: Bool = false
    
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
        print(question)
        if question.answer == userAnswer {
            isCorrect = true
            score += 1
        } else {
            isCorrect = false
        }
        questionDelegate?.scoreChanged(for: userAnswer)
    }
    
    func goToNextQuestion() {
        if questionsAnswered == 10 {
            showEndGame()
        } else {
            showNextQuestion()
        }
    }
    
    private func showEndGame() {
        questionDelegate?.currentQuestion(number: questionsAnswered, isHidden: false)
        questionDelegate?.showAnswerButton(isHidden: true)
        questionDelegate?.newGameEnabled(isEnabled: true)
        questionDelegate?.updateTitleGameButton(title: "Recommencer")
        questionDelegate?.updateScore(correct: score, incorrect: numberToAnswer - score)
        questionDelegate?.updateQuestion(with: "Partie terminé.")
    }
    
    private func showNextQuestion() {
        randomNumber = random()
        questionsAnswered += 1
        questionDelegate?.updateQuestion(with: questions[randomNumber].text)
        questionDelegate?.currentQuestion(number: questionsAnswered, isHidden: false)
    }
    
    func newGame() {
        randomNumber = random()
        score = 0
        questionsAnswered = 1
        questionDelegate?.updateTitleGameButton(title: "Nouvelle partie")
        questionDelegate?.updateQuestion(with: questions[randomNumber].text)
        questionDelegate?.updateScore(correct: 0, incorrect: 0)
        questionDelegate?.showAnswerButton(isHidden: false)
        questionDelegate?.currentQuestion(number: questionsAnswered, isHidden: false)
    }
    
    func random() -> Int { return Int.random(in: 0..<numberOfQuestion) }
}
