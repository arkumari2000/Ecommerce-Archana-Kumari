//
//  ImageLoader.swift
//  Ecommerce-Archana-Kumari
//
//  Created by Archana Kumari on 27/12/25.
//

import UIKit

class ImageLoader {
    
    // MARK: - Singleton
    static let shared = ImageLoader()
    
    // MARK: - Properties
    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession
    private var runningTasks: [String: URLSessionDataTask] = [:]
    private let queue = DispatchQueue(label: "com.ecommerce.imageloader", attributes: .concurrent)
    
    // MARK: - Initialization
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
        
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }
    
    // MARK: - Public Methods

    func loadImage(from urlString: String?, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let urlString = urlString, !urlString.isEmpty else {
            completion(.failure(ImageLoaderError.invalidURL))
            return
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(ImageLoaderError.invalidURL))
            return
        }
        
        let cacheKey = NSString(string: urlString)
        
        if let cachedImage = cache.object(forKey: cacheKey) {
            DispatchQueue.main.async {
                completion(.success(cachedImage))
            }
            return
        }
        
        cancelTask(for: urlString)
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            self.queue.async(flags: .barrier) {
                self.runningTasks.removeValue(forKey: urlString)
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(ImageLoaderError.invalidResponse))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(ImageLoaderError.invalidResponse))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(ImageLoaderError.invalidImageData))
                }
                return
            }
            
            guard let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(.failure(ImageLoaderError.invalidImageData))
                }
                return
            }
            
            self.cache.setObject(image, forKey: cacheKey)
            
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }
        
        queue.async(flags: .barrier) {
            self.runningTasks[urlString] = task
        }
        task.resume()
    }
    
    func loadImage(from urlString: String?, into imageView: UIImageView) {
        imageView.image = nil
        
        loadImage(from: urlString) { result in
            switch result {
            case .success(let image):
                imageView.image = image
            case .failure:
                imageView.image = nil
            }
        }
    }
    
    func cancelLoad(for urlString: String?) {
        guard let urlString = urlString else { return }
        cancelTask(for: urlString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    // MARK: - Private Methods
    
    private func cancelTask(for urlString: String) {
        queue.async(flags: .barrier) {
            if let task = self.runningTasks[urlString] {
                task.cancel()
                self.runningTasks.removeValue(forKey: urlString)
            }
        }
    }
}

// MARK: - ImageLoader Errors
enum ImageLoaderError: LocalizedError {
    case invalidURL
    case invalidResponse
    case invalidImageData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid image URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidImageData:
            return "Failed to create image from data"
        }
    }
}
