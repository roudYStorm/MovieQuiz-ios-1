//
//  Gamerecord.swift
//  MovieQuiz
//
//  Created by Yulianna on 26.01.2024.
//

import Foundation
struct GameRecord: Codable {
    
    let correct: Int
    let total: Int
    let date: Date
    
    init(correct: Int, total: Int, date: Date) {
          self.correct = correct
          self.total = total
          self.date = date
      }
    func isBetterThan(_ another: GameRecord) -> Bool {
        correct < another.correct
    }
}

