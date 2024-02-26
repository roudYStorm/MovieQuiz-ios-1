//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Yulianna on 24.01.2024.
//

import Foundation
protocol QuestionFactoryProtocol: AnyObject {
    var delegate: QuestionFactoryDelegate? { get set }
    
    func requestNextQuestion()
    func loadData()
}
     
