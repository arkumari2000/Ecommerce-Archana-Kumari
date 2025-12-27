//
//  ProductListViewModel.swift
//  Ecommerce-Archana-Kumari
//
//  Created by Archana Kumari on 27/12/25.
//

import Foundation

// MARK: - ViewModel Delegate Protocol
protocol ProductListViewModelDelegate: AnyObject {
    func didUpdateProducts()
    func didStartLoading()
    func didStopLoading()
    func didEncounterError(_ error: NetworkError)
    func didUpdateEmptyState(_ isEmpty: Bool)
}

// MARK: - ViewModel
class ProductListViewModel {
    
    // MARK: - Properties
    weak var delegate: ProductListViewModelDelegate?
    
    private let networkingService: NetworkingServiceProtocol
    private(set) var products: [Product] = []
    private var currentPage: Int = 0
    private var nextPage: Int?
    private var isLoading: Bool = false
    private var hasMorePages: Bool = true
    
    // MARK: - Computed Properties
    var isEmpty: Bool {
        return products.isEmpty && !isLoading
    }
    
    var productCount: Int {
        return products.count
    }
    
    // MARK: - Initialization
    init(networkingService: NetworkingServiceProtocol = NetworkingService.shared) {
        self.networkingService = networkingService
    }
    
    // MARK: - Public Methods
    
    func fetchInitialProducts() {
        guard !isLoading else { return }
        
        currentPage = 0
        nextPage = nil
        products.removeAll()
        hasMorePages = true
        
        fetchProducts(page: currentPage)
    }
    
    func fetchNextPage() {
        guard !isLoading && hasMorePages else { return }
        
        // Use nextPage from API response, or increment current page
        let pageToFetch = nextPage ?? (currentPage + 1)
        fetchProducts(page: pageToFetch)
    }
    
    func retryFetch() {
        if products.isEmpty {
            fetchInitialProducts()
        } else {
            fetchNextPage()
        }
    }
    
    func product(at index: Int) -> Product? {
        guard index >= 0 && index < products.count else { return nil }
        return products[index]
    }
    
    // MARK: - Private Methods
    
    private func fetchProducts(page: Int) {
        guard !isLoading else { return }
        
        isLoading = true
        delegate?.didStartLoading()
        
        networkingService.fetchProducts(page: page, limit: 10, category: "electronics") { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.delegate?.didStopLoading()
                
                switch result {
                case .success(let productResponse):
                    self.handleSuccess(productResponse: productResponse, page: page)
                    
                case .failure(let error):
                    self.handleError(error)
                }
            }
        }
    }
    
    private func handleSuccess(productResponse: ProductResponse, page: Int) {
        currentPage = page
        
        if let nextPageValue = productResponse.nextPage {
            nextPage = nextPageValue
            hasMorePages = true
        } else {
            hasMorePages = false
        }
        
        products.append(contentsOf: productResponse.products)
        
        delegate?.didUpdateProducts()
        delegate?.didUpdateEmptyState(isEmpty)
    }
    
    private func handleError(_ error: NetworkError) {
        delegate?.didEncounterError(error)
        delegate?.didUpdateEmptyState(isEmpty)
    }
}
