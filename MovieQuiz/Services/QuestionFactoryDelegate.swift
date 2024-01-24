//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Yulianna on 24.01.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject { 
    func didReceiveNextQuestion(question: QuizQuestion?)
} 
