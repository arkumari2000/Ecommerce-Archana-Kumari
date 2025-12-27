//
//  Product.swift
//  Ecommerce-Archana-Kumari
//
//  Created by Archana Kumari on 27/12/25.
//

import Foundation

struct Product: Codable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let image: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case category
        case price
        case image
    }
}
