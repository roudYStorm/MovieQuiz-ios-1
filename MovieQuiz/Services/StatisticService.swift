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

final class StaticticServiceImplementation: StatisticService {
    var gamesCount: Int = 0
    
    var totalCorrectAnswers: Int = 0
    // реализуем протокол StatisticService для хранения данных и статистики
    
    private enum Keys: String { // создаем перечисление всех ключей и сущностей котрые придется хранить
        case correct, total,  bestGame, gameCount, totalCorrectAnswer, totalAmount
    }
    
    private let userDefaults = UserDefaults.standard // чтобы каждый раз при работе с UserDefaults не обращаться к standart создадим константу
    
    var totalAccuracy: Double {
        get {
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let total = try? JSONDecoder().decode(Double.self, from: data) else {
                return 0.0
            }
            return total
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue)  else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    
    var gameCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gameCount.rawValue),
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
            userDefaults.set(data, forKey: Keys.gameCount.rawValue)
        }
    }
    
    var bestGame: GameRecord  {
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
    
    var totalCorrectAnswer: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.totalCorrectAnswer.rawValue),
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
            userDefaults.set(data, forKey: Keys.totalCorrectAnswer.rawValue)
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
    
    func store(correct count: Int, total amount: Int) { //  метод для сохранения текущего результата игры с проверкой на то что новый результат лучше
        let currentRecord = GameRecord(correct: count, total: amount, date: Date())
        if currentRecord.isBetterThan(bestGame) {
            bestGame = currentRecord
        }
        // изменяем счетчики статистики
        gameCount += 1
        totalCorrectAnswer = bestGame.correct + count
        totalAmount = bestGame.total + amount
        totalAccuracy = (Double(totalCorrectAnswer) / Double(totalAmount)) * 100
    }
}

