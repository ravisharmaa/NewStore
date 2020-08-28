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
    }
    
    //MARK:- Subscription
    var subscription: Set<AnyCancellable> = Set<AnyCancellable>()
    
    //MARK:- Datasource
    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    
    var businessItems: [Item] = [Item]()
    
    var entertainmentItems:[Item] =  [Item]()
    
    var generalItem: [Item] = [Item]()
    
    var scienceItem: [Item] = [Item]()
    
    var sportsItem: [Item] = [Item]()
    
    var technologyItem: [Item] = [Item]()
    
    var healthItem: [Item] = [Item]()
    
    
    fileprivate lazy var newsSourcesCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight ]
        collectionView.register(NewsCell.self, forCellWithReuseIdentifier: CellReuseIdentifiers.NewsCell.description)
        collectionView.register(CategoriesHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
       
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        //collectionView.allowsSelection = true
        return collectionView
    }()
    
    
    //MARK:- Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureCollectionView()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "News Categories"
        
        NetworkManager
            .shared
            .sendRequest(to: "sources", model: Response.self, queryItems: nil)
            .receive(on: RunLoop.main).catch { (error) -> AnyPublisher<Response, Never> in
                return Just(Response.placeholder).eraseToAnyPublisher()
            }.sink { (_) in
                //
            } receiveValue: { [unowned self ](response) in
                
                guard let sources = response.sources else {
                    return
                }
                
                // since this is not a great method to filter the array might look into this
                #warning("Please Refactor This")
                
             
                
                sources.forEach { (source) in
                   
                    if source.category == "business" {
                        businessItems.append(Item(id: source.id ?? "", name: source.name ?? "", category: source.category ?? ""))
                    }
                    
                    if source.category == "entertainment" {
                        entertainmentItems.append(Item(id: source.id ?? "", name: source.name ?? "", category: source.category ?? ""))
                    }
                    
                    if source.category == "health" {
                        healthItem.append(Item(id: source.id ?? "", name: source.name ?? "", category: source.category ?? ""))
                    }
                    
                    if source.category == "sports" {
                        sportsItem.append(Item(id: source.id ?? "", name: source.name ?? "", category: source.category ?? ""))
                    }
                    
                    if source.category == "science" {
                        scienceItem.append(Item(id: source.id ?? "", name: source.name ?? "", category: source.category ?? ""))
                    }
                    
                    if source.category == "technology" {
                        technologyItem.append(Item(id: source.id ?? "", name: source.name ?? "", category: source.category ?? ""))
                    }
                    
                    if source.category == "general" {
                        generalItem.append(Item(id: source.id ?? "", name: source.name ?? "", category: source.category ?? ""))
                    }
                }
                
                self.configureDataSource()
                
                self.configureSnapshot()
                
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
            
            cell.newsTitle = item.name
            
            
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
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        Section.allCases.forEach { (section) in
            
            snapshot.appendSections([section])
            
            switch section {
            
            
            case .Business:
                snapshot.appendItems(businessItems, toSection: .Business)
            case .Entertainment:
                snapshot.appendItems(entertainmentItems,toSection: .Entertainment)
            case .General:
                snapshot.appendItems(generalItem, toSection: .General)
            case .Health:
                snapshot.appendItems(healthItem, toSection: .Health)
            case .Science:
                snapshot.appendItems(scienceItem, toSection: .Science)
            case .Sports:
                snapshot.appendItems(sportsItem, toSection: .Sports)
            case .Technology:
                snapshot.appendItems(technologyItem, toSection: .Technology)

            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    
        guard  let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        print(item)
    }
}
