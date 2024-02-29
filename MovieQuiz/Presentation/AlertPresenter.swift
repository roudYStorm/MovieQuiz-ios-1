//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Yulianna on 24.01.2024.
//

import UIKit

final class AlertPresenter  {
    weak var delegate: AlertPresenterDelegate?
    init(delegate: AlertPresenterDelegate?) {
            self.delegate = delegate
        }
    
    
    func showAlert(alertModel: AlertModel) {
           let alert = UIAlertController(
               title: alertModel.title,
               message: alertModel.text,
               preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = "Game results"
        
           let action = UIAlertAction(
               title: alertModel.buttonText,
               style: .default) { _ in
               alertModel.buttonAction()
           }
           alert.addAction(action)
           delegate?.showAlert(alert: alert)
       }
   }
