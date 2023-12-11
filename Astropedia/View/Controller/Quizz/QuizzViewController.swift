//
//  QuizzViewController.swift
//  Astropedia
//
//  Created by Yves Charpentier on 18/06/2023.
//

import Combine
import UIKit

enum ButtonState {
    case none, truePressed, falsePressed
}

class QuizzViewController: UIViewController {
    
    @IBOutlet private weak var correctAnswerLabel: UILabel!
    @IBOutlet private weak var incorrectAnswerLabel: UILabel!
    @IBOutlet private weak var questionTextView: UITextView!
    @IBOutlet private weak var trueButton: UIButton!
    @IBOutlet private weak var falseButton: UIButton!
    @IBOutlet private weak var newGameButton: UIButton!
    @IBOutlet private weak var questionProgressView: UIProgressView!
    
    private let questionViewModel = QuizzViewModel(wrapper: FirebaseWrapper())
    private var cancellables: Set<AnyCancellable> = []
    private var buttonState: ButtonState = .none
    private var buttonPressed: Bool?
    private var gameState: GameState = .notStarted
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIButton(button: [trueButton, falseButton], borderColor: .clear)
        
        questionViewModel.$trueScore
            .combineLatest(questionViewModel.$falseScore)
            .sink(receiveValue: { trueScore, falseScore in
                self.correctAnswerLabel.text = "\(trueScore)"
                self.incorrectAnswerLabel.text = "\(falseScore)"
            })
            .store(in: &cancellables)
        
        questionViewModel.$random
            .sink { question in
                self.questionTextView.text = question.text
            }
            .store(in: &cancellables)
        
        questionViewModel.$isShowedButton
            .sink { isAvailable in
                self.trueButton.isHidden = isAvailable
                self.falseButton.isHidden = isAvailable
                self.newGameButton.isEnabled = isAvailable
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
        
        questionViewModel.$isButtonEnabled
            .sink { isEnabled in
                self.trueButton.isEnabled = isEnabled
                self.falseButton.isEnabled = isEnabled
            }
            .store(in: &cancellables)
    }
    
    @IBAction private final func didTappedButton(_ sender: UIButton) {
        let userAnswer = sender == trueButton
        buttonState = userAnswer ? .truePressed : .falsePressed
        questionViewModel.checkAnswer(question: questionViewModel.random, userAnswer: userAnswer)
        if questionViewModel.isCorrect {
            setUIButton(button: [sender], borderColor: .systemGreen)
        } else {
            setUIButton(button: [sender], borderColor: .systemRed)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.questionViewModel.goToNextQuestion()
            self.buttonState = .none
            self.resetSelectedButton(buttons: [sender])
        }
    }
    
    @IBAction private final func didTappedNewGame() {
        questionViewModel.newGame()
        gameState = .inProgress
        buttonState = .none
        resetSelectedButton(buttons: [trueButton, falseButton])
    }
}
