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
        case nextPage
    }
}
