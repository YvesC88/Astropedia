//
//  QuizzViewController.swift
//  Planets
//
//  Created by Yves Charpentier on 18/06/2023.
//

import Foundation
import UIKit

enum ButtonState {
    case none
    case truePressed
    case falsePressed
    case submitPressed
}

class QuizzViewController: UIViewController {
    
    @IBOutlet weak var correctAnswerLabel: UILabel!
    @IBOutlet weak var incorrectAnswerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var trueButton: UIButton!
    @IBOutlet weak var falseButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var currentQuestionLabel: UILabel!
    @IBOutlet weak var nextQuestionButton: UIButton!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var numberOfQuestionView: UIView!
    @IBOutlet weak var scoreView: UIView!
    @IBOutlet weak var questionAnsweredLabel: UILabel!
    
    let questionService = QuestionService(wrapper: FirebaseWrapper())
    var questions: [Question] = []
    var scoreChanged: Bool?
    var randomNumber: Int?
    var buttonState: ButtonState = .none
    var buttonPressed: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchQuestion()
        numberOfQuestionView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.4)
        questionService.questionDelegate = self
        setUIButton(button: [newGameButton, nextQuestionButton])
        setUIView(view: [questionView, scoreView])
    }
    
    func fetchQuestion() {
        questionService.fetchQuestion(collectionID: "questions") { question, error in
            if let question = question {
                self.questions = question
            }
        }
    }
    
    @IBAction func didTappedTrue() {
        if buttonState == .truePressed {
            buttonState = .none
            nextQuestionButton.isEnabled = false
            resetSelectedButton(buttons: [trueButton])
        } else {
            buttonState = .truePressed
            nextQuestionButton.isEnabled = true
            colorSelectedButton(button: trueButton)
            resetSelectedButton(buttons: [falseButton])
        }
    }
    
    @IBAction func didTappedFalse() {
        if buttonState == .falsePressed {
            buttonState = .none
            nextQuestionButton.isEnabled = false
            resetSelectedButton(buttons: [falseButton])
        } else {
            buttonState = .falsePressed
            nextQuestionButton.isEnabled = true
            colorSelectedButton(button: falseButton)
            resetSelectedButton(buttons: [trueButton])
        }
    }
    
    @IBAction func didTappedSubmit() {
        if buttonState == .submitPressed {
            questionService.goToNextQuestion()
            buttonState = .none
            nextQuestionButton.setTitle("Soumettre", for: .normal)
            resetSelectedButton(buttons: [trueButton, falseButton])
            nextQuestionButton.isEnabled = false
            trueButton.isEnabled = true
            falseButton.isEnabled = true
        } else {
            questionService.checkAnswer(question: questions[randomNumber!], userAnswer: buttonState == .truePressed)
            if let scoreChanged = scoreChanged, let buttonPressed = buttonPressed {
                if scoreChanged {
                    correctColorButton(button: buttonPressed ? trueButton : falseButton)
                } else {
                    incorrectColorButton(button: buttonPressed ? falseButton : trueButton)
                }
            }
            nextQuestionButton.setTitle("Suivant", for: .normal)
            buttonState = .submitPressed
            trueButton.isEnabled = false
            falseButton.isEnabled = false
        }
    }
    
    @IBAction func didTappedNewGame() {
        questionService.newGame()
        buttonState = .none
        resetSelectedButton(buttons: [trueButton, falseButton])
        nextQuestionButton.isHidden = false
        nextQuestionButton.isEnabled = false
        trueButton.isEnabled = true
        falseButton.isEnabled = true
    }
}

extension QuizzViewController: QuestionDelegate {
    func updateTitleGameButton(title: String) {
        newGameButton.setTitle(title, for: .normal)
    }
    
    func newGameEnabled(isEnabled: Bool) {
        newGameButton.isEnabled = isEnabled
    }
    
    func scoreChanged(isChanged: Bool, for answer: Bool) {
        scoreChanged = isChanged
        self.buttonPressed = answer
    }
    
    func randomNumber(number: Int) {
        self.randomNumber = number
    }
    
    func showScoreLabel(isHidden: Bool) {
//        correctAnswerLabel.isHidden = isHidden
//        incorrectAnswerLabel.isHidden = isHidden
    }
    
    func showAnswerButton(isHidden: Bool) {
        trueButton.isHidden = isHidden
        falseButton.isHidden = isHidden
        nextQuestionButton.isHidden = isHidden
    }
    
    func updateQuestion(with question: Question) {
        questionLabel.text = question.text
    }
    
    func currentQuestion(number: Int, isHidden: Bool) {
        currentQuestionLabel.text = ("Question \(number) / 10").uppercased()
        currentQuestionLabel.isHidden = isHidden
    }
    
    func updateQuestionLabel(with text: String) {
        questionLabel.text = text
    }
    
    func updateScore(correct: Int, incorrect: Int) {
        correctAnswerLabel.text = "\(correct)"
        incorrectAnswerLabel.text = "\(incorrect)"
    }
}
