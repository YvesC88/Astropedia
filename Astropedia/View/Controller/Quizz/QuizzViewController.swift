//
//  QuizzViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 18/06/2023.
//

import Foundation
import UIKit

enum ButtonState {
    case none, truePressed, falsePressed, submitPressed
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
    
    let questionService = QuestionService(wrapper: FirebaseWrapper())
    var buttonState: ButtonState = .none
    var buttonPressed: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionService.fetchQuestion(collectionID: "questions")
        numberOfQuestionView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.4)
        questionService.questionDelegate = self
        setUIButton(button: [newGameButton, nextQuestionButton])
        setUIView(view: [questionView, scoreView])
    }
    
    @IBAction func didTappedButton(_ sender: UIButton) {
        let isTrueButton = sender == trueButton
        if buttonState == (isTrueButton ? .truePressed : .falsePressed) {
            buttonState = .none
            nextQuestionButton.isEnabled = false
            resetSelectedButton(buttons: [sender])
        } else {
            buttonState = isTrueButton ? .truePressed : .falsePressed
            nextQuestionButton.isEnabled = true
            colorSelectedButton(button: sender)
            resetSelectedButton(buttons: [isTrueButton ? falseButton : trueButton])
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
            questionService.checkAnswer(question: questionService.random ?? Question(text: "Erreur", answer: true), userAnswer: buttonState == .truePressed)
            if questionService.isCorrect {
                correctColorButton(button: buttonPressed ?? false ? trueButton : falseButton)
            } else {
                incorrectColorButton(button: buttonPressed ?? false ? falseButton : trueButton)
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
    func updateQuestion(with text: String) {
        questionLabel.text = text
    }
    
    func updateTitleGameButton(title: String) {
        newGameButton.setTitle(title, for: .normal)
    }
    
    func newGameEnabled(isEnabled: Bool) {
        newGameButton.isEnabled = isEnabled
    }
    
    func scoreChanged(for answer: Bool) {
        self.buttonPressed = answer
    }
    
    func showAnswerButton(isHidden: Bool) {
        trueButton.isHidden = isHidden
        falseButton.isHidden = isHidden
        nextQuestionButton.isHidden = isHidden
    }
    
    func currentQuestion(number: Int, isHidden: Bool) {
        currentQuestionLabel.text = ("Question \(number) / 10").uppercased()
        currentQuestionLabel.isHidden = isHidden
    }
    
    func updateScore(correct: Int, incorrect: Int) {
        correctAnswerLabel.text = "\(correct)"
        incorrectAnswerLabel.text = "\(incorrect)"
    }
}
