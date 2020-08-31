//
//  NewsCell.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/25/20.
//

import UIKit
import SDWebImage

class  NewsCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 8
        
        backgroundColor = .opaqueSeparator
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)

        titleLabel.translatesAutoresizingMaskIntoConstraints  = false

        titleLabel.adjustsFontSizeToFitWidth = false
        
        titleLabel.numberOfLines = 0
        
        titleLabel.lineBreakMode = .byWordWrapping
        
        [titleLabel].forEach({addSubview($0)})
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

