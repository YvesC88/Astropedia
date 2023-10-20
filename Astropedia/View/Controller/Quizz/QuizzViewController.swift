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
    
    @IBOutlet private weak var correctAnswerLabel: UILabel!
    @IBOutlet private weak var incorrectAnswerLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var trueButton: UIButton!
    @IBOutlet private weak var falseButton: UIButton!
    @IBOutlet private weak var newGameButton: UIButton!
    @IBOutlet private weak var currentQuestionLabel: UILabel!
    @IBOutlet private weak var nextQuestionButton: UIButton!
    @IBOutlet private weak var questionView: UIView!
    @IBOutlet private weak var numberOfQuestionView: UIView!
    @IBOutlet private weak var scoreView: UIView!
    
    private let questionService = QuestionService(wrapper: FirebaseWrapper())
    private var buttonState: ButtonState = .none
    private var buttonPressed: Bool?
    
    private lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.colors = [
            UIColor(red: 39/255, green: 55/255, blue: 74/255, alpha: 1).cgColor,
            UIColor.black.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        return gradient
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        
        questionService.fetchQuestion(collectionID: "questions")
        questionService.questionDelegate = self
        setUIButton(button: [newGameButton, nextQuestionButton])
        
        applyBlurEffect(to: questionView, withCornerRadius: 20)
        applyBlurEffect(to: scoreView, withCornerRadius: 20)
    }
    
    @IBAction private final func didTappedButton(_ sender: UIButton) {
        let isTrueButton = sender == trueButton
        if buttonState == (isTrueButton ? .truePressed : .falsePressed) {
            buttonState = .none
            nextQuestionButton.isEnabled = false
            resetSelectedButton(buttons: [sender])
        } else {
            buttonState = isTrueButton ? .truePressed : .falsePressed
            nextQuestionButton.isEnabled = true
            setButtonBorderColor(button: sender, color: UIColor.white)
            resetSelectedButton(buttons: [isTrueButton ? falseButton : trueButton])
        }
    }
    
    @IBAction private final func didTappedSubmit() {
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
                setButtonBorderColor(button: buttonPressed ?? false ? trueButton : falseButton, color: UIColor.systemGreen)
            } else {
                setButtonBorderColor(button: buttonPressed ?? false ? falseButton : trueButton, color: UIColor.systemRed)
            }
            nextQuestionButton.setTitle("Suivant", for: .normal)
            buttonState = .submitPressed
            trueButton.isEnabled = false
            falseButton.isEnabled = false
        }
    }
    
    @IBAction private final func didTappedNewGame() {
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
        currentQuestionLabel.text = "Question \(number) / 10"
        currentQuestionLabel.isHidden = isHidden
    }
    
    func updateScore(correct: Int, incorrect: Int) {
        correctAnswerLabel.text = "\(correct)"
        incorrectAnswerLabel.text = "\(incorrect)"
    }
}
