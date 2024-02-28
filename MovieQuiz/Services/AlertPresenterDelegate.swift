//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Yulianna on 26.02.2024.
//

import UIKit
   
protocol AlertPresenterDelegate: AnyObject {  // создаем протокол делегата для Алерт презентора и подписывваем его на вьюконтроллер
    // 1. тот кто подписан на этот протокол (в данном случае это вью контроллер) должен показать этот метод
    // 2. передаем в этот метод структуру алерт модели
    func showAlert(alert: UIAlertController)
}
