//
//  FeaturedCell.swift
//  NewsApp
//
//  Created by Ravi Bastola on 8/28/20.
//

import UIKit
import SDWebImage

class FeaturedCell: UICollectionViewCell {
    
    fileprivate lazy var thumbnailImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 7
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "bloomberg")
        return imageView
    }()
    
    lazy var newsContent:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        
        label.font = UIFont.systemFont(ofSize: 18)
        return label
        
    }()
    
    var field: Everything.Articles? {
        didSet {
            self.newsContent.text = field?.description ?? field?.content ?? "Content Unavailable"
            
            guard let url = URL(string: field?.urlToImage ?? "") else { return }
            thumbnailImage.sd_setImage(with: url, completed: nil)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stack = UIStackView(arrangedSubviews: [
            thumbnailImage, newsContent
       ])
        
        stack.spacing = 8
        
        stack.alignment = .fill
        
        addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 20, left: 20, bottom: 0, right: 20)
        
        thumbnailImage.widthAnchor.constraint(equalToConstant: 64).isActive = true
        thumbnailImage.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        NSLayoutConstraint.activate([
            //stack.heightAnchor.constraint(equalTo: heightAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
