//
//  FeaturedNewsController.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/28/20.
//

import UIKit
import Combine

class FeaturedNewsController: UICollectionViewController {
    
    enum Section: Int, CaseIterable, CustomStringConvertible {
        
        case Business
        case General
        case Technology
        case Science
        
        var description: String {
            switch  self {
            case .Business:
                return "Business"
            case .General:
                return "General"
            case .Technology:
                return "Technology"
            case .Science:
                return "Science"
                
            }
        }
        
        var itemHeight: CGFloat {
            switch self {
            case .Business:
                return 1.0
            default:
                return 1/3
            }
        }
        
        var itemWidth: CGFloat {
            return 1.0
        }
        
        var groupHeight: CGFloat {
            return 300
        }
        
        var groupWidth: CGFloat {
            return 0.9
        }
        
        var contentInsets: CGFloat {
            return 7
        }
        
        var badgeWidth: CGFloat {
            return 0.95
        }
        
        var badgeHeight: CGFloat {
            return 0.5
        }
        
        
        func groupLayout(size: NSCollectionLayoutSize, items: [NSCollectionLayoutItem]) -> NSCollectionLayoutGroup {
            switch self {
            case .Business:
                return NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: items)
            default:
                return NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: items)
            }
        }
        
        var scrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior {
            return .groupPaging
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    
    var subscription: Set<AnyCancellable> = []
    
    var generalItem: Everything!
    var businessItem: Everything!
    var technologyItem: Everything!
    var scienceItem: Everything!
    
    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init() {
        
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            
            let collectionViewSection = Section(rawValue: sectionIndex)!
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(collectionViewSection.itemWidth), heightDimension: .fractionalHeight(collectionViewSection.itemHeight))
            
            let badgeAnchor = NSCollectionLayoutAnchor(edges: [.leading, .trailing], fractionalOffset: .init(x: 0.05, y: 105))
            
            let badgeSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(collectionViewSection.badgeWidth), heightDimension: .absolute(collectionViewSection.badgeHeight))
            
            let badge = NSCollectionLayoutSupplementaryItem(layoutSize: badgeSize, elementKind: "badge", containerAnchor: badgeAnchor)
            
            let items: NSCollectionLayoutItem!
            
            switch collectionViewSection {
            case .General, .Technology:
                items = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [badge])
            default:
                items = NSCollectionLayoutItem(layoutSize: itemSize)
            }
            
            items.contentInsets = NSDirectionalEdgeInsets(top: collectionViewSection.contentInsets, leading: collectionViewSection.contentInsets, bottom: collectionViewSection.contentInsets, trailing: collectionViewSection.contentInsets)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(collectionViewSection.groupWidth), heightDimension: .absolute(collectionViewSection.groupHeight))
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50))
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
            
            let group = collectionViewSection.groupLayout(size: groupSize, items: [items])
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.boundarySupplementaryItems = [header]
            
            section.orthogonalScrollingBehavior = collectionViewSection.scrollingBehavior
            
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
   

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.title  = "Curated News For You"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        configureCollectionView()
        
        configureActivityIndicator()
        
        prepareNetworkRequest()
    }
    
    fileprivate func configureCollectionView() {
        collectionView.register(BusinessCell.self, forCellWithReuseIdentifier: BusinessCell.reuseIdentifier)
        collectionView.register(FeaturedCell.self, forCellWithReuseIdentifier: FeaturedCell.reuseIdentifier)
        collectionView.register(CategoriesHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoriesHeader.reuseIdentifier)
        collectionView.register(BadgeView.self, forSupplementaryViewOfKind: "badge", withReuseIdentifier: BadgeView.reuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
    }
    
    
    fileprivate func configureActivityIndicator() {
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    fileprivate func prepareNetworkRequest() {
        
        // prepare publishers to send group request to network
        
        let businessPublisher = NetworkManager.shared.sendRequest(to: "top-headlines", model: Everything.self, queryItems: [
                                                             ApiConstants.CountryKeyword.description:ApiConstants.US.description, "category":"business"])
        let techPublisher =  NetworkManager.shared.sendRequest(to: "top-headlines", model: Everything.self, queryItems: ["country":"us", "category":"technology"])
        let generalPublisher = NetworkManager.shared.sendRequest(to: "top-headlines", model: Everything.self, queryItems: ["country":"us", "category":"general"])
        let sciencePublisher = NetworkManager.shared.sendRequest(to: "top-headlines", model: Everything.self, queryItems: ["country":"us", "category":"science"])
        
        
        // combine the publishers and send request
        
        Publishers.Zip4(businessPublisher, techPublisher, generalPublisher, sciencePublisher).receive(on: RunLoop.main).sink { (_) in
            //
        } receiveValue: { [unowned self](everything) in

            activityIndicator.stopAnimating()
            businessItem = everything.0
            technologyItem = everything.1
            generalItem = everything.2
            
            scienceItem = everything.3

            configureDataSource()
            
            scrollAutomatically()

        }.store(in: &subscription)
        
        
    }
    
    //MARK:- Data Source Config
    
    fileprivate func configureDataSource() {
        
        dataSource = .init(collectionView: collectionView, cellProvider: { (collectionView, indexPath, hashedObject) -> UICollectionViewCell? in
            
            let section = Section(rawValue: indexPath.section)!
            
            switch  section {
            case .Business:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BusinessCell.reuseIdentifier, for: indexPath) as? BusinessCell else {
                    preconditionFailure("Could not dequeue cell")
                }
                
                if let hashedObject = hashedObject as? Everything.Articles {
                    cell.field = hashedObject
                }
                
                return cell
            default:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedCell.reuseIdentifier, for: indexPath) as? FeaturedCell else {
                    preconditionFailure("Could not dequeue cell")
                }
                
                if let hashedObject = hashedObject as? Everything.Articles {
                    cell.field = hashedObject
                }
                
                return cell
            }
        })
        
        dataSource.supplementaryViewProvider = .some({ (collectionView, identifier, indexPath) ->  UICollectionReusableView? in
            
            if identifier == UICollectionView.elementKindSectionHeader {
                
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: identifier, withReuseIdentifier: CategoriesHeader.reuseIdentifier, for: indexPath) as? CategoriesHeader else {
                    return nil
                }
                
                header.label.text = Section(rawValue: indexPath.section)?.description
                
                header.seeAllClickHandler = .some({
                    
                })
                
                return header
                
            } else {
                
                let section = Section(rawValue: indexPath.section)!
                
                if section != .Business {
                    guard let supplementary = collectionView.dequeueReusableSupplementaryView(ofKind: identifier, withReuseIdentifier: BadgeView.reuseIdentifier, for: indexPath)
                            as? BadgeView else { preconditionFailure("Could not dequeue cell")}
                    
                    supplementary.backgroundColor = .red
                    
                    return supplementary
                }
            }
            
            
            return UICollectionReusableView()
        })
        
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        
        snapshot.appendSections(Section.allCases)
        
        // add items to sections
        
        snapshot.appendItems(businessItem.articles ?? [], toSection: .Business)
        snapshot.appendItems(generalItem.articles ?? [], toSection: .General)
        snapshot.appendItems(technologyItem.articles ?? [], toSection: .Technology)
        snapshot.appendItems(scienceItem.articles ?? [], toSection: .Science)
        
        dataSource.apply(snapshot)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) as? Everything.Articles else {return }
        navigationController?.pushViewController(WebViewController(webViewURL: item.url), animated: true)
        
    }
    
    var counter = 1
    
    func scrollAutomatically() {
        
        let start = Date()
        
        let timer = Timer.TimerPublisher(interval: 4.0, runLoop: .main, mode: .common).autoconnect()
        
        timer.map { (output) -> TimeInterval in
            return output.timeIntervalSince(start)
        }.map { (interval) -> Int in
            return Int(interval)
        }.sink { [unowned self] (time) in
            
            let indexPath = IndexPath(item: counter, section: 0)
            
            collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            
            if counter == self.businessItem.articles?.count {
                timer.upstream.connect().cancel()
            }
            
            counter += 1
            
        }.store(in: &subscription)
    }
}

class BadgeView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
