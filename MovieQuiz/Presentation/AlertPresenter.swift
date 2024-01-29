//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Yulianna on 24.01.2024.
//

import UIKit

class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
    
    func createAlert(message: String) -> AlertModel {
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            text: message,
            buttonText: "Сыграть еще раз")

        return alertModel
    }
}
