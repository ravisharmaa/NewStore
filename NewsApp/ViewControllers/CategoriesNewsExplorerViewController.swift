//
//  CategoriesNewsExplorerViewController.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/31/20.
//

import UIKit
import Combine

class CategoriesNewsExplorerViewController: UITableViewController {
    
    
    fileprivate enum Section {
        case main
    }
    
    let item: Response.Source
    
    init(item: Response.Source) {
        self.item = item
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    fileprivate lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Search News, For ex: Apple"
        
        return controller
    }()
    
    fileprivate var subscription: Set<AnyCancellable> = []
    
    fileprivate var dataSource: UITableViewDiffableDataSource<Section, Everything.Articles>!
    
    fileprivate var items: [Everything.Articles]  = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        if let category = item.category {
            
            let categoryName = category.prefix(1).uppercased() + category.dropFirst()
            
            navigationItem.title = "\(categoryName) News From \(item.name ?? "")"
        }
        
        navigationItem.searchController = searchController
        
        tableView.register(BrowserCell.self, forCellReuseIdentifier: BrowserCell.reuseIdentifier)
        
        
        
        configureDataSource()
        
        NetworkManager.shared.sendRequest(to: "top-headlines", model: Everything.self, queryItems: ["sources": item.id!])
            .receive(on: RunLoop.main)
            .catch { (error) -> AnyPublisher<Everything, Never> in
                return Just(Everything.placeholder).eraseToAnyPublisher()
            }.sink { (_) in
                //
            } receiveValue: { [unowned self](response) in
                self.items = response.articles ?? []
                
                self.updateDataSource()
                
            
            }.store(in: &subscription)
        
        configureSearch()
        
        tableView.tableFooterView = UIView()
        
    }
    
    fileprivate func configureDataSource() {
        
        dataSource = .init(tableView: tableView, cellProvider: { (tableView, indexPath, articles) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BrowserCell.reuseIdentifier) as? BrowserCell else {
                return nil
            }
            
            cell.newsContent.text = articles.content
            cell.newsTitle.text = articles.title
            cell.downloadImage(from: articles.urlToImage ?? "")
            
            return cell
        })
        
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Everything.Articles>()
        
        snapshot.appendSections([.main])
        
        snapshot.appendItems([])
        
        dataSource.apply(snapshot)
        
    }
    
    fileprivate func updateDataSource() {
        var snapshot = dataSource.snapshot()
        
        snapshot.deleteAllItems()
        
        snapshot.appendSections([.main])
        
        snapshot.appendItems(items)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    fileprivate func configureSearch() {
        
        let searchPublisher = NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: searchController.searchBar.searchTextField)
        
        searchPublisher.map { (notification) -> String in
            
            if let textField = notification.object as? UISearchTextField, let typed = textField.text {
                return typed.lowercased()
            }
            
            return String()
            
        }.debounce(for: .milliseconds(500), scheduler: RunLoop.main)
        
        .sink { [unowned self] (searchQuery) in
            
            if searchQuery.isEmpty {
                return
            }
           
            self.items = self.items.filter({ (article) -> Bool in
                guard let title = article.title else { return  false }
                
                return title.contains(searchQuery)
            })
           
            
            updateDataSource()
           
        }.store(in: &subscription)
    }
    
    
}

