//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Yulianna on 24.01.2024.
//

import UIKit

class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
    
    func createAlert(correctAnswers: Int, questionsAmount: Int) -> AlertModel {
        let text = correctAnswers == questionsAmount ? "Поздравляем, вы ответили на 10 из 10!" :
        "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            text: text,
            buttonText: "Сыграть еще раз")

        return alertModel
    }
}
