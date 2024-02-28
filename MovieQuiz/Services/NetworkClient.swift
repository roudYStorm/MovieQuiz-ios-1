//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Yulianna on 12.02.2024.
//

import Foundation
/// Отвечает за загрузку данных по URL
struct NetworkClient {

    private enum NetworkError: Error { // создаем перечисление возможных ошибок
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) { // функция загрузки URL и обработки наших ошибок
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in // проверяем на ошибки и обрабатываем их
          
            if let error = error { // проверяем пришла ли ошибка
                handler(.failure(error)) // проверяем и возвращаем результат
                return
            }
            
            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError)) // обрабатываем и возвращаем результат
                return
            }
            
            // Возвращаем данные
            guard let data = data else { return } // если ошибок нет, то обрабатываем ответ
            handler(.success(data)) // обрабатываем и возвращаем результат
        }
        
        task.resume() // все ошибки обработаны, получен ответ, теперь возобновляем работу приложения
    }
} 
