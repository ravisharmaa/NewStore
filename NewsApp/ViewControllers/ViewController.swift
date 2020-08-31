//
//  ViewController.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/24/20.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    
    //MARK:- Collection View Section
    enum Section: Int, CaseIterable, CustomStringConvertible {
        case Business
        case Entertainment
        case General
        case Health
        case Science
        case Sports
        case Technology
        
        
        var description: String {
            switch self {
            case .Business:
                return "Business"
            case .Entertainment:
                return "Entertainment"
            case .General:
                return "General"
            case .Health:
                return "Health"
            case .Science:
                return "Science"
            case .Sports:
                return "Sports"
            case .Technology:
                return "Technology"
                
            }
        }
        
        var name: String {
            switch self {
            case .Business:
                return "business"
            case .Entertainment:
                return "entertainment"
            case .General:
                return "general"
            case .Health:
                return "health"
            case .Science:
                return "science"
            case .Sports:
                return "sports"
            case .Technology:
                return "technology"
            }
        }
    }
    
    //MARK:- Subscription
    var subscription: Set<AnyCancellable> = []
    
    //MARK:- Datasource
    var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    
    var groupedSource: [String: [Response.Source]] = [:]
    
    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    fileprivate lazy var newsSourcesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight ]
        collectionView.register(NewsCell.self, forCellWithReuseIdentifier: CellReuseIdentifiers.NewsCell.description)
        collectionView.register(CategoriesHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
       
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        return collectionView
    }()
    
    
    //MARK:- Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureCollectionView()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "News Categories"
        
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
        
        NetworkManager
            .shared
            .sendRequest(to: "sources", model: Response.self, queryItems: nil)
            .receive(on: RunLoop.main).catch { (error) -> AnyPublisher<Response, Never> in
                return Just(Response.placeholder).eraseToAnyPublisher()
            }.sink { (_) in
                //
            } receiveValue: { [unowned self](response) in
                
                guard let sources = response.sources else {
                    return
                }
                
                self.groupedSource = Dictionary(grouping: sources) { $0.category! }
                
                self.configureDataSource()
                
                self.configureSnapshot()
                
                activityIndicator.stopAnimating()
                
            }.store(in: &subscription)
    }
    
    //MARK:- View Configuration
    
    func configureCollectionView() {
        
        newsSourcesCollectionView.backgroundColor = .systemBackground
        
        view.addSubview(newsSourcesCollectionView)
        
        NSLayoutConstraint.activate([
            newsSourcesCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            newsSourcesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsSourcesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsSourcesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    //MARK:- Layout
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(125))
            
            let items = NSCollectionLayoutItem(layoutSize: itemSize)
            
            items.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3.1), heightDimension: .absolute(125))
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .topLeading)
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [items])
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.boundarySupplementaryItems = [header]
                    
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            
            
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        config.interSectionSpacing = 10
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        return layout
    }
    
    //MARK:- Datasource
    
    func configureDataSource() {
        dataSource = .init(collectionView: newsSourcesCollectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellReuseIdentifiers.NewsCell.description, for: indexPath) as? NewsCell else {
                fatalError()
            }
            
            if let item = item as? Response.Source {
                cell.titleLabel.text = item.name
            }
        
            return cell
            
            
        })
        
        dataSource.supplementaryViewProvider = .some({ (collectionView, identifier, indexPath) -> UICollectionReusableView? in
           
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as? CategoriesHeader else {
                fatalError()
            }
            header.label.text = Section(rawValue: indexPath.section)?.description
            
            return header
        })
    }
    
    //MARK:- Snapshot
    
    func configureSnapshot() {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        
        Section.allCases.forEach { (section) in
            
            snapshot.appendSections([section])
            
            switch section {
            
            case .Business:
                snapshot.appendItems(groupedSource[section.name] ?? [], toSection: .Business)
            case .Entertainment:
                snapshot.appendItems(groupedSource[section.name] ?? [] ,toSection: .Entertainment)
            case .General:
                snapshot.appendItems(groupedSource[section.name] ?? [], toSection: .General)
            case .Health:
                snapshot.appendItems(groupedSource[section.name] ?? [], toSection: .Health)
            case .Science:
                snapshot.appendItems(groupedSource[section.name] ?? [], toSection: .Science)
            case .Sports:
                snapshot.appendItems(groupedSource[section.name] ?? [], toSection: .Sports)
            case .Technology:
                snapshot.appendItems(groupedSource[section.name] ?? [], toSection: .Technology)

            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard  let item = dataSource.itemIdentifier(for: indexPath) as? Response.Source else {
            return
        }
        
        navigationController?.pushViewController(CategoriesNewsExplorerViewController(item: item), animated: true)
    }
}
