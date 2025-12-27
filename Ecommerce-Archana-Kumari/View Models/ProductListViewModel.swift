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
        guard !isLoading else {
            return
        }
        
        guard hasMorePages else {
            return
        }
        
        // Use nextPage from API response, or increment current page
        let pageToFetch = nextPage ?? (currentPage + 1)
        print("📄 ViewModel: Fetching next page: \(pageToFetch) (currentPage: \(currentPage), nextPage from API: \(nextPage?.description ?? "nil"))")
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
        print("✅ ViewModel: Received \(productResponse.products.count) products, nextPage: \(productResponse.nextPage?.description ?? "nil")")
        
        currentPage = page
        
        // Determine if there are more pages
        if let nextPageValue = productResponse.nextPage {
            // API explicitly provided nextPage
            if nextPageValue > page {
                nextPage = nextPageValue
                hasMorePages = true
            } else {
                // nextPage is same or less than current, no more pages
                hasMorePages = false
                nextPage = nil
            }
        } else {
            // API didn't provide nextPage - use heuristics
            if productResponse.products.isEmpty {
                // Got 0 products, assume we've reached the end
                hasMorePages = false
                nextPage = nil
            } else if productResponse.products.count < 10 {
                // Got fewer products than limit (10), likely last page
                hasMorePages = false
                nextPage = nil
            } else {
                // Got full page of products but no nextPage - assume there might be more
                hasMorePages = true
                nextPage = page + 1
                print("✅ ViewModel: Got \(productResponse.products.count) products (full page) but no nextPage, will try page \(nextPage ?? -1) next")
            }
        }
        
        products.append(contentsOf: productResponse.products)
        print("✅ ViewModel: Total products after append: \(products.count)")
        
        delegate?.didUpdateProducts()
        delegate?.didUpdateEmptyState(isEmpty)
    }
    
    private func handleError(_ error: NetworkError) {
        delegate?.didEncounterError(error)
        delegate?.didUpdateEmptyState(isEmpty)
    }
}
