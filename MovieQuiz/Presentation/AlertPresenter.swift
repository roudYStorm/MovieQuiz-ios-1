//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Yulianna on 24.01.2024.
//

import UIKit

class AlertPresenter {
    private var statisticService: StatisticService = StatisticServiceImplementation()
    weak var delegate: AlertPresenterDelegate?
    
    func createAlert(correctAnswers: Int, questionsAmount: Int) -> AlertModel {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let quizCount = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let formattedAccuracy = String(format: "%.0f%%", statisticService.totalAccuracy * 100)
        let text = """
                        Ваш результат: \(correctAnswers)/\(questionsAmount)
                        Количество сыгранных квизов: \(quizCount)
                        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                        Средняя точность: \(formattedAccuracy)
                        """
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            text: text,
            buttonText: "Сыграть еще раз")

        return alertModel
    }
}
