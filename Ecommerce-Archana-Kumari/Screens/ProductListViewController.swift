//
//  ProductListViewController.swift
//  Ecommerce-Archana-Kumari
//
//  Created by Archana Kumari on 27/12/25.
//

import UIKit

class ProductListViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let loadingView = LoadingView()
    private let errorView = ErrorView()
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No products available"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    private let footerLoadingView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    // MARK: - Properties
    private let viewModel: ProductListViewModel
    
    // MARK: - Initialization
    init(viewModel: ProductListViewModel = ProductListViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
        viewModel.fetchInitialProducts()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Products"
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(loadingView)
        view.addSubview(errorView)
        view.addSubview(emptyStateView)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        setupTableView()
        setupErrorView()
        
        hideAllOverlays()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ProductTableViewCell.self, forCellReuseIdentifier: ProductTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 130
    }
    
    private func setupErrorView() {
        errorView.onRetry = { [weak self] in
            self?.viewModel.retryFetch()
        }
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    // MARK: - Helper Methods
    private func hideAllOverlays() {
        loadingView.stopAnimating()
        errorView.isHidden = true
        emptyStateView.isHidden = true
        tableView.isHidden = false
    }
    
    private func showLoading() {
        loadingView.startAnimating()
        errorView.isHidden = true
        emptyStateView.isHidden = true
        tableView.isHidden = false
    }
    
    private func showError(_ error: NetworkError) {
        loadingView.stopAnimating()
        errorView.configure(with: error)
        errorView.isHidden = false
        emptyStateView.isHidden = true
        tableView.isHidden = viewModel.productCount == 0
    }
    
    private func showEmptyState() {
        loadingView.stopAnimating()
        errorView.isHidden = true
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }
    
    private func showContent() {
        loadingView.stopAnimating()
        errorView.isHidden = true
        emptyStateView.isHidden = true
        tableView.isHidden = false
    }
}

// MARK: - UITableViewDataSource
extension ProductListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.productCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTableViewCell.identifier, for: indexPath) as! ProductTableViewCell
        
        if let product = viewModel.product(at: indexPath.row) {
            cell.configure(with: product)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ProductListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let product = viewModel.product(at: indexPath.row) else { return }
        
        let detailViewController = ProductDetailViewController(product: product)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        // Load more when user scrolls to 80% of the content
        if offsetY > contentHeight - height * 2.0 && contentHeight > 0 {
            viewModel.fetchNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Show loading footer when displaying the last cell
        if indexPath.row == viewModel.productCount - 1 {
            tableView.tableFooterView = footerLoadingView
            // Trigger pagination when last cell is about to be displayed
            viewModel.fetchNextPage()
        } else {
            tableView.tableFooterView = nil
        }
    }
}

// MARK: - ProductListViewModelDelegate
extension ProductListViewController: ProductListViewModelDelegate {
    func didUpdateProducts() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let previousCount = self.tableView.numberOfRows(inSection: 0)
            let newCount = self.viewModel.productCount
            
            // If we have products, show content first
            if newCount > 0 {
                self.showContent()
                
                // Use insertRows for pagination (smoother), reloadData for initial load
                if previousCount > 0 && newCount > previousCount {
                    // Pagination: insert new rows
                    let indexPaths = (previousCount..<newCount).map { IndexPath(row: $0, section: 0) }
                    
                    // Use beginUpdates/endUpdates for batch updates
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                    self.tableView.endUpdates()
                } else if previousCount == 0 {
                    // Initial load: reload all
                    self.tableView.reloadData()
                } else {
                    // Same count or less (shouldn't happen, but handle it)
                    self.tableView.reloadData()
                }
            } else {
                // Only show empty state if we're not showing an error
                if self.errorView.isHidden {
                    self.showEmptyState()
                }
            }
        }
    }
    
    func didStartLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.viewModel.productCount == 0 {
                self.showLoading()
            }
        }
    }
    
    func didStopLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.loadingView.stopAnimating()
            self?.tableView.tableFooterView = nil
        }
    }
    
    func didEncounterError(_ error: NetworkError) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showError(error)
        }
    }
    
    func didUpdateEmptyState(_ isEmpty: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Only show empty state if there's no error and no products
            if isEmpty && self.errorView.isHidden {
                self.showEmptyState()
            } else if !isEmpty {
                self.showContent()
            }
        }
    }
}
