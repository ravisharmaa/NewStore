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
        
        var description: String {
            switch  self {
            case .Business:
                return "Business"
            case .General:
                return "General"
            case .Technology:
                return "Technology"
                
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
            switch self {
            default:
                return 1.0
            }
        }
        
        var groupHeight: CGFloat {
            switch self {
            default:
                return 300
            }
        }
        
        var groupWidth: CGFloat {
            switch self {
            case .Business:
                return 0.95
            default:
                return 0.9
            }
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
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    
    var subscription: Set<AnyCancellable> = Set<AnyCancellable>()
    
    var generalItem: Everything!
    var businessItem: Everything!
    var technologyItem: Everything!
    
    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init() {
        
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            
            let collectionViewSection = Section(rawValue: sectionIndex)!
            
            let group: NSCollectionLayoutGroup!
            
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
            
            
            switch collectionViewSection {
            
            case .Business:
                group =  NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [items])
            default:
                group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [items])
            }
            
            
            let section = NSCollectionLayoutSection(group: group)
            
            section.boundarySupplementaryItems = [header]
            
            switch collectionViewSection {
            case .Business:
                section.orthogonalScrollingBehavior = .groupPagingCentered
            default:
                section.orthogonalScrollingBehavior = .groupPaging
            }
            
            
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
        collectionView.register(BusinessCell.self, forCellWithReuseIdentifier: "reuseMe")
        collectionView.register(FeaturedCell.self, forCellWithReuseIdentifier: "reuseMeWe")
        collectionView.register(CategoriesHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.register(BadgeView.self, forSupplementaryViewOfKind: "badge", withReuseIdentifier: "badgeView")
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        
        navigationItem.title  = "Curated News For You"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
        
        
        let businessPublisher = NetworkManager.shared.sendRequest(to: "top-headlines", model: Everything.self, queryItems: [
                                                                    ApiConstants.CountryKeyword.description:ApiConstants.US.description, "category":"business"])
        let techPublisher = NetworkManager.shared.sendRequest(to: "top-headlines", model: Everything.self, queryItems: ["country":"us", "category":"technology"])
        let generalPublisher = NetworkManager.shared.sendRequest(to: "top-headlines", model: Everything.self, queryItems: ["country":"us", "category":"general"])
        
        
        
        Publishers.Zip3(businessPublisher, techPublisher, generalPublisher).receive(on: RunLoop.main).sink { (_) in
            //
        } receiveValue: { [unowned self](everything) in
            self.activityIndicator.stopAnimating()
            self.businessItem = everything.0
            self.technologyItem = everything.1
            self.generalItem = everything.2
            self.configureDataSource()
            
        }.store(in: &subscription)
        
    }
    
    func configureDataSource() {
        
        dataSource = .init(collectionView: collectionView, cellProvider: { (collectionView, indexPath, hashedObject) -> UICollectionViewCell? in
            
            let section = Section(rawValue: indexPath.section)!
            
            switch  section {
            case .Business:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseMe", for: indexPath) as? BusinessCell else {
                    return nil
                }
                
                if let hashedObject = hashedObject as? Everything.Articles {
                    cell.field = hashedObject
                }
                
                return cell
            default:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseMeWe", for: indexPath) as? FeaturedCell else {
                    fatalError()
                }
                
                if let hashedObject = hashedObject as? Everything.Articles {
                    cell.field = hashedObject
                }
                
                
                return cell
            }
        })
        
        dataSource.supplementaryViewProvider = .some({ (collectionView, identifier, indexPath) -> UICollectionReusableView? in
            
            if identifier == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: identifier, withReuseIdentifier: "header", for: indexPath) as? CategoriesHeader else {
                    return nil
                }
                
                header.label.text = Section(rawValue: indexPath.section)?.description
                
                header.seeAllClickHandler = {
                   
                }
                
                return header
            } else {
                
                let section = Section(rawValue: indexPath.section)!
                
                if section != .Business {
                    guard let supplementary = collectionView.dequeueReusableSupplementaryView(ofKind: identifier, withReuseIdentifier: "badgeView", for: indexPath)
                            as? BadgeView else { fatalError()}
                    
                    supplementary.backgroundColor = .lightGray
                    
                    return supplementary
                }
            }
            
            
            return UICollectionReusableView()
        })
        
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        
        snapshot.appendSections(Section.allCases)
        
        snapshot.appendItems(businessItem.articles!, toSection: .Business)
        snapshot.appendItems(generalItem.articles!, toSection: .General)
        snapshot.appendItems(technologyItem.articles!, toSection: .Technology)
        
        dataSource.apply(snapshot)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) as? Everything.Articles else {return }
        navigationController?.pushViewController(WebViewController(webViewURL: item.url), animated: true)
        
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
