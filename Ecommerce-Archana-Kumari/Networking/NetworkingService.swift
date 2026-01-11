//
//  NetworkingService.swift
//  Ecommerce-Archana-Kumari
//
//  Created by Archana Kumari on 27/12/25.
//

import Foundation

class NetworkingService: NetworkingServiceProtocol {

    static let shared = NetworkingService()
    
    private let baseURL = "https://fakeapi.net/products"
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchProducts(page: Int,
                       limit: Int = 10,
                       category: String = "electronics",
                       completion: @escaping (Result<ProductResponse, NetworkError>) -> Void) {
        guard var urlComponents = URLComponents(string: baseURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "category", value: category)
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) { data, response, error in
            
            // Network Error Handling
            if let error = error {
                let nsError = error as NSError
                if nsError.code == NSURLErrorNotConnectedToInternet ||
                    nsError.code == NSURLErrorNetworkConnectionLost ||
                    nsError.code == NSURLErrorTimedOut {
                    completion(.failure(.noInternetConnection))
                } else {
                    completion(.failure(.unknown(error)))
                }
                return
            }
            
            // Valid Response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            let decoder = JSONDecoder()

            if let productResponse = try? decoder.decode(ProductResponse.self, from: data) {
                print("✅ Decoded as ProductResponse: \(productResponse.products.count) products, nextPage: \(productResponse.nextPage ?? -1)")
                completion(.success(productResponse))
                return
            }
        }
        task.resume()
    }
}
