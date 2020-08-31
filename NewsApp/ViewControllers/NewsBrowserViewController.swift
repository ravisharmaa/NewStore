//
//  NewsBrowserViewController.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/25/20.
//

import UIKit
import Combine
import TimelaneCombine

class NewsBrowserViewController: UITableViewController {
    
    var subscription: Set<AnyCancellable> = []
    
    fileprivate lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Search News, For ex: Apple"
        
        return controller
    }()
    
    // MARK:- Section Definition
    
    enum Section {
        case main
    }
    
    var dataSource: UITableViewDiffableDataSource<Section, Everything.Articles>!
    
    var item: [Everything.Articles] = []
    
    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    //MARK:- LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.title = "Browse Recent News"
        
        navigationItem.searchController = searchController
        
        searchController.obscuresBackgroundDuringPresentation = false
        
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(BrowserCell.self, forCellReuseIdentifier: BrowserCell.reuseIdentifier)
        
        if tableView.visibleCells.isEmpty {
            let backGroundView = UIView(frame: tableView.bounds)
         
            
            tableView.backgroundView = backGroundView
            
            let label = UILabel()
            label.text = "Whoops! You need to \n \n search your desired news 👩‍💻"
            label.font = UIFont.boldSystemFont(ofSize: 18)
            label.numberOfLines = 0
            label.textAlignment = .center
            tableView.backgroundView?.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
        
            label.centerXAnchor.constraint(equalTo: backGroundView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: backGroundView.centerYAnchor).isActive = true
           
            
            
            tableView.tableFooterView  = UIView()
            
            view.addSubview(activityIndicator)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            
            
        } else {
            tableView.backgroundView = UIView()
        }
        
        configureDataSource()
        
        configureSearch()
    }
    
    // MARK:- Search Configuration
    
    fileprivate func configureSearch() {
        
        let searchPublisher = NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification, object: searchController.searchBar.searchTextField)
        
        searchPublisher.map { (notification) -> String in
            
            if let textField = notification.object as? UISearchTextField, let typed = textField.text {
                return typed.lowercased()
            }
            
            return String().lowercased()
            
        }.debounce(for: .milliseconds(500), scheduler: RunLoop.main)
        .lane("Search")
        .removeDuplicates()
        .sink {[unowned self] (string) in
            self.startSearching(with: string)
            
            string.isEmpty ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
            
        }.store(in: &subscription)
        
        
    }
    
    // MARK:- Begin Search
    
    fileprivate func startSearching(with query: String) {
        
        let networkPublisher = NetworkManager.shared.sendRequest(to: ApiConstants.EndPointForEverything.description,
                                                                 model: Everything.self,
                                                                 queryItems: [ApiConstants.QueryStringForKeyword.description : query])
        
        networkPublisher
            .receive(on: RunLoop.main).catch { (error) -> AnyPublisher<Everything, Never> in
                return Just(Everything.placeholder).eraseToAnyPublisher()
            }.sink { (_) in
                //
            } receiveValue: {[unowned self] (everything) in
                
                guard let articles = everything.articles else {
                    return
                }
                
                self.item = articles
                self.updateDataSource(with: self.item)
                
            }.store(in: &subscription)
    }
    
    // MARK:- DataSource
    
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
        
        snapshot.appendItems(item)
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
    }
    
    fileprivate func updateDataSource(with item: [Everything.Articles]) {
        var snapshot = dataSource.snapshot()
        
        snapshot.deleteAllItems()
        
        snapshot.appendSections([.main])
        
        snapshot.appendItems(item)
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
        tableView.backgroundView = UIView()
        activityIndicator.stopAnimating()
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        navigationController?.pushViewController(WebViewController(webViewURL: item.url), animated: true)
        
    }
}
