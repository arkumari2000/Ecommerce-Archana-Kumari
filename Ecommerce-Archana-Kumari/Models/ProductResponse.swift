//
//  ProductResponse.swift
//  Ecommerce-Archana-Kumari
//
//  Created by Archana Kumari on 27/12/25.
//

import Foundation

struct ProductResponse: Codable {

    let products: [Product]
    let nextPage: Int?
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextPage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try different keys for products array (data, products, items, results)
        if let productsArray = try? container.decode([Product].self, forKey: .data) {
            products = productsArray
        } else {
            products = []
        }
        
        // Try different keys for nextPage
        if let next = try? container.decode(Int.self, forKey: .nextPage) {
            nextPage = next
        } else {
            nextPage = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(products, forKey: .data)
        try container.encodeIfPresent(nextPage, forKey: .nextPage)
    }
    
    // Custom initializer for creating ProductResponse manually
    init(products: [Product], nextPage: Int?) {
        self.products = products
        self.nextPage = nextPage
    }
}
