//
//  AlertProtocol.swift
//  MovieQuiz
//
//  Created by Yulianna on 24.01.2024.
//

import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func showAlert(quiz result: AlertModel)
}
