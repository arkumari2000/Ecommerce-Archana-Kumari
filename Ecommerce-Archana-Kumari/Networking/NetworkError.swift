//
//  NetworkError.swift
//  Ecommerce-Archana-Kumari
//
//  Created by Archana Kumari on 27/12/25.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noInternetConnection
    case invalidResponse
    case decodingError(Error)
    case serverError(Int)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noInternetConnection:
            return "No internet connection. Please check your network settings."
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
