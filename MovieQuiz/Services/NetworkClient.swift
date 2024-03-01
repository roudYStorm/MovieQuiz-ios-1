//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Yulianna on 12.02.2024.
//

import Foundation
/// Отвечает за загрузку данных по URL
protocol NetworkRouting {
func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}
struct NetworkClient: NetworkRouting {

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
struct StubNetworkClient: NetworkRouting {
    
    enum TestError: Error { // тестовая ошибка
    case test
    }
    
    let emulateError: Bool // этот параметр нужен, чтобы заглушка эмулировала либо ошибку сети, либо успешный ответ
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        if emulateError {
            handler(.failure(TestError.test))
        } else {
            handler(.success(expectedResponse))
        }
    }
    
    private var expectedResponse: Data {
        """
        {
           "errorMessage" : "",
           "items" : [
              {
                 "crew" : "Dan Trachtenberg (dir.), Amber Midthunder, Dakota Beavers",
                 "fullTitle" : "Prey (2022)",
                 "id" : "tt11866324",
                 "imDbRating" : "7.2",
                 "imDbRatingCount" : "93332",
                 "image" : "https://m.media-amazon.com/images/M/MV5BMDBlMDYxMDktOTUxMS00MjcxLWE2YjQtNjNhMjNmN2Y3ZDA1XkEyXkFqcGdeQXVyMTM1MTE1NDMx._V1_Ratio0.6716_AL_.jpg",
                 "rank" : "1",
                 "rankUpDown" : "+23",
                 "title" : "Prey",
                 "year" : "2022"
              },
              {
                 "crew" : "Anthony Russo (dir.), Ryan Gosling, Chris Evans",
                 "fullTitle" : "The Gray Man (2022)",
                 "id" : "tt1649418",
                 "imDbRating" : "6.5",
                 "imDbRatingCount" : "132890",
                 "image" : "https://m.media-amazon.com/images/M/MV5BOWY4MmFiY2QtMzE1YS00NTg1LWIwOTQtYTI4ZGUzNWIxNTVmXkEyXkFqcGdeQXVyODk4OTc3MTY@._V1_Ratio0.6716_AL_.jpg",
                 "rank" : "2",
                 "rankUpDown" : "-1",
                 "title" : "The Gray Man",
                 "year" : "2022"
              }
            ]
          }
        """.data(using: .utf8) ?? Data()
    }
}

