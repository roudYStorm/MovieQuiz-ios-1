//
//   MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Yulianna on 29.02.2024.
//

import Foundation
import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    func showAlert(alert: UIAlertController)
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func changeStateButtons(isEnable: Bool)
    
    func showNetworkError(message: String)
}

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    
    // MARK: - Properties
    
    
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var correctAnswers = 0
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticService = StaticticServiceImplementation() 
    
    
    private weak var viewController: MovieQuizViewControllerProtocol?
    init(viewController: MovieQuizViewControllerProtocol?) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController?.showLoadingIndicator()
        viewController?.hideLoadingIndicator()
    }
    
    
    // MARK: - QuestionFactoryDelegate
    
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
        viewController?.changeStateButtons(isEnable: true)
    }
    
    
    // MARK: - Function (currentQuestionIndex)
    
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        self.currentQuestionIndex = 0
        self.correctAnswers = 0
        self.questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    
    // MARK: - Function
    
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
               let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
               let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
               + " (\(bestGame.date.dateTimeString))"
               let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
               
               let resultMessage = [
                   currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
               ].joined(separator: "\n")
               
               return resultMessage
    }
    
    
    // MARK: - Private
    
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.proceedToNextQuestionOrResult()
        }
    }
    
    private func proceedToNextQuestionOrResult() {
        if self.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: self.questionsAmount)
            
            let text = makeResultsMessage()
            
            
            let viewModel = QuizResultViewModel(title: "Этот раунд окончен!",
                                                text: text,
                                                buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: viewModel)
            
        } else {
            self.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    
    private func didAnswer(isYes: Bool) {
        
        viewController?.showLoadingIndicator()
        viewController?.changeStateButtons(isEnable: false)  
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    // MARK: - Function (Action)
    
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
}
