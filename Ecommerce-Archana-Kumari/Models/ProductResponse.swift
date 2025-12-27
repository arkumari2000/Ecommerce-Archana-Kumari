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
        case products
        case data
        case items
        case results
        case nextPage
        case next_page
        case nextPageNumber
        case next
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try different keys for products array (data, products, items, results)
        if let productsArray = try? container.decode([Product].self, forKey: .data) {
            products = productsArray
        } else if let productsArray = try? container.decode([Product].self, forKey: .products) {
            products = productsArray
        } else if let productsArray = try? container.decode([Product].self, forKey: .items) {
            products = productsArray
        } else if let productsArray = try? container.decode([Product].self, forKey: .results) {
            products = productsArray
        } else {
            products = []
        }
        
        // Try different keys for nextPage
        if let next = try? container.decode(Int.self, forKey: .nextPage) {
            nextPage = next
        } else if let next = try? container.decode(Int.self, forKey: .next_page) {
            nextPage = next
        } else if let next = try? container.decode(Int.self, forKey: .nextPageNumber) {
            nextPage = next
        } else if let next = try? container.decode(Int.self, forKey: .next) {
            nextPage = next
        } else {
            nextPage = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(products, forKey: .products)
        try container.encodeIfPresent(nextPage, forKey: .nextPage)
    }
    
    // Custom initializer for creating ProductResponse manually
    init(products: [Product], nextPage: Int?) {
        self.products = products
        self.nextPage = nextPage
    }
}
