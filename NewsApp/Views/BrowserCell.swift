//
//  BrowserCell.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/26/20.
//

import UIKit
import Combine

class BrowserCell: UITableViewCell {
    
    fileprivate lazy var thumbnailImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        return imageView
    }()
    
    lazy var newsContent:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 16.5)
        return label
        
    }()
    
    lazy var newsTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .darkGray
        label.numberOfLines = 0
        
        return label
    }()
    
    var subscription: AnyCancellable!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let newsContentStack = UIStackView(arrangedSubviews: [
            newsTitle, newsContent
        ])
        
        newsContentStack.spacing = 8
        
        newsContentStack.axis = .vertical
        
        let stack = UIStackView(arrangedSubviews: [
            thumbnailImage, newsContentStack
        ])
        
        stack.axis = .horizontal
        
        stack.alignment = .top
        
        stack.spacing = 10
        
        addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func downloadImage(from urlString: String) {
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        subscription = URLSession.shared.dataTaskPublisher(for: url)
            .map({UIImage(data: $0.data)})
            .receive(on: RunLoop.main)
            .replaceError(with: UIImage(named: "bloomberg"))
            .assign(to: \.image, on: thumbnailImage)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subscription.cancel()
    }
}
