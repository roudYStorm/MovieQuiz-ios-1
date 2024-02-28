//
//   NetworkErrorModel.swift
//  MovieQuiz
//
//  Created by Yulianna on 26.02.2024.
//

import Foundation
struct NetworkError {
    let title: String
    let text: String
    let buttonText: String
    let buttonAction: () -> Void
}
