//
//  QuizzViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 18/06/2023.
//

import Combine
import UIKit

enum ButtonState {
    case none, truePressed, falsePressed, submitPressed
}

class QuizzViewController: UIViewController {
    
    @IBOutlet private weak var correctAnswerLabel: UILabel!
    @IBOutlet private weak var incorrectAnswerLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var currentQuestionLabel: UILabel!
    @IBOutlet private weak var trueButton: UIButton!
    @IBOutlet private weak var falseButton: UIButton!
    @IBOutlet private weak var newGameButton: UIButton!
    @IBOutlet private weak var nextQuestionButton: UIButton!
    @IBOutlet private weak var numberOfQuestionView: UIView!
    
    private let questionViewModel = QuestionViewModel(wrapper: FirebaseWrapper())
    private var cancellables: Set<AnyCancellable> = []
    private var buttonState: ButtonState = .none
    private var buttonPressed: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionViewModel.$score
            .sink { score in
                self.correctAnswerLabel.text = "\(score)"
            }
            .store(in: &cancellables)
        
        questionViewModel.$random
            .sink { question in
                self.questionLabel.text = question?.text
            }
            .store(in: &cancellables)
        
        questionViewModel.$isShowedButton
            .sink { isHidden in
                self.trueButton.isHidden = isHidden
                self.falseButton.isHidden = isHidden
                self.currentQuestionLabel.isHidden = isHidden
                
            }
            .store(in: &cancellables)
        
        questionViewModel.$isGameEnabled
            .sink { isAvailble in
                self.newGameButton.isEnabled = isAvailble
            }
            .store(in: &cancellables)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: numberOfQuestionView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        setUIButton(button: [newGameButton, nextQuestionButton], color: UIColor.white)
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
            setUIButton(button: [sender], color: UIColor.white)
            resetSelectedButton(buttons: [isTrueButton ? falseButton : trueButton])
        }
    }
    
    @IBAction private final func didTappedSubmit() {
        if buttonState == .submitPressed {
            questionViewModel.goToNextQuestion()
            buttonState = .none
            nextQuestionButton.setTitle("Soumettre", for: .normal)
            resetSelectedButton(buttons: [trueButton, falseButton])
            nextQuestionButton.isEnabled = false
            trueButton.isEnabled = true
            falseButton.isEnabled = true
        } else {
            questionViewModel.checkAnswer(question: questionViewModel.random ?? Question(text: "Erreur", answer: true), userAnswer: buttonState == .truePressed)
            if questionViewModel.isCorrect {
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
        questionViewModel.newGame()
        buttonState = .none
        resetSelectedButton(buttons: [trueButton, falseButton])
        nextQuestionButton.isHidden = false
        nextQuestionButton.isEnabled = false
        trueButton.isEnabled = true
        falseButton.isEnabled = true
    }
}

//extension QuizzViewController: QuestionDelegate {
//    func updateQuestion(with text: String) {
//        questionLabel.text = text
//    }
//    
//    func updateTitleGameButton(title: String) {
//        newGameButton.setTitle(title, for: .normal)
//    }
//    
//    func newGameEnabled(isEnabled: Bool) {
//        newGameButton.isEnabled = isEnabled
//    }
//    
//    func scoreChanged(for answer: Bool) {
//        self.buttonPressed = answer
//    }
//    
//    func showAnswerButton(isHidden: Bool) {
//        trueButton.isHidden = isHidden
//        falseButton.isHidden = isHidden
//        nextQuestionButton.isHidden = isHidden
//    }
//    
//    func currentQuestion(number: Int, isHidden: Bool) {
//        currentQuestionLabel.text = "Question \(number) / 10"
//        currentQuestionLabel.isHidden = isHidden
//    }
//    
//    func updateScore(correct: Int, incorrect: Int) {
//        correctAnswerLabel.text = "\(correct)"
//        incorrectAnswerLabel.text = "\(incorrect)"
//    }
//}
