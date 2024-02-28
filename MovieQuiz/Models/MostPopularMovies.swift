//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Yulianna on 12.02.2024.
//

import UIKit

struct MostPopularMovies: Codable {
    
    private enum Keys: CodingKey {
           case errorMessage, items
    }
    let errorMessage: String
    let items: [MostPopularMovie]
    
    init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           self.errorMessage = try container.decode(String.self, forKey: .errorMessage)
           self.items = try container.decode([MostPopularMovie].self, forKey: .items)
       }
}

struct MostPopularMovie: Codable {
    
    private enum CodingKeys: String, CodingKey { // если имена в JSON не совпадают с именами полей в структуре, то надо указать соответствие между полями в структуре и JSON
            case title = "fullTitle"
            case rating = "imDbRating"
            case imageURL = "image"
        }
    let title: String
    let rating: String
    let imageURL: URL
    
    var resizedImageURL: URL {
           let urlString = imageURL.absoluteString // создаем строку из адреса
           let imageUrlString = urlString.components(separatedBy: "._")[0] + "._VO_UX600_.jpg" // обрезаем лишнюю часть и добавляем модификатор желаемого качества и размера
           
           guard let newURL = URL(string: imageUrlString) else { // пытаемся создать новый адрес
               return imageURL // если не получается то возвращаем старый
           }
           return newURL // возвращаем новый адрес
       }
}
