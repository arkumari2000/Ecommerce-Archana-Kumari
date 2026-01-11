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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        category = try container.decode(String.self, forKey: .category)
        price = try container.decode(Double.self, forKey: .price)
        
        // Try different image field names
        if let imageValue = try? container.decode(String.self, forKey: .image) {
            image = imageValue
        } else {
            image = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(category, forKey: .category)
        try container.encode(price, forKey: .price)
        try container.encodeIfPresent(image, forKey: .image)
    }
}
