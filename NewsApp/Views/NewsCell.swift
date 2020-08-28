//
//  NewsCell.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/25/20.
//

import UIKit
import Combine

class  NewsCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    
    @Published
    var newsTitle: String = String()
    
    var subscription: AnyCancellable!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 8
        
        backgroundColor = .opaqueSeparator
        
        addSubview(titleLabel)
        
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints  = false
        
        titleLabel.adjustsFontSizeToFitWidth = true
        
        titleLabel.numberOfLines = 0
        
        titleLabel.lineBreakMode = .byWordWrapping
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
        
        subscription = $newsTitle
            .map({$0.description})
            .assign(to: \.text, on: titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        subscription.cancel()
    }
}

