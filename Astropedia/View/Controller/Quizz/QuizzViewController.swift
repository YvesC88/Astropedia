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
    @IBOutlet private weak var trueButton: UIButton!
    @IBOutlet private weak var falseButton: UIButton!
    @IBOutlet private weak var newGameButton: UIButton!
    @IBOutlet private weak var nextQuestionButton: UIButton!
    @IBOutlet private weak var numberOfQuestionView: UIView!
    @IBOutlet weak var questionProgressView: UIProgressView!
    
    private let questionViewModel = QuizzViewModel(wrapper: FirebaseWrapper())
    private var cancellables: Set<AnyCancellable> = []
    private var buttonState: ButtonState = .none
    private var buttonPressed: Bool?
    private var gameState: GameState = .notStarted
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUIForGameState()
        
        questionViewModel.$trueScore
            .combineLatest(questionViewModel.$falseScore)
            .sink(receiveValue: { trueScore, falseScore in
                self.correctAnswerLabel.text = "\(trueScore)"
                self.incorrectAnswerLabel.text = "\(falseScore)"
            })
            .store(in: &cancellables)
        
        questionViewModel.$random
            .sink { question in
                self.questionLabel.text = question.text
            }
            .store(in: &cancellables)
        
        questionViewModel.$isShowedButton
            .sink { isHidden in
                self.trueButton.isHidden = isHidden
                self.falseButton.isHidden = isHidden
                self.nextQuestionButton.isHidden = isHidden
            }
            .store(in: &cancellables)
        
        questionViewModel.$isGameEnabled
            .sink { isAvailble in
                self.newGameButton.isEnabled = isAvailble
            }
            .store(in: &cancellables)
        
        questionViewModel.$isScoreChanged
            .sink { isChanged in
                self.buttonPressed = isChanged
            }
            .store(in: &cancellables)
        
        questionViewModel.$titleButton
            .sink { text in
                self.newGameButton.setTitle(text, for: .normal)
            }
            .store(in: &cancellables)
        
        questionViewModel.$questionAnswered
            .sink { _ in
                self.questionProgressView.setProgress(self.questionViewModel.getProgess(), animated: true)
            }
            .store(in: &cancellables)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: numberOfQuestionView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        setUIButton(button: [newGameButton, nextQuestionButton], color: UIColor.white)
    }
    
    private func updateUIForGameState() {
        switch gameState {
        case .notStarted:
            nextQuestionButton.isEnabled = false
            trueButton.isEnabled = false
            falseButton.isEnabled = false
        case .inProgress:
            nextQuestionButton.isEnabled = false
            trueButton.isEnabled = true
            falseButton.isEnabled = true
        case .ended:
            nextQuestionButton.isEnabled = false
            trueButton.isEnabled = false
            falseButton.isEnabled = false
        }
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
//        questionProgressView.setProgress(questionViewModel.getProgess(), animated: true)
        if buttonState == .submitPressed {
            questionViewModel.goToNextQuestion()
            buttonState = .none
            nextQuestionButton.setTitle("Soumettre", for: .normal)
            resetSelectedButton(buttons: [trueButton, falseButton])
            nextQuestionButton.isEnabled = false
            trueButton.isEnabled = true
            falseButton.isEnabled = true
        } else {
            questionViewModel.checkAnswer(question: questionViewModel.random, userAnswer: buttonState == .truePressed)
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
        gameState = .inProgress
        buttonState = .none
        resetSelectedButton(buttons: [trueButton, falseButton])
        updateUIForGameState()
    }
}
