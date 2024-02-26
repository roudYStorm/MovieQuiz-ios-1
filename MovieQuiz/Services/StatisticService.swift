//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Yulianna on 25.01.2024.
//

import Foundation
import UIKit

protocol StatisticService {
    var totalAccuracy: Double { get set }
    var gamesCount: Int { get set }
    var bestGame: GameRecord { get set }
    var totalCorrectAnswers: Int { get set }
    var totalAmount: Int { get set }
    func store(correct count: Int, total amount: Int)
}

    final class StatisticServiceImplementation: StatisticService {
    private enum Keys: String {
        case correct, total, bestGame, gamesCount, totalCorrectAnswers, totalAmount
    }
    
    private let userDefaults = UserDefaults.standard
    
    var totalAccuracy: Double {
        get {
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let totalAcc = try? JSONDecoder().decode(Double.self, from: data) else {
                return 0.0
            }
            
            return totalAcc
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let count = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            
            return count
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    var totalCorrectAnswers: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.totalCorrectAnswers.rawValue),
                  let count = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            
            return count
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    var totalAmount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.totalAmount.rawValue),
                  let count = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            
            return count
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.totalAmount.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let currentGame: GameRecord = GameRecord(correct: count, total: amount, date: Date())
        if bestGame.isBetterThan(currentGame){
            bestGame = currentGame
        }
        
        gamesCount += 1
        totalCorrectAnswers = bestGame.correct + count
        totalAmount = bestGame.total + amount
        totalAccuracy = Double(totalCorrectAnswers) / Double(totalAmount) * 100
    }
}
        
    
